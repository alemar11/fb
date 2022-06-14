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
    WorkerThread.shared.sync {
      print("start the call")

      // In the actual implementation, stats are generated later once some other events
      // (in a different thread) occur
      self.stats.start()
    }
  }

  func close() {
    WorkerThread.shared.sync {
      print("close the call")
      self.stats.stop()
    }
  }
}

/// Ongoing call stats generator
class Stats {
  func start() {
    WorkerThread.timer.sync {
      // In here a Timer is fired to generate stats
      print("start generatic stats")
    }
  }
  
  func stop() {
    WorkerThread.timer.sync {
      print("stop stats")
    }
  }
}
