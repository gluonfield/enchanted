//
//  VectorStoreProtocol.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 25/02/2024.
//

import Foundation

/// `VectorStore` protoco defines class of Index.
protocol VectorDatabase {}

/// Document
struct VectorDocument: Identifiable, Codable {
    var id: UUID
    var vector: [Double]
    var text: String
    var metadata: [String:String] = [:]
}
