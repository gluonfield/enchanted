//
//  ChatMessageView.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 09/12/2023.
//

import SwiftUI
import MarkdownUI
import ActivityIndicatorView
import Splash

struct ChatMessageView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var speechSynthesizer = SpeechSynthesizer.shared
    var message: MessageSD
    var showLoader: Bool = false
    var userInitials: String
    @Binding var editMessage: MessageSD?
    @State private var mouseHover = false
    @State private var isSpeaking = false
    @State private var showThink = false
    
    var roleName: String  {
        let userInitialsNotEmpty = userInitials != "" ? userInitials : "AM"
        return message.role == "user" ? userInitialsNotEmpty.uppercased() : "AI"
    }
    
    var image: Image? {
        message.image != nil ? Image(data: message.image!) : nil
    }
    
    private var codeHighlightColorScheme: Splash.Theme {
        switch colorScheme {
        case .dark:
            return .wwdc17(withFont: .init(size: 16))
        default:
            return .sunset(withFont: .init(size: 16))
        }
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Group {
                    if message.role == "user" {
                        Spacer()
                    } else {
                        if showLoader {
                            ActivityIndicatorView(isVisible: .constant(true), type: .rotatingDots(count: 5))
                                .frame(width: 24, height: 24)
                                .rotationEffect(.degrees(90))
                        } else {
                            Image("logo-nobg")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                    }
                }
                .offset(CGSize(width: 0, height: 6))
                
                VStack(alignment: .leading) {
                    if message.hasThink {
                        HStack(spacing: 10.0, content: {
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 10)
                            if showThink {
                                if let think = message.think {
                                    Markdown(think)
#if os(macOS)
                                        .textSelection(.enabled)
#endif
                                        .markdownCodeSyntaxHighlighter(.splash(theme: codeHighlightColorScheme))
                                        .markdownTheme(MarkdownColours.enchantedTheme)
                                }
                            } else {
                                if message.thinkComplete {
                                    Text("Thought for a few seconds.")
                                } else {
                                    Text("Thinking...")
                                }
                            }
                        }).fixedSize(horizontal: false, vertical: true)
                          .padding(.init(top: 0, leading: 0, bottom: 10, trailing: 0))
                          .onTapGesture {
                              showThink = !showThink
                          }
                    }
                    if let content = message.realContent {
                        Markdown(content)
    #if os(macOS)
                            .textSelection(.enabled)
    #endif
                            .markdownCodeSyntaxHighlighter(.splash(theme: codeHighlightColorScheme))
                            .markdownTheme(MarkdownColours.enchantedTheme)
                    }
                    
                    if let uiImage = image {
                        uiImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                        
                    }
                }
                .if(message.role == "user", transform: { v in
                    v.padding()
                        .background(RoundedRectangle(cornerRadius: 25).fill(.regularMaterial))
                })
                
                if message.role != "user" {
                    Spacer()
                }
            }
#if os(macOS)
            HStack(spacing: 0) {
                /// Copy button
                Button(action: {Clipboard.shared.setString(message.content)}) {
                    Image(systemName: "doc.on.doc")
                        .padding(8)
                }
                .buttonStyle(GrowingButton())
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                /// Play button
                Button(action: {
                    Task {
                        await speechSynthesizer.stopSpeaking()
                        await speechSynthesizer.speak(text: message.content, onFinished: { isSpeaking = false })
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                            isSpeaking = true
                        }
                    }
                }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .frame(width: 10)
                        .padding(8)
                }
                .buttonStyle(GrowingButton())
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .showIf(!isSpeaking)
                
                /// Stop button
                Button(action: {
                    Task {
                        isSpeaking = false
                        await speechSynthesizer.stopSpeaking()
                    }
                }) {
                    Image(systemName: "speaker.slash.fill")
                        .frame(width: 10)
                        .padding(8)
                }
                .buttonStyle(GrowingButton())
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .showIf(isSpeaking)
                
                /// Edit button
                Button(action: {editMessage = message}) {
                    Image(systemName: "pencil")
                        .padding(8)
                }
                .buttonStyle(GrowingButton())
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .showIf(message.role == "user")
            }
            .opacity(mouseHover ? 1 : 0.0001)
            
#endif
        }
#if os(macOS)
        .onHover { over in
            withAnimation(.easeInOut(duration: 0.3)) {
                mouseHover = over
            }
        }
#endif
    }
}

#Preview {
    VStack {
        ChatMessageView(message: MessageSD.sample[0], userInitials: "AM", editMessage: .constant(nil))
            .previewLayout(.sizeThatFits)
        
        ChatMessageView(message: MessageSD.sample[1], userInitials: "AM", editMessage: .constant(nil))
            .previewLayout(.sizeThatFits)
        
        ChatMessageView(message: MessageSD(content: "```python \nprint(5+5)\n```", role: "ai"), showLoader: true, userInitials: "AM", editMessage: .constant(nil))
            .previewLayout(.sizeThatFits)
    }
}
