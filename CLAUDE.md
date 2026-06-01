# castbrick-dart

Official Dart SDK for the CastBrick API. Published as `castbrick` on pub.dev. Works in Dart and Flutter.

## Commands

```bash
dart pub get              # install dependencies
dart pub publish --dry-run # validate before publishing
dart pub publish           # publish to pub.dev
dart test                  # run tests
```

## Version

Current: `0.1.3` — bump in `pubspec.yaml` before releasing.

## Source files

```
lib/src/
├── client.dart            # CastBrickClient (http package)
├── models.dart            # All model classes
└── resources/
    ├── sms.dart           # SmsResource
    ├── contacts.dart      # ContactsResource
    └── broadcasts.dart    # BroadcastsResource
```

## API base URL

Default: `https://api.castbrick.co` — **no `/v1`**. Previous versions had `/v1` which caused 404s — never add it back.

## Correct API facts

- `sms.cancelScheduled(messageId)` → `DELETE /sms/{id}`
- `contacts.createList(name)` → returns `Future<String>` (ID), not `Future<ContactList>`
- `contacts.create(phoneNumbers: ...)` — no `emails` param
- `sms.list({ status, phone, from, to, page, pageSize })` — all optional filters
- `sms.send({ ..., fallback: bool? })` — fallback param supported

## Publishing

Tag `v0.1.x` triggers GitHub Actions → publishes to pub.dev via OIDC (no token needed).
Uses `id-token: write` permission in workflow.
