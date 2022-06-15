//
//  ViewController.swift
//  ThreadSample
//
//  Created by Alessandro Marzoli on 14/06/22.
//

import Cocoa

class ViewController: NSViewController {

  @IBAction func start(_ sender: Any) {
    (1...1000).forEach { i in
      print(i)
      let call = Call()
      call.start()
      call.close()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

