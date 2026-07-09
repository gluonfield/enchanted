//
//  DocumentSD.swift
//  Enchanted
//
//  Created by Daniel on 3/19/25.
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
    
}
