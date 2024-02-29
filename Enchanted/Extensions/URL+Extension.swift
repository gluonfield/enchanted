//
//  URL+Extension.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 25/02/2024.
//

import Foundation
import Collections
import UniformTypeIdentifiers

extension URL {
    public func mimeType() -> String {
        if let mimeType = UTType(filenameExtension: self.pathExtension)?.preferredMIMEType {
            return mimeType
        }
        else {
            return "application/octet-stream"
        }
    }
}
