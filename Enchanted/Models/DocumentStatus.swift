//
//  DocumentStatus.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 24/02/2024.
//

import Foundation
import SwiftUI

enum DocumentIndexStatus: String, Codable {
    case indexing
    case completed
    case notStarted
    case failed
    
    var humanReadable: String {
        switch self {
        case .indexing: "Indexing"
        case .completed: "Completed"
        case .notStarted: "Not Started"
        case .failed: "Failed"
        }
    }
}

// MARK: - Icon extension
extension DocumentIndexStatus {
    var icon: some View {
        switch self {
        case .indexing: return Image(systemName: "hourglass.circle").foregroundColor(.indigo)
        case .completed: return Image(systemName: "checkmark.circle").foregroundColor(.green)
        case .notStarted: return Image(systemName: "hourglass.circle").foregroundColor(.yellow)
        case .failed: return Image(systemName: "circle.slash").foregroundColor(.red)
        }
    }
}


