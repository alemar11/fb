//
//  WorkerThread.swift
//  ThreadSample
//
//  Created by Alessandro Marzoli on 14/06/22.
//

import Foundation

final class WorkerThread: Thread {
  convenience init(name: String, qualityOfService: QualityOfService ) {
    self.init()
    self.name = name
    self.qualityOfService = qualityOfService
  }

  override func main() {
    autoreleasepool {
      RunLoop.current.add(Port(), forMode: .default) // required or the RunLoop will exit immediatly
      RunLoop.current.run()
    }
  }

  override func cancel() {
    fatalError("\(name ?? String(describing: type(of: self))) doesn't support cancellation.")
  }
}

extension WorkerThread {
  /// Thread used to work with PJSIP api.
  static let shared: WorkerThread = {
    let thread = WorkerThread(name: "PJSIP Thread", qualityOfService: .userInitiated)
    thread.start()
    return thread
  }()
}

extension WorkerThread {
  static let timer: WorkerThread = {
    let thread = WorkerThread(name: "Timer Thread", qualityOfService: .userInitiated)
    thread.start()
    return thread
  }()
}

extension Thread {
  typealias Block = @convention(block) () -> Void

  /// Perform work on current thread asynchronously.
  /// - parameter block: Process to be executed.
  func async(execute work: @escaping Block) {
    perform(#selector(run(block:)), on: self, with: work as AnyObject, waitUntilDone: false)
  }

  /// Perform work on current thread asynchronously after a delay.
  /// - Parameters:
  ///   - delay: The minimum time after which the work is processed. Specifying a delay of 0 does not necessarily cause the work to be performed immediately.
  ///   - work: Process to be executed.
  func async(afterDelay delay: TimeInterval, execute work: @escaping Block) {
    // internally sets up a timer to perform the selector message on the current thread’s run loop.
    perform(#selector(run(block:)), with: work as AnyObject, afterDelay: delay)
  }

  /// Performs work on current thread synchronously.
  /// - parameter work: Process to be executed.
//  func sync<T>(execute work: () throws -> T) rethrows -> T {
//    guard Thread.current !== self else {
//      return try work()
//    }
//
//    return try _syncHelper(execute: work, rescue: { throw $0 }) // 🚩 random crash
//    //return try _syncHelper2(execute: work, rescue: { throw $0 }) // ⚠️ it crashes rarely but the solution is not that great
//  }

  func sync<T>(execute work: @escaping () throws -> T) rethrows -> T {
    guard Thread.current !== self else {
      return try work()
    }

    return try _syncHelper3(execute: work, rescue: { throw $0 })
  }

  private func _syncHelper3<T>(execute work: @escaping () throws -> T, rescue: ((Swift.Error) throws -> (T))) rethrows -> T {

      var result: T?
      var error: Swift.Error?
      let task: (@convention(block) () -> Void)? = {
        do {
          result = try work()
        } catch let catchedError {
          error = catchedError
        }
      }
      perform(#selector(run(block:)), on: self, with: task, waitUntilDone: true)

      if let error = error {
        return try rescue(error)
      } else {
        return result!
      }
  }

  private func _syncHelper2<T>(execute work: () throws -> T, rescue: ((Swift.Error) throws -> (T))) rethrows -> T {
    return try withoutActuallyEscaping(work) { _work in
      var result: T?
      var error: Swift.Error?
      weak var wTask: AnyObject?
      autoreleasepool {
        let task: (@convention(block) () -> Void)? = {
          do {
            result = try _work()
          } catch let catchedError {
            error = catchedError
          }
        }
        wTask = task as AnyObject
        perform(#selector(run(block:)), on: self, with: wTask, waitUntilDone: true)
      }

      while wTask != nil {
        print("task is retained")
      }
      assert(wTask == nil)

      if let error = error {
        return try rescue(error)
      } else {
        return result!
      }
    }
  }

  @objc private func run(block: Block) {
    block()
  }
}

