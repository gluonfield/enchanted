//
//  AVSpeechSynthesisVoice+Extension.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 27/05/2024.
//

import Foundation
import AVFoundation

extension AVSpeechSynthesisVoice {
    var prettyName: String {
        guard quality == .enhanced || quality == .premium else { return name }

        let qualityString = quality.displayString
        guard !name.lowercased().contains(qualityString.lowercased()) else { return name }
        
        return "\(name) (\(qualityString))"
    }
}

extension AVSpeechSynthesisVoiceQuality {
    var displayString: String {
        switch self {
        case .default: return "Default"
        case .enhanced: return "Enhanced"
        case .premium: return "Premium"
        @unknown default:
            return "Unknown"
        }
    }
}
