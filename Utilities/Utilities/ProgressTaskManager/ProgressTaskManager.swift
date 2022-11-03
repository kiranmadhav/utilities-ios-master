//
//  ProgressTaskManager.swift
//  ePub Reader
//
//  Created by Arum_Kumar on 6/17/19.
//  Copyright © 2019 MHE. All rights reserved.
//

import Foundation
import PromiseKit

/**
 ProgressTask - a container for pairing a Promise and a Progress whose
 cancellationHandler will cause the Promise to reject with `Error.cancelledError()`.
 Typically the Progress should show Progress of the task being executed by the Promise,
 although it is not necessary to the functioning of `ProgressTaskManager`
 */
public struct ProgressTask<ResultType> {
    /**
        The cancellationHandler of `progress` should cause
        promise` to reject with `Error.cancelledError()`
    */
    public let progress: Progress
    public let promise: Promise<ResultType>
    public init(progress: Progress, promise: Promise<ResultType>) {
        self.progress = progress
        self.promise = promise
    }
}

/**
 ProgressTaskManager - manages a collection of ProgressTasks, providing for the client
 child ProgressTasks that can piggyback off of one ProgressTask, but whose cancellation
 handlers only reject the child Promise, UNLESS there are no other child ProgressTasks
 sharing the underlying ProgressTasks
 */
public class ProgressTaskManager<ResultType, IDType: Hashable> {
    private var progressTaskDictionary = [IDType: ParentTask<ResultType>]()

    // public initializer just to override default internal
    public init() {}

    /**
     addNewProgressTask - method for retrieving a new ProgressTask for an existing ProgressTask underway.
     - Parameter id: The id to store/reuse the given Task
     - Returns: a NEW ProgressTask that will share the underlying progress task IF PRESENT, but whose
     Progress.cancellationHandler will only cancel the underlying Progress IF it is the only oustanding
     ProgressTask left.  If no progress task exists for this ID, returns nil
    */
    public func getExistingProgressTask(id: IDType) -> ProgressTask<ResultType>? {
        if let task = progressTaskDictionary[id] {
            return makeChildProgressTask(for: task, with: id)
        }
        return nil
    }

    /**
    addNewProgressTask - method for adding a new ProgressTask to the manager.  It is expected that
     a client should call `getExistingProgressTask(id:)` prior to calling this method.  Behavior is
     undefined if there is still an ongoing ProgressTask in the manager.
     - Parameter task: the ProgressTask to add.  It must adhear to the contract defined by ProgressTask documentation
     - Parameter id: The id to store/reuse the given Task
     - Returns: a NEW ProgressTask that will share the underlying (passed in) progress task, but whose
         Progress.cancellationHandler will only cancel the underlying Progress IF it is the only oustanding
         ProgressTask left
    */
    public func addNewProgressTask(task: ProgressTask<ResultType>, for id: IDType) -> ProgressTask<ResultType> {
        assert(progressTaskDictionary[id] == nil)

        let newTask = ParentTask(task: task, childCount: 0)
        progressTaskDictionary[id] = newTask

        return makeChildProgressTask(for: newTask, with: id)
    }

    private func makeChildProgressTask(for parentTask: ParentTask<ResultType>, with id: IDType) -> ProgressTask<ResultType> {
        parentTask.childCountLock.lock()
        parentTask.childCount += 1
        parentTask.childCountLock.unlock()

        let originalPromise = parentTask.task.promise
        let (childPromise, resolver) = Promise<ResultType>.pending()
        let childProgress = MirrorProgress(originalProgress: parentTask.task.progress)

        firstly {
            originalPromise
        }.ensure { [weak self] in
            parentTask.childCountLock.lock()
            parentTask.childCount -= 1
            //remove the cancellationHandler once our promise is resolved
            //(This is to prevent a parent progress from triggering it even though we're long
            //since resolved, cf. AVLN-16634
            childProgress.cancellationHandler = nil
            if parentTask.childCount == 0 {
                self?.progressTaskDictionary[id] = nil
            }
            parentTask.childCountLock.unlock()
        }.done { value -> Void in
            if childPromise.isPending {
                resolver.fulfill(value)
            }
        }.catch(policy: .allErrors) { error in
            if childPromise.isPending {
                resolver.reject(error)
            }
        }

        childProgress.cancellationHandler = {
            if parentTask.task.promise.isResolved {
                //Guarding against potential race conditions, our cancellationHandler has
                //been triggered but our underlying promise has resolved. We need not do anything.
                return
            }
            parentTask.childCountLock.lock()
            assert(parentTask.childCount >= 1)

            if parentTask.childCount == 1 {
                parentTask.task.progress.cancel()
            } else {
                parentTask.childCount -= 1
                resolver.reject(PMKError.cancelled)
            }
            parentTask.childCountLock.unlock()
        }

        return ProgressTask(progress: childProgress, promise: childPromise)
    }
}

/**
    ParentTask:  A private container for pairing a ProgressTask with it's child reference count
 */
private class ParentTask<ResultType> {
    let task: ProgressTask<ResultType>
    let childCountLock = NSLock()
    var childCount: Int = 0

    init(task: ProgressTask<ResultType>, childCount: Int) {
        self.task = task
        self.childCount = childCount
    }
}

/**
    MirrorProgress: A simple Progress subclass that mirrors another Progress object
      (without being a child or a parent), and tracks the other Progress's completedUnitCount
 */

private class MirrorProgress: Progress {
    let originalProgress: Progress
    var observation: NSKeyValueObservation?

    private func updateWithFractionCompleted(_ newFraction: Double) {
        completedUnitCount = Int64(Double(totalUnitCount) * newFraction)
    }

    init(originalProgress: Progress) {
        self.originalProgress = originalProgress
        super.init(parent: nil, userInfo: nil)

        //Arbitrary number: the higher the better for showing fraction completed
        //(Power of 2 to be nerdy!)
        totalUnitCount = 1024
        updateWithFractionCompleted(originalProgress.fractionCompleted)
        startObserving(originalProgress: originalProgress)
    }

    func startObserving(originalProgress: Progress) {
        observation = originalProgress.observe(\.fractionCompleted, options: [.old, .new], changeHandler: { [weak self] (_, change) in
            if let newValue = change.newValue {
                self?.updateWithFractionCompleted(newValue)
            }
        })
    }

    deinit {
        //This is not supposed to be required, but seems to fix a bug in NSProgress
        //involving threading, KVO, and deallocation.  Reliably fixes EPR-4210
        //cf https://stackoverflow.com/questions/46782372/ios-11-what-the-kvo-is-retaining-all-observers-of-this-object-if-it-crashes-an
        observation?.invalidate()
    }
}
