//
//  EnchantedApp.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 09/12/2023.
//

import SwiftUI
import SwiftData

#if os(macOS)
import KeyboardShortcuts
extension KeyboardShortcuts.Name {
    static let togglePanelMode = Self("togglePanelMode1", default: .init(.k, modifiers: [.command, .option]))
}
#endif

@main
struct EnchantedApp: App {
    @State private var appStore = AppStore.shared
    @State private var retrievalStore = RetrievalStore.shared
#if os(macOS)
    @NSApplicationDelegateAdaptor(PanelManager.self) var panelManager
#endif
    
    var body: some Scene {
        WindowGroup {
            ApplicationEntry()
#if os(macOS)
                .onKeyboardShortcut(KeyboardShortcuts.Name.togglePanelMode, type: .keyDown) {
                    print("heya")
                    panelManager.togglePanel()
                }
#endif
                .onAppear {
#if os(macOS)
                    NSWindow.allowsAutomaticWindowTabbing = false
#endif
                    Task{
                        do {
                            try await retrievalStore.fetchDatabases()
                            retrievalStore.selectDatabase(database: nil)
                        } catch {
                            print("Error fetching databases: \(error)")
                        }
                    }
                }
        }
#if os(macOS)
        .commands {
            Menus()
        }
#endif
#if os(macOS)
        Window("Keyboard Shortcuts", id: "keyboard-shortcuts") {
            KeyboardShortcutsDemo()
        }
#endif
        
#if os(macOS)
#if false
        MenuBarExtra {
            MenuBarControl()
        } label: {
            if let iconName = appStore.menuBarIcon {
                Image(systemName: iconName)
            } else {
                MenuBarControlView.icon
            }
        }
        .menuBarExtraStyle(.window)
#endif
#endif
    }
}

