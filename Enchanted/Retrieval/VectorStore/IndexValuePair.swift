//
//  IndexValuePair.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 26/02/2024.
//

import Foundation
import Collections

struct IndexValuePair {
    internal var index: Int
    internal var value: Double
}

extension IndexValuePair: Comparable {
    internal static func < (lhs: IndexValuePair, rhs: IndexValuePair) -> Bool {
        lhs.value < rhs.value
    }
}
