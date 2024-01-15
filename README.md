# Lamp Realm Create (macOS)

A macOS app sharing the data model of [Lamp Bible](https://github.com/mattsbennett/lamp-bible-ios) used to create the Realm database.

## Build

Data model/classes matching those of [Lamp Bible](https://github.com/mattsbennett/lamp-bible-ios) must be copied to `ContentView.swift`. Add seed data (JSON) to the `LampRealmCreate` directory and run the app. The Realm database will be created in the `/Users/{username}/Library/Containers/com.neus.Lamp-Realm-Create/Data/Library/Application Support` directory.

### Seed data

- `books.json`
- `cross_references.json`
- `genres.json`
- `plans.json`
- `translations.json`

## License

[CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/)
