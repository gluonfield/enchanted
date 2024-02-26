//
//  RetrievalStore.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 24/02/2024.
//

import Foundation

@Observable
final class RetrievalStore {
    private var swiftDataService: SwiftDataService
    static let shared = RetrievalStore(swiftDataService: SwiftDataService.shared)
    
    var databases: [DatabaseSD] = []
    var selectedDatabase: DatabaseSD?
    
    let splitter = SimpleTextSplitter()
    let dataLoader = DataLoader()

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
    
    func indexDocuments(databaseId: UUID) async throws {
        guard let db = databases.filter({$0.id == databaseId}).first else { return }
        guard let languageModel = db.model else { return }
        let documents = db.documents?.filter({$0.status != .completed}) ?? []
        for document in documents {
            print("calculate embeddings for \(String(describing: document.documentUrl?.absoluteString)) using model \(languageModel.name)")
            
            guard let url = document.documentUrl else {
                print("skipped")
                continue
            }
            guard let fileContents = dataLoader.from(url) else {
                print("Skipped")
                continue
            }
            
            let chunks = splitter.split(text: fileContents, maxChunkSize: 510)
            for chunk in chunks {
                print("chunk")
                print(chunk.count)
            }
            
            for chunk in chunks {
                if let embedding = await LanguageModelStore.shared.getEmbedding(model: languageModel, prompt: chunk) {
                    print(embedding.count)
                }
            }
        }
    }
}
