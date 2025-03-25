//
//  DatabaseSD.swift
//  Enchanted
//
//  Created by Daniel on 3/19/25.
//

import Foundation
import SwiftData

@Model
final class DatabaseSD: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()

    var name: String
    var indexPath: String?
    var updatedAt: Date

    @Relationship(deleteRule: .nullify)
    var model: LanguageModelSD?

    @Relationship(deleteRule: .cascade, inverse: \DocumentSD.database)
    var documents: [DocumentSD]? = []

    init(name: String, updatedAt: Date = Date.now, indexPath: String, documents: [DocumentSD] = []) {
        self.name = name
        self.updatedAt = updatedAt
        self.indexPath = indexPath
        self.documents = documents
    }
}

extension DatabaseSD {
    static let sample = [
        DatabaseSD(name: "Personal", indexPath: "./home/personal", documents: DocumentSD.sample)
    ]
}

// MARK: - @unchecked Sendable
extension DatabaseSD: @unchecked Sendable {
    
}
