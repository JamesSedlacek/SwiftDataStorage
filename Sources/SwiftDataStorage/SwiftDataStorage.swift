//
//  SwiftDataStorage.swift
//
//
//  Created by James Sedlacek on 3/9/24.
//

import Foundation
import OSLog
@_exported import SwiftData
import SwiftUI

/// A property wrapper for managing persistent storage of objects conforming to `PersistentModel`.
/// This wrapper simplifies interacting with persistent storage, allowing easy fetch, append, and removal of objects.
/// It ensures thread-safety and leverages Swift's modern concurrency model by requiring operations to be performed on the `MainActor`.
@MainActor
@Observable
@propertyWrapper
public final class SwiftDataStorage<T: PersistentModel> {
    /// A logger for capturing and reporting runtime warnings. It is configured with the application's bundle identifier
    /// and the class name, facilitating easier identification of logs related to `SwiftDataStorage` operations.
    @ObservationIgnored
    lazy private var logger: Logger = {
        .init(
            subsystem: Bundle.main.bundleIdentifier ?? "Default Subsystem",
            category: String(describing: Self.self)
        )
    }()

    /// The context within which model operations are performed. Must be set before performing any fetch, append, or remove operations.
    private var context: ModelContext? = nil

    /// A collection of objects currently managed by `SwiftDataStorage`.
    /// This property is private to encapsulate storage management while providing public access through `wrappedValue`.
    private var objects: [T] = []

    /// Initializes a new instance of `SwiftDataStorage`. This is a default initializer with no parameters.
    public init() {}

    /// Provides access to the collection of objects managed by `SwiftDataStorage`.
    /// Getting this property returns the current collection of managed objects.
    /// Setting this property synchronizes the provided collection with the current managed collection, reflecting any changes in the persistent storage.
    public var wrappedValue: [T] {
        get { objects }
        set { update(to: newValue) }
    }

    /// Fetches objects from the persistent storage based on the specified criteria and updates the internally managed collection.
    /// - Parameter context: The context within which the fetch operation should be performed.
    /// - Parameter descriptor: The criteria used to fetch objects. Defaults to an empty descriptor indicating no specific filtering.
    /// - Throws: An error if the fetch operation fails, allowing calling code to handle fetch-related issues appropriately.
    public func fetch(
        context: ModelContext,
        descriptor: FetchDescriptor<T> = .init()
    ) throws {
        self.context = context
        objects = try context.fetch(descriptor)
    }

    /// Appends a single object to the persistent storage and the managed collection, if it's not already present.
    /// - Parameter object: The object to be appended.
    /// Ensures that the operation is performed within the appropriate context and logs a warning if the context is not set.
    public func append(_ object: T) {
        guard let context else {
            logger.warning("modelContext must be set before calling append")
            return
        }
        guard !objects.contains(where: { $0.id == object.id }) else {
            logger.warning("attempt to append a duplicate object")
            return
        }
        context.insert(object)
        objects.append(object)
    }

    /// Appends multiple objects to the persistent storage and the managed collection, excluding duplicates.
    /// - Parameter objectsToAppend: The collection of objects to be appended.
    public func append(_ objectsToAppend: [T]) {
        objectsToAppend.forEach { append($0) }
    }

    /// Removes a specified object from both the persistent storage and the managed collection.
    /// - Parameter object: The object to be removed.
    /// Verifies the operation's context and logs a warning if the context is not set.
    public func remove(_ object: T) {
        guard let context else {
            logger.warning("modelContext must be set before calling remove")
            return
        }
        context.delete(object)
        objects = objects.filter { $0.id != object.id }
    }

    /// Removes multiple objects from both the persistent storage and the managed collection.
    /// - Parameter objectsToRemove: The collection of objects to be removed.
    public func remove(_ objectsToRemove: [T]) {
        objectsToRemove.forEach { remove($0) }
    }

    /// Removes all objects that meet the criteria specified by a predicate from both the persistent storage and the managed collection.
    /// - Parameters:
    ///   - predicate: An optional predicate to filter objects for removal. If nil, all objects in the collection are removed.
    ///   - includeSubclasses: Indicates whether to include subclasses of `T` in the removal operation. Defaults to true.
    /// - Throws: An error if the removal operation fails, allowing for error handling by the caller.
    public func removeAll(
        where predicate: Predicate<T>? = nil,
        includeSubclasses: Bool = true
    ) throws {
        guard let context else {
            logger.warning("modelContext must be set before calling removeAll")
            return
        }
        try context.delete(
            model: T.self,
            where: predicate,
            includeSubclasses: includeSubclasses
        )
        objects = []
    }

    /// Updates the managed collection of objects to synchronize with the provided collection,
    /// ensuring consistency between the persistent storage and the internal state.
    /// - Parameter objects: The new collection of objects to be synchronized.
    private func update(to objects: [T]) {
        let newSet = Set(objects)
        let localSet = Set(self.objects)

        let objectsToAppend = Array(newSet.subtracting(localSet))
        let objectsToRemove = Array(localSet.subtracting(newSet))

        append(objectsToAppend)
        remove(objectsToRemove)
    }
}
