//
//  URL+Extension.swift
//  Enchanted
//
//  Created by Daniel on 3/19/25.
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
