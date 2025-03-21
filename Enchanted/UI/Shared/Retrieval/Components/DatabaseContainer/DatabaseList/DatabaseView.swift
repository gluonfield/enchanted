//
//  DatabaseView.swift
//  Enchanted
//
//  Created by Daniel on 3/19/25.
//

import SwiftUI

struct DatabaseView: View {
    var documents: [DocumentSD]

    var body: some View {
#if os(macOS) || os(visionOS)
        Table(documents) {
            TableColumn("Path") { document in
                    Text(document.documentUrl?.absoluteString ?? "")
                        .truncationMode(.head)
                        .lineLimit(1)
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

#elseif os(iOS)
        List(documents) { document in
            HStack {
                // Path column
                Text(document.documentUrl?.absoluteString ?? "")
                    .truncationMode(.head)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                // Status column
                Group {
                    if document.status == .indexing {
                        CircularProgressView(progress: document.indexProgress ?? 0)
                            .frame(width: 13, height: 13, alignment: .center)
                    } else {
                        IndexingStatusView(status: document.status)
                    }
                }
                .frame(width: 30, alignment: .center)
            }
        }
        .listStyle(.plain)
#endif
    }
}


#Preview {
    DatabaseView(documents: DocumentSD.sample)
}
