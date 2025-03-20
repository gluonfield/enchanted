//
//  SpeechService.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 26/05/2024.
//

import Foundation
import AVFoundation
import SwiftUI


class SpeechSynthesizerDelegate: NSObject, AVSpeechSynthesizerDelegate {
    var onSpeechFinished: (() -> Void)?
    var onSpeechStart: (() -> Void)?

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        onSpeechFinished?()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        onSpeechStart?()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didReceiveError error: Error, for utterance: AVSpeechUtterance, at characterIndex: UInt) {
        print("Speech synthesis error: \(error)")
    }
}

@MainActor final class SpeechSynthesizer: NSObject, ObservableObject {
    static let shared = SpeechSynthesizer()
    private let synthesizer = AVSpeechSynthesizer()
    private let delegate = SpeechSynthesizerDelegate()

    @Published var isSpeaking = false
    @Published var voices: [AVSpeechSynthesisVoice] = []

    override init() {
        super.init()
        synthesizer.delegate = delegate
        fetchVoices()
    }

    static func systemDefaultVoiceIdentifier() -> String {
        // Type system says this might be nil, but documentation says we'll receive
        // the default voice for the system's language & region
        return AVSpeechSynthesisVoice(language: nil)?.identifier ?? ""
    }

    func getVoiceIdentifier() -> String? {
        let voiceIdentifier = UserDefaults.standard.string(forKey: "voiceIdentifier")
        if let voice = voices.first(where: {$0.identifier == voiceIdentifier}) {
            return voice.identifier
        }

        return SpeechSynthesizer.systemDefaultVoiceIdentifier()
    }

    var lastCancelation: (()->Void)? = {}

    func speak(text: String, onFinished: @escaping () -> Void = {}) async {
        guard let voiceIdentifier = getVoiceIdentifier() else {
            print("could not find identifier")
            return
        }

        print("selected", voiceIdentifier)

#if os(iOS)
        let audioSession = AVAudioSession()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: .duckOthers)
            try audioSession.setActive(false)
        } catch let error {
            print("❓", error.localizedDescription)
        }
#endif

        lastCancelation = onFinished
        delegate.onSpeechFinished = {
            withAnimation {
                self.isSpeaking = false
            }
            onFinished()
        }
        delegate.onSpeechStart = {
            withAnimation {
                self.isSpeaking = true
            }
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(identifier: voiceIdentifier)
        utterance.rate = 0.5
        synthesizer.speak(utterance)

        let voices = AVSpeechSynthesisVoice.speechVoices()
        voices.forEach { voice in
            print("\(voice.identifier) - \(voice.name)")
        }
    }

    func stopSpeaking() async {
        withAnimation {
            isSpeaking = false
        }
        lastCancelation?()
        synthesizer.stopSpeaking(at: .immediate)
    }


    func fetchVoices() {
        let currentLanguage: String = AVSpeechSynthesisVoice.currentLanguageCode()
        let voicesByLanguage = Dictionary(grouping: AVSpeechSynthesisVoice.speechVoices(), by: \.language)
        // Filter the list to only include voices for the current language
        // example language codes: en-US, en-GB, fr-FR
            .filter { $0.key.prefix(2) == currentLanguage.prefix(2) }

        let voices = voicesByLanguage.values.reduce(
            // Start with all voices that exactly match current language & locale
            into: voicesByLanguage[currentLanguage, default: []]) { result, voices in
                // add one instance of other voices that match the language, uniquing by name & quality
                for voice in voices {
                    if !result.contains(where: { otherVoice in otherVoice.name == voice.name && otherVoice.quality == voice.quality }) {
                        result.append(voice)
                    }
                }
            }
            .sorted { $0.prettyName.localizedStandardCompare($1.prettyName) == .orderedAscending }

        /// prevent state refresh if there are no new elements
        let diff = self.voices.elementsEqual(voices, by: { $0.identifier == $1.identifier })
        if diff {
            return
        }

        DispatchQueue.main.async {
            self.voices = voices
        }
    }
}
