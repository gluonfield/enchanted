//
//  TextMessageInput.swift
//  Enchanted
//
//  Created by Daniel on 3/19/25.
//

#if os(macOS) || os(visionOS)
import SwiftUI

struct TextMessageInput: View {
    @Binding var message: String
    @Binding var fileDropActive: Bool
    var sendMessage: () -> ()
    var isFocusedInput: FocusState<Bool>.Binding

#if os(macOS)
    @Binding var selectedImage: Image?

    private func updateSelectedImage(_ image: Image) {
        selectedImage = image
    }

    var hotkeys: [HotkeyCombination] {
        [
            HotkeyCombination(keyBase: [.command], key: .kVK_ANSI_V) {
                if let nsImage = Clipboard.shared.getImage() {
                    let image = Image(nsImage: nsImage)
                    updateSelectedImage(image)
                }
            }
        ]
    }
#endif

    var body: some View {
        TextField("Message", text: $message.animation(.easeOut(duration: 0.3)), axis: .vertical)
            .focused(isFocusedInput)
            .font(.system(size: 14))
            .frame(maxWidth:.infinity, minHeight: 40)
            .clipped()
            .textFieldStyle(.plain)
#if os(macOS)
            .onSubmit {
                if NSApp.currentEvent?.modifierFlags.contains(.shift) == true {
                    message += "\n"
                } else {
                    sendMessage()
                }
            }
#endif
        /// TextField bypasses drop area
            .allowsHitTesting(!fileDropActive)
#if os(macOS)
            .addCustomHotkeys(hotkeys)
#endif
            .padding(.trailing, 80)
    }
}
#endif
