//
//  ModelStore.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 10/12/2023.
//

import Foundation
import SwiftData
import Combine

@Observable
final class LanguageModelStore {
    static let shared = LanguageModelStore(swiftDataService: SwiftDataService.shared)
    private var swiftDataService: SwiftDataService
    
    var models: [LanguageModelSD] = []
    var supportsImages = false
    var selectedModel: LanguageModelSD?
    
    init(swiftDataService: SwiftDataService) {
        self.swiftDataService = swiftDataService
    }
    
    @MainActor
    func setModel(model: LanguageModelSD?) {
        if let model = model {
            // check if model still exists
            if models.contains(model) {
                selectedModel = model
            }
        } else {
            selectedModel = nil
        }
    }
    
    @MainActor
    func setModel(modelName: String) {
        for model in models {
            if model.name == modelName {
                setModel(model: model)
                return
            }
        }
    }
    
    func loadModels() async throws {
        print("loading models")
        let localModels = try await swiftDataService.fetchModels()
        print("completed loadLocal()")
        let remoteModels = try await OllamaService.shared.getModels()
        print("completed loadRemote()")
        
        _ = localModels.map { model in
            model.isAvailable == remoteModels.contains(model)
        }
        
        let updateModelsList = Array(Set(localModels + remoteModels))
        try await swiftDataService.saveModels(models: updateModelsList)
        print("completed saveModels()")
        
        models = try await swiftDataService.fetchModels()
    }
    
    func deleteAllModels() async throws {
        models = []
        try await swiftDataService.deleteModels()
    }
    
    func getEmbedding(model: LanguageModelSD, prompt: String) async -> [Double]? {
        switch model.provider {
        case .ollama:
            let embeddings = await OllamaService.shared.getEmbedding(prompt: prompt, model: model)
            return embeddings
        }
    }
}
