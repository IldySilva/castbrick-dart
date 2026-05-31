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
