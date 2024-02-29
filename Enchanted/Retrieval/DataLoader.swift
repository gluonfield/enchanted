//
//  PDFDataLoader.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 25/02/2024.
//

import Foundation
import PDFKit

struct DataLoader {
    func fromPDF(_ url: URL) -> String? {
        guard url.startAccessingSecurityScopedResource() else {
            print("could not get access to file \(url.absoluteString)")
            return nil
        }
        
        let pdfDocument = PDFDocument(url: url)
        
        guard let document = pdfDocument else {
            print("Could not load \(url.absoluteString)")
            return nil
        }
        
        var contents = ""
        for i in 0..<document.pageCount {
            if let page = document.page(at: i) {
                if let pageContent = page.string {
                    contents += pageContent
                }
            }
        }
        return contents
    }
    
    func fromTextFile(_ url: URL) -> String? {
        do {
            let contents = try String(contentsOf: url, encoding: .utf8)
            return contents
        } catch {
            print("Could not parse \(url.absoluteString). Error: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func from(_ url: URL) -> String? {
        let mimeType = url.mimeType()
        
        if mimeType.contains("text/") {
            return fromTextFile(url)
        } else if mimeType == "application/pdf" {
            return fromPDF(url)
        } else if mimeType == "application/octet-stream" {
            return fromTextFile(url)
        } else if mimeType == "application/x-yaml" {
            return fromTextFile(url)
        }
        
        print("unhandled mime type \(mimeType) for \(url.absoluteString)")
        return nil
    }
}
