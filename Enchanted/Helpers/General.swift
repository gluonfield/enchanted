//
//  General.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 26/02/2024.
//

import Foundation

struct GeneralHelpers {
    static func timer(_ name: String, block: () async -> Void) async {
        let startTime = CFAbsoluteTimeGetCurrent()
        await block()
        let endTime = CFAbsoluteTimeGetCurrent()
        print("\(name) execution time: \(endTime - startTime) seconds")
    }
}
