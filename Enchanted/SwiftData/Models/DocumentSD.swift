//
//  DocumentSD.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 24/02/2024.
//

import Foundation
import SwiftData

@Model
final class DocumentSD: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    
    var documentUrl: URL?
    var updatedAt: Date
    var status: DocumentIndexStatus
    var indexProgress: Double?

    @Relationship(deleteRule: .nullify)
    var database: DatabaseSD?
    
    init(updatedAt: Date = Date.now, documentUrl: URL, status: DocumentIndexStatus) {
        self.updatedAt = updatedAt
        self.documentUrl = documentUrl
        self.status = status
        self.indexProgress = 0
    }
}

// MARK: - Sample
extension DocumentSD {
    static let sample = [
        DocumentSD(documentUrl: URL(string: "./files/company_house.pdf")!, status: .completed),
        DocumentSD(documentUrl: URL(string: "./files/somedoc.pdf")!, status: .indexing),
        DocumentSD(documentUrl: URL(string: "./files/important.pdf")!, status: .completed)
    ]
}


// MARK: - @unchecked Sendable
extension DocumentSD: @unchecked Sendable {
    /// We hide compiler warnings for concurency. We have to make sure to modify the data only via `SwiftDataManager` to ensure concurrent operations.
}
