library social_auth;

// Export main facade
export 'social_auth.dart';

// Export core types
export 'src/core/social_provider.dart';
export 'src/core/auth_result.dart';
export 'src/core/social_auth_error.dart';
export 'src/core/auth_service.dart';
export 'src/core/token_storage.dart';
export 'src/core/logger.dart';

// Export widgets
export 'src/widgets/social_sign_in_button.dart';
export 'src/widgets/social_sign_in_row.dart';

// Export service implementations (examples)
export 'src/services/firebase_auth_service.dart';
export 'src/services/rest_api_auth_service.dart';
