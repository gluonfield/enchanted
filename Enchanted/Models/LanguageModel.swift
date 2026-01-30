//
//  LanguageModel.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 12/05/2024.
//

import Foundation

struct LanguageModel {
    var name: String
    var provider: ModelProvider
    var imageSupport: Bool
}

enum ModelProvider: String, Codable, CaseIterable {
    case ollama = "ollama"
    case openAI = "openai"

    var displayName: String {
        switch self {
        case .ollama:
            return "Ollama"
        case .openAI:
            return "OpenAI Compatible"
        }
    }
}
