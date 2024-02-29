//
//  RetrievalStore.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 24/02/2024.
//

import Foundation
import SwiftUI

@Observable
final class RetrievalStore {
    private var swiftDataService: SwiftDataService
    static let shared = RetrievalStore(swiftDataService: SwiftDataService.shared)
    
    var databases: [DatabaseSD] = []
    var selectedDatabase: DatabaseSD?
    var indexStore: SimpleVectorStore?
    
    let splitter = SimpleTextSplitter()
    let dataLoader = DataLoader()
    
    // Indexing state
    var progress: Double?
    
    init(swiftDataService: SwiftDataService) {
        self.swiftDataService = swiftDataService
    }
    
    func createDatabase(name: String, indexPath: String, languageModelName: String) async throws {
        try await swiftDataService.createDatabase(name: name, indexPath: indexPath, languageModelName: languageModelName)
        try await getDatabases()
    }
    
    func getDatabases() async throws {
        databases = try await swiftDataService.getDatabases()
    }
    
    func attachDocuments(databaseId: UUID, documentPaths: [URL]) async throws {
        guard let db = databases.filter({$0.id == databaseId}).first else { return }
        //        let existingDocuments = Set(arrayLiteral: db.documents?.compactMap{$0.documentPath})
        try await swiftDataService.databaseAttachDocuments(db: db, paths: documentPaths)
        try await getDatabases()
    }
    
    func indexDocuments(databaseId: UUID, callback: @escaping @Sendable (_ documentsListProgress: Double) -> ()?) async throws {
        print("index called")
        guard let db = databases.filter({$0.id == databaseId}).first else { return }
        guard let languageModel = db.model else { return }
        let documents = db.documents?.filter({$0.status != .completed}) ?? []
        for (index, document) in documents.enumerated() {
            let documentsListProgress = Double(index)/Double(documents.count)
            
            print("calculate embeddings for \(String(describing: document.documentUrl?.absoluteString)) using model \(languageModel.name)")
            
            try await swiftDataService.updateDocumentStatus(document: document, status: .indexing)
            
            guard let url = document.documentUrl, let fileContents = dataLoader.from(url) else {
                try await swiftDataService.updateDocumentStatus(document: document, status: .failed)
                continue
            }
            
            let chunks = splitter.split(text: fileContents, maxChunkSize: 510)
            
            indexStore = SimpleVectorStore()
            
            for (chunkIndex, chunk) in chunks.enumerated() {
                if let embedding = await LanguageModelStore.shared.getEmbedding(model: languageModel, prompt: chunk) {
                    indexStore?.upsert(embedding: embedding, text: chunk)
                    let documentProgress = Double(chunkIndex)/Double(chunks.count)
                    callback(documentsListProgress)
                    DispatchQueue.main.async {
                        document.indexProgress = documentProgress
                    }
                    print("embedding calculated")
                }
            }
            
            
            try await swiftDataService.updateDocumentStatus(document: document, status: .completed)
            
        }
        
        /// completed
        callback(1.0)
    }
}
