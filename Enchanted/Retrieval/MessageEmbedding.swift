//
//  MessageEmbedding.swift
//  Enchanted
//
//  Created by Now or Never on 3/19/25.
//

import Foundation
import SVDB

protocol MessageEmbeddingProtocol {
    func generateContext(_ prompt: String, _ model: LanguageModelSD) async -> String
}

struct MessageEmbedding: MessageEmbeddingProtocol {
    private let languageModelStore: LanguageModelStore
    private let retrievalStore: RetrievalStore

    init(
        languageModelStore: LanguageModelStore = .shared,
        retrievalStore: RetrievalStore = .shared
    ) {
        self.languageModelStore = languageModelStore
        self.retrievalStore = retrievalStore
    }

    func generateContext(_ prompt: String, _ model: LanguageModelSD) async -> String {
        // Obtain the embedding vector for the given prompt
        guard let promptEmbedding = await languageModelStore.getEmbedding(model: model, prompt: prompt) else {
            print("[MessageEmbedding] Error: Unable to generate embedding for prompt: \(prompt)")
            return ""
        }

        print("[MessageEmbedding] Embedding vector generated: \(promptEmbedding)")

        // Perform similarity search to retrieve relevant context
        let retrievedContext = retrievalStore.searchSVDB(promptEmbedding: promptEmbedding)

        return retrievedContext
    }
}
