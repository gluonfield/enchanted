//
//  ModelSD.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 10/12/2023.
//

import Foundation
import SwiftData

@Model
final class LanguageModelSD: Identifiable {
    @Attribute(.unique) var name: String
    var isAvailable: Bool = false
    
    @Relationship(deleteRule: .cascade, inverse: \ConversationSD.model)
    var conversations: [ConversationSD]? = []
    
    var provider: LanguageModelProvider
    
    init(name: String, provider: LanguageModelProvider = .ollama) {
        self.name = name
        self.provider = provider
    }
    
    @Transient var isNotAvailable: Bool {
        isAvailable == false
    }
}

// MARK: - Helpers
extension LanguageModelSD {
    var prettyName: String {
        guard let modelName = name.components(separatedBy: ":").first else {
            return name
        }
        
        return modelName.capitalized
    }
    
    var prettyVersion: String {
        let components = name.components(separatedBy: ":")
        if components.count >= 2 {
            return components[1]
        }
        return ""
    }
    
    var supportsImages: Bool {
        let imageSupportedModels = ["llava"]
        for modelName in imageSupportedModels {
            if name.contains(modelName) {
                return true
            }
        }
        return false
    }
    
    static let sample: [LanguageModelSD] = [
        .init(name: "Llama:latest"),
        .init(name: "Mistral:latest")
    ]
}


// MARK: - @unchecked Sendable
extension LanguageModelSD: @unchecked Sendable {
    /// We hide compiler warnings for concurency. We have to make sure to modify the data only via SwiftDataManager to ensure concurrent operations.
}
