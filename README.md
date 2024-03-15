# SwiftDataStorage
[![Platforms](https://img.shields.io/badge/platforms-_iOS_|_macOS_|_watchOS_|_tvOS-lightgrey.svg?style=flat)](https://developer.apple.com/resources/)
[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](http://mit-license.org)

This library offers a lightweight property wrapper that can be used for abstracting SwiftData logic.

## Table of Contents
1. [Requirements](#requirements)
2. [Installation](#installation)
3. [Setup](#setup)
4. [Usage](#usage)
5. [Examples](#examples)
6. [Author](#author)

## Requirements

| Platform | Minimum Version |
|----------|-----------------|
| iOS      | 17.0            |
| macOS    | 14.0            |
| tvOS     | 17.0            |
| watchOS  | 10.0            |

## Installation

### Swift Package Manager

[Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift code. It integrates with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

#### Xcode

To integrate `SwiftDataStorage` into your Xcode project using Xcode 15 or later, follow these steps:

1. Open your project in Xcode.
2. Select `File` > `Swift Packages` > `Add Package Dependency...`
3. Enter the package repository URL:
```
https://github.com/JamesSedlacek/SwiftDataStorage.git
```
4. Choose the version rule that makes sense for your project.
5. Select `Add Package`.

#### Package.swift

If you are developing a Swift package or have a project that already uses `Package.swift`, you can add `SwiftDataStorage` as a dependency:

```swift
// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "SwiftDataStorage",
    dependencies: [
        .package(url: "https://github.com/JamesSedlacek/SwiftDataStorage.git", branch: "main")
    ],
    targets: [
        .target(
            name: "YourTargetName",
            dependencies: ["SwiftDataStorage"])
    ]
)
```

## Setup

1. Create any `PersistentModel` for your project.
```swift
@Model
final class MockModel: Identifiable {
    @Attribute(.unique) public let id: UUID
    public var testProperty: String

    init(id: UUID = .init(), _ testProperty: String) {
        self.id = id
        self.testProperty = testProperty
    }
}
```

2. Set up your `ModelContainer` with all of your models.
```swift
extension ModelContainer {
    @MainActor
    static let prod: ModelContainer = {
        do {
            return try ModelContainer(for: MockModel.self)
        } catch {
            fatalError("Failed to initialize ModelContainer.")
        }
    }()
}
```

3. Inject the `ModelContainer` into the environment via the `.modelContainer` modifier.
```swift
@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(.prod)
        }
    }
}
```

## Usage

Inject the `modelContext` from the `environment` into the ViewModel via `.fetch(context:)`
```swift
struct ContentView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel: ContentViewModel = .init()

    var body: some View {
        VStack {
            // Add more code here
        }
        .onAppear {
            viewModel.fetch(context: context)
        }
    }
}
```

Use the `@SwiftDataStorage` property wrapper to manage your `PersistentModel` array. <br>
Note - `@ObservationIgnored` is required to use Property Wrappers when using `@Observable` macro
```swift
@Observable
final class ContentViewModel {
    @ObservationIgnored
    @SwiftDataStorage var models: [MockModel]

    init() {}

    func fetch(context: ModelContext) {
        do {
            try _models.fetch(context: context)
        } catch {
            // TODO: Handle fetch failure
        }
    }
}
```

### Public Functions
``` swift
/// Fetches objects from the persistent storage based on the specified criteria and updates the internally managed collection.
/// - Parameter context: The context within which the fetch operation should be performed.
/// - Parameter descriptor: The criteria used to fetch objects. Defaults to an empty descriptor indicating no specific filtering.
/// - Throws: An error if the fetch operation fails, allowing calling code to handle fetch-related issues appropriately.
public func fetch(
    context: ModelContext,
    descriptor: FetchDescriptor<T> = .init()
) throws

/// Appends a single object to the persistent storage and the managed collection, if it's not already present.
/// - Parameter object: The object to be appended.
/// Ensures that the operation is performed within the appropriate context and logs a warning if the context is not set.
public func append(_ object: T)

/// Appends multiple objects to the persistent storage and the managed collection, excluding duplicates.
/// - Parameter objectsToAppend: The collection of objects to be appended.
public func append(_ objectsToAppend: [T])

/// Removes a specified object from both the persistent storage and the managed collection.
/// - Parameter object: The object to be removed.
/// Verifies the operation's context and logs a warning if the context is not set.
public func remove(_ object: T)

/// Removes multiple objects from both the persistent storage and the managed collection.
/// - Parameter objectsToRemove: The collection of objects to be removed.
public func remove(_ objectsToRemove: [T])

/// Removes all objects that meet the criteria specified by a predicate from both the persistent storage and the managed collection.
/// - Parameters:
///   - predicate: An optional predicate to filter objects for removal. If nil, all objects in the collection are removed.
///   - includeSubclasses: Indicates whether to include subclasses of `T` in the removal operation. Defaults to true.
/// - Throws: An error if the removal operation fails, allowing for error handling by the caller.
public func removeAll(
    where predicate: Predicate<T>? = nil,
    includeSubclasses: Bool = true
) throws

/// Updates the managed collection of objects to synchronize with the provided collection,
/// ensuring consistency between the persistent storage and the internal state.
/// - Parameter objects: The new collection of objects to be synchronized.
private func update(to objects: [T])
```

## Examples
Example of adding, deleting, and showing model data in a `List`
```swift
struct ContentView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel: ContentViewModel = .init()

    var body: some View {
        VStack {
            Button("Add Random Model") {
                viewModel.addRandom()
            }
            List(viewModel.models) { model in
                Text(model.testProperty)
                    .swipeActions {
                        Button("Delete", role: .destructive) {
                            viewModel.delete(model)
                        }
                    }
            }
        }
        .onAppear {
            viewModel.fetch(context: context)
        }
    }
}
```

```swift
@Observable
final class ContentViewModel {
    @ObservationIgnored
    @SwiftDataStorage var models: [MockModel]

    init() {}

    func fetch(context: ModelContext) {
        try? _models.fetch(context: context)
    }

    func addRandom() {
        _models.append(.init(UUID().uuidString))
    }

    func delete(_ model: MockModel) {
        _models.remove(model)
    }
}
```

## Author

James Sedlacek, find me on [X/Twitter](https://twitter.com/jsedlacekjr) or [LinkedIn](https://www.linkedin.com/in/jamessedlacekjr/)
