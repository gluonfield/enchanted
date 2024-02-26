//
//  Retrieval.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 24/02/2024.
//

import SwiftUI

struct Retrieval: View {
    @State var retrievalStore = RetrievalStore.shared
    @State var languageModelStore = LanguageModelStore.shared
    
    func createDatabase(name: String, languageModelName: String) {
        Task {
            try? await retrievalStore.createDatabase(name: name, indexPath: "./www.com", languageModelName: languageModelName)
        }
    }
    
    func onAddDocuments(databaseId: UUID, paths: [URL]) {
        Task {
            try? await retrievalStore.attachDocuments(databaseId: databaseId, documentPaths: paths)
        }
    }
    
    func indexDocuments(databaseId: UUID) {
        Task {
            try? await retrievalStore.indexDocuments(databaseId: databaseId)
        }
    }
    
    var body: some View {
        RetrievalView(
            databases: retrievalStore.databases,
            selectedDatabase: $retrievalStore.selectedDatabase,
            languageModels: languageModelStore.models, 
            documents: retrievalStore.selectedDatabase?.documents ?? [],
            onCreateDatabase: createDatabase,
            onAddDocuments: onAddDocuments,
            onIndexDocuments: indexDocuments
        )
    }
}
