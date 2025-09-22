//
//  ContentView.swift
//  Lamp Realm Create
//
//  Created by Matthew Bennett on 2023-12-27.
//
//  The purpose of this application, when run, is to take JSON input files with matching
//  Realm schema/model/classes, insert them into a realm DB, then write that DB out to
//  a file for bundling with an application with the same Realm data model/classes
//

import SwiftUI
import RealmSwift
import Realm

struct ContentView: View {
    init() {

    }

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }.task {
            // Delete existing Realm database to start fresh
            try! deleteRealmDatabase()
            let realm = try! await Realm()
            if let jsonBooksData = readFile(forName: "books") {
                let decoder = JSONDecoder()

                do {
                    let decodedData = try decoder.decode([Book].self, from: jsonBooksData)
                    print("book count: ", decodedData.count)

                    // Batch operation for better performance
                    try! realm.write {
                        for eachBook in decodedData {
                            let book = Book(value: eachBook)
                            realm.add(book)
                        }
                    }
                } catch {
                    print("JSON decode error")
                    print(error)
                }
            }
            
            if let jsonGenresData = readFile(forName: "genres") {
                let decoder = JSONDecoder()

                do {
                    let decodedData = try decoder.decode([Genre].self, from: jsonGenresData)
                    print("genre count: ", decodedData.count)

                    // Batch operation for better performance
                    try! realm.write {
                        for eachGenre in decodedData {
                            let genre = Genre(value: eachGenre)
                            realm.add(genre)
                        }
                    }
                } catch {
                    print("JSON decode error")
                    print(error)
                }
            }
            
            if let jsonPlansData = readFile(forName: "plans") {
                let decoder = JSONDecoder()

                do {
                    let decodedData = try decoder.decode([Plan].self, from: jsonPlansData)
                    print("plan count: ", decodedData.count)

                    // Batch operation for better performance
                    try! realm.write {
                        for eachPlan in decodedData {
                            let plan = Plan(value: eachPlan)
                            realm.add(plan)
                        }
                    }
                } catch {
                    print("JSON decode error")
                    print(error)
                }
            }
            
            if let jsonTranslationsData = readFile(forName: "translations") {
                let decoder = JSONDecoder()

                do {
                    let decodedData = try decoder.decode([Translation].self, from: jsonTranslationsData)
                    print("translations count: ", decodedData.count)

                    // Batch operation for better performance
                    try! realm.write {
                        for eachTranslation in decodedData {
                            let translation = Translation(value: eachTranslation)
                            realm.add(translation)
                        }
                    }
                } catch {
                    print("JSON decode error")
                    print(error)
                }
            }
            
            if let jsonCrossRefData = readFile(forName: "cross_references") {
                let decoder = JSONDecoder()

                do {
                    let decodedData = try decoder.decode([CrossReference].self, from: jsonCrossRefData)
                    print("crossRefs count: ", decodedData.count)

                    // Transactions are costly, so much faster with many records here to add them all in a single transaction
                    try! realm.write {
                        for eachCrossRef in decodedData {
                            let crossReference = CrossReference(value: eachCrossRef)
                            realm.add(crossReference)
                        }
                    }
                } catch {
                    print("JSON decode error")
                    print(error)
                }
            }
            
            do {
                try createBundledRealm()
            } catch {
                print("Error creating bundled realm: \(error)")
            }
            
            print("Database creation completed")
        }
        .padding()
    }
}

private func readFile(forName name: String) -> Data? {
        do {

            if let bundlePath = Bundle.main.path(forResource: name, ofType: "json"),
                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print(error)
        }
        return nil
    }

private func deleteRealmDatabase() throws {
    let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
    let realmURLs = [
        realmURL,
        realmURL.appendingPathExtension("lock"),
        realmURL.appendingPathExtension("note"),
        realmURL.appendingPathExtension("management")
    ]
    
    for url in realmURLs {
        do {
            try FileManager.default.removeItem(at: url)
        } catch CocoaError.fileNoSuchFile {
            // File doesn't exist, which is fine
        } catch {
            // Re-throw other errors
            throw error
        }
    }
}

class Genre: RealmSwiftObject, Decodable {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var name: String
}

class Book: RealmSwiftObject, Decodable {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var genre: Int
    @Persisted var name: String
    @Persisted var osisId: String
    @Persisted var osisParatextAbbreviation: String
    @Persisted var testament: String
}

class Translation: RealmSwiftObject, Decodable {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var abbreviation: String
    @Persisted var language: String
    @Persisted var name: String
    @Persisted var url: String
    @Persisted var license: String
    @Persisted var fullDescription: String
    @Persisted var verses: RealmSwift.List<Verse>
}

class Verse: RealmSwiftObject, Decodable {
    @Persisted(indexed: true) var id: Int
    @Persisted var b: Int
    @Persisted var c: Int
    @Persisted var v: Int
    @Persisted var t: String
    @Persisted(indexed: true) var tr: Int
}

class Plan: RealmSwiftObject, Decodable {
    @Persisted(primaryKey: true) var id: Int
    @Persisted var author: String
    @Persisted var name: String
    @Persisted var shortDescription: String
    @Persisted var fullDescription: String
    @Persisted var plan: RealmSwift.List<PlanDay>
}

class PlanDay: RealmSwiftObject, Decodable {
    @Persisted(indexed: true) var day: Int
    @Persisted var readings: RealmSwift.List<Reading>
}

class Reading: RealmSwiftObject, Decodable {
    @Persisted var book: ReadingRange?
    @Persisted var chapter: ReadingRange?
    @Persisted var verse: ReadingRange?
}

class ReadingRange: RealmSwiftObject, Decodable {
    @Persisted var start: Int?
    @Persisted var end: Int?
}

class CrossReference: RealmSwiftObject, Decodable {
    @Persisted(indexed: true) var id: Int
    @Persisted var r: Int
    @Persisted var sv: Int
    @Persisted var ev: Int?
}

class User: RealmSwiftObject, Identifiable {
    @Persisted var plans = RealmSwift.List<Plan>()
    @Persisted var planInAppBible = true
    @Persisted var planExternalBible: String? = nil
    @Persisted var planWpm: Double = 183
    @Persisted var planNotification = false
    @Persisted var planNotificationDate: Date = {
        var dateComponents = DateComponents()
        dateComponents.hour = 18
        dateComponents.minute = 30
        return Calendar.current.date(from: dateComponents) ?? Date()
    }()
    @Persisted var readerTranslation: Translation? = nil
    @Persisted var readerCrossReferenceSort = "r"
    @Persisted var readerFontSize: Float = 16
    @Persisted var completedReadings = RealmSwift.List<CompletedReading>()
    
    let defaultTranslationId = 3
}

class CompletedReading: RealmSwiftObject, Identifiable {
    @Persisted(primaryKey: true) var id: String

    convenience init(id: String) {
        self.init()
        self.id = id
    }
}

//try await createBundledRealm()

// Opening a realm and accessing it must be done from the same thread.
// Marking this function as `@MainActor` avoids threading-related issues.
//@MainActor
func createBundledRealm() throws {
    // Get the file URL for the default Realm
    guard let defaultRealmURL = Realm.Configuration.defaultConfiguration.fileURL else { return }

    // Specify the destination file URL for the saved Realm file
    let fileManager = FileManager.default
    let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let destinationURL = documentsURL.appendingPathComponent("lamp.realm")

    // Remove existing file if it exists
    if fileManager.fileExists(atPath: destinationURL.path) {
        try fileManager.removeItem(at: destinationURL)
    }

    // Copy the Realm file to the destination URL
    try fileManager.copyItem(at: defaultRealmURL, to: destinationURL)
    
    print("Successfully created bundled Realm at: \(destinationURL.path)")
}
