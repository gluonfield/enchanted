//
//  Throttler.swift
//  Enchanted
//
//  Created by Augustinas Malinauskas on 29/12/2023.
//

import Foundation

class Throttler {
    private var workItem: DispatchWorkItem?
    private var lastRun: Date = .distantPast
    private let queue: DispatchQueue
    private let delay: TimeInterval

    init(delay: TimeInterval, queue: DispatchQueue = DispatchQueue.main) {
        self.delay = delay
        self.queue = queue
    }

    func throttle(_ block: @escaping () -> Void) {
        workItem?.cancel()

        let item = DispatchWorkItem { [weak self] in
            self?.lastRun = Date()
            block()
        }
        self.workItem = item

        let delayFactor = Date().timeIntervalSince(lastRun) >= delay ? 0 : delay
        queue.asyncAfter(deadline: .now() + delayFactor, execute: item)
    }
}
