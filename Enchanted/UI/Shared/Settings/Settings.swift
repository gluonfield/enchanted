//
//  Settings.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 28/12/2023.
//

import SwiftUI
import Combine

struct Settings: View {
    var languageModelStore = LanguageModelStore.shared
    var conversationStore = ConversationStore.shared
    var swiftDataService = SwiftDataService.shared
    
    @AppStorage("ollamaUri") private var ollamaUri: String = ""
    @AppStorage("systemPrompt") private var systemPrompt: String = ""
    @AppStorage("vibrations") private var vibrations: Bool = true
    @AppStorage("colorScheme") private var colorScheme = AppColorScheme.system
    @AppStorage("defaultOllamaModel") private var defaultOllamaModel: String = ""
    @AppStorage("ollamaBearerToken") private var ollamaBearerToken: String = ""
    @AppStorage("appUserInitials") private var appUserInitials: String = ""
    @AppStorage("pingInterval") private var pingInterval: String = "5"
    @AppStorage("voiceIdentifier") private var voiceIdentifier: String = ""
    @AppStorage("selectedProvider") private var selectedProvider: String = ModelProvider.ollama.rawValue
    @AppStorage("openAIUri") private var openAIUri: String = ""
    @AppStorage("openAIApiKey") private var openAIApiKey: String = ""
    
    @StateObject private var speechSynthesiser = SpeechSynthesizer.shared
    
    @Environment(\.presentationMode) var presentationMode
    
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    @State private var cancellable: AnyCancellable?
    
    private func save() {
#if os(iOS)
#endif
        // remove trailing slash
        if ollamaUri.last == "/" {
            ollamaUri = String(ollamaUri.dropLast())
        }
        if openAIUri.last == "/" {
            openAIUri = String(openAIUri.dropLast())
        }

        OllamaService.shared.initEndpoint(url: ollamaUri, bearerToken: ollamaBearerToken)
        OpenAIService.shared.initEndpoint(url: openAIUri, apiKey: openAIApiKey)
        Task {
            Haptics.shared.mediumTap()
            try? await languageModelStore.loadModels()
        }
        presentationMode.wrappedValue.dismiss()
    }
    
    private func checkServer() {
        Task {
            let provider = ModelProvider(rawValue: selectedProvider) ?? .ollama
            if provider == .ollama {
                OllamaService.shared.initEndpoint(url: ollamaUri)
                ollamaStatus = await OllamaService.shared.reachable()
            } else {
                OpenAIService.shared.initEndpoint(url: openAIUri, apiKey: openAIApiKey)
                ollamaStatus = await OpenAIService.shared.reachable()
            }
            try? await languageModelStore.loadModels()
        }
    }
    
    private func deleteAll() {
        Task {
            try? await conversationStore.deleteAllConversations()
            try? await languageModelStore.deleteAllModels()
        }
    }
    
    @State var ollamaStatus: Bool?
    var body: some View {
        SettingsView(
            ollamaUri: $ollamaUri,
            systemPrompt: $systemPrompt,
            vibrations: $vibrations,
            colorScheme: $colorScheme,
            defaultOllamModel: $defaultOllamaModel,
            ollamaBearerToken: $ollamaBearerToken,
            appUserInitials: $appUserInitials,
            pingInterval: $pingInterval,
            voiceIdentifier: $voiceIdentifier,
            selectedProvider: $selectedProvider,
            openAIUri: $openAIUri,
            openAIApiKey: $openAIApiKey,
            save: save,
            checkServer: checkServer,
            deleteAll: deleteAll,
            ollamaLangugeModels: languageModelStore.models,
            voices: speechSynthesiser.voices
        )
        .frame(maxWidth: 700)
        #if os(visionOS)
        .frame(minWidth: 600, minHeight: 800)
        #endif
        .onChange(of: defaultOllamaModel) { _, modelName in
            languageModelStore.setModel(modelName: modelName)
        }
        .onAppear {
            /// refresh voices in the background
            cancellable = timer.sink { _ in
                speechSynthesiser.fetchVoices()
            }
        }
        .onDisappear {
            cancellable?.cancel()
        }
    }
}

#Preview {
    Settings()
}
