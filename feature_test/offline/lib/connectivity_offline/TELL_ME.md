# TELL ME - How to Test Connectivity & Offline Support

This guide shows you what screens to create to test connectivity monitoring and offline functionality.

## Main File Setup

### Add Navigation Button in main.dart

```
Button: "Test Connectivity & Offline"
OnPressed: Navigate to ConnectivityTestScreen
```

## Screens to Create

### Screen 1: ConnectivityTestScreen (Main Menu)

**Purpose**: Test connectivity monitoring and offline features

**UI Elements**:
```
AppBar: "Connectivity Testing"

Section 1: Connection Status
  Icon: WiFi/Mobile/Disconnected icon (updates in real-time)
  Text: "Status: Connected via WiFi" (or Mobile/Offline)
  Text: "Connection Type: WiFi" (or Mobile/None)
  Container: Green (online) or Red (offline) indicator

Section 2: Connectivity History
  Text: "Connection changes (last 10):"
  ListView:
    - "Connected via WiFi - 2:30 PM"
    - "Disconnected - 2:28 PM"
    - "Connected via Mobile - 2:25 PM"

Section 3: Offline Mode Tests
  Buttons:
    "Test API Call" → Makes network request
    "View Cached Data" → Shows offline cached data
    "Queue Offline Request" → Adds to offline queue
    "View Request Queue" → Shows pending requests
    "Sync Now" → Manually trigger sync

Section 4: Cache Management
  Text: "Cache Statistics:"
  Text: "Cached items: 42"
  Text: "Cache size: 2.3 MB"
  Text: "Last sync: 5 minutes ago"

  Buttons:
    "Clear Cache"
    "View Cache Contents"

Bottom:
  Text: "Live connection monitoring active"
  Switch: "Auto-sync when online"
```

**What You Need to Do**:
- Open app
- See current connection status
- Watch status update when you toggle WiFi/mobile data

---

### Screen 2: LiveMonitoringScreen

**Purpose**: Watch real-time connectivity changes

**UI Elements**:
```
AppBar: "Live Connection Monitor"

Large animated icon (changes based on status):
  - WiFi icon when on WiFi
  - Mobile signal bars when on mobile
  - Offline icon when disconnected

Text: "You are: ONLINE" (or OFFLINE)
Text: "via WiFi" (or "via Mobile Data" or "Disconnected")

Timeline (shows connection changes):
  Entry: "Connected WiFi - 14:35:22"
  Entry: "Disconnected - 14:30:15"
  Entry: "Connected Mobile - 14:25:10"

Instructions:
  Text: "Try these:"
  - "Turn off WiFi → See offline status"
  - "Turn on mobile data → See mobile connection"
  - "Enable WiFi → See WiFi connection"
  - "Turn off all → See offline status"
```

**What You Need to Do**:
1. Keep this screen open
2. Turn off WiFi on your device
3. Watch status change to "Mobile" or "Offline"
4. Turn WiFi back on
5. Watch status change to "WiFi"

**What You Should See**:
- Status updates within 1-2 seconds of change
- Icon animates/changes
- New entry added to timeline
- Color indicator changes (green→yellow→red)

**Implementation**:
```
Listen to connectivity stream:
  ConnectivityService.instance.connectivityStream.listen((status) {
    // Update UI based on status
    if (status == ConnectivityStatus.wifi) {
      Show WiFi icon, green indicator
      Add timeline entry
    } else if (status == ConnectivityStatus.mobile) {
      Show mobile icon, yellow indicator
      Add timeline entry
    } else {
      Show offline icon, red indicator
      Add timeline entry
    }
  })
```

---

### Screen 3: OfflineAPITestScreen

**Purpose**: Test offline caching and request queueing

**UI Elements**:
```
AppBar: "Offline API Testing"

Section 1: Make Request
  TextField: "API URL" (pre-filled with test endpoint)
  Button: "Fetch Data"

  Text: "Response:"
  Container: Shows API response or cached data
  Text: "Source: Network" (or "Cache")
  Text: "Cached at: [timestamp]"

Section 2: Offline Queue
  Text: "Queued Requests: 3"

  List of pending requests:
    Card: "POST /api/create-user"
      Status: "Pending (offline)"
      Created: "2:30 PM"
      Button: "Remove"

    Card: "PUT /api/update-profile"
      Status: "Pending (offline)"
      Created: "2:28 PM"

  Button: "Process Queue" (enabled when online)

Section 3: Connection Simulation
  Text: "Test offline behavior:"
  Switch: "Simulate Offline Mode"
    (Forces offline behavior even when connected)
```

**What You Need to Do - Online**:
1. Tap "Fetch Data" (while online)
2. See response from network
3. Data cached automatically

**What You Need to Do - Offline**:
1. Turn off WiFi and mobile data
2. Tap "Fetch Data" again
3. See cached response
4. Text shows "Source: Cache"

**What You Need to Do - Queue Request**:
1. Stay offline
2. Tap "Queue Offline Request"
3. Request added to queue
4. Shows "Pending (offline)"
5. Turn on WiFi
6. Tap "Process Queue"
7. Requests sent to server
8. Queue cleared

**What You Should See**:
- Online: Fresh data from network
- Offline: Cached data (if available)
- Offline (no cache): Error message
- Queued requests auto-sync when connection restored

---

### Screen 4: CacheManagementScreen

**Purpose**: View and manage offline cache

**UI Elements**:
```
AppBar: "Cache Management"

Stats Card:
  Text: "Total cached items: 42"
  Text: "Cache size: 2.3 MB"
  Text: "Oldest entry: 3 days ago"
  Text: "Newest entry: 5 minutes ago"

Cache Strategy:
  Dropdown: "Cache Strategy"
    Options:
      - FIFO (First In First Out)
      - LRU (Least Recently Used)
      - LFU (Least Frequently Used)
      - TTL (Time To Live)

  If TTL selected:
    TextField: "TTL (hours)" (default: 24)

Cached Items List:
  ListView:
    Card: "User Profile Data"
      Size: 14 KB
      Cached: 10 minutes ago
      Accessed: 2 times
      Buttons: "View" | "Delete"

    Card: "Products List"
      Size: 156 KB
      Cached: 2 hours ago
      Accessed: 5 times
      Buttons: "View" | "Delete"

Bottom buttons:
  "Clear All Cache"
  "Export Cache" (for debugging)
```

**What You Need to Do**:
1. Make several API calls (creates cache entries)
2. Navigate to this screen
3. See all cached items
4. Tap "View" on an item → See cached data
5. Tap "Delete" → Item removed from cache
6. Select different cache strategy
7. Fill cache to limit → Old items auto-deleted per strategy

**Cache Strategy Testing**:
- **FIFO**: Add 10 items, add 11th → 1st item deleted
- **LRU**: Access item 5, add new → Least recently used (not 5) deleted
- **LFU**: Access item 3 many times, add new → Least frequently used deleted
- **TTL**: Set 1 hour, wait 1 hour → Expired items auto-deleted

---

### Screen 5: SyncStatusScreen

**Purpose**: Monitor sync operations

**UI Elements**:
```
AppBar: "Sync Status"

Status Card:
  Icon: Syncing animation (if syncing) or checkmark (if synced)
  Text: "Status: Synced" (or "Syncing..." or "Pending")
  Text: "Last sync: 5 minutes ago"
  Text: "Next sync: in 25 minutes"

Sync Queue:
  Text: "Pending operations: 3"

  Card: "Create Post"
    Type: POST
    Endpoint: /api/posts
    Data: {...}
    Retries: 0
    Status: "Waiting for connection"

  Card: "Update User"
    Type: PUT
    Endpoint: /api/user/123
    Data: {...}
    Retries: 2
    Status: "Failed - will retry"

Auto-Sync Settings:
  Switch: "Auto-sync when online"
  Slider: "Sync interval (minutes)"
    Min: 5, Max: 60, Current: 30

Manual Actions:
  Button: "Sync Now"
  Button: "Retry Failed"
  Button: "Clear Queue"
```

**What You Need to Do**:
1. Go offline
2. Make changes (create/update data)
3. Operations queued
4. Go online
5. Auto-sync starts
6. Watch queue clear

**What You Should See**:
- Operations added to queue when offline
- Sync starts automatically when online
- Failed operations retry with backoff
- Success → removed from queue
- Failed after max retries → shows error

---

### Screen 6: NetworkSimulatorScreen

**Purpose**: Simulate different network conditions

**UI Elements**:
```
AppBar: "Network Simulator"

Simulation Controls:
  Switch: "Simulate Slow Network"
  Slider: "Delay (ms)" - 100 to 5000
  Switch: "Simulate Offline"
  Switch: "Simulate Packet Loss"
  Slider: "Packet loss %" - 0 to 100

Test Section:
  Button: "Make Test Request"
  Progress: Shows loading with simulated delay
  Text: "Result: [Success/Failed/Timeout]"
  Text: "Time taken: 2.5s"

Preset Scenarios:
  Button: "Good Connection (WiFi)"
    → Fast, no loss
  Button: "Average 3G"
    → 500ms delay, 5% loss
  Button: "Poor 2G"
    → 2000ms delay, 20% loss
  Button: "Offline"
    → Disconnected
```

**What You Need to Do**:
1. Tap "Simulate Slow Network"
2. Set delay to 2000ms
3. Tap "Make Test Request"
4. See loading indicator for 2 seconds
5. Response delayed as configured

**Testing Different Conditions**:
- Good WiFi: Fast response
- 3G: Slight delay, occasional timeouts
- 2G: Very slow, frequent failures
- Offline: Immediate failure or cached response

---

## Testing Checklist

### Connectivity Monitoring
- [ ] App detects WiFi connection
- [ ] App detects mobile data connection
- [ ] App detects offline state
- [ ] Status updates in real-time (<2 seconds)
- [ ] Connection changes logged
- [ ] UI updates based on status

### Offline Caching
- [ ] API responses cached automatically
- [ ] Cached data served when offline
- [ ] Cache size limits enforced
- [ ] Old cache items deleted per strategy
- [ ] Can view cached items
- [ ] Can clear cache manually

### Request Queueing
- [ ] Offline requests queued
- [ ] Queue persists across app restarts
- [ ] Requests auto-sync when online
- [ ] Failed requests retry with backoff
- [ ] Can view queue
- [ ] Can remove queued items

### Sync Operations
- [ ] Auto-sync works when online
- [ ] Manual sync works
- [ ] Sync interval configurable
- [ ] Failed syncs retry
- [ ] Max retries enforced
- [ ] Sync status visible

### Cache Strategies
- [ ] FIFO: Oldest deleted first
- [ ] LRU: Least recently used deleted
- [ ] LFU: Least frequently used deleted
- [ ] TTL: Expired items deleted

---

## Quick Test Script

**5-Minute Connectivity Test**:
1. Open app → Connectivity Test
2. See "Connected via WiFi" ✓
3. Turn off WiFi
4. See "Connected via Mobile" (or "Offline") ✓
5. Turn off mobile data
6. See "Offline" ✓
7. Turn WiFi back on
8. See "Connected via WiFi" ✓

**Offline Cache Test**:
1. Tap "Test API Call" (while online)
2. See network response ✓
3. Turn off all connections
4. Tap "Test API Call" again
5. See cached response ✓
6. Source shows "Cache" ✓

**Request Queue Test**:
1. Go offline
2. Tap "Queue Offline Request" 3 times
3. See 3 queued requests ✓
4. Go online
5. Tap "Process Queue"
6. Queue clears ✓
7. Requests sent to server ✓

---

## What to Expect

### Success Signs:
- ✓ Status updates immediately when connectivity changes
- ✓ Green indicator when online, red when offline
- ✓ Cached data available offline
- ✓ Requests queue when offline
- ✓ Auto-sync when connection restored
- ✓ No crashes when offline

### Common Behaviors:
- WiFi preferred over mobile (if both available)
- Slight delay (1-2s) in detecting changes
- Queue processes in order (FIFO)
- Failed requests retry 3 times with backoff (2s, 4s, 8s)
- Cache limited to 50MB by default
- Old cache auto-deleted when limit reached

### Common Issues:
- **Status not updating**: Check permissions (Android: ACCESS_NETWORK_STATE)
- **Cache not working**: Check Hive initialization
- **Queue not processing**: Check auto-sync enabled
- **iOS offline detection**: May have delay due to iOS restrictions

---

## Advanced Testing

### Stress Test:
```
1. Queue 100 requests while offline
2. Go online
3. All should sync (may take time)
4. Check for memory issues
5. Verify no crashes
```

### Cache Eviction Test:
```
1. Fill cache to 90% capacity
2. Add more items
3. Old items auto-deleted
4. Cache stays under limit
5. FIFO/LRU strategy works correctly
```

### Edge Cases:
```
1. Connection flapping (on/off rapidly)
   → App handles gracefully, no crashes

2. Partial connectivity (connected but no internet)
   → Detects and shows appropriate status

3. App restart while syncing
   → Sync resumes after restart
   → No duplicate requests

4. Very large cache items
   → Handles or rejects if too large
```

---

## Monitoring

**Display in App**:
- Current connection status (WiFi/Mobile/Offline)
- Connection strength (if available)
- Cache size and item count
- Queue size and pending operations
- Last sync timestamp
- Failed requests count

**Metrics to Track**:
- Connection uptime %
- Average time to detect change
- Cache hit rate (cache used / total requests)
- Queue success rate
- Average sync time

---

That's it! Build these screens to see connectivity monitoring and offline functionality working end-to-end.
