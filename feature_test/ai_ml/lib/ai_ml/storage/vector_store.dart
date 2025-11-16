import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import '../models/vector_store_models.dart';
import '../models/text_embedding.dart';
import '../errors/ai_ml_exceptions.dart';

/// Abstract interface for vector store
abstract class VectorStore {
  /// Adds a document to the store
  Future<void> addDocument(
    String id,
    String text, {
    Map<String, dynamic>? metadata,
  });

  /// Adds a document with pre-computed embedding
  Future<void> addDocumentWithEmbedding(
    String id,
    String text,
    TextEmbedding embedding, {
    Map<String, dynamic>? metadata,
  });

  /// Queries similar documents
  Future<List<ScoredDocument>> query(
    String queryText, {
    int topK = 10,
    double? minSimilarity,
    Map<String, dynamic>? metadataFilter,
  });

  /// Queries with pre-computed embedding
  Future<List<ScoredDocument>> queryWithEmbedding(
    TextEmbedding queryEmbedding, {
    int topK = 10,
    double? minSimilarity,
    Map<String, dynamic>? metadataFilter,
  });

  /// Gets a document by ID
  Future<VectorDocument?> getDocument(String id);

  /// Deletes a document by ID
  Future<void> deleteDocument(String id);

  /// Clears all documents
  Future<void> clear();

  /// Persists the store to disk
  Future<void> persist();

  /// Loads the store from disk
  Future<void> load();

  /// Gets the count of documents
  Future<int> count();

  /// Disposes resources
  Future<void> dispose();
}

/// SQLite-based vector store implementation
class SqliteVectorStore implements VectorStore {
  final String dbName;
  final TextEmbeddingGenerator? embeddingGenerator;
  Database? _database;

  static const String _tableName = 'vector_documents';

  SqliteVectorStore({
    required this.dbName,
    this.embeddingGenerator,
  });

  /// Initializes the database
  Future<void> initialize() async {
    if (_database != null) return;

    final dbPath = await getDatabasesPath();
    final fullPath = path.join(dbPath, '$dbName.db');

    _database = await openDatabase(
      fullPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id TEXT PRIMARY KEY,
            text TEXT NOT NULL,
            embedding TEXT NOT NULL,
            metadata TEXT,
            created_at INTEGER NOT NULL
          )
        ''');

        // Create index on created_at for faster queries
        await db.execute('''
          CREATE INDEX idx_created_at ON $_tableName (created_at)
        ''');
      },
    );
  }

  Database get _db {
    if (_database == null) {
      throw VectorStoreException('VectorStore not initialized. Call initialize() first.');
    }
    return _database!;
  }

  @override
  Future<void> addDocument(
    String id,
    String text, {
    Map<String, dynamic>? metadata,
  }) async {
    if (embeddingGenerator == null) {
      throw VectorStoreException(
        'Cannot add document without embedding. Either provide an embeddingGenerator or use addDocumentWithEmbedding.',
      );
    }

    final embedding = await embeddingGenerator!.generate(text);
    await addDocumentWithEmbedding(id, text, embedding, metadata: metadata);
  }

  @override
  Future<void> addDocumentWithEmbedding(
    String id,
    String text,
    TextEmbedding embedding, {
    Map<String, dynamic>? metadata,
  }) async {
    await _db.insert(
      _tableName,
      {
        'id': id,
        'text': text,
        'embedding': jsonEncode(embedding.vector),
        'metadata': metadata != null ? jsonEncode(metadata) : null,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<ScoredDocument>> query(
    String queryText, {
    int topK = 10,
    double? minSimilarity,
    Map<String, dynamic>? metadataFilter,
  }) async {
    if (embeddingGenerator == null) {
      throw VectorStoreException(
        'Cannot query without embedding. Either provide an embeddingGenerator or use queryWithEmbedding.',
      );
    }

    final queryEmbedding = await embeddingGenerator!.generate(queryText);
    return queryWithEmbedding(
      queryEmbedding,
      topK: topK,
      minSimilarity: minSimilarity,
      metadataFilter: metadataFilter,
    );
  }

  @override
  Future<List<ScoredDocument>> queryWithEmbedding(
    TextEmbedding queryEmbedding, {
    int topK = 10,
    double? minSimilarity,
    Map<String, dynamic>? metadataFilter,
  }) async {
    // Get all documents (for brute-force search)
    final query = await _db.query(_tableName);

    final scoredDocs = <ScoredDocument>[];

    for (final row in query) {
      // Apply metadata filter if provided
      if (metadataFilter != null) {
        final metadataJson = row['metadata'] as String?;
        if (metadataJson != null) {
          final metadata = jsonDecode(metadataJson) as Map<String, dynamic>;
          bool matches = true;
          for (final entry in metadataFilter.entries) {
            if (metadata[entry.key] != entry.value) {
              matches = false;
              break;
            }
          }
          if (!matches) continue;
        } else {
          continue; // No metadata, skip if filter is provided
        }
      }

      final embeddingVector = (jsonDecode(row['embedding'] as String) as List)
          .map((e) => (e as num).toDouble())
          .toList();

      final docEmbedding = TextEmbedding(vector: embeddingVector);
      final similarity = queryEmbedding.cosineSimilarity(docEmbedding);

      // Apply minimum similarity filter
      if (minSimilarity != null && similarity < minSimilarity) {
        continue;
      }

      final doc = VectorDocument(
        id: row['id'] as String,
        text: row['text'] as String,
        embedding: docEmbedding,
        metadata: row['metadata'] != null
            ? jsonDecode(row['metadata'] as String) as Map<String, dynamic>
            : null,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      );

      scoredDocs.add(ScoredDocument(document: doc, score: similarity));
    }

    // Sort by score (descending)
    scoredDocs.sort((a, b) => b.score.compareTo(a.score));

    // Return top K
    return scoredDocs.take(topK).toList();
  }

  @override
  Future<VectorDocument?> getDocument(String id) async {
    final result = await _db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;

    final row = result.first;
    final embeddingVector = (jsonDecode(row['embedding'] as String) as List)
        .map((e) => (e as num).toDouble())
        .toList();

    return VectorDocument(
      id: row['id'] as String,
      text: row['text'] as String,
      embedding: TextEmbedding(vector: embeddingVector),
      metadata: row['metadata'] != null
          ? jsonDecode(row['metadata'] as String) as Map<String, dynamic>
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
    );
  }

  @override
  Future<void> deleteDocument(String id) async {
    await _db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> clear() async {
    await _db.delete(_tableName);
  }

  @override
  Future<void> persist() async {
    // SQLite automatically persists, but we can flush WAL if needed
    // This is a no-op for now, but kept for interface compatibility
  }

  @override
  Future<void> load() async {
    // Ensure database is initialized
    await initialize();
  }

  @override
  Future<int> count() async {
    final result = await _db.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<void> dispose() async {
    await _database?.close();
    _database = null;
  }
}

/// Interface for generating text embeddings
abstract class TextEmbeddingGenerator {
  Future<TextEmbedding> generate(String text);
}
