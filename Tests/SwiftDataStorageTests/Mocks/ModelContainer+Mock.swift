//
//  ModelContainer+Mock.swift
//
//
//  Created by James Sedlacek on 3/9/24.
//

import SwiftData

extension ModelContainer {
    @MainActor
    static let mock: ModelContainer = {
        do {
            return try ModelContainer(for: MockModel.self)
        } catch {
            fatalError("Failed to initialize ModelContainer.")
        }
    }()
}
