//
//  ViewController.swift
//  DemoApp
//
//  Created by Alessandro Marzoli on 08/11/2019.
//  Copyright © 2019 com.ambrogio. All rights reserved.
//

import UIKit
import Demo

public class Subclass<T>: Test<T> {
  let block: ((Output) -> Void) -> Void

  public init(block: @escaping ((Output) -> Void) -> Void) {
    self.block = block
  }

  public override func run(completion: @escaping (Output) -> Void) {
    block { result in
      print("hello world S1")
      completion(result)
    }
  }
}

public class Subclass2: Test<String> {
  let block: ((Output) -> Void) -> Void

  public init(block: @escaping ((Output) -> Void) -> Void) {
    self.block = block
  }

  public override func run(completion: @escaping (Output) -> Void) {
    block { result in
      print("hello world S2")
      completion(result)
    }
  }
}

class ViewController: UIViewController {
  let s1 = Subclass<String> { completion in
    completion(.success("success"))
  }

  let s2 = Subclass2 { completion in
    completion(.success("success"))
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    s1.start() // EXC_BAD_INSTRUCTION
    s2.start()
  }
}

