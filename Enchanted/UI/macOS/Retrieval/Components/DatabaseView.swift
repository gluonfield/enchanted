//
//  DatabaseView.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 24/02/2024.
//

import SwiftUI

struct DatabaseView: View {
    var documents: [DocumentSD]
    
    var body: some View {
        Table(documents) {
            TableColumn("Path") { document in
                    Text(document.documentUrl?.absoluteString ?? "")
                        .truncationMode(.head)
            }
            .alignment(.trailing)
            TableColumn("Status") { document in
                HStack {
                    Spacer()
                    Group {
                        if document.status == .indexing {
                            CircularProgressView(progress: document.indexProgress ?? 0)
                                .frame(width: 13, height: 13, alignment: .center)
                        } else {
                            IndexingStatusView(status: document.status)
                        }
                    }
                    Spacer()
                }
            }
            .width(min: 50, max: 50)
        }
    }
}

#Preview {
    DatabaseView(documents: DocumentSD.sample)
}
