//
//  KeyboardObserver.swift
//  Utilities
//
//  Created by kurtu on 9/7/17.
//  Copyright © 2017 mhe. All rights reserved.
//

import UIKit

open class KeyboardObserver {
    public var keyboardWillShowEventHandler: ((NSNotification) -> Void)?
    public var keyboardDidShowEventHandler: ((NSNotification) -> Void)?
    public var keyboardWillHideEventHandler: ((NSNotification) -> Void)?
    public var keyboardDidHideEventHandler: ((NSNotification) -> Void)?
    public var keyboardWillChangeFrameEventHandler: ((NSNotification) -> Void)?
    public var keyboardDidChangeFrameEventHandler: ((NSNotification) -> Void)?

    private let eventsAndHandlers = [UIResponder.keyboardWillShowNotification: #selector(keyboardWillShow(notification:)),
                                     UIResponder.keyboardDidShowNotification: #selector(keyboardDidShow(notification:)),
                                     UIResponder.keyboardWillHideNotification: #selector(keyboardWillHide(notification:)),
                                     UIResponder.keyboardDidHideNotification: #selector(keyboardDidHide(notification:)),
                                     UIResponder.keyboardWillChangeFrameNotification: #selector(keyboardWillChangeFrame(notification:)),
                                     UIResponder.keyboardDidChangeFrameNotification: #selector(keyboardDidChangeFrame(notification:))]

    public init() {
        registerForKeyboardNotifications()
    }

    deinit {
        deregisterFromKeyboardNotifications()
    }

    public func registerForKeyboardNotifications() {
        for (notificationName, selector) in eventsAndHandlers {
            NotificationCenter.default.addObserver(self,
                                                   selector: selector,
                                                   name: notificationName,
                                                   object: nil)
        }
    }

    public func deregisterFromKeyboardNotifications() {
        for (notificationName, _) in eventsAndHandlers {
            NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
        }
    }

    @objc
    private func keyboardDidShow(notification: NSNotification) {
        keyboardDidShowEventHandler?(notification)
    }

    @objc
    private func keyboardWillShow(notification: NSNotification) {
        keyboardWillShowEventHandler?(notification)
    }

    @objc
    private func keyboardWillHide(notification: NSNotification) {
        keyboardWillHideEventHandler?(notification)
    }

    @objc
    private func keyboardDidHide(notification: NSNotification) {
        keyboardDidHideEventHandler?(notification)
    }

    @objc
    private func keyboardWillChangeFrame(notification: NSNotification) {
        keyboardWillChangeFrameEventHandler?(notification)
    }

    @objc
    private func keyboardDidChangeFrame(notification: NSNotification) {
        keyboardDidChangeFrameEventHandler?(notification)
    }
}
