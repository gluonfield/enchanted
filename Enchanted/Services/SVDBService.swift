//
//  SVDBService.swift
//  Enchanted
//
//  Created by Now or Never on 3/24/25.
//

import SVDB
import Foundation

final actor SVDBService {
    var svdb: SVDB
    var collection: Collection?
    
    static let shared = SVDBService()
    
    private init() {
        self.svdb = SVDB.shared
    }
    
    func createCollection(databaseId: UUID) async throws -> Collection {
        do {
            let newCollection = try svdb.collection("\(databaseId)")
            self.collection = newCollection
            return newCollection
        } catch let error as SVDBError {
            if(error == .collectionAlreadyExists) {
                if let collection = self.collection {
                    return collection
                }
            }
            throw error
        }  catch {
            throw error
        }
    }
    
    func releaseCollection(_ collectionName: String) async throws -> Void {
        svdb.releaseCollection(collectionName)
    }
    
    func addDocument(text: String, embedding: [Double]) throws -> Void {
        guard let collection = collection else {
            throw NSError(
                domain: "SVDBService",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Collection not initialized"]
            )
        }
        
        collection.addDocument(text: text, embedding: embedding)
    }
    
    func search(query: [Double], databaseId: UUID) -> String {
        do {
            let collection = try svdb.collection(databaseId.uuidString)
            return searchInCollection(collection, with: query)
        } catch let error as SVDBError {
            if(error == .collectionAlreadyExists) {
                guard let collection = collection else {
                    print("Collection not initialized")
                    return ""
                }
                return searchInCollection(collection, with: query)
            }
        } catch {
            print("Failed to load or search collection:", error)
        }
        return ""
    }
    
    private func searchInCollection(_ collection: Collection, with query: [Double]) -> String {
        if let firstResult = collection.search(query: query, num_results: 1).first {
            print("Result found: \(firstResult.text)")
            return firstResult.text
        } else {
            print("No result found.")
            return ""
        }
    }
}
