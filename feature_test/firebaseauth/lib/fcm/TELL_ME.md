# TELL ME - How to Test FCM Notifications

This guide shows you exactly what screens to create, what buttons to add, and how to test Firebase Cloud Messaging (push notifications).

## Main File Setup

### Add Navigation Button in main.dart

```
Button: "Test FCM Notifications"
OnPressed: Navigate to FCMTestScreen
```

## Screens to Create

### Screen 1: FCMTestScreen (Main Menu)

**Purpose**: Test all FCM notification features

**UI Elements**:
```
AppBar: "FCM Notifications Testing"

Section 1: Token Info
  Text: "FCM Token:"
  SelectableText: [full token] (can copy)
  Button: "Copy Token" (copies to clipboard)
  Button: "Refresh Token"

Section 2: Topic Subscription
  TextField: "Topic name" (hint: "news")
  Button: "Subscribe to Topic"
  Button: "Unsubscribe from Topic"
  Text: "Subscribed topics: [list]"

Section 3: Notification History
  Text: "Recent Notifications (last 10):"
  ListView: Shows received notifications with:
    - Title
    - Body
    - Received time
    - Data payload (if any)

Section 4: Test Actions
  Button: "Request Permission" (iOS only, shows permission dialog)
  Button: "Clear Notification History"
  Button: "Send Test from Console" (opens browser to Firebase Console)

Bottom:
  Text: "App State: [Foreground/Background/Terminated]"
  Text: "Last notification: [time]"
```

**What You Need to Do**:
1. Open app
2. See this screen
3. Copy FCM token
4. Use token to send test notifications

---

## How to Test Notifications

### Test 1: Foreground Notification

**Purpose**: Receive notification while app is open

**Steps**:
1. Keep app open on FCMTestScreen
2. Send test notification (see "How to Send" below)
3. Notification appears in notification history list
4. Local notification banner shows at top of screen

**What You Should See**:
- Notification appears in history list immediately
- Banner notification shows at top (if local notifications enabled)
- Title and body displayed correctly
- Data payload shown (if sent)
- Timestamp shows current time

**Implementation Notes**:
```
Set up foreground listener:
  FirebaseMessaging.onMessage.listen((message) {
    // Add to notification history list
    // Show local notification banner
    // Update UI
  })
```

---

### Test 2: Background Notification

**Purpose**: Receive notification while app is in background

**Steps**:
1. Open app, copy token
2. Press home button (app goes to background)
3. Send test notification
4. Tap notification in system tray
5. App opens and shows notification

**What You Should See**:
- Notification appears in system notification tray
- Tapping notification opens app
- FCMTestScreen shows notification in history
- Data payload received (if sent)

**Implementation Notes**:
```
Background messages handled by OS
Tapping notification triggers:
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    // App was in background, user tapped notification
    // Navigate to relevant screen based on data
  })
```

---

### Test 3: Terminated Notification

**Purpose**: Receive notification while app is completely closed

**Steps**:
1. Open app, copy token
2. Close app completely (swipe away from recent apps)
3. Send test notification
4. Tap notification in system tray
5. App launches and shows notification

**What You Should See**:
- Notification appears in system tray (app closed)
- Tapping notification launches app
- App opens directly to relevant screen (if deep linking configured)
- Notification data available on launch

**Implementation Notes**:
```
On app start, check for launch notification:
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      // App was launched by tapping notification
      // Navigate based on data payload
    }
  })
```

---

### Test 4: Topic Subscription

**Purpose**: Test subscribing to topics for group messaging

**Steps**:
1. In app, enter topic name: "news"
2. Tap "Subscribe to Topic"
3. See success message
4. Send notification to topic from Firebase Console
5. Receive notification

**What You Should See**:
- Success message: "Subscribed to topic: news"
- Topic added to subscribed topics list
- Notifications sent to "news" topic are received

**To Unsubscribe**:
1. Enter same topic: "news"
2. Tap "Unsubscribe from Topic"
3. See success message
4. Notifications to "news" topic no longer received

**Implementation Notes**:
```
Subscribe:
  await FirebaseMessaging.instance.subscribeToTopic('news')

Unsubscribe:
  await FirebaseMessaging.instance.unsubscribeFromTopic('news')
```

**Topic Naming Rules**:
- Lowercase letters, numbers, hyphens, underscores
- No spaces
- Examples: "news", "updates", "sports-scores"

---

### Test 5: Data Payload

**Purpose**: Test receiving custom data with notifications

**Steps**:
1. Send notification with data payload (see example below)
2. Receive notification
3. View data in notification history

**Example Data Payload**:
```
{
  "to": "[YOUR_FCM_TOKEN]",
  "notification": {
    "title": "New Order",
    "body": "Order #12345 has been placed"
  },
  "data": {
    "orderId": "12345",
    "screen": "orderDetails",
    "action": "view"
  }
}
```

**What You Should See**:
- Notification shows in history
- Data section shows:
  ```
  orderId: 12345
  screen: orderDetails
  action: view
  ```
- Can use data to navigate to specific screen

**Implementation Notes**:
```
Access data payload:
  final data = message.data
  final orderId = data['orderId']
  final screen = data['screen']

  // Navigate based on data
  if (screen == 'orderDetails') {
    Navigator.push(OrderDetailsScreen(orderId: orderId))
  }
```

---

### Test 6: iOS Permission Request

**Purpose**: Request notification permission on iOS

**Steps** (iOS only):
1. Fresh install app (or delete and reinstall)
2. Open app to FCMTestScreen
3. Tap "Request Permission" button
4. iOS permission dialog appears
5. Tap "Allow"

**What You Should See**:
- Permission dialog: "App wants to send you notifications"
- Options: "Don't Allow" / "Allow"
- After allowing: FCM token generated
- Notifications will now be received

**On Android**:
- Button disabled or hidden
- Permission granted by default (no dialog)

**Implementation Notes**:
```
Request permission (iOS):
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  )

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission')
  }
```

---

## How to Send Test Notifications

### Method 1: Firebase Console (Easiest)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to "Cloud Messaging" (in left menu under "Engage")
4. Click "Send your first message" (or "New notification")
5. Fill in:
   - **Notification title**: "Test Notification"
   - **Notification text**: "This is a test message"
6. Click "Next"
7. Select target:
   - Option A: "User segment" → "All users" (sends to everyone)
   - Option B: "Single device" → Paste your FCM token
   - Option C: "Topic" → Enter topic name (e.g., "news")
8. Click "Next"
9. Click "Review"
10. Click "Publish"

**What You Should See**:
- Notification appears on device (if foreground: in app, if background: in system tray)

---

### Method 2: cURL Command (For Testing)

Copy your FCM token from app, then run this in terminal:

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "YOUR_FCM_TOKEN",
    "notification": {
      "title": "Test from cURL",
      "body": "This is a test notification"
    },
    "data": {
      "key1": "value1",
      "key2": "value2"
    }
  }'
```

**Get Server Key**:
1. Firebase Console → Project Settings
2. Cloud Messaging tab
3. Copy "Server key"

**Replace**:
- `YOUR_SERVER_KEY`: Your Firebase server key
- `YOUR_FCM_TOKEN`: Token from app

---

### Method 3: Postman/API Client

**Endpoint**: `https://fcm.googleapis.com/fcm/send`

**Method**: POST

**Headers**:
```
Authorization: key=YOUR_SERVER_KEY
Content-Type: application/json
```

**Body** (JSON):
```json
{
  "to": "YOUR_FCM_TOKEN",
  "notification": {
    "title": "Test Notification",
    "body": "Testing from Postman"
  },
  "data": {
    "orderId": "12345",
    "userId": "user123"
  },
  "priority": "high"
}
```

**Send to Topic**:
Replace `"to": "token"` with:
```json
"to": "/topics/news"
```

---

### Method 4: Firebase Admin SDK (Node.js)

```javascript
const admin = require('firebase-admin');

admin.initializeApp({
  credential: admin.credential.applicationDefault()
});

const message = {
  notification: {
    title: 'Test from Admin SDK',
    body: 'This is a test message'
  },
  data: {
    key1: 'value1',
    key2: 'value2'
  },
  token: 'YOUR_FCM_TOKEN' // or topic: 'news'
};

admin.messaging().send(message)
  .then((response) => {
    console.log('Successfully sent:', response);
  })
  .catch((error) => {
    console.log('Error:', error);
  });
```

---

## Testing Checklist

### Basic Functionality
- [ ] App displays FCM token
- [ ] Can copy token to clipboard
- [ ] Token refresh works
- [ ] Notification appears in foreground
- [ ] Notification appears in background
- [ ] Notification appears when app terminated
- [ ] Tapping notification opens app
- [ ] Notification history shows received messages

### Topics
- [ ] Can subscribe to topic
- [ ] Subscribed topics list updates
- [ ] Receives notifications sent to topic
- [ ] Can unsubscribe from topic
- [ ] After unsubscribe, doesn't receive topic notifications

### Data Payload
- [ ] Data payload received with notification
- [ ] Can access data fields
- [ ] Can navigate based on data
- [ ] Data shown in notification history

### Platform Specific
- [ ] **iOS**: Permission request works
- [ ] **iOS**: Notifications appear with permission granted
- [ ] **iOS**: Notifications don't appear without permission
- [ ] **Android**: Notifications work without permission request
- [ ] **Android**: Notification channel created
- [ ] **Android**: Notification icon shows

### Error Handling
- [ ] Invalid token shows error
- [ ] Network error handled gracefully
- [ ] Permission denied handled (iOS)
- [ ] Topic subscription error shown

---

## UI Implementation Tips

### Notification History List Item

```
Card:
  Title: "Test Notification" (bold)
  Subtitle: "This is a test message"
  Time: "5 minutes ago" (relative time)
  If has data:
    ExpansionTile: "Data payload"
      Shows JSON data in formatted view
  Trailing: Delete button (remove from history)
```

### Token Display

```
Row:
  Expanded:
    SelectableText: "fA3b...Xy9z" (truncated token)
  IconButton: Copy icon
    OnPressed: Copy full token to clipboard
    ShowSnackbar: "Token copied!"
```

### Topic Subscription UI

```
Row:
  TextField: Topic name
  Buttons:
    "Subscribe" (green)
    "Unsubscribe" (red)

Below:
  Wrap: (chips of subscribed topics)
    Chip: "news" (can tap to unsubscribe)
    Chip: "updates"
    Chip: "sports"
```

---

## Quick Test Script

**5-Minute Test**:
1. Open app → FCMTestScreen
2. See FCM token displayed
3. Tap "Copy Token"
4. Open Firebase Console → Cloud Messaging
5. "Send your first message"
6. Title: "Hello", Body: "Testing"
7. Target: Single device → Paste token
8. Click "Publish"
9. See notification appear in app ✓
10. Put app in background
11. Send another notification
12. See in system tray, tap to open ✓

**Topic Test**:
1. In app, enter topic: "news"
2. Tap "Subscribe"
3. In Firebase Console, send to topic: "news"
4. Receive notification ✓
5. Tap "Unsubscribe"
6. Send to topic again
7. Don't receive (correctly unsubscribed) ✓

---

## What to Expect

### Success Signs:
- ✓ FCM token shows in app (long string)
- ✓ Notifications appear in all states (foreground, background, terminated)
- ✓ Notification history updates in real-time
- ✓ Topic subscription/unsubscription works
- ✓ Data payload accessible
- ✓ Tapping notification opens app correctly

### Common Issues:
- **Token is null**: Firebase not initialized, check `Firebase.initializeApp()`
- **iOS no notifications**: Permission not granted, request permission
- **Android no icon**: Add notification icon to drawable resources
- **Background not working**: Check background handler registered
- **Topic not receiving**: Wait 5-10 seconds after subscribe for propagation

---

## Additional Test Scenarios

### Deep Linking Test:
```
1. Send notification with data: {"screen": "profile", "userId": "123"}
2. App closed, tap notification
3. Should open directly to ProfileScreen with userId=123
```

### Multiple Notifications:
```
1. Send 5 notifications quickly
2. All should appear in history
3. All should have unique timestamps
4. Can clear all at once
```

### Notification Actions (Advanced):
```
1. Send notification with actions (if supported):
   "actions": [{"title": "View", "action": "view"}, {"title": "Dismiss"}]
2. Tap action button
3. App receives action ID
4. Navigate accordingly
```

---

## Monitoring

**Firebase Console - Cloud Messaging**:
- See total messages sent
- Delivery rates
- Open rates (if analytics enabled)
- Error logs

**In App**:
- Count of received notifications
- Last notification timestamp
- Token refresh count
- Failed delivery attempts

---

That's it! Follow these screens and tests to see FCM notifications working end-to-end in all app states.
