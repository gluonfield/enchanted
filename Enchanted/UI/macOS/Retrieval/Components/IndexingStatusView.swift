//
//  IndexingStatusView.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 28/02/2024.
//

import SwiftUI

struct IndexingStatusView: View {
    var status: DocumentIndexStatus
    var body: some View {
        switch status {
        case .indexing: return Image(systemName: "hourglass.circle").foregroundColor(.indigo)
        case .completed: return Image(systemName: "checkmark.circle").foregroundColor(.green)
        case .notStarted: return Image(systemName: "hourglass.circle").foregroundColor(.yellow)
        case .failed: return Image(systemName: "x.circle").foregroundColor(.red)
        }
    }
}

#Preview {
    HStack {
        IndexingStatusView(status: .indexing)
        IndexingStatusView(status: .completed)
        IndexingStatusView(status: .notStarted)
        IndexingStatusView(status: .failed)
    }
    .padding()
}
