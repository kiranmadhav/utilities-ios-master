//
//  PipeOperator.swift
//  Utilities
//
//  Created by Chien, Arnold on 2/7/17.
//  Copyright © 2017 MHE. All rights reserved.
//

// Modified version of:
// https://gist.github.com/kristopherjohnson/ed97acf0bbe0013df8af
//
// F#'s "pipe-forward" |> operator
//
// Also "Optional-chaining" operators |>! and |>&
//
// And adapters for standard library map/filter/sorted

import Foundation

infix operator |>: AdditionPrecedence
infix operator |>!: AdditionPrecedence
infix operator |>&: AdditionPrecedence
infix operator |>*: AdditionPrecedence

// Pipe forward: transform "x |> f" to "f(x)" and "x |> f |> g |> h" to "h(g(f(x)))"
public func |> <T, U>(lhs: T, rhs: (T) -> U) -> U {
    return rhs(lhs)
}

// Unwrap the optional value on the left-hand side and apply the right-hand function
public func |>! <T, U>(lhs: T?, rhs: (T) -> U) -> U {
    return rhs(lhs!)
}

// If Optional value on left is nil, return nil; otherwise unwrap it and
// apply the right-hand function to it.
//
// (It would be nice if we could name this |>?, but the ? character
// is not allowed in custom operators.)
public func |>& <T, U>(lhs: T?, rhs: (T) -> U) -> U? {
    return lhs.map(rhs)
}

// Transform "x |>* (f, predicate)" to "f(x, predicate)"
public func |>* <A, B, C, T>(lhs: A, rhs: ((A, (B) -> C) -> T, (B) -> C)) -> T {
    return (rhs.0)(lhs, rhs.1)
}
