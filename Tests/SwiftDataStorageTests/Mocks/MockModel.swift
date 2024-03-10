//
//  MockModel.swift
//
//
//  Created by James Sedlacek on 3/9/24.
//

import Foundation
import SwiftData

@Model
final class MockModel: Identifiable {
    @Attribute(.unique) public let id: UUID
    public var testProperty: String

    init(id: UUID = .init(), _ testProperty: String) {
        self.id = id
        self.testProperty = testProperty
    }
}
