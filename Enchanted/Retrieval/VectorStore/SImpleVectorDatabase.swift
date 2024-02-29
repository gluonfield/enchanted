//
//  SimpleVectorDatabase.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 26/02/2024.
//

import Foundation
import Accelerate
import Collections


class SimpleVectorStore: VectorDatabase {
    private var vectors: [VectorDocument] = []
    
    func upsert(id: UUID? = nil, embedding: [Double], text: String) {
        var v = VectorDocument(id: UUID(), vector: embedding, text: text, metadata: [:])
        if let id = id {
            v.id = id
        }
        vectors.append(v)
    }
    
    func search(_ embedding: [Double], topK: Int = 3) -> [VectorDocument] {
        let indices = findTopKVectorIndices(referenceVector: embedding, vectors: vectors.map{$0.vector}, topK: topK)
        return indices.compactMap { index in
            vectors.indices.contains(index) ? vectors[index] : nil
        }
    }
    
    func findTopKVectorIndices(referenceVector: [Double], vectors: [[Double]], topK: Int) -> [Int] {
        var topKIndices: [(index: Int, dotProduct: Double)] = []
        
        for (index, vector) in vectors.enumerated() {
            let dotProduct = zip(referenceVector, vector).reduce(0) { $0 + $1.0 * $1.1 }
            if topKIndices.count < topK {
                topKIndices.append((index, dotProduct))
            } else {
                if let minElement = topKIndices.min(by: { $0.dotProduct < $1.dotProduct }) {
                    if dotProduct > minElement.dotProduct {
                        if let minIndex = topKIndices.firstIndex(where: { $0.dotProduct == minElement.dotProduct }) {
                            topKIndices[minIndex] = (index, dotProduct)
                        }
                    }
                }
            }
        }
        
        topKIndices.sort(by: { $0.dotProduct > $1.dotProduct })
        return topKIndices.map { $0.index }
    }
    
}
