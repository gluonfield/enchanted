//
//  RetrievalStore.swift
//  Enchanted
//
//  Created by Daniel on 3/19/25.
//

import Foundation
import SwiftUI
import Observation

@Observable
final class RetrievalStore {

    static let shared = RetrievalStore()

    private let swiftDataService: SwiftDataService
    private let svdbService: SVDBService
    private let splitter: SimpleTextSplitter
    private let dataLoader: DataLoader
    private let languageModelStore: LanguageModelStore

    var databases: [DatabaseSD] = []
    var selectedDatabase: DatabaseSD?
    var progress: Double?

    // MARK: - Initialization
    private init(
        swiftDataService: SwiftDataService = .shared,
        svdbService: SVDBService = .shared,
        splitter: SimpleTextSplitter = .init(),
        dataLoader: DataLoader = .init(),
        languageModelStore: LanguageModelStore = .shared
    ) {
        self.swiftDataService = swiftDataService
        self.svdbService = svdbService
        self.splitter = splitter
        self.dataLoader = dataLoader
        self.languageModelStore = languageModelStore
    }

    // MARK: - Public Methods
    func createDatabase(name: String, indexPath: String, languageModelName: String) async throws {
        try await swiftDataService.createDatabase(name: name, indexPath: indexPath, languageModelName: languageModelName)
        try await fetchDatabases()
    }

    func deleteDatabase(selectedDatabase: DatabaseSD) async throws {
        try await swiftDataService.deleteDatabase(selectedDatabase: selectedDatabase)
        try await fetchDatabases()
    }

    func fetchDatabases() async throws {
        databases = try await swiftDataService.getDatabases()
    }

    func selectDatabase(database: DatabaseSD?, overWrite: Bool = false) {
        if (self.databases.count == 0) {
            return
        }

        if (self.selectedDatabase == nil || overWrite) {
            self.selectedDatabase = database ?? self.databases[0]
        }
    }

    func attachDocuments(databaseId: UUID, documentPaths: [URL]) async throws {
        guard let database = databases.first(where: { $0.id == databaseId }) else {
            throw RetrievalError.databaseNotFound
        }
        try await swiftDataService.databaseAttachDocuments(db: database, paths: documentPaths)
        try await fetchDatabases()
    }

    func indexDocuments(
        databaseId: UUID,
        progressCallback: @escaping @Sendable (_ progress: Double) -> Void
    ) async throws {

        guard let database = databases.first(where: { $0.id == databaseId }),
              let languageModel = database.model else {
            throw RetrievalError.databaseOrModelNotFound
        }

        let documentsToIndex = database.documents?.filter { $0.status != .completed } ?? []

        guard !documentsToIndex.isEmpty else {
            progressCallback(1.0)
            return
        }

        for (docIndex, document) in documentsToIndex.enumerated() {
            let documentsProgress = Double(docIndex) / Double(documentsToIndex.count)

            try await swiftDataService.updateDocumentStatus(document: document, status: .indexing)

            guard let fileURL = document.documentUrl else {
                try await markDocumentFailed(document)
                continue
            }

            do {
                let fileContents = try readContentsSecurely(from: fileURL)
                let chunks = splitter.split(text: fileContents, maxChunkSize: 512)

                try await indexChunks(
                    chunks,
                    with: languageModel,
                    document: document,
                    documentsProgress: documentsProgress,
                    progressCallback: progressCallback,
                    databaseId: databaseId
                )

                try await swiftDataService.updateDocumentStatus(document: document, status: .completed)

            } catch {
                print("Failed indexing document: \(error.localizedDescription)")
                try await markDocumentFailed(document)
            }
        }

        progressCallback(1.0)
    }

    // MARK: - Private Helper Methods
    private func readContentsSecurely(from url: URL) throws -> String {
        guard url.startAccessingSecurityScopedResource() else {
            throw RetrievalError.cannotAccessURL
        }
        defer { url.stopAccessingSecurityScopedResource() }

        guard let contents = dataLoader.from(url) else {
            throw RetrievalError.failedToLoadData
        }

        return contents
    }

    private func indexChunks(
        _ chunks: [String],
        with languageModel: LanguageModelSD,
        document: DocumentSD,
        documentsProgress: Double,
        progressCallback: @escaping @Sendable (_ progress: Double) -> Void,
        databaseId: UUID
    ) async throws {

        
        for (chunkIndex, chunk) in chunks.enumerated() {
            guard let embedding = await languageModelStore.getEmbedding(model: languageModel, prompt: chunk) else {
                continue
            }

            // add document in selected collection of SVDB
            try await svdbService.addDocument(text: chunk, embedding: embedding)

            let chunkProgress = Double(chunkIndex + 1) / Double(chunks.count)
            let overallProgress = documentsProgress + (chunkProgress / Double(chunks.count))

            DispatchQueue.main.async { [weak document] in
                document?.indexProgress = chunkProgress
            }

            progressCallback(overallProgress)
        }
    }

    private func markDocumentFailed(_ document: DocumentSD) async throws {
        try await swiftDataService.updateDocumentStatus(document: document, status: .failed)
    }
}

// MARK: - Custom Errors
enum RetrievalError: LocalizedError {
    case databaseNotFound
    case databaseOrModelNotFound
    case cannotAccessURL
    case failedToLoadData

    var errorDescription: String? {
        switch self {
        case .databaseNotFound:
            return "The specified database could not be found."
        case .databaseOrModelNotFound:
            return "Database or associated language model not found."
        case .cannotAccessURL:
            return "Unable to access URL securely."
        case .failedToLoadData:
            return "Failed to load data from the specified URL."
        }
    }
}
