//
//  AudioMessageInput.swift
//  Enchanted
//
//  Created by Daniel on 3/19/25.
//

#if os(macOS) || os(visionOS)
import SwiftUI

struct AudioMessageInput: View {
    @Binding var message: String
    var conversationState: ConversationState
    var onStopGenerateTap: @MainActor () -> Void
    var selectedModel: LanguageModelSD?
    @Binding var isRecording: Bool
    @Binding var selectedImage: Image?
    @Binding var fileSelectingActive: Bool
    var sendMessage: () -> ()

    var body: some View {
        HStack {
            RecordingView(isRecording: $isRecording.animation()) { transcription in
                withAnimation(.easeIn(duration: 0.3)) {
                    self.message = transcription
                }
            }

            SimpleFloatingButton(systemImage: "photo.fill", onClick: { fileSelectingActive.toggle() })
                .showIf(selectedModel?.supportsImages ?? false)
                .fileImporter(isPresented: $fileSelectingActive,
                              allowedContentTypes: [.png, .jpeg, .tiff],
                              onCompletion: { result in
                    switch result {
                    case .success(let url):
                        guard url.startAccessingSecurityScopedResource() else { return }
                        if let imageData = try? Data(contentsOf: url) {
                            selectedImage = Image(data: imageData)
                        }
                        url.stopAccessingSecurityScopedResource()
                    case .failure(let error):
                        print(error)
                    }
                })


            Group {
                switch conversationState {
                case .loading:
                    SimpleFloatingButton(systemImage: "square.fill", onClick: onStopGenerateTap)
                default:
                    SimpleFloatingButton(systemImage: "paperplane.fill", onClick: { Task { sendMessage() } })
                        .showIf(!message.isEmpty)
                }
            }

        }
    }
}
#endif
