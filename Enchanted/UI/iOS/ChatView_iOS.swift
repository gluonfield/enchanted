//
//  ChatView.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 09/12/2023.
//

#if os(iOS)
import SwiftUI
import PhotosUI

struct ChatView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    var conversation: ConversationSD?
    var messages: [MessageSD]
    var modelsList: [LanguageModelSD]
    var onMenuTap: () -> ()
    var onNewConversationTap: () -> ()
    var onSendMessageTap: @MainActor (_ prompt: String, _ model: LanguageModelSD, _ image: Image?, _ trimmingMessageId: String?) -> ()
    var conversationState: ConversationState
    var onStopGenerateTap: @MainActor () -> ()
    var reachable: Bool
    var onSelectModel: @MainActor (_ model: LanguageModelSD?) -> ()
    var userInitials: String

    private var selectedModel: LanguageModelSD?
    @State private var message = ""
    @State private var isRecording = false
    @State private var editMessage: MessageSD?
    @FocusState private var isFocusedInput: Bool
    @StateObject var speechRecognizer = SpeechRecognizer()

    /// Image selection
    @State private var pickerSelectorActive: PhotosPickerItem?
    @State private var selectedImage: Image?
    
    init(
        conversation: ConversationSD? = nil,
        messages: [MessageSD],
        modelsList: [LanguageModelSD],
        selectedModel: LanguageModelSD?,
        onSelectModel: @MainActor @escaping (_ model: LanguageModelSD?) -> (),
        onMenuTap: @escaping () -> Void,
        onNewConversationTap: @escaping () -> Void,
        onSendMessageTap: @MainActor @escaping (_ prompt: String, _ model: LanguageModelSD, _ image: Image?, _ trimmingMessageId: String?) -> Void,
        conversationState: ConversationState,
        onStopGenerateTap: @MainActor @escaping () -> Void,
        reachable: Bool,
        modelSupportsImages: Bool = false,
        userInitials: String
    ) {
        self.conversation = conversation
        self.messages = messages
        self.modelsList = modelsList
        self.onMenuTap = onMenuTap
        self.onNewConversationTap = onNewConversationTap
        self.onSendMessageTap = onSendMessageTap
        self.conversationState = conversationState
        self.onStopGenerateTap = onStopGenerateTap
        self.reachable = reachable
        self.onSelectModel = onSelectModel
        self.selectedModel = selectedModel
        self.userInitials = userInitials
    }
    
    private func onMessageSubmit() {
        Task {
            await Haptics.shared.mediumTap()
            
            guard let selectedModel = selectedModel else { return }
            
            await onSendMessageTap(
                message,
                selectedModel,
                selectedImage,
                editMessage?.id.uuidString
            )
            
            withAnimation {
                isFocusedInput = false
                editMessage = nil
                selectedImage = nil
                message = ""
            }
        }
    }
    
    var header: some View {
        HStack(alignment: .center) {
            if horizontalSizeClass == .compact {
                Button(action: onMenuTap) {
                    Image(systemName: "line.3.horizontal")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22)
                        .foregroundColor(Color(.label))
                }
            }

            Spacer()

            ModelSelectorView(
                modelsList: modelsList,
                selectedModel: selectedModel,
                onSelectModel: onSelectModel
            )
            .showIf(!modelsList.isEmpty)

            Spacer()

            if horizontalSizeClass == .compact {
                Button(action: onNewConversationTap) {
                    Image(systemName: "square.and.pencil")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22)
                        .foregroundColor(Color(.label))
                }
            }
        }
    }
    
    var inputFields: some View {
        HStack(spacing: 10) {
            PhotosPicker(selection: $pickerSelectorActive) {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.foreground)
                    .frame(height: 19)
            }
            .onChange(of: pickerSelectorActive) {
                Task {
                    if let loaded = try? await pickerSelectorActive?.loadTransferable(type: Image.self) {
                        selectedImage = loaded
                    } else {
                        print("Failed")
                    }
                }
            }
            .showIf(selectedModel?.supportsImages ?? false)
            
            
            HStack {
                SelectedImageView(image: $selectedImage)
                
                TextField("Message", text: $message, axis: .vertical)
                    .focused($isFocusedInput)
                    .frame(minHeight: 40)
                    .font(.system(size: 14))
                
                RecordingView(speechRecognizer: speechRecognizer, isRecording: $isRecording.animation()) { transcription in
                    self.message = transcription
                }
            }
            .onChange(of: isFocusedInput, { oldValue, newValue in
                withAnimation {
                    isFocusedInput = newValue
                }
            })
            .padding(.horizontal)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        isRecording ? Color(.systemBlue) : Color(.systemGray2),
                        style: StrokeStyle(lineWidth: isRecording ? 2 : 0.5)
                    )
            )
            
            switch conversationState {
            case .loading:
                SimpleFloatingButton(systemImage: "square.fill", onClick: onStopGenerateTap)
                    .frame(width: 12)
            default:
                SimpleFloatingButton(systemImage: "paperplane.fill", onClick: onMessageSubmit)
                    .frame(width: 18)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // allow focusing text area on greater tap area
            isFocusedInput = true
        }
    }
    
    var body: some View {
        VStack {
            if horizontalSizeClass == .compact {
                header
                    .padding(.horizontal)
            }

            if conversation != nil {
                MessageListView(
                    messages: messages,
                    conversationState: conversationState,
                    userInitials: userInitials,
                    editMessage: $editMessage
                )
            } else {
                EmptyConversaitonView(sendPrompt: {selectedMessage in
                    if let selectedModel = selectedModel {
                        onSendMessageTap(selectedMessage, selectedModel, nil, nil)
                    }
                })
            }
            
            ConversationStatusView(state: conversationState)
                .padding()
            
            if !reachable {
                UnreachableAPIView()
            }
            
            inputFields
                .padding(.horizontal)
            
        }
        .padding(.bottom, 5)
        .onChange(of: editMessage, initial: false) { _, newMessage in
            if let newMessage = newMessage {
                message = newMessage.content
                isFocusedInput = true
            }
        }
        .toolbar {
            if horizontalSizeClass == .regular {
                ToolbarItem(placement: .principal) {
                    ModelSelectorView(
                        modelsList: modelsList,
                        selectedModel: selectedModel,
                        onSelectModel: onSelectModel
                    )
                    .showIf(!modelsList.isEmpty)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: onNewConversationTap) {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
        }
    }
}

#Preview {
    ChatView(
        conversation: ConversationSD.sample[0],
        messages: MessageSD.sample,
        modelsList: LanguageModelSD.sample,
        selectedModel: LanguageModelSD.sample[0],
        onSelectModel: {_ in },
        onMenuTap: {},
        onNewConversationTap: { },
        onSendMessageTap: {_,_,_,_    in},
        conversationState: .loading,
        onStopGenerateTap: {},
        reachable: false,
        modelSupportsImages: true, 
        userInitials: "AM"
    )
}

#Preview {
    ChatView(
        conversation: nil,
        messages: [],
        modelsList: LanguageModelSD.sample,
        selectedModel: LanguageModelSD.sample[0],
        onSelectModel: {_ in},
        onMenuTap: {},
        onNewConversationTap: { },
        onSendMessageTap: {_,_,_,_    in},
        conversationState: .completed,
        onStopGenerateTap: {},
        reachable: true,
        modelSupportsImages: true,
        userInitials: "AM"
    )
}
#endif
