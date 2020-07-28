//
//  OperationTests.swift
//  OperationExample002
//
//  Created by Alessandro Marzoli on 20/02/2020.
//  Copyright © 2020 Alessandro Marzoli. All rights reserved.
//

import XCTest

class OperationTests: XCTestCase {
  func test1() {
    let manager = OperationManager1()
    manager.run()
    manager.run()
    manager.run()
    
    while !manager.isReady {
      sleep(1)
      print("not ready")
    }
    print("finish")
  }
  
  func test2() {
    let manager = OperationManager2()
    manager.run()
    manager.run()
    manager.run()
    
    while !manager.isReady {
      sleep(1)
      print("not ready")
    }
    print("finish")
  }
}

class OperationManager1 {
  var isReady: Bool { weakoperation == nil }
  private weak var weakoperation: Operation?
  private let queue: OperationQueue = {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1
    return queue
  }()
  
  func run() {
    if weakoperation != nil { return }
    
    let operation = MyBlockOperation {
      print("✅ MyBlockOperation: running!!")
      sleep(1)
    }
    self.weakoperation = operation
    queue.addOperation(self.weakoperation!)
  }
}

class OperationManager2 {
  var isReady: Bool { weakoperation == nil }
  private weak var weakoperation: Operation?
  private let queue: OperationQueue = {
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1
    return queue
  }()
  
  func run() {
    if weakoperation != nil { return }
    
    let operation = MyOperation()
    self.weakoperation = operation
    queue.addOperation(self.weakoperation!)
  }
}

class MyBlockOperation: BlockOperation {
  deinit {
    print("deinit") // ❌ never called
  }
}

class MyOperation: Operation {
  override func main() {
    print("✅ MyOperation: running!!")
    sleep(1)
  }
  deinit {
    print("deinit")
  }
}
