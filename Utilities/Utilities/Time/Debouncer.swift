//
//  Debouncer.swift
//  Utilities
//
//  Created by Chien, Arnold on 3/20/18.
//  Copyright © 2018 McGraw-Hill Education. All rights reserved.
//
//  Based on https://stackoverflow.com/questions/27116684/how-can-i-debounce-a-method-call

import Foundation

class Callback {
    let handler:() -> Void
    init(_ handler: @escaping () -> Void) {
        self.handler = handler
    }
    @objc func fire() {
        handler()
    }
}

open class Debouncer {

    /**
     Return a function which debounces a callback, to be called at most once within `delay` seconds.  If called again within that time, cancels the original call and reschedules.
     - Parameter delay: the delay.
     - Parameter action: the callback.
     - Returns: the function.
     */
    public static func debounce(delay: TimeInterval, action: @escaping () -> Void) -> (() -> Void) {
        let callback = Callback(action)
        var timer: Timer?
        return {
            if let timer = timer {
                timer.invalidate()
            }
            timer = Timer.scheduledTimer(timeInterval: delay, target: callback, selector: #selector(callback.fire), userInfo: nil, repeats: false)
        }
    }
}
