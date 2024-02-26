//
//  OllamaService.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 09/12/2023.
//

import Foundation
import OllamaKit

class OllamaService: @unchecked Sendable {
    static let shared = OllamaService()
    
    var ollamaKit: OllamaKit
    
    init() {
        ollamaKit = OllamaKit(baseURL: URL(string: "http://localhost:11434")!)
        initEndpoint()
    }
    
    func initEndpoint(url: String? = nil) {
        let defaultUrl = "http://localhost:11434"
        let localStorageUrl = UserDefaults.standard.string(forKey: "ollamaUri")
        if var ollamaUrl = [localStorageUrl, defaultUrl].compactMap({$0}).filter({$0.count > 0}).first {
            if !ollamaUrl.contains("http") {
                ollamaUrl = "http://" + ollamaUrl
            }
            
            if let url = URL(string: ollamaUrl) {
                ollamaKit =  OllamaKit(baseURL: url)
                return
            }
        }
    }
    
    func getModels() async throws -> [LanguageModelSD]  {
        let response = try await ollamaKit.models()
        let models = response.models.map{model in LanguageModelSD(name: model.name)}
        return models
    }
    
    func reachable() async -> Bool {
        return await ollamaKit.reachable()
    }
}

// MARK: - Vector embeddings
extension OllamaService {
    func getEmbedding(prompt: String, model: LanguageModelSD) async -> [Double]? {
        let res = try? await ollamaKit.generateEmbeddings(data: .init(model: model.name, prompt: prompt))
        return res?.embedding
    }
}
