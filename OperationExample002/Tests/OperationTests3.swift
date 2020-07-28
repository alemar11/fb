//
//  OperationKVOtests.swift
//  OperationExample002
//
//  Created by Alessandro Marzoli on 20/02/2020.
//  Copyright © 2020 Alessandro Marzoli. All rights reserved.
//

import XCTest

class OperationTests3: XCTestCase {
  
  func testKVO1() {
    let operation1 = BlockOperation { }
    let operation2 = BlockOperation { }
    let operation3 = BlockOperation { }
    let expectation = self.expectation(description: "dependencies changed")
    expectation.assertForOverFulfill = false
    
    let t1 = operation1.observe(\.dependencies, options: [.old, .new]) { (op, changes) in
      print("🔸 op1 - dependencies changed") // ❌ never fired
      expectation.fulfill()
    }
    
    operation1.addDependency(operation2)
    operation1.addDependency(operation3)
    
    let queue = OperationQueue()
    queue.addOperations([operation1, operation2, operation3], waitUntilFinished: true)
    wait(for: [expectation], timeout: 3)
  }
  
  
  // It seems like "depedendencies" property can't be observed unless we observe isReady too
  func testKVO2() {
    let operation1 = BlockOperation {}
    let operation2 = BlockOperation {}
    let operation3 = BlockOperation { }
    let expectation = self.expectation(description: "dependencies changed")
    expectation.assertForOverFulfill = false
    
    let t1 = operation1.observe(\.dependencies, options: [.old, .new]) { (op, changes) in
      print("🔸 op1 - dependencies changed") // ❌ never fired
      expectation.fulfill()
    }
    
    let t2 = operation1.observe(\.isReady, options: [.old, .new]) { (op, changes) in
      print("op1 - ready: \(String(describing: changes.newValue))")
    }
    
    operation1.addDependency(operation2)
    operation1.addDependency(operation3)
    
    let queue = OperationQueue()
    queue.addOperations([operation1, operation2, operation3], waitUntilFinished: true)
    wait(for: [expectation], timeout: 10)
  }
}
