//
//  CharStarArray.swift
//  Utilities
//
//  Created by jbrooks on 1/25/16.
//  Copyright © 2016 MHE. All rights reserved.
//

import Foundation

public struct CharStarArray {
    private let utf8Strings: [UTF8CString]

    /**
     Create encapsulated char** pointer from an array of swift strings.
     - Parameter string: the array of strings.
     */
    public init(strings: [String]) {
        utf8Strings = strings.map { UTF8CString($0.utf8CString) }
    }

    private func withOneStringPtr<T>(
        strings: ArraySlice<UTF8CString>,
        ptrs: inout ContiguousArray<CStringPointer?>,
        ptrIndex: UnsafeBufferPointer<CStringPointer>.Index,
        finalCallback: (UnsafePointer<CStringPointer?>) -> (T)) -> T {

        if strings.isEmpty {
            //assert ptrIndex is at the end
            if ptrIndex != ptrs.endIndex {
                fatalError("Error in logic")
            }
            return ptrs.withUnsafeBufferPointer { (ptr: UnsafeBufferPointer<CStringPointer?>) -> T in
                return finalCallback(ptr.baseAddress!)
            }

        }

        //We have to have a first string if we're not empty
        let first = strings.first!

        return first.withUnsafeBufferPointer { (ptr: UnsafeBufferPointer<UnicodeCChar>) -> T in
            ptrs[ptrIndex] = ptr.baseAddress

            return withOneStringPtr(
                strings: strings.dropFirst(),
                ptrs: &ptrs,
                ptrIndex: ptrIndex.advanced(by: 1),
                finalCallback: finalCallback
            )
        }

    }

    public func withPointer<T>(_ body: (UnsafePointer<CStringPointer?>) -> (T)) -> T {
        var ptrs = ContiguousArray<CStringPointer?>(repeating: nil, count: utf8Strings.count)

        return withOneStringPtr(
            strings: ArraySlice(utf8Strings),
            ptrs: &ptrs,
            ptrIndex: ptrs.startIndex,
            finalCallback: body
        )
    }
}
