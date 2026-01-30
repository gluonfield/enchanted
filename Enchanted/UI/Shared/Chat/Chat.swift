//
//  MainView.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 09/12/2023.
//

import SwiftUI

struct Chat: View, Sendable {
    @State private var languageModelStore: LanguageModelStore
    @State private var conversationStore: ConversationStore
    @State private var appStore: AppStore
    @AppStorage("systemPrompt") private var systemPrompt: String = ""
    @AppStorage("appUserInitials") private var userInitials: String = ""
    @AppStorage("defaultOllamaModel") private var defaultOllamaModel: String = ""
    @State var showMenu = false
#if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var columnVisibility = NavigationSplitViewVisibility.doubleColumn
#endif

    init(languageModelStore: LanguageModelStore, conversationStore: ConversationStore, appStore: AppStore) {
        _languageModelStore = State(initialValue: languageModelStore)
        _conversationStore = State(initialValue: conversationStore)
        _appStore = State(initialValue: appStore)
    }

    func toggleMenu() {
        withAnimation(.spring) {
            showMenu.toggle()
        }
        Task {
            await Haptics.shared.mediumTap()
        }
    }

    @MainActor
    func updateSelectedModel() {
        if languageModelStore.selectedModel == nil {
            if defaultOllamaModel != "" {
                languageModelStore.setModel(modelName: defaultOllamaModel)
            } else {
                languageModelStore.setModel(model: languageModelStore.models.first)
            }
        }
    }

    @MainActor
    func sendMessage(prompt: String, model: LanguageModelSD, image: Image?, trimmingMessageId: String?) {
        conversationStore.sendPrompt(
            userPrompt: prompt,
            model: model,
            image: image,
            systemPrompt: systemPrompt,
            trimmingMessageId: trimmingMessageId
        )
    }

    func onConversationTap(_ conversation: ConversationSD) {
        Task {
            try await conversationStore.selectConversation(conversation)
            await languageModelStore.setModel(model: conversation.model)
            Haptics.shared.mediumTap()
        }
#if os(iOS)
        if horizontalSizeClass == .compact {
            withAnimation {
                showMenu.toggle()
            }
        }
#else
        withAnimation {
            showMenu.toggle()
        }
#endif
    }

    @MainActor func onStopGenerateTap() {
        conversationStore.stopGenerate()
        Haptics.shared.mediumTap()
    }

    func onConversationDelete(_ conversation: ConversationSD) {
        Task {
            await Haptics.shared.mediumTap()
            try? await conversationStore.delete(conversation)
        }
    }

    func newConversation() {
        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 0.3)) {
                self.conversationStore.selectedConversation = nil
            }
        }

        Task {
            await Haptics.shared.mediumTap()
            try? await languageModelStore.loadModels()
        }

#if os(iOS)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
#endif
    }

    func copyChat(_ json: Bool) {
        Task {
            let messages = await ConversationStore.shared.messages

            if messages.count == 0 {
                return
            }

            if json {
                let jsonArray = messages.map { message in
                    return [
                        "role": message.role,
                        "content": message.content
                    ]
                }
                let jsonEncoder = JSONEncoder()
                jsonEncoder.outputFormatting = [.withoutEscapingSlashes]

                if let jsonData = try? jsonEncoder.encode(jsonArray),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    Clipboard.shared.setString(jsonString)
                }
            } else {
                let body = messages.map{"\($0.role.capitalized): \($0.content)"}.joined(separator: "\n\n")
                Clipboard.shared.setString(body)
            }
        }
    }

    var body: some View {
        Group {
#if os(macOS) || os(visionOS)
            ChatView(
                selectedConversation: conversationStore.selectedConversation,
                conversations: conversationStore.conversations,
                messages: conversationStore.messages,
                modelsList: languageModelStore.models,
                onMenuTap: toggleMenu,
                onNewConversationTap: newConversation,
                onSendMessageTap: sendMessage,
                onConversationTap:onConversationTap,
                conversationState: conversationStore.conversationState,
                onStopGenerateTap: onStopGenerateTap,
                reachable: appStore.isReachable,
                modelSupportsImages: languageModelStore.supportsImages,
                selectedModel: languageModelStore.selectedModel,
                onSelectModel: languageModelStore.setModel,
                onConversationDelete: onConversationDelete,
                onDeleteDailyConversations: conversationStore.deleteDailyConversations,
                userInitials: userInitials,
                copyChat: copyChat
            )
#else
            if horizontalSizeClass == .regular {
                NavigationSplitView(columnVisibility: $columnVisibility) {
                    SidebarView(
                        selectedConversation: conversationStore.selectedConversation,
                        conversations: conversationStore.conversations,
                        onConversationTap: onConversationTap,
                        onConversationDelete: onConversationDelete,
                        onDeleteDailyConversations: conversationStore.deleteDailyConversations
                    )
                    .navigationTitle("Conversations")
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button(action: newConversation) {
                                Image(systemName: "square.and.pencil")
                            }
                        }
                    }
                } detail: {
                    ChatView(
                        conversation: conversationStore.selectedConversation,
                        messages: conversationStore.messages,
                        modelsList: languageModelStore.models,
                        selectedModel: languageModelStore.selectedModel,
                        onSelectModel: languageModelStore.setModel,
                        onMenuTap: { columnVisibility = .doubleColumn },
                        onNewConversationTap: newConversation,
                        onSendMessageTap: sendMessage,
                        conversationState: conversationStore.conversationState,
                        onStopGenerateTap: onStopGenerateTap,
                        reachable: appStore.isReachable,
                        modelSupportsImages: languageModelStore.supportsImages,
                        userInitials: userInitials
                    )
                }
                .navigationSplitViewStyle(.balanced)
            } else {
                SideBarStack(sidebarWidth: 300, showSidebar: $showMenu, sidebar: {
                    SidebarView(
                        selectedConversation: conversationStore.selectedConversation,
                        conversations: conversationStore.conversations,
                        onConversationTap: onConversationTap,
                        onConversationDelete: onConversationDelete,
                        onDeleteDailyConversations: conversationStore.deleteDailyConversations
                    )
                }) {
                    ChatView(
                        conversation: conversationStore.selectedConversation,
                        messages: conversationStore.messages,
                        modelsList: languageModelStore.models,
                        selectedModel: languageModelStore.selectedModel,
                        onSelectModel: languageModelStore.setModel,
                        onMenuTap: toggleMenu,
                        onNewConversationTap: newConversation,
                        onSendMessageTap: sendMessage,
                        conversationState: conversationStore.conversationState,
                        onStopGenerateTap: onStopGenerateTap,
                        reachable: appStore.isReachable,
                        modelSupportsImages: languageModelStore.supportsImages,
                        userInitials: userInitials
                    )
                }
            }
#endif
        }
        .onChange(of: languageModelStore.models, { _, modelsList in
            if languageModelStore.selectedModel == nil {
                updateSelectedModel()
            }
        })
        .onChange(of: conversationStore.selectedConversation, initial: true, { _, newConversation in
            if let conversation = newConversation {
                languageModelStore.setModel(model: conversation.model)
            } else {
                updateSelectedModel()
            }
        })
    }
}
