//
//  DatabaseListView.swift
//  Enchanted
//
//  Created by Daniel on 3/19/25.
//

import SwiftUI

struct DatabaseListView: View {
    @Binding var selectedDatabase: DatabaseSD?
    var databases: [DatabaseSD]
    var documents: [DocumentSD]
    @Binding var indexFilesProgress: Double
    @Binding var indexing: Bool

    var deleteDatabase: () -> ()
    var indexFiles: () -> ()
    var attachFiles: ([URL]) -> ()

    var body: some View {
        HStack {
            Picker(selection: $selectedDatabase) {
                ForEach(databases, id:\.self) { database in
                    Text("\(database.name) (\(database.model?.name ?? "Unknown"))").tag(Optional(database))
                }
            } label: {
#if os(macOS) || os(visionOS)
                Text("Database:")
                    .font(.system(size: 14))
                    .fontWeight(.regular)
#endif
            }
#if os(macOS) || os(visionOS)
            .frame(maxWidth: 300)
#endif

            DeleteDatabaseButton {
                deleteDatabase()
            }

            Spacer()
        }
#if os(macOS) || os(visionOS)
        .padding(.horizontal, 20)
#elseif os(iOS)
        .padding(.leading, 8)
#endif

        DatabaseView(documents: documents)

        HStack {
            Spacer()

            ImportFilesButton { urls in
                attachFiles(urls)
            }

            Button("Index files") {
                indexFiles()
            }
            .buttonStyle(BorderedProminentButtonStyle())
        }
        .padding(.horizontal)

        HStack {
            ProgressView(value: indexFilesProgress)
        }
        .opacity(indexing ? 1 : 0)
        .padding(.horizontal)
    }
}
