import CoreData

public func makeContainer() -> NSPersistentContainer {
  let model = makeManagedObjectModel()
  let container = NSPersistentContainer(name: "Model", managedObjectModel: model)
  let description = NSPersistentStoreDescription()
  description.url = URL.dbURL(for: "Model")
  container.persistentStoreDescriptions = [description]

  container.loadPersistentStores(completionHandler: { (_, error) in
    guard let error = error as NSError? else { return }
    fatalError("###\(#function): Failed to load persistent stores:\(error)")
  })

  container.viewContext.automaticallyMergesChangesFromParent = true

  return container
}

func makeManagedObjectModel() -> NSManagedObjectModel {
  let managedObjectModel = NSManagedObjectModel()
  let book = makeBookEntity()
  managedObjectModel.entities = [book]
  return managedObjectModel
}

private func makeBookEntity() -> NSEntityDescription {
  var entity = NSEntityDescription()
  entity = NSEntityDescription()
  entity.name = String(describing: Book.self)
  entity.managedObjectClassName = String(describing: Book.self)

  let uniqueID = NSAttributeDescription.uuid(name: #keyPath(Book.uniqueID))
  uniqueID.isOptional = false

  let title = NSAttributeDescription.string(name: #keyPath(Book.title))
  title.isOptional = false
  let rule = (NSPredicate(format: "length >= 3 AND length <= 20"),"Title must have a length between 3 and 20 chars.")
  title.setValidationPredicates([rule.0], withValidationWarnings: [rule.1])

  let price = NSAttributeDescription.decimal(name: #keyPath(Book.price))
  price.isOptional = false

  entity.properties = [uniqueID, title, price]
  entity.uniquenessConstraints = [[#keyPath(Book.uniqueID)]]
  return entity
}

@objc(Book)
public class Book: NSManagedObject {
  @NSManaged public var uniqueID: UUID
  @NSManaged public var title: String

  //@NSManaged var price: NSDecimalNumber

  @NSManaged private var primitivePrice: NSDecimalNumber
  @objc var price: Decimal {
    get {
      willAccessValue(forKey: #keyPath(Book.price))
      defer { didAccessValue(forKey: #keyPath(Book.price)) }
      return primitivePrice.decimalValue
      //let pv = primitiveValue(forKey: #keyPath(Book.price)) as! NSDecimalNumber
      //return pv.decimalValue
    }
    set {
      willChangeValue(forKey: #keyPath(Book.price))
      defer { didChangeValue(forKey: #keyPath(Book.price)) }
      //setPrimitiveValue(NSDecimalNumber(decimal: newValue), forKey: #keyPath(Book.price))
      primitivePrice = NSDecimalNumber(decimal: newValue)
    }
  }
}

public extension NSManagedObjectContext {
  func createValidBook() -> Book {
    let book = Book(context: self)
    //book.price = NSDecimalNumber(decimal: 3.3333333333)
    book.price = Decimal(3.3333333333)
    book.title = "book title"
    book.uniqueID = UUID()
    return book
  }

  func createNotValidBook() -> Book {
    let book = Book(context: self)
    //book.price = NSDecimalNumber(decimal: 10.11)
    book.price = Decimal(10.11)
    book.title = "b" // length must be >= 3 and <= 20
    book.uniqueID = UUID()
    return book
  }
}
