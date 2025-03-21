//
//  ToolbarView_macOS.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 10/02/2024.
//

#if os(macOS) || os(visionOS)
import SwiftUI

struct ToolbarView: View {
    var modelsList: [LanguageModelSD]
    var selectedModel: LanguageModelSD?
    var onSelectModel: @MainActor (_ model: LanguageModelSD?) -> ()
    var onNewConversationTap: () -> ()
    var copyChat: (_ json: Bool) -> ()
    
    @State var showRetrieval = false

    private func showRetrievalTap() {
        showRetrieval.toggle()
    }
    
    var body: some View {
        Button(action: showRetrievalTap) {
            HStack(alignment: .center) {
                Image(systemName: "opticaldiscdrive")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 14)
                    .foregroundColor(Color.labelCustom)

                Text("Retrieval")
                    .font(.system(size: 14))
            }
            .padding(.vertical, 10)

        }
        .keyboardShortcut(KeyEquivalent("r"), modifiers: .command)
        .sheet(isPresented: $showRetrieval) {
            Retrieval()
        }

        ModelSelectorView(
            modelsList: modelsList,
            selectedModel: selectedModel,
            onSelectModel: onSelectModel,
            showChevron: false
        )
        .frame(height: 20)
        
        MoreOptionsMenuView(copyChat: copyChat)
        
        Button(action: onNewConversationTap) {
            Image(systemName: "square.and.pencil")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(height: 20)
                .padding(5)
        }
        .buttonStyle(PlainButtonStyle())
        .keyboardShortcut(KeyEquivalent("n"), modifiers: .command)
    }
}

#Preview {
    ToolbarView(
        modelsList: LanguageModelSD.sample,
        selectedModel: LanguageModelSD.sample[0],
        onSelectModel: {_ in},
        onNewConversationTap: {}, 
        copyChat: {_ in}
    )
}

#endif
