//
//  OperationExample001Tests.swift
//  OperationExample001Tests
//
//  Created by Alessandro Marzoli on 10/09/2019.
//  Copyright © 2019 com.alessandromarzoli. All rights reserved.
//

import XCTest
@testable import OperationExample001

class OperationExample001Tests: XCTestCase {
  
  func testExplicitProgressUsingSerialQueue() {
    let currentProgress = Progress(totalUnitCount: 1)
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1
    queue.isSuspended = true
    
    let operation1 = BlockOperation { sleep(1); print("operation 1 executed") }
    let operation2 = BlockOperation { sleep(1); print("operation 2 executed") }
    let operation3 = BlockOperation { sleep(1); print("operation 3 executed") }
    
    let expectation0 = self.expectation(description: "Progress is completed")
    let expectation1 = XCTKVOExpectation(keyPath: #keyPath(Operation.isFinished), object: operation1, expectedValue: true)
    let expectation2 = XCTKVOExpectation(keyPath: #keyPath(Operation.isFinished), object: operation2, expectedValue: true)
    let expectation3 = XCTKVOExpectation(keyPath: #keyPath(Operation.isFinished), object: operation3, expectedValue: true)
    
    queue.progress.totalUnitCount = 3
    queue.addOperation(operation1)
    queue.addOperation(operation2)
    queue.addOperation(operation3)
    
    currentProgress.addChild(queue.progress, withPendingUnitCount: 1)
    
    let token = currentProgress.observe(\.fractionCompleted, options: [.initial, .old, .new]) { (progress, change) in
      print(progress.fractionCompleted, progress.localizedAdditionalDescription ?? "")
      
      if progress.completedUnitCount == 1 && progress.fractionCompleted == 1.0 {
        expectation0.fulfill()
      }
    }
    
    queue.isSuspended = false
    wait(for: [expectation1, expectation2, expectation3, expectation0], timeout: 10)
    token.invalidate()
  }
  
  func testImplictProgressUsingSerialQueue() {
    // ➡️ the rule of thumb for implicit progress is to call becomeCurrent() and resignCurrent() as closely a possible around the code which you want to track.
    // ➡️ Note: Only the first progress attached to the parent during that window will be tracked; the rest will be ignored.
    let currentProgress = Progress(totalUnitCount: 1)
    currentProgress.becomeCurrent(withPendingUnitCount: 1)
    
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1
    queue.isSuspended = true
    
    let operation1 = BlockOperation { sleep(1); print("operation 1 executed") }
    let operation2 = BlockOperation { sleep(1); print("operation 2 executed") }
    let operation3 = BlockOperation { sleep(1); print("operation 3 executed") }
    
    let expectation0 = self.expectation(description: "Progress is completed")
    let expectation1 = XCTKVOExpectation(keyPath: #keyPath(Operation.isFinished), object: operation1, expectedValue: true)
    let expectation2 = XCTKVOExpectation(keyPath: #keyPath(Operation.isFinished), object: operation2, expectedValue: true)
    let expectation3 = XCTKVOExpectation(keyPath: #keyPath(Operation.isFinished), object: operation3, expectedValue: true)
    
    queue.progress.totalUnitCount = 3
    queue.addOperation(operation1)
    queue.addOperation(operation2)
    queue.addOperation(operation3)
    
    let token = currentProgress.observe(\.fractionCompleted, options: [.initial, .old, .new]) { (progress, change) in
      print(progress.fractionCompleted, progress.localizedAdditionalDescription ?? "")
      
      if progress.completedUnitCount == 1 && progress.fractionCompleted == 1.0 {
        expectation0.fulfill()
      }
    }
    
    queue.isSuspended = false
    currentProgress.resignCurrent() // resign immediately when the queue resumes work
    wait(for: [expectation1, expectation2, expectation3, expectation0], timeout: 10)
    token.invalidate()
  }
  
  func testExplicitProgressUsingConcurrentQueue() {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 10
    queue.isSuspended = true
    
    let operation1 = BlockOperation { print("operation 1 started"); sleep(1); print("operation 1 executed") }
    let operation2 = BlockOperation { print("operation 2 started"); sleep(1); print("operation 2 executed") }
    let operation3 = BlockOperation { print("operation 3 started"); sleep(1); print("operation 3 executed") }
    
    let expectation0 = self.expectation(description: "Progress is completed")
    expectation0.assertForOverFulfill = false // ✅ disable assertions for non-deterministic expectations.
    expectation0.expectedFulfillmentCount = 1 // ✅ set the minimum allotted fulfillment count to 1.
    let expectation1 = XCTKVOExpectation(keyPath: #keyPath(Operation.isFinished), object: operation1, expectedValue: true)
    let expectation2 = XCTKVOExpectation(keyPath: #keyPath(Operation.isFinished), object: operation2, expectedValue: true)
    let expectation3 = XCTKVOExpectation(keyPath: #keyPath(Operation.isFinished), object: operation3, expectedValue: true)
    
    let currentProgress = Progress(totalUnitCount: 1)
    
    queue.progress.totalUnitCount = 3
    queue.addOperation(operation1)
    queue.addOperation(operation2)
    queue.addOperation(operation3)
    
    currentProgress.addChild(queue.progress, withPendingUnitCount: 1)
    
    let token = currentProgress.observe(\.fractionCompleted, options: [.initial, .old, .new]) { (progress, change) in
      print("cP: \(progress.localizedDescription ?? "")") // ✅ prints "0%", 33%, 66% and 100%, but is aggregated due to race condition
      if progress.completedUnitCount == 1 && progress.fractionCompleted == 1.0 {
        expectation0.fulfill() // ✅ called exactly 1 times
      }
    }
    
    queue.isSuspended = false
    wait(for: [expectation1, expectation2, expectation3, expectation0], timeout: 10)
    token.invalidate()
  }
  
  // new test
  func testExplicitProgressUsingConcurrentQueue_v2() {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 10
    queue.isSuspended = true
    
    let operation1 = BlockOperation { print("operation 1 started"); sleep(1); print("operation 1 executed") }
    let operation2 = BlockOperation { print("operation 2 started"); sleep(2); print("operation 2 executed") }
    let operation3 = BlockOperation { print("operation 3 started"); sleep(5); print("operation 3 executed") }
    
    let expectation0 = self.expectation(description: "Progress is completed")
    expectation0.assertForOverFulfill = true // ✅ disable assertions for non-deterministic expectations.
    expectation0.expectedFulfillmentCount = 1 // ✅ set the minimum allotted fulfillment count to 1.
    let expectation1 = XCTKVOExpectation(keyPath: #keyPath(Operation.isFinished), object: operation1, expectedValue: true)
    let expectation2 = XCTKVOExpectation(keyPath: #keyPath(Operation.isFinished), object: operation2, expectedValue: true)
    let expectation3 = XCTKVOExpectation(keyPath: #keyPath(Operation.isFinished), object: operation3, expectedValue: true)
    
    let currentProgress = Progress(totalUnitCount: 1)
    
    queue.progress.totalUnitCount = 3
    queue.addOperation(operation1)
    queue.addOperation(operation2)
    queue.addOperation(operation3)
    
    currentProgress.addChild(queue.progress, withPendingUnitCount: 1)
    
    let token = currentProgress.observe(\.fractionCompleted, options: [.initial, .old, .new]) { (progress, change) in
      print("cP: \(progress.localizedDescription ?? "")") // ✅ prints "0%", 33%, 66% and 100%
      if progress.completedUnitCount == 1 && progress.fractionCompleted == 1.0 {
        expectation0.fulfill() // ✅ called exactly 1 times
      }
    }
    
    queue.isSuspended = false
    wait(for: [expectation1, expectation2, expectation3, expectation0], timeout: 20)
    token.invalidate()
  }
}
