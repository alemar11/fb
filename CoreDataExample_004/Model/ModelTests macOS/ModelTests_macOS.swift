//
//  ModelTests_macOS.swift
//  ModelTests macOS
//
//  Created by Alessandro Marzoli on 11/04/21.
//

import XCTest
import CoreData
@testable import Model

class ModelMacOSTests: XCTestCase {
  lazy var container: NSPersistentContainer = {
    print("-------")
    return NSPersistentContainer.makeContainer()
  }()

  func testExample() throws {
    let context = container.viewContext
    context.createValidBook()
    try context.save()
  }

  func testExample2() throws {
    let context = container.viewContext
    context.createNotValidBook()
    //do {
    try context.save()
//    } catch {
//      print(error)
//    }
  }

}

