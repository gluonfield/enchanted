//
//  Retrieval.swift
//  Enchanted
//
//  Created by Daniel on 3/19/25.
//

import SwiftUI
import SVDB

struct Retrieval: View {
    @State private var retrievalStore = RetrievalStore.shared
    @State private var languageModelStore = LanguageModelStore.shared
    @State private var svdb = SVDB.shared

    @State private var indexFilesProgress: Double = 0
    @State private var indexing: Bool = false

    // Create Database
    private func createDatabase(databaseName: String, languageModelName: String) {
        Task {
            try? await retrievalStore.createDatabase(name: databaseName, indexPath: "./www.com", languageModelName: languageModelName)
            retrievalStore.selectDatabase(database: nil, overWrite: true)
        }
    }

    private func handleCreateDatabase(newDatabaseName: String) {
        guard let selectedLanguageModel = languageModelStore.selectedModel else { return }

        createDatabase(databaseName: newDatabaseName, languageModelName: selectedLanguageModel.name)
    }

    // Delete Database
    private func deleteDatabase(selectedDatabase: DatabaseSD) {
        Task {
            try? await retrievalStore.deleteDatabase(selectedDatabase: selectedDatabase)
            retrievalStore.selectDatabase(database: nil, overWrite: true)
            
            svdb.releaseCollection(selectedDatabase.id.uuidString)
        }
    }

    private func handleDeleteDatabase() {
        guard let selectedDatabase = retrievalStore.selectedDatabase else { return }
        deleteDatabase(selectedDatabase: selectedDatabase)
    }

    // Attach Files
    private func attachFiles(databaseId: UUID, paths: [URL]) {
        Task {
            try? await retrievalStore.attachDocuments(databaseId: databaseId, documentPaths: paths)
        }
    }

    private func handleAttachFiles(urls: [URL]) {
        var files = [URL]()

        for url in urls {
            guard url.startAccessingSecurityScopedResource() else {
                print("Couldn't access URL: \(url)")
                continue
            }

            defer { url.stopAccessingSecurityScopedResource() } // Ensure we stop accessing when done

            files.append(url)
        }

        guard let selectedDatabase = retrievalStore.selectedDatabase else { return }
        attachFiles(databaseId: selectedDatabase.id, paths: files)
    }

    // Index Files
    private func indexFiles(databaseId: UUID) {
        Task {
            do {
                indexing.toggle()
                try await retrievalStore.indexDocuments(databaseId: databaseId) { progress in
                    withAnimation {
                        self.indexFilesProgress = progress
                    }
                }
                indexFilesProgress = 0
                indexing.toggle()
            } catch {
                print("Error indexing documents: \(error)")
            }
        }
    }

    private func handleIndexFiles() {
        guard let selectedDatabase = retrievalStore.selectedDatabase, let _ = languageModelStore.selectedModel else { return }

        indexFiles(databaseId: selectedDatabase.id)
    }



    var body: some View {
        RetrievalView(selectedDatabase: $retrievalStore.selectedDatabase, databases: retrievalStore.databases, documents: retrievalStore.selectedDatabase?.documents ?? [], indexFilesProgress: $indexFilesProgress, indexing: $indexing, createDatabase: handleCreateDatabase(newDatabaseName:), deleteDatabase: handleDeleteDatabase, indexFiles: handleIndexFiles, attachFiles: handleAttachFiles(urls:))
    }
}
