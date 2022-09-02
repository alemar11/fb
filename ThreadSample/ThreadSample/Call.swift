//
//  Call.swift
//  ThreadSample
//
//  Created by Alessandro Marzoli on 14/06/22.
//

import Foundation

/// VoIP Call
class Call {
  private let stats = Stats()

  func start() {
    WorkerThread.shared.sync2 {
      print("start the call")

      // In the actual implementation, stats are generated later once some other events
      // (in a different thread) occur
      self.stats.start()
    }
  }

  func close() {
    WorkerThread.shared.sync2 {
      print("close the call")
      self.stats.stop()
    }
  }
}

/// Ongoing call stats generator
class Stats {
  func start() {
    WorkerThread.timer.sync2 {
      // In here a Timer is fired to generate stats
      print("start generating call stats")
    }
  }
  
  func stop() {
    WorkerThread.timer.sync2 {
      print("stop stats")
    }
  }
}
