## 0.2.0

### New Features
- **`push.issueToken()`** — issue short-lived HMAC-signed channel tokens for browser/mobile clients
- **`push.publish()`** — publish events to named channels from server-side code
- **`push.subscribe()`** — open SSE subscription; returns `PushSubscription` with per-channel `Stream<PushEvent>`
- New models: `PushEvent`, `PushTokenResponse`, `PushPublishResponse`
- `SseClient` — raw SSE stream parser over `http.Client.send()` (works on all Flutter platforms)
- Auto-reconnect with exponential backoff (1s → 30s), `Last-Event-ID` replay support

## 0.1.3

### Bug Fixes
- **`sms.cancelScheduled()`** — fixed endpoint from `POST /sms/cancel-scheduled` to `DELETE /sms/{id}` (was completely broken)
- **`contacts.createList()`** — now correctly returns `String` (the new list ID) instead of trying to deserialize a `ContactList` object
- **`contacts.create()`** — removed unsupported `emails` parameter; API only accepts `phoneNumbers`

### New Features
- **`sms.send()`** — added `fallback` parameter to control sender ID fallback behaviour
- **`sms.list()`** — added `status`, `phone`, `from` and `to` filter parameters
- **`CastBrickClient`** — corrected default `baseUrl` to `https://api.castbrick.co` (was incorrectly including `/v1` path prefix)

## 0.1.2

- Initial version.
