//
//  DeallocPrinter.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 17/02/2024.
//

import Foundation

class DeallocPrinter {
    var message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    deinit {
        print("deallocated \(message)")
    }
}

