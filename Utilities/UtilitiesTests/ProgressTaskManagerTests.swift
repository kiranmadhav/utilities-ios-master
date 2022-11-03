//
//  ProgressTaskManagerTest.swift
//  ePub ReaderTests
//
//  Created by Arum_Kumar on 6/19/19.
//  Copyright © 2019 MHE. All rights reserved.
//

import XCTest
import PromiseKit
@testable import Utilities

class ProgressTaskManagerTests: XCTestCase {
    let progressManager = ProgressTaskManager<String, String>()

    // getExistingProgressTask should return nil for a new id
    func testgetExistingProgressTaskNilReturn() {
        let testId = "a"
        XCTAssertNil(progressManager.getExistingProgressTask(id: testId))
    }

    //getExistingProgressTask should return nil if addNewProgressTask has been called with that id, but the promise has resolved (fulfill)
    func testgetExistingProgressTaskNilWithFulfilledPromise() {
        let (task, resolver) = makeProgressTaskTuple()
        let expectation = self.expectation(description: "test")

        resolver.fulfill("success")

        let testId = "a"
        firstly { () -> Promise<String> in
            progressManager.addNewProgressTask(task: task, for: testId).promise
        }.done { _ in
            XCTAssertNil(self.progressManager.getExistingProgressTask(id: testId))
        }.catch { err in
            XCTFail("Encountered unexpected error: \(err)")
        }.finally {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    //getExistingProgressTask should return nil if addNewProgressTask has been called with that id, but the promise has resolved (rejected)
    func testgetExistingProgressTaskNilWithRejectedPromise() {
        let (task, resolver) = makeProgressTaskTuple()
        let expectation = self.expectation(description: "test")
        let testId = "a"

        resolver.reject(TestError.failed)

        firstly {
            progressManager.addNewProgressTask(task: task, for: testId).promise
        }.done { value in
            XCTFail("Encountered unexpected fulfillment: \(value)")
        }.catch { err in
            //swiftlint:disable force_cast
            XCTAssert((err as! TestError) == TestError.failed)
        }.finally {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    // getExistingProgressTask should return nonnil if addNewProgressTask has been called with that id, and the promise is not yet resolved
    func testgetExistingProgressTaskNonNilWhilePending() {
        let (task, resolver) = makeProgressTaskTuple()
        let testId = "a"

        let firstTask = progressManager.addNewProgressTask(task: task, for: testId)

        resolver.fulfill("success")
        let newTask = self.progressManager.getExistingProgressTask(id: testId)
        XCTAssertNotNil(newTask)
        XCTAssert(!(newTask!.promise === task.promise))
        XCTAssert(!(newTask!.progress === task.progress))
        XCTAssert(!(newTask!.promise === firstTask.promise))
        XCTAssert(!(newTask!.progress === firstTask.progress))
}

    // when there are 2 outstanding PromiseTasks sharing the same underlying promise, and it fulfills, both PromiseTasks' promises should fulfill with the same result
    func testSharedPromiseTaskResults() {
        let (task, resolver) = makeProgressTaskTuple()
        let expectation = self.expectation(description: "test")
        let testId = "a"

        let task1 = progressManager.addNewProgressTask(task: task, for: testId)
        let task2 = progressManager.getExistingProgressTask(id: testId)!

        resolver.fulfill("success")

        firstly {
            when(fulfilled: [task1.promise, task2.promise])
        }.done { results -> Void in
            XCTAssertEqual(results[0], results[1])
            XCTAssertEqual(results[0], "success")
        }.catch { err in
            XCTFail("Encountered unexpected error: \(err)")
        }.finally {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    // when there are 2 outstanding PromiseTasks sharing the same underlying promise, and it rejects, both PromiseTasks' promises should reject with its error
    func testSharedPromiseTaskErrors() {
        let (task, resolver) = makeProgressTaskTuple()
        let expectation = self.expectation(description: "test")
        let testId = "a"

        let task1 = progressManager.addNewProgressTask(task: task, for: testId)
        let task2 = progressManager.getExistingProgressTask(id: testId)!

        resolver.reject(TestError.failed)

        firstly {
            when(resolved: [task1.promise, task2.promise])
        }.done { results -> Void in
            let errs = results.compactMap { item -> TestError? in
                switch item {
                case .rejected(let err):
                    return (err as? TestError)
                default:
                    return nil
                }
            }

            XCTAssert(errs[0]==errs[1])
        }.catch { _ in
            //will never get here
            XCTFail("Unexpected")
        }.finally {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    // when there are 2 outstanding PromiseTasks sharing the same underlying promise, calling cancel on one's progress should not cancel the other
    func testCancelFirstNotSecond() {
        let (task, resolver) = makeProgressTaskTuple()
        let expectation = self.expectation(description: "test")
        let testId = "a"

        let task1 = progressManager.addNewProgressTask(task: task, for: testId)
        let task2 = progressManager.getExistingProgressTask(id: testId)!

        task1.progress.cancel()
        task1.promise.catch(policy: .allErrors) { _ in
            //After task1 cancels, fulfill the underlying task for both
            resolver.fulfill("success")
        }

        firstly {
            when(resolved: [task1.promise, task2.promise])
        }.done { result -> Void in
            switch result[0] {
            case .fulfilled(let result):
                XCTFail("Encountered unexpected result: \(result)")
            case .rejected(let error):
                XCTAssert(error.isCancelled)
            }
            switch result[1] {
            case .fulfilled(let result):
                XCTAssertEqual(result, "success")
            case .rejected(let error):
                XCTFail("Encountered unexpected error: \(error)")
            }
        }.catch { _ in
            //will never get here
            XCTFail("Unexpected")
        }.finally {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testCancelSecondNotFirst() {
        let (task, resolver) = makeProgressTaskTuple()
        let expectation = self.expectation(description: "test")
        let testId = "a"

        let task1 = progressManager.addNewProgressTask(task: task, for: testId)
        let task2 = progressManager.getExistingProgressTask(id: testId)!

        task2.progress.cancel()

        task2.promise.catch(policy: .allErrors) { _ in
            //After task2 cancels, fulfill the underlying task for both
            resolver.fulfill("success")
        }

        firstly {
            when(resolved: [task1.promise, task2.promise])
        }.done { result -> Void in
            switch result[1] {
            case .fulfilled(let result):
                XCTFail("Encountered unexpected result: \(result)")
            case .rejected(let error):
                XCTAssert(error.isCancelled)
            }
            switch result[0] {
            case .fulfilled(let result):
                XCTAssertEqual(result, "success")
            case .rejected(let error):
                XCTFail("Encountered unexpected error: \(error)")
            }
        }.catch { _ in
            //will never get here
            XCTFail("Unexpected")
        }.finally {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    // when there are 2 outstanding PromiseTasks sharing the same underlying promise, calling cancel on one's progress, and then calling cancel on the second SHOULD cancel the underlying promise/progress
    func testCancelBoth() {
        let (originalTask, _) = makeProgressTaskTuple()
        let expectation = self.expectation(description: "test")
        let testId = "a"

        let task1 = progressManager.addNewProgressTask(task: originalTask, for: testId)
        let task2 = progressManager.getExistingProgressTask(id: testId)!

        task1.progress.cancel()
        task2.progress.cancel()

        firstly {
            when(resolved: [task1.promise, task2.promise, originalTask.promise])
        }.done { results -> Void in
            results.forEach { result in
                switch result {
                case .fulfilled(let result):
                    XCTFail("Encountered unexpected result: \(result)")
                case .rejected(let error):
                    XCTAssert(error.isCancelled)
                }
            }
        }.catch { _ in
            //will never get here
            XCTFail("Unexpected")
        }.finally {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    //This tests a case where an already resolved task's Progress cancelationHandler was
    //being called when the parent Progress cancelled.  The unfulfilled tasks should cancel
    //but the one that has already succeeded should not do anything.
    func testCancelParentAfterAChildHasResolved() {
        let firstTuple = makeProgressTaskTuple()
        let tuples = [
            firstTuple,
            makeProgressTaskTuple(),
            makeProgressTaskTuple()
        ]

        let progress = Progress(totalUnitCount: 3)
        var increment = 0
        let newTasks = tuples.map { tuple -> Promise<String> in
            let newTask = progressManager.addNewProgressTask(task: tuple.0, for: "id-\(increment)")
            increment += 1
            progress.addChild(newTask.progress, withPendingUnitCount: 1)
            return newTask.promise
        }

        let expectation = self.expectation(description: "test")

        //One of the children fulfills
        firstTuple.1.fulfill("First Result")

        //Then cancel the parent, which cancels the rest of the children
        DispatchQueue.main.async {
            progress.cancel()
        }

        firstly {
            when(resolved: newTasks)// + duplicateTasks)
        }.done { results -> Void in
            results.forEach { result in
                switch result {
                case .fulfilled(let result):
                    XCTAssertEqual(result, "First Result")
                case .rejected(let error):
                    XCTAssert(error.isCancelled)
                }
            }
        }.catch { _ in
            //will never get here
            XCTFail("Unexpected")
        }.finally {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testChildProgressValues() {
        let (originalTask, resolver) = makeProgressTaskTuple()
        let testId = "a"

        let task1 = progressManager.addNewProgressTask(task: originalTask, for: testId)
        let task2 = progressManager.getExistingProgressTask(id: testId)!

        originalTask.progress.completedUnitCount = 5
        XCTAssertEqual(originalTask.progress.fractionCompleted, task1.progress.fractionCompleted)
        XCTAssertEqual(originalTask.progress.fractionCompleted, task2.progress.fractionCompleted)

        resolver.fulfill("success")
    }

    // MARK: - Helper methods
    private enum TestError: Error {
        case failed
    }

    private func makeProgressTaskTuple() -> (ProgressTask<String>, Resolver<String>) {
        let (promise, resolver) = Promise<String>.pending()
        let progress = Progress(totalUnitCount: 10)
        progress.cancellationHandler = {
            resolver.reject(PMKError.cancelled)
        }
        let task = ProgressTask(
            progress: progress,
            promise: promise
        )

        return (task, resolver)
    }
}
