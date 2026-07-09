//
//  RetrievalView.swift
//  Enchanted
//
//  Created by Daniel on 3/19/25.
//

import SwiftUI

struct RetrievalView: View {
    @Binding var selectedDatabase: DatabaseSD?
    var databases: [DatabaseSD]
    var documents: [DocumentSD]
    @Binding var indexFilesProgress: Double
    @Binding var indexing: Bool

    var createDatabase: (String) -> ()
    var deleteDatabase: () -> ()
    var indexFiles: () -> ()
    var attachFiles: ([URL]) -> ()


    @State private var retrievalStore = RetrievalStore.shared

    var body: some View {
        VStack (spacing: 20) {
            RetrievalHeaderView { newDatabaseName in
                createDatabase(newDatabaseName)
            }

            if (retrievalStore.databases.isEmpty) {
                DatabaseEmptyView()
            } else {
                DatabaseListView(selectedDatabase: $selectedDatabase, databases: databases, documents: documents, indexFilesProgress: $indexFilesProgress, indexing: $indexing, deleteDatabase: deleteDatabase, indexFiles: indexFiles, attachFiles: attachFiles)
            }
            
#if os(iOS)
            Spacer()
#endif
        }
#if os(macOS) || os(visionOS)
        .frame(minWidth: 700, maxWidth: 800, minHeight: 500)
#endif
    }
}
