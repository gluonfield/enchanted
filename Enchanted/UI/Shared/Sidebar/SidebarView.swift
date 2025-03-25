//
//  SidebarView.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 10/12/2023.
//

import SwiftUI

struct SidebarView: View {
    @Environment(\.openWindow) var openWindow
    var selectedConversation: ConversationSD?
    var conversations: [ConversationSD]
    var onConversationTap: (_ conversation: ConversationSD) -> ()
    var onConversationDelete: (_ conversation: ConversationSD) -> ()
    var onDeleteDailyConversations: (_ date: Date) -> ()
    @State var showSettings = false
    @State var showRetrieval = false
    @State var showCompletions = false
    @State var showKeyboardShortcutas = false
    
    private func onSettingsTap() {
        Task {
            showSettings.toggle()
            await Haptics.shared.mediumTap()
        }
    }
    
    private func showRetrievalTap() {
        showRetrieval.toggle()
    }

    var body: some View {
        VStack {
            ScrollView() {
                ConversationHistoryList(
                    selectedConversation: selectedConversation,
                    conversations: conversations,
                    onTap: onConversationTap,
                    onDelete: onConversationDelete,
                    onDeleteDailyConversations: onDeleteDailyConversations
                )
            }
            .scrollIndicators(.never)
            
            Divider()
            
#if os(macOS)
            SidebarButton(title: "Completions", image: "textformat.abc", onClick: {showCompletions.toggle()})
            
            SidebarButton(title: "Shortcuts", image: "keyboard.fill", onClick: {showKeyboardShortcutas.toggle()})
#endif
            
            SidebarButton(title: "Retrieval", image: "tray.fill", onClick: showRetrievalTap)
            
            SidebarButton(title: "Settings", image: "gearshape.fill", onClick: onSettingsTap)
            
        }
        .padding()
#if os(macOS)
        .focusedSceneValue(\.showSettings, $showSettings)
#endif
        .sheet(isPresented: $showSettings) {
            Settings()
        }
        .sheet(isPresented: $showRetrieval) {
            Retrieval()
        }
#if os(macOS)
        .sheet(isPresented: $showCompletions) {
            CompletionsEditor()
        }
        .sheet(isPresented: $showKeyboardShortcutas) {
            KeyboardShortcutsDemo()
        }
#endif
        
    }
}

#Preview {
    SidebarView(selectedConversation: ConversationSD.sample[0], conversations: ConversationSD.sample, onConversationTap: {_ in}, onConversationDelete: {_ in}, onDeleteDailyConversations: {_ in})
}
