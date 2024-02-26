//
//  SwiftDataService.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 10/12/2023.
//

import Foundation
import SwiftData

final actor SwiftDataService: ModelActor {
    let modelContainer: ModelContainer
    let modelExecutor: ModelExecutor
    private let modelContext: ModelContext
    
    static let shared = SwiftDataService()
    
    init() {
        let sharedModelContainer: ModelContainer = {
            let schema = Schema([
                LanguageModelSD.self,
                ConversationSD.self,
                MessageSD.self,
                DatabaseSD.self,
                DocumentSD.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }()
        
        self.modelContext = ModelContext(sharedModelContainer)
        self.modelContext.autosaveEnabled = false
        modelContainer = sharedModelContainer
        modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
    }
}

// MARK: - Language Models
extension SwiftDataService {
    func fetchModels() throws -> [LanguageModelSD] {
        let sortDescriptor = SortDescriptor(\LanguageModelSD.name)
        let fetchDescriptor = FetchDescriptor<LanguageModelSD>(sortBy: [sortDescriptor])
        let models = try modelContext.fetch(fetchDescriptor)
        
        return models
    }
    
    func saveModels(models: [LanguageModelSD]) throws {
        for model in models {
            modelContext.insert(model)
        }
        
        try modelContext.saveChanges()
    }
    
    func deleteModels() throws {
        try modelContext.delete(model: LanguageModelSD.self)
        try modelContext.saveChanges()
    }
}

// MARK: - Conversations
extension SwiftDataService {
    func createConversation(_ conversation: ConversationSD) throws {
        self.modelContext.insert(conversation)
        try modelContext.saveChanges()
    }
    
    func renameConversation(_ conversation: ConversationSD) throws {
        try modelContext.saveChanges()
    }
    
    func deleteConversation(_ conversation: ConversationSD) throws {
        self.modelContext.delete(conversation)
        try modelContext.saveChanges()
    }
    
    func updateConversation(_ conversation: ConversationSD) throws {
        conversation.updatedAt = .now
        try modelContext.saveChanges()
    }
    
    func fetchConversations() throws -> [ConversationSD] {
        let sortDescriptor = SortDescriptor(\ConversationSD.updatedAt, order: .reverse)
        let fetchDescriptor = FetchDescriptor<ConversationSD>(sortBy: [sortDescriptor])
        return try modelContext.fetch(fetchDescriptor)
    }
    
    func getConversation(_ conversationId: UUID) throws -> ConversationSD? {
        let predicate = #Predicate<ConversationSD>{ $0.id == conversationId }
        let fetchDescriptor = FetchDescriptor<ConversationSD>(predicate: predicate)
        let conversations = try modelContext.fetch(fetchDescriptor)
        return conversations.first
    }
    
    func deleteConversations() throws {
        try modelContext.delete(model: ConversationSD.self)
        try modelContext.saveChanges()
    }
    
    func deleteConversations(_ date: Date) throws {
        let predicate = #Predicate<ConversationSD>{ $0.createdAt >=  date && $0.createdAt <= date}
        try modelContext.delete(model: ConversationSD.self, where: predicate)
    }
}


// MARK: - Messages
extension SwiftDataService {
    func fetchMessages(_ conversationId: UUID) throws -> [MessageSD] {
        let predicate = #Predicate<MessageSD>{ $0.conversation?.id == conversationId }
        let sortDescriptor = SortDescriptor(\MessageSD.createdAt)
        let fetchDescriptor = FetchDescriptor<MessageSD>(predicate: predicate, sortBy: [sortDescriptor])
        return try modelContext.fetch(fetchDescriptor)
    }
    
    func updateMessage(_ message: MessageSD) throws {
        try modelContext.saveChanges()
    }
    
    func createMessage(_ mesasge: MessageSD) throws {
        self.modelContext.insert(mesasge)
        try modelContext.saveChanges()
    }
}

// MARK: - Database
extension SwiftDataService {
    func createDatabase(name: String, indexPath: String, languageModelName: String) throws {
        let db = DatabaseSD(name: name, indexPath: indexPath)
        guard let llm = try? fetchModels().filter({$0.name == languageModelName}).first else { return }
        db.model = llm
        self.modelContext.insert(db)
        try modelContext.saveChanges()
    }
    
    func getDatabases() throws -> [DatabaseSD] {
        let sortDescriptor = SortDescriptor(\DatabaseSD.updatedAt, order: .reverse)
        let fetchDescriptor = FetchDescriptor<DatabaseSD>(sortBy: [sortDescriptor])
        return try modelContext.fetch(fetchDescriptor)
    }
    
    func databaseAttachDocuments(db: DatabaseSD, paths: [URL]) throws {
        let docs = paths.map({DocumentSD(documentUrl: $0, status: .indexing)})
        db.documents = docs
        db.updatedAt = .now
        try modelContext.saveChanges()
    }
}

// MARK: - General
extension SwiftDataService {
    func deleteEverything() throws {
        try modelContext.delete(model: ConversationSD.self)
        try modelContext.delete(model: LanguageModelSD.self)
        try modelContext.delete(model: MessageSD.self)
        try modelContext.saveChanges()
    }
}
