//
//  OperationExample002Tests.swift
//  OperationExample002Tests
//
//  Created by Alessandro Marzoli on 17/02/2020.
//  Copyright © 2020 Alessandro Marzoli. All rights reserved.
//

import XCTest

class TestOperation: Operation {
  var input: String?
  var output: String?
  
  override func main() {
    if let input = input {
      output = "*\(input)*"
    }
  }
}

class OperationTests2: XCTestCase {
  func testDataRace() {
    (1...1000).forEach { (i) in
      print(i)
      checkDataRaces()
    }
  }
  
  func checkDataRaces() {
    let operation1 = TestOperation()
    let operation2 = TestOperation()
    let inject = BlockOperation { [unowned operation1, unowned operation2] in
      operation2.input = operation1.output
    }
    
    inject.addDependency(operation1)
    operation2.addDependency(inject)
    
    operation1.input = "1"
    let queue = OperationQueue()
    queue.addOperations([operation1, operation2, inject], waitUntilFinished: true)
    XCTAssertEqual(operation2.output, "**1**") // ❌ Data races detected only on macOS
  }
  
  func testDataRace_2() {
    (1...1000).forEach { (i) in
      print(i)
      checkDataRaces_2()
    }
  }
  
  func checkDataRaces_2() {
    let operation1 = TestOperation()
    let operation2 = TestOperation()
    let inject = BlockOperation { [unowned operation1, unowned operation2] in
      operation2.input = operation1.output
    }
    
    inject.addDependency(operation1)
    operation2.addDependency(inject)
    
    operation1.input = "1"
    let queue = OperationQueue()
    queue.isSuspended = true
    queue.addOperation(operation1)
    queue.addOperation(operation2)
    queue.addOperation(inject)
    queue.isSuspended = false
    queue.waitUntilAllOperationsAreFinished()
    XCTAssertEqual(operation2.output, "**1**") // ✅ No data races detected on both iOS and macOS
  }
}
