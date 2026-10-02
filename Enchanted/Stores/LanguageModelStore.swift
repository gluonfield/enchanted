//
//  ModelStore.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 10/12/2023.
//

import Foundation
import SwiftData

@Observable
final class LanguageModelStore {
    static let shared = LanguageModelStore(swiftDataService: SwiftDataService.shared)
    
    private var swiftDataService: SwiftDataService
    @MainActor var models: [LanguageModelSD] = []
    @MainActor var supportsImages = false
    @MainActor var selectedModel: LanguageModelSD?
    
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
        if let lastModel = models.last {
            setModel(model: lastModel)
        }
    }
    
    func loadModels() async throws {
        let selectedProvider = UserDefaults.standard.string(forKey: "selectedProvider") ?? ModelProvider.ollama.rawValue
        let provider = ModelProvider(rawValue: selectedProvider) ?? .ollama

        let remoteModels: [LanguageModel]
        if provider == .ollama {
            remoteModels = try await OllamaService.shared.getModels()
        } else {
            remoteModels = try await OpenAIService.shared.getModels()
        }

        try await swiftDataService.saveModels(models: remoteModels.map{LanguageModelSD(name: $0.name, imageSupport: $0.imageSupport, modelProvider: provider)})

        let storedModels = (try? await swiftDataService.fetchModels()) ?? []

        DispatchQueue.main.async {
            let remoteModelNames = remoteModels.map { $0.name }
            self.models = storedModels.filter{remoteModelNames.contains($0.name)}
        }
    }

    func currentProvider() -> ModelProvider {
        let selectedProvider = UserDefaults.standard.string(forKey: "selectedProvider") ?? ModelProvider.ollama.rawValue
        return ModelProvider(rawValue: selectedProvider) ?? .ollama
    }
    
    func deleteAllModels() async throws {
        DispatchQueue.main.async {
            self.models = []
        }
        try await swiftDataService.deleteModels()
    }
}
