# Seznam Ghibli

Studio Ghibli film catalog built with Flutter.

## Setup

```bash
flutter pub get
./scripts/generate-api.sh   # swagger_parser + retrofit
dart run build_runner build  # test mocks
```

## Testing

```bash
dart analyze lib/
flutter test --exclude-tags=patrol
flutter test patrol_test/          # needs device
dart format --output=none --set-exit-if-changed lib/ test/
```

Covers: failure handling (Dio errors), favorites storage CRUD, provider state transitions, film loading/sort/cache, failure widget rendering.

## Trade-offs

- **No repository layer** — direct API calls from providers. Single API source, no benefit from extra indirection.
- **Sealed states over freezed** — zero external dependency, Dart 3 `sealed` is sufficient.
- **Lazy sub-entities** — only films load at startup. People, species, locations, vehicles fetch on demand.
