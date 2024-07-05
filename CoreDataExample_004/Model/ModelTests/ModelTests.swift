import XCTest
import CoreData
@testable import Model

class ModelTests: XCTestCase {
  lazy var container: NSPersistentContainer = {
    return Model.makeContainer()
  }()
  
  func testExample() throws {
    let context = container.viewContext
    _ = context.createValidBook()
    try context.save()
  }
  
  func testExample2() throws {
    let context = container.viewContext
    _ = context.createNotValidBook()
    do {
      try context.save()
    } catch {
      print(error)
    }
  }
  
}

