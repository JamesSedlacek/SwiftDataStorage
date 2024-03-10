import XCTest
import SwiftData
@testable import SwiftDataStorage

final class SwiftDataStorageTests: XCTestCase {
    @SwiftDataStorage var models: [MockModel]
    var container: ModelContainer!

    override func setUp() {
        super.setUp()
        container = .mock
    }

    override func tearDown() {
        container = nil
        models = []
        super.tearDown()
    }

    func testInitialization() throws {
        try? _models.fetch(context: container.mainContext)
        models = []
        XCTAssertTrue(
            models.isEmpty,
            "Models should be empty upon initialization."
        )
    }

    func testAppend() throws {
        // Given
        try? _models.fetch(context: container.mainContext)
        models = []
        let mockModel = MockModel("Testing")

        // When
        _models.append(mockModel)

        // Then
        XCTAssertEqual(
            models.count, 1,
            "There should be exactly one model after appending."
        )
        XCTAssertEqual(
            models.first?.testProperty, "Testing",
            "The property of the first model should match the input."
        )
    }

    func testAppendIgnoresDuplicates() {
        // Given
        try? _models.fetch(context: container.mainContext)
        models = []
        let uniqueId = UUID()
        let initialModel = MockModel(id: uniqueId, "UniqueValue")
        _models.append(initialModel)

        // When appending a model with the same unique identifier (or duplicate criteria),
        // we expect the storage to ignore this operation and maintain only the original instance.
        let duplicateModel = MockModel(id: uniqueId, "UniqueValue")
        _models.append(duplicateModel)

        // Then
        XCTAssertEqual(
            models.count, 1,
            "Models should contain only one instance of the model despite appending a duplicate."
        )
        let model = models.first(where: { $0.id == uniqueId })
        XCTAssertNotNil(model, "The model with the unique identifier should exist in the storage.")
        XCTAssertEqual(
            model?.testProperty, "UniqueValue",
            "The properties of the model in storage should match the original values."
        )
    }

    func testAppendArray() throws {
        // Given
        try? _models.fetch(context: container.mainContext)
        models = []
        let mockModels = [MockModel("First"), MockModel("Second")]

        // When
        _models.append(mockModels)

        // Then
        XCTAssertEqual(
            models.count, 2,
            "There should be exactly two models after appending an array."
        )
        XCTAssertEqual(
            models[0].testProperty, "First",
            "The property of the first model should match the input."
        )
        XCTAssertEqual(
            models[1].testProperty, "Second",
            "The property of the second model should match the input."
        )
    }

    func testRemove() throws {
        // Given
        try? _models.fetch(context: container.mainContext)
        models = []
        let mockModel = MockModel("ToRemove")
        _models.append(mockModel)

        // When
        _models.remove(mockModel)

        // Then
        XCTAssertTrue(models.isEmpty, "Models should be empty after removing the model.")
    }

    func testRemoveArray() throws {
        // Given
        try? _models.fetch(context: container.mainContext)
        models = []
        let mockModels = [MockModel("First"), MockModel("Second")]
        _models.append(mockModels)

        // When
        _models.remove(mockModels)

        // Then
        XCTAssertTrue(models.isEmpty, "Models should be empty after removing the array of models.")
    }

    func testRemoveAll() throws {
        // Given
        try? _models.fetch(context: container.mainContext)
        models = []
        let mockModels = [MockModel("First"), MockModel("Second")]
        _models.append(mockModels)

        // When
        do {
            try _models.removeAll()
        } catch {
            XCTFail("Failed to remove all models due to error: \(error)")
        }

        // Then
        XCTAssertTrue(models.isEmpty, "Models should be empty after removing all models.")
    }

    func testUpdateModels() throws {
        // Given
        try? _models.fetch(context: container.mainContext)
        models = []
        let mockModel = MockModel("Initial")
        _models.append(mockModel)

        // When
        models[0].testProperty = "Updated"

        // Then
        XCTAssertEqual(
            models.count, 1,
            "There should be only one model after updating."
        )
        XCTAssertEqual(
            models.first?.testProperty, "Updated",
            "The property of the model should be updated."
        )
    }
}
