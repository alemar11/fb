//
//  ViewController.swift
//  ThreadSample
//
//  Created by Alessandro Marzoli on 14/06/22.
//

import Cocoa
import os.log

class ViewController: NSViewController {
  let logger = Logger(subsystem: "test", category: "time")

  @IBAction func start(_ sender: Any) {
    let start = DispatchTime.now()
    defer {
      let end = DispatchTime.now()
      let nanoseconds = end.uptimeNanoseconds - start.uptimeNanoseconds
      let timeInterval = Double(nanoseconds) / 1_000_000_000
      logger.log("Executed in \(timeInterval, format: .fixed(precision: 2), privacy: .public) seconds.")
    }
    (1...10_000).forEach { i in
      //print(i)
      let call = Call()
      call.start()
      call.close()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

