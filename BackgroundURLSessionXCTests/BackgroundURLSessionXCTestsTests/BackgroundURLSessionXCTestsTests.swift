//
//  BackgroundURLSessionXCTestsTests.swift
//  BackgroundURLSessionXCTestsTests
//
//  Created by Alessandro Marzoli on 30/11/2018.
//

import XCTest
@testable import BackgroundURLSessionXCTests

class BackgroundURLSessionXCTestsTests: XCTestCase {

  let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1")!

  func testExample() {
    let expectation = self.expectation(description: "\(#function)\(#line)")
    let delegate = Delegate()
    let configuration = URLSessionConfiguration.background(withIdentifier: "Test")

    delegate.onCompletion = { error in
      XCTAssertNil(error)
      print("\n")
      print(error?.localizedDescription ?? "No Description") // unknown error
      print("\n")
      expectation.fulfill()
    }

    let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)

    let task = session.downloadTask(with: url)
    //let task = session.dataTask(with: url) // same error as for downloadTask
    task.resume()

    waitForExpectations(timeout: 20)
  }

}

public class Delegate: NSObject, URLSessionDelegate  {
  var onCompletion: ((Error?) -> Void)?
  public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    onCompletion?(error)
  }
}

extension Delegate: URLSessionDataDelegate {
  public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    print("didReceiveData")
  }

}
