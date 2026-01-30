//
//  PromptPanelVM.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 29/02/2024.
//

import SwiftUI
import OllamaKit
import Combine

@Observable
final class CompletionsPanelVM {
    var selectedText: String?
    var onReceiveText: (String) -> ()
    var messageResponse: String = ""
    var isReady = false
    let sentenceQueue = AsyncQueue<String>()
    private var generation: AnyCancellable?
    private var currentMessageBuffer: String = ""

    
    init(onReceiveText: @escaping (String) -> Void = {_ in}) {
        self.onReceiveText = onReceiveText
    }
    
    static func constructPrompt(completion: CompletionInstructionSD, selectedText: String) -> String {
        var prompt = completion.instruction
        
        if prompt.contains("{{text}}") {
            prompt.replace("{{text}}", with: selectedText)
        } else {
            prompt += " " + selectedText
        }
        
        return prompt
    }
    
    @MainActor
    func sendPrompt(completion: CompletionInstructionSD, model: LanguageModelSD)  {
        guard let selectedText = selectedText, !isReady else { return }
        let prompt = CompletionsPanelVM.constructPrompt(completion: completion, selectedText: selectedText)
        
        let messages: [OKChatRequestData.Message] = [
            .init(role: .user, content: prompt)
        ]
        var request = OKChatRequestData(model: model.name, messages: messages)
        request.options = OKCompletionOptions(temperature: completion.modelTemperature ?? 0.8)
        currentMessageBuffer = ""
        messageResponse = ""
        
        print("request", request.messages)

        let selectedProvider = UserDefaults.standard.string(forKey: "selectedProvider") ?? ModelProvider.ollama.rawValue
        let provider = ModelProvider(rawValue: selectedProvider) ?? .ollama

        Task {
            if provider == .ollama {
                if await OllamaService.shared.ollamaKit.reachable() {
                    generation = OllamaService.shared.ollamaKit.chat(data: request)
                        .sink(receiveCompletion: { [weak self] completion in
                            switch completion {
                            case .finished:
                                self?.handleComplete()
                            case .failure(let error):
                                self?.handleError(error.localizedDescription)
                            }
                        }, receiveValue: { [weak self] response in
                            self?.handleReceive(response)
                        })
                } else {
                    self.handleError("Server unreachable")
                }
            } else {
                // OpenAI-compatible API
                if await OpenAIService.shared.reachable() {
                    let openAIMessages = messages.map { msg in
                        OpenAIChatMessage(role: msg.role.rawValue, content: msg.content)
                    }

                    generation = OpenAIService.shared.chat(
                        model: model.name,
                        messages: openAIMessages,
                        temperature: completion.modelTemperature.map { Double($0) } ?? 0.8
                    )
                    .sink(receiveCompletion: { [weak self] completion in
                        switch completion {
                        case .finished:
                            self?.handleComplete()
                        case .failure(let error):
                            self?.handleError(error.localizedDescription)
                        }
                    }, receiveValue: { [weak self] response in
                        self?.handleOpenAIReceive(response)
                    })
                } else {
                    self.handleError("Server unreachable")
                }
            }
        }
    }

    @MainActor
    private func handleOpenAIReceive(_ response: OpenAIChatResponse) {
        Task {
            if let responseContent = response.content {
                await sentenceQueue.enqueue(responseContent)
                self.messageResponse = self.messageResponse + responseContent
            }
        }
    }
    
    @MainActor
    private func handleReceive(_ response: OKChatResponse)  {
        Task {
            if let responseContent = response.message?.content {
                await sentenceQueue.enqueue(responseContent)
                self.messageResponse = self.messageResponse + responseContent
            }
        }
    }
    
    @MainActor
    private func handleError(_ errorMessage: String) {
        print("error \(errorMessage)")
    }
    
    @MainActor
    private func handleComplete() {
        print("model response ", self.messageResponse)
    }
    
    @MainActor
    func cancel() {
        generation?.cancel()
    }
}
