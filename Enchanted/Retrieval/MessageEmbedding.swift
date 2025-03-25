//
//  MessageEmbedding.swift
//  Enchanted
//
//  Created by Now or Never on 3/19/25.
//

import Foundation

protocol MessageEmbeddingProtocol {
    func generateContext(_ prompt: String, _ model: LanguageModelSD) async -> String
}

struct MessageEmbedding: MessageEmbeddingProtocol {
    private let languageModelStore: LanguageModelStore
    private let retrievalStore: RetrievalStore
    private let svdbService: SVDBService

    init(
        languageModelStore: LanguageModelStore = .shared,
        retrievalStore: RetrievalStore = .shared,
        svdbService: SVDBService = .shared
    ) {
        self.languageModelStore = languageModelStore
        self.retrievalStore = retrievalStore
        self.svdbService = svdbService
    }

    func generateContext(_ prompt: String, _ model: LanguageModelSD) async -> String {
        // Obtain the embedding vector for the given prompt
        guard let promptEmbedding = await languageModelStore.getEmbedding(model: model, prompt: prompt) else {
            print("[MessageEmbedding] Error: Unable to generate embedding for prompt: \(prompt)")
            return ""
        }

        print("[MessageEmbedding] Embedding vector generated: \(promptEmbedding)")

        guard let databaseId = retrievalStore.selectedDatabase?.id else {
            print("Database ID not found.")
            return ""
        }
        
        // Perform similarity search to retrieve relevant context
        let retrievedContext = await svdbService.search(query: promptEmbedding, databaseId: databaseId)

        return retrievedContext
    }
}
