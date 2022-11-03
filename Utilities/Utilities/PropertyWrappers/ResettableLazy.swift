//
//  ResettableLazy.swift
//  Utilities
//
//  Created by Chien, Arnold on 11/17/20.
//  Copyright © 2020 Chien, Arnold. All rights reserved.
//

import Foundation

/*
    Property wrapper for a lazy variable that can be reinitialized.  Acts as a regular lazy variable until clear() is called, at which point the variable is reinitialized.  Continues as a regular lazy variable until the next clear().  Swift 5.1 support.

    Example usage:

     func exampleInitializer() -> Int {
         return Int.random(in: 1..<50)
     }
     struct ExampleStruct {
         @ResettableLazy(initializer: exampleInitializer) var resettable: Int
     }
     var exampleStruct = ExampleStruct()
     print("Lazy var set to \(exampleStruct.resettable)")   // Prints say "Lazy var set to 12\n"
     print("Lazy var is still \(exampleStruct.resettable)") // Prints say "Lazy var is still 12\n"
     exampleStruct.$resettable.clear()                       // Note "$" as built-in way to access the ResettableLazy type, enabled by exposure of projectedValue
     print("Lazy var reset to \(exampleStruct.resettable)") // Prints say "Lazy var reset to 20\n"
     print("Lazy var is still \(exampleStruct.resettable)") // Prints say "Lazy var is still 20\n"
 */
@propertyWrapper
public class ResettableLazy<Value> {
    private var storage: Value?
    private let initializer: () -> Value
    public func clear() {
        storage = nil
    }
    public init(initializer: @escaping () -> Value) {
        storage = nil
        self.initializer = initializer
    }
    public var wrappedValue: Value {
        get {
            if storage == nil {
                storage = initializer()
            }
            return storage!
        }
        set {
            storage = newValue
        }
    }
    public var projectedValue: ResettableLazy<Value> {
        return self
    }
}
