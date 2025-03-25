//
//  InputFields_macOS.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 10/02/2024.
//

#if os(macOS) || os(visionOS)
import SwiftUI

struct InputFieldsView: View {
    @Binding var message: String
    var conversationState: ConversationState
    var onStopGenerateTap: @MainActor () -> Void
    var selectedModel: LanguageModelSD?
    var onSendMessageTap: @MainActor (_ prompt: String, _ model: LanguageModelSD, _ image: Image?, _ trimmingMessageId: String?,_ documentUsage: Bool?) -> ()
    @Binding var editMessage: MessageSD?
    @State var isRecording = false
    
    @State private var selectedImage: Image?
    @State private var fileDropActive: Bool = false
    @State private var fileSelectingActive: Bool = false
    @FocusState private var isFocusedInput: Bool
    
    @State private var documentUsage: Bool = false
    
    @MainActor private func sendMessage() {
        guard let selectedModel = selectedModel else { return }
        
        onSendMessageTap(
            message,
            selectedModel,
            selectedImage,
            editMessage?.id.uuidString,
            documentUsage
        )
        withAnimation {
            isRecording = false
            isFocusedInput = false
            editMessage = nil
            selectedImage = nil
            message = ""
        }
    }
    
    var body: some View {
        HStack(spacing: 20) {
            if let image = selectedImage {
                RemovableImage(
                    image: image,
                    onClick: {selectedImage = nil},
                    height: 70
                )
                .padding(5)
            }
            
            ZStack(alignment: .trailing) {
#if os(macOS)
                TextMessageInput(message: $message, fileDropActive: $fileDropActive, sendMessage: sendMessage, isFocusedInput: $isFocusedInput, selectedImage: $selectedImage)
#elseif os(visionOS)
                TextMessageInput(message: $message, fileDropActive: $fileDropActive, sendMessage: sendMessage, isFocusedInput: $isFocusedInput)
#endif
                HStack {
                    UseDocumentView(documentUsage: $documentUsage)

                    AudioMessageInput(message: $message, conversationState: conversationState, onStopGenerateTap: onStopGenerateTap, isRecording: $isRecording, selectedImage: $selectedImage, fileSelectingActive: $fileSelectingActive, sendMessage: sendMessage)
                }
            }
            
        }
        .transition(.slide)
        .padding(.horizontal)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    Color.gray2Custom,
                    style: StrokeStyle(lineWidth: 1)
                )
        )
        .overlay {
            if fileDropActive {
                DragAndDrop(cornerRadius: 10)
            }
        }
        .animation(.default, value: fileDropActive)
        .onDrop(of: [.image], isTargeted: $fileDropActive.animation(), perform: { providers in
            guard let provider = providers.first else { return false }
            _ = provider.loadDataRepresentation(for: .image) { data, error in
                if error == nil, let data {
                    selectedImage = Image(data: data)
                }
            }
            
            return true
        })
        .contentShape(Rectangle())
        .onTapGesture {
            // allow focusing text area on greater tap area
            isFocusedInput = true
        }
    }
}

#Preview {
    @Previewable @State var message = ""
    
    InputFieldsView(
        message: $message,
        conversationState: .completed,
        onStopGenerateTap: {},
        onSendMessageTap: {_, _, _, _, _  in},
        editMessage: .constant(nil)
    )
}
#endif
