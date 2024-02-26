//
//  TextSplitter.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 24/02/2024.
//

import Foundation

protocol TextBatchSplitter {
    func split(text: String, maxChunkSize: Int) -> [String]
}

struct SimpleTextSplitter: TextBatchSplitter {
    func split(text: String, maxChunkSize: Int) -> [String] {
        var chunks: [String] = []
        var currentChunk = ""
        
        let separators = ["\n\n", "\n", ".", " ", ""]
        
        for separator in separators {
            let paragraphs = text.components(separatedBy: separator)
            let chunkOverflow = chunkOverflows(chunks: paragraphs, maxChunkSize: maxChunkSize)
            
            if chunkOverflow {
                print("overflows for \(separator)")
                continue
            }
            
            for paragraph in paragraphs {
                // Check if adding the next paragraph exceeds the max chunk size
                if currentChunk.count + paragraph.count + 2 > maxChunkSize { // +2 for the paragraph break
                    // If the current chunk is not empty, add it to the chunks array
                    if !currentChunk.isEmpty {
                        chunks.append(currentChunk)
                        currentChunk = ""
                    }
                    // If the paragraph itself exceeds the maxChunkSize, split it further (simple split, could be refined)
                    if paragraph.count > maxChunkSize {
                        let startIndex = paragraph.startIndex
                        let endIndex = paragraph.index(startIndex, offsetBy: maxChunkSize)
                        chunks.append(String(paragraph[startIndex..<endIndex]))
                        // Here, we only handle a single overflow; a more complex method could loop to handle multiple overflows
                    } else {
                        // Start a new chunk with the current paragraph
                        currentChunk = paragraph
                    }
                } else {
                    if !currentChunk.isEmpty {
                        currentChunk += "\n\n"
                    }
                    currentChunk += paragraph
                }
            }
            
            // Add the last chunk if it's not empty
            if !currentChunk.isEmpty {
                chunks.append(currentChunk)
            }
            
            return chunks
        }
        
        print("could not chunk anything")
        return []
    }
    
    private func chunkOverflows(chunks: [String], maxChunkSize: Int) -> Bool {
        for chunk in chunks {
            if chunk.count > maxChunkSize {
                return true
            }
        }
        return false
    }
}
