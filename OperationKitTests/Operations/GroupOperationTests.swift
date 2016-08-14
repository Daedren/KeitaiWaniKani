//
//  GroupOperationTests.swift
//  OperationKit
//
//  Copyright © 2015 Chris Laverty. All rights reserved.
//

import XCTest
@testable import OperationKit

class GroupOperationTests: XCTestCase {
    
    func testRunNoConditions() {
        let operationQueue = createOperationQueue()
        
        let childOperation1 = StubOperation()
        keyValueObservingExpectation(for: childOperation1, keyPath: "isFinished", expectedValue: true)
        childOperation1.addObserver(BlockObserver { _, errors in
            XCTAssertTrue(errors.isEmpty, "Expected no errors on operation finish")
            })
        
        let childOperation2 = StubOperation()
        keyValueObservingExpectation(for: childOperation2, keyPath: "isFinished", expectedValue: true)
        childOperation2.addObserver(BlockObserver { _, errors in
            XCTAssertTrue(errors.isEmpty, "Expected no errors on operation finish")
            })
        childOperation2.addDependency(childOperation1)
        
        let operation = StubGroupOperation(operations: childOperation1, childOperation2)
        keyValueObservingExpectation(for: operation, keyPath: "isFinished", expectedValue: true)
        operation.addObserver(BlockObserver { _, errors in
            XCTAssertTrue(errors.isEmpty, "Expected no errors on operation finish")
            })
        
        Thread.sleep(forTimeInterval: 0.5)
        
        XCTAssertEqual(operation.stateTransitions, OperationWorkflows.New)
        XCTAssertEqual(operation.internalQueue.operationCount, 3)
        XCTAssertEqual(childOperation1.stateTransitions, OperationWorkflows.Pending)
        XCTAssertEqual(childOperation2.stateTransitions, OperationWorkflows.Pending)
        
        operationQueue.addOperation(operation)
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertEqual(operation.stateTransitions, OperationWorkflows.Finished)
        XCTAssertEqual(operation.internalQueue.operationCount, 0)
        XCTAssertEqual(childOperation1.stateTransitions, OperationWorkflows.Finished)
        XCTAssertEqual(childOperation2.stateTransitions, OperationWorkflows.Finished)
        
        XCTAssertFalse(operation.isReady)
        XCTAssertFalse(operation.isExecuting)
        XCTAssertTrue(operation.isFinished)
        XCTAssertFalse(operation.isCancelled)
        
        XCTAssertTrue(childOperation1.wasRun)
        XCTAssertFalse(childOperation1.isReady)
        XCTAssertFalse(childOperation1.isExecuting)
        XCTAssertTrue(childOperation1.isFinished)
        XCTAssertFalse(childOperation1.isCancelled)
        
        XCTAssertTrue(childOperation2.wasRun)
        XCTAssertFalse(childOperation2.isReady)
        XCTAssertFalse(childOperation2.isExecuting)
        XCTAssertTrue(childOperation2.isFinished)
        XCTAssertFalse(childOperation2.isCancelled)
    }
    
    func testCancelBeforeStart() {
        let operationQueue = createOperationQueue()
        
        let childOperation1 = StubOperation()
        keyValueObservingExpectation(for: childOperation1, keyPath: "isFinished", expectedValue: true)
        childOperation1.addObserver(BlockObserver { _, errors in
            XCTAssertTrue(errors.isEmpty, "Expected no errors on operation finish")
            })
        
        let childOperation2 = StubOperation()
        keyValueObservingExpectation(for: childOperation2, keyPath: "isFinished", expectedValue: true)
        childOperation2.addObserver(BlockObserver { _, errors in
            XCTAssertTrue(errors.isEmpty, "Expected no errors on operation finish")
            })
        childOperation2.addDependency(childOperation1)
        
        let operation = StubGroupOperation(operations: childOperation1, childOperation2)
        keyValueObservingExpectation(for: operation, keyPath: "isFinished", expectedValue: true)
        operation.addObserver(BlockObserver { _, errors in
            XCTAssertTrue(errors.isEmpty, "Expected no errors on operation finish")
            })
        
        Thread.sleep(forTimeInterval: 0.5)
        
        XCTAssertEqual(operation.stateTransitions, OperationWorkflows.New)
        XCTAssertEqual(operation.internalQueue.operationCount, 3)
        XCTAssertEqual(childOperation1.stateTransitions, OperationWorkflows.Pending)
        XCTAssertEqual(childOperation2.stateTransitions, OperationWorkflows.Pending)
        
        operation.cancel()
        
        Thread.sleep(forTimeInterval: 0.5)
        
        XCTAssertEqual(operation.stateTransitions, OperationWorkflows.New)
        XCTAssertEqual(operation.internalQueue.operationCount, 0)
        XCTAssertEqual(childOperation1.stateTransitions, OperationWorkflows.CancelledBeforeReady)
        XCTAssertEqual(childOperation2.stateTransitions, OperationWorkflows.CancelledBeforeReady)
        
        operationQueue.addOperation(operation)
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertEqual(operation.stateTransitions, OperationWorkflows.CancelledBeforeReady)
        XCTAssertEqual(operation.internalQueue.operationCount, 0)
        XCTAssertEqual(childOperation1.stateTransitions, OperationWorkflows.CancelledBeforeReady)
        XCTAssertEqual(childOperation2.stateTransitions, OperationWorkflows.CancelledBeforeReady)
        
        XCTAssertFalse(operation.isReady)
        XCTAssertFalse(operation.isExecuting)
        XCTAssertTrue(operation.isFinished)
        XCTAssertTrue(operation.isCancelled)
        
        XCTAssertFalse(childOperation1.wasRun)
        XCTAssertFalse(childOperation1.isReady)
        XCTAssertFalse(childOperation1.isExecuting)
        XCTAssertTrue(childOperation1.isFinished)
        XCTAssertTrue(childOperation1.isCancelled)
        
        XCTAssertFalse(childOperation2.wasRun)
        XCTAssertFalse(childOperation2.isReady)
        XCTAssertFalse(childOperation2.isExecuting)
        XCTAssertTrue(childOperation2.isFinished)
        XCTAssertTrue(childOperation2.isCancelled)
    }
    
    func testCancelAfterStart() {
        let operationQueue = createOperationQueue()
        
        let childOperation1 = StubOperation()
        keyValueObservingExpectation(for: childOperation1, keyPath: "isFinished", expectedValue: true)
        childOperation1.addObserver(BlockObserver { _, errors in
            XCTAssertTrue(errors.isEmpty, "Expected no errors on operation finish")
            })
        
        let childOperation2 = StubOperation(immediatelyFinish: false)
        keyValueObservingExpectation(for: childOperation2, keyPath: "isFinished", expectedValue: true)
        childOperation2.addObserver(BlockObserver { _, errors in
            XCTAssertTrue(errors.isEmpty, "Expected no errors on operation finish")
            })
        childOperation2.addDependency(childOperation1)
        
        let childOperation3 = StubOperation()
        keyValueObservingExpectation(for: childOperation3, keyPath: "isFinished", expectedValue: true)
        childOperation3.addObserver(BlockObserver { _, errors in
            XCTAssertTrue(errors.isEmpty, "Expected no errors on operation finish")
            })
        childOperation3.addDependency(childOperation2)
        
        let operation = StubGroupOperation(operations: childOperation1, childOperation2, childOperation3)
        keyValueObservingExpectation(for: operation, keyPath: "isFinished", expectedValue: true)
        operation.addObserver(BlockObserver(
            startHandler: { _ in
                let when = DispatchTime.now() + 0.5
                DispatchQueue.global(qos: .default).asyncAfter(deadline: when) {
                    XCTAssertEqual(operation.stateTransitions, OperationWorkflows.Executing)
                    XCTAssertEqual(operation.internalQueue.operationCount, 3)
                    XCTAssertEqual(childOperation1.stateTransitions, OperationWorkflows.Finished)
                    XCTAssertEqual(childOperation2.stateTransitions, OperationWorkflows.Executing)
                    XCTAssertEqual(childOperation3.stateTransitions, OperationWorkflows.Pending)
                    
                    XCTAssertFalse(operation.isReady)
                    XCTAssertTrue(operation.isExecuting)
                    XCTAssertFalse(operation.isFinished)
                    XCTAssertFalse(operation.isCancelled)
                    
                    XCTAssertTrue(childOperation1.wasRun)
                    XCTAssertFalse(childOperation1.isReady)
                    XCTAssertFalse(childOperation1.isExecuting)
                    XCTAssertTrue(childOperation1.isFinished)
                    XCTAssertFalse(childOperation1.isCancelled)
                    
                    XCTAssertTrue(childOperation2.wasRun)
                    XCTAssertFalse(childOperation2.isReady)
                    XCTAssertTrue(childOperation2.isExecuting)
                    XCTAssertFalse(childOperation2.isFinished)
                    XCTAssertFalse(childOperation2.isCancelled)
                    
                    XCTAssertFalse(childOperation3.wasRun)
                    XCTAssertFalse(childOperation3.isReady)
                    XCTAssertFalse(childOperation3.isExecuting)
                    XCTAssertFalse(childOperation3.isFinished)
                    XCTAssertFalse(childOperation3.isCancelled)
                    
                    print("Cancelling operation")
                    operation.cancel()
                }
            },
            finishHandler: { _, errors in
                XCTAssertTrue(errors.isEmpty, "Expected no errors on operation finish")
        }))
        
        Thread.sleep(forTimeInterval: 0.5)
        
        XCTAssertEqual(operation.stateTransitions, OperationWorkflows.New)
        XCTAssertEqual(operation.internalQueue.operationCount, 4)
        XCTAssertEqual(childOperation1.stateTransitions, OperationWorkflows.Pending)
        XCTAssertEqual(childOperation2.stateTransitions, OperationWorkflows.Pending)
        
        operationQueue.addOperation(operation)
        waitForExpectations(timeout: 5, handler: nil)
        
        Thread.sleep(forTimeInterval: 0.5)
        
        XCTAssertEqual(operation.stateTransitions, OperationWorkflows.Finished)
        XCTAssertEqual(operation.internalQueue.operationCount, 0)
        XCTAssertEqual(childOperation1.stateTransitions, OperationWorkflows.Finished)
        XCTAssertEqual(childOperation2.stateTransitions, OperationWorkflows.Finished)
        XCTAssertEqual(childOperation3.stateTransitions, OperationWorkflows.CancelledAfterReady)
        
        XCTAssertFalse(operation.isReady)
        XCTAssertFalse(operation.isExecuting)
        XCTAssertTrue(operation.isFinished)
        XCTAssertTrue(operation.isCancelled)
        
        XCTAssertTrue(childOperation1.wasRun)
        XCTAssertFalse(childOperation1.isReady)
        XCTAssertFalse(childOperation1.isExecuting)
        XCTAssertTrue(childOperation1.isFinished)
        XCTAssertFalse(childOperation1.isCancelled)
        
        XCTAssertTrue(childOperation2.wasRun)
        XCTAssertFalse(childOperation2.isReady)
        XCTAssertFalse(childOperation2.isExecuting)
        XCTAssertTrue(childOperation2.isFinished)
        XCTAssertTrue(childOperation2.isCancelled)
        
        XCTAssertFalse(childOperation3.wasRun)
        XCTAssertFalse(childOperation3.isReady)
        XCTAssertFalse(childOperation3.isExecuting)
        XCTAssertTrue(childOperation3.isFinished)
        XCTAssertTrue(childOperation3.isCancelled)
    }
    
    func testRunNestedNoConditions() {
        let operationQueue = createOperationQueue()
        
        let childOperation1_1 = StubOperation()
        keyValueObservingExpectation(for: childOperation1_1, keyPath: "isFinished", expectedValue: true)
        childOperation1_1.addObserver(BlockObserver { _, errors in
            XCTAssertTrue(errors.isEmpty, "Expected no errors on operation finish")
            })
        
        let childOperation1_2 = StubOperation()
        keyValueObservingExpectation(for: childOperation1_2, keyPath: "isFinished", expectedValue: true)
        childOperation1_2.addObserver(BlockObserver { _, errors in
            XCTAssertTrue(errors.isEmpty, "Expected no errors on operation finish")
            })
        childOperation1_2.addDependency(childOperation1_1)
        
        let nested1 = StubGroupOperation(operations: childOperation1_1, childOperation1_2)
        keyValueObservingExpectation(for: nested1, keyPath: "isFinished", expectedValue: true)
        nested1.addObserver(BlockObserver { _, errors in
            XCTAssertTrue(errors.isEmpty, "Expected no errors on operation finish")
            })
        
        let childOperation2_1 = StubOperation()
        keyValueObservingExpectation(for: childOperation2_1, keyPath: "isFinished", expectedValue: true)
        childOperation2_1.addObserver(BlockObserver { _, errors in
            XCTAssertTrue(errors.isEmpty, "Expected no errors on operation finish")
            })
        
        let childOperation2_2 = StubOperation()
        keyValueObservingExpectation(for: childOperation2_2, keyPath: "isFinished", expectedValue: true)
        childOperation2_2.addObserver(BlockObserver { _, errors in
            XCTAssertTrue(errors.isEmpty, "Expected no errors on operation finish")
            })
        childOperation2_2.addDependency(childOperation2_1)
        
        let nested2 = StubGroupOperation(operations: childOperation2_1, childOperation2_2)
        keyValueObservingExpectation(for: nested2, keyPath: "isFinished", expectedValue: true)
        nested2.addObserver(BlockObserver { _, errors in
            XCTAssertTrue(errors.isEmpty, "Expected no errors on operation finish")
            })
        
        let operation = StubGroupOperation(operations: nested1, nested2)
        keyValueObservingExpectation(for: operation, keyPath: "isFinished", expectedValue: true)
        operation.addObserver(BlockObserver { _, errors in
            XCTAssertTrue(errors.isEmpty, "Expected no errors on operation finish")
            })
        
        Thread.sleep(forTimeInterval: 0.5)
        
        XCTAssertEqual(operation.stateTransitions, OperationWorkflows.New)
        XCTAssertEqual(nested1.stateTransitions, OperationWorkflows.Pending)
        XCTAssertEqual(childOperation1_1.stateTransitions, OperationWorkflows.Pending)
        XCTAssertEqual(childOperation1_2.stateTransitions, OperationWorkflows.Pending)
        XCTAssertEqual(nested2.stateTransitions, OperationWorkflows.Pending)
        XCTAssertEqual(childOperation2_1.stateTransitions, OperationWorkflows.Pending)
        XCTAssertEqual(childOperation2_2.stateTransitions, OperationWorkflows.Pending)
        
        operationQueue.addOperation(operation)
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertEqual(operation.stateTransitions, OperationWorkflows.Finished)
        XCTAssertEqual(nested1.stateTransitions, OperationWorkflows.Finished)
        XCTAssertEqual(childOperation1_1.stateTransitions, OperationWorkflows.Finished)
        XCTAssertEqual(childOperation1_2.stateTransitions, OperationWorkflows.Finished)
        XCTAssertEqual(nested2.stateTransitions, OperationWorkflows.Finished)
        XCTAssertEqual(childOperation2_1.stateTransitions, OperationWorkflows.Finished)
        XCTAssertEqual(childOperation2_2.stateTransitions, OperationWorkflows.Finished)
        
        XCTAssertFalse(operation.isReady)
        XCTAssertFalse(operation.isExecuting)
        XCTAssertTrue(operation.isFinished)
        XCTAssertFalse(operation.isCancelled)
        
        XCTAssertFalse(nested1.isReady)
        XCTAssertFalse(nested1.isExecuting)
        XCTAssertTrue(nested1.isFinished)
        XCTAssertFalse(nested1.isCancelled)
        
        XCTAssertTrue(childOperation1_1.wasRun)
        XCTAssertFalse(childOperation1_1.isReady)
        XCTAssertFalse(childOperation1_1.isExecuting)
        XCTAssertTrue(childOperation1_1.isFinished)
        XCTAssertFalse(childOperation1_1.isCancelled)
        
        XCTAssertTrue(childOperation1_2.wasRun)
        XCTAssertFalse(childOperation1_2.isReady)
        XCTAssertFalse(childOperation1_2.isExecuting)
        XCTAssertTrue(childOperation1_2.isFinished)
        XCTAssertFalse(childOperation1_2.isCancelled)
        
        XCTAssertFalse(nested2.isReady)
        XCTAssertFalse(nested2.isExecuting)
        XCTAssertTrue(nested2.isFinished)
        XCTAssertFalse(nested2.isCancelled)
        
        XCTAssertTrue(childOperation2_1.wasRun)
        XCTAssertFalse(childOperation2_1.isReady)
        XCTAssertFalse(childOperation2_1.isExecuting)
        XCTAssertTrue(childOperation2_1.isFinished)
        XCTAssertFalse(childOperation2_1.isCancelled)
        
        XCTAssertTrue(childOperation2_2.wasRun)
        XCTAssertFalse(childOperation2_2.isReady)
        XCTAssertFalse(childOperation2_2.isExecuting)
        XCTAssertTrue(childOperation2_2.isFinished)
        XCTAssertFalse(childOperation2_2.isCancelled)
    }
    
    func testRunNestedCancelBeforeStart() {
        let operationQueue = createOperationQueue()
        
        let childOperation1_1 = StubOperation()
        keyValueObservingExpectation(for: childOperation1_1, keyPath: "isFinished", expectedValue: true)
        childOperation1_1.addObserver(BlockObserver { _, errors in
            XCTAssertTrue(errors.isEmpty, "Expected no errors on operation finish")
            })
        
        let childOperation1_2 = StubOperation()
        keyValueObservingExpectation(for: childOperation1_2, keyPath: "isFinished", expectedValue: true)
        childOperation1_2.addObserver(BlockObserver { _, errors in
            XCTAssertTrue(errors.isEmpty, "Expected no errors on operation finish")
            })
        childOperation1_2.addDependency(childOperation1_1)
        
        let nested1 = StubGroupOperation(operations: childOperation1_1, childOperation1_2)
        keyValueObservingExpectation(for: nested1, keyPath: "isFinished", expectedValue: true)
        nested1.addObserver(BlockObserver { _, errors in
            XCTAssertTrue(errors.isEmpty, "Expected no errors on operation finish")
            })
        
        let childOperation2_1 = StubOperation()
        keyValueObservingExpectation(for: childOperation2_1, keyPath: "isFinished", expectedValue: true)
        childOperation2_1.addObserver(BlockObserver { _, errors in
            XCTAssertTrue(errors.isEmpty, "Expected no errors on operation finish")
            })
        
        let childOperation2_2 = StubOperation()
        keyValueObservingExpectation(for: childOperation2_2, keyPath: "isFinished", expectedValue: true)
        childOperation2_2.addObserver(BlockObserver { _, errors in
            XCTAssertTrue(errors.isEmpty, "Expected no errors on operation finish")
            })
        childOperation2_2.addDependency(childOperation2_1)
        
        let nested2 = StubGroupOperation(operations: childOperation2_1, childOperation2_2)
        keyValueObservingExpectation(for: nested2, keyPath: "isFinished", expectedValue: true)
        nested2.addObserver(BlockObserver { _, errors in
            XCTAssertTrue(errors.isEmpty, "Expected no errors on operation finish")
            })
        
        let operation = StubGroupOperation(operations: nested1, nested2)
        keyValueObservingExpectation(for: operation, keyPath: "isFinished", expectedValue: true)
        operation.addObserver(BlockObserver { _, errors in
            XCTAssertTrue(errors.isEmpty, "Expected no errors on operation finish")
            })
        
        Thread.sleep(forTimeInterval: 0.5)
        
        XCTAssertEqual(operation.stateTransitions, OperationWorkflows.New)
        XCTAssertEqual(nested1.stateTransitions, OperationWorkflows.Pending)
        XCTAssertEqual(childOperation1_1.stateTransitions, OperationWorkflows.Pending)
        XCTAssertEqual(childOperation1_2.stateTransitions, OperationWorkflows.Pending)
        XCTAssertEqual(nested2.stateTransitions, OperationWorkflows.Pending)
        XCTAssertEqual(childOperation2_1.stateTransitions, OperationWorkflows.Pending)
        XCTAssertEqual(childOperation2_2.stateTransitions, OperationWorkflows.Pending)
        
        operation.cancel()
        
        Thread.sleep(forTimeInterval: 0.5)
        
        XCTAssertEqual(operation.stateTransitions, OperationWorkflows.New)
        XCTAssertEqual(nested1.stateTransitions, OperationWorkflows.CancelledBeforeReady)
        XCTAssertEqual(childOperation1_1.stateTransitions, OperationWorkflows.CancelledBeforeReady)
        XCTAssertEqual(childOperation1_2.stateTransitions, OperationWorkflows.CancelledBeforeReady)
        XCTAssertEqual(nested2.stateTransitions, OperationWorkflows.CancelledBeforeReady)
        XCTAssertEqual(childOperation2_1.stateTransitions, OperationWorkflows.CancelledBeforeReady)
        XCTAssertEqual(childOperation2_2.stateTransitions, OperationWorkflows.CancelledBeforeReady)
        
        operationQueue.addOperation(operation)
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertEqual(operation.stateTransitions, OperationWorkflows.CancelledBeforeReady)
        XCTAssertEqual(nested1.stateTransitions, OperationWorkflows.CancelledBeforeReady)
        XCTAssertEqual(childOperation1_1.stateTransitions, OperationWorkflows.CancelledBeforeReady)
        XCTAssertEqual(childOperation1_2.stateTransitions, OperationWorkflows.CancelledBeforeReady)
        XCTAssertEqual(nested2.stateTransitions, OperationWorkflows.CancelledBeforeReady)
        XCTAssertEqual(childOperation2_1.stateTransitions, OperationWorkflows.CancelledBeforeReady)
        XCTAssertEqual(childOperation2_2.stateTransitions, OperationWorkflows.CancelledBeforeReady)
        
        XCTAssertFalse(operation.isReady)
        XCTAssertFalse(operation.isExecuting)
        XCTAssertTrue(operation.isFinished)
        XCTAssertTrue(operation.isCancelled)
        
        XCTAssertFalse(nested1.isReady)
        XCTAssertFalse(nested1.isExecuting)
        XCTAssertTrue(nested1.isFinished)
        XCTAssertTrue(nested1.isCancelled)
        
        XCTAssertFalse(childOperation1_1.wasRun)
        XCTAssertFalse(childOperation1_1.isReady)
        XCTAssertFalse(childOperation1_1.isExecuting)
        XCTAssertTrue(childOperation1_1.isFinished)
        XCTAssertTrue(childOperation1_1.isCancelled)
        
        XCTAssertFalse(childOperation1_2.wasRun)
        XCTAssertFalse(childOperation1_2.isReady)
        XCTAssertFalse(childOperation1_2.isExecuting)
        XCTAssertTrue(childOperation1_2.isFinished)
        XCTAssertTrue(childOperation1_2.isCancelled)
        
        XCTAssertFalse(nested2.isReady)
        XCTAssertFalse(nested2.isExecuting)
        XCTAssertTrue(nested2.isFinished)
        XCTAssertTrue(nested2.isCancelled)
        
        XCTAssertFalse(childOperation2_1.wasRun)
        XCTAssertFalse(childOperation2_1.isReady)
        XCTAssertFalse(childOperation2_1.isExecuting)
        XCTAssertTrue(childOperation2_1.isFinished)
        XCTAssertTrue(childOperation2_1.isCancelled)
        
        XCTAssertFalse(childOperation2_2.wasRun)
        XCTAssertFalse(childOperation2_2.isReady)
        XCTAssertFalse(childOperation2_2.isExecuting)
        XCTAssertTrue(childOperation2_2.isFinished)
        XCTAssertTrue(childOperation2_2.isCancelled)
    }
    
}
