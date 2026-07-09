//
//  TextSplitter.swift
//  Enchanted
//
//  Created by Daniel on 3/19/25.
//

import Foundation

protocol TextBatchSplitter {
    func split(text: String, maxChunkSize: Int) -> [String]
}

struct SimpleTextSplitter: TextBatchSplitter {
    func split(text: String, maxChunkSize: Int) -> [String] {
        guard !text.isEmpty, maxChunkSize > 0 else { return [] }

        let separators = ["\n\n", "\n", ".", " ", ""]

        // Attempt to split using separators
        for separator in separators {
            let components = separator.isEmpty ? text.map { String($0) } : text.components(separatedBy: separator)

            // If any single component is larger than maxChunkSize, skip this separator
            if components.contains(where: { $0.count > maxChunkSize }) {
                continue
            }

            var chunks: [String] = []
            var currentChunk = ""

            for component in components {
                let separatorLength = currentChunk.isEmpty ? 0 : separator.count
                if currentChunk.count + separatorLength + component.count <= maxChunkSize {
                    currentChunk += (currentChunk.isEmpty ? "" : separator) + component
                } else {
                    if !currentChunk.isEmpty {
                        chunks.append(currentChunk)
                    }
                    currentChunk = component
                }
            }

            if !currentChunk.isEmpty {
                chunks.append(currentChunk)
            }

            return chunks
        }

        // Fallback: split text into fixed-size chunks (by characters)
        return fixedSizeCharacterChunks(text: text, maxChunkSize: maxChunkSize)
    }

    private func fixedSizeCharacterChunks(text: String, maxChunkSize: Int) -> [String] {
        var chunks: [String] = []
        var currentIndex = text.startIndex

        while currentIndex < text.endIndex {
            let endIndex = text.index(currentIndex, offsetBy: maxChunkSize, limitedBy: text.endIndex) ?? text.endIndex
            let chunk = String(text[currentIndex..<endIndex])
            chunks.append(chunk)
            currentIndex = endIndex
        }

        return chunks
    }
}
