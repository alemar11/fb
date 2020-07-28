//
//  CancelAndProgressTests.swift
//  OperationExample001Tests
//
//  Created by Alessandro Marzoli on 07/05/2020.
//  Copyright © 2020 com.alessandromarzoli. All rights reserved.
//

import Foundation

import XCTest
@testable import OperationExample001

class CancelAndProgressTests: XCTestCase {
  func testOperationCancellationWhileReportingProgress() {
    let currentProgress = Progress(totalUnitCount: 1)
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1
    queue.isSuspended = true

    let operation1 = BlockOperation { sleep(1); print("operation 1 executed") }
    let operation2 = BlockOperation { sleep(1); print("operation 2 executed") }
    let operation3 = BlockOperation { sleep(1); print("operation 3 executed") }
    let operation5 = BlockOperation { sleep(1); print("operation 5 executed") }
    let operation4 = BlockOperation { [unowned operation5] in
      OperationQueue.current!.progress.totalUnitCount -= 1 // 🚩 is this the right approach?
      operation5.cancel()
      sleep(1);
      print("operation 4 executed")
    }

    let expectation0 = self.expectation(description: "Progress is completed")

    queue.progress.totalUnitCount = 5
    queue.addOperation(operation1)
    queue.addOperation(operation2)
    queue.addOperation(operation3)
    queue.addOperation(operation4)
    queue.addOperation(operation5)

    currentProgress.addChild(queue.progress, withPendingUnitCount: 1)

    let token = currentProgress.observe(\.fractionCompleted, options: [.initial, .old, .new]) { (progress, change) in
      print(progress.fractionCompleted, progress.localizedAdditionalDescription ?? "")

      if progress.completedUnitCount == 1 && progress.fractionCompleted == 1.0 {
        expectation0.fulfill()
      }
    }

    queue.isSuspended = false
    wait(for: [expectation0], timeout: 10)
    token.invalidate()
  }
}
