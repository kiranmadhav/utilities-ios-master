//
//  DispatchQueue+Delay.swift
//  Utilities
//
//  Created by jbrooks on 2/17/16.
//  Copyright © 2016 MHE. All rights reserved.
//

import Foundation

public extension DispatchQueue {
    /**
     Dispatches the given block after the given delay (in seconds) on the given queue (defaults to main).
     - Parameter delayInSeconds: the delay.
     - Parameter queue: the queue.
     - Parameter block: the block.
     */
    class func delayed(_ delayInSeconds: Double, queue: DispatchQueue = DispatchQueue.main, block:@escaping () -> Void) {
        queue.asyncAfter(deadline: DispatchTime.now() + delayInSeconds, execute: block)
    }

}
