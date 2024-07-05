import CoreData

// MARK: - NSAttributeDescription

extension NSAttributeDescription {
  public static func decimal(name: String, defaultValue: Decimal? = nil, isOptional: Bool = false) -> NSAttributeDescription {
    let attributes = NSAttributeDescription(name: name, type: .decimalAttributeType)
    attributes.isOptional = isOptional
    attributes.defaultValue = defaultValue.map { NSDecimalNumber(decimal: $0) }
    return attributes
  }

  public static func string(name: String, defaultValue: String? = nil, isOptional: Bool = false) -> NSAttributeDescription {
    let attributes = NSAttributeDescription(name: name, type: .stringAttributeType)
    attributes.isOptional = isOptional
    attributes.defaultValue = defaultValue
    return attributes
  }

  public static func uuid(name: String, defaultValue: UUID? = nil, isOptional: Bool = false) -> NSAttributeDescription {
    let attributes = NSAttributeDescription(name: name, type: .UUIDAttributeType)
    attributes.isOptional = isOptional
    attributes.defaultValue = defaultValue
    return attributes
  }

  private convenience init(name: String, type: NSAttributeType) {
    self.init()
    self.name = name
    self.attributeType = type
  }
}

// MARK: - URL

extension URL {
  public static func dbURL(for name: String) -> URL {
    var dir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    dir.appendPathComponent("\(name).sqlite")
    print(dir)
    return dir
  }
}

// MARK: - NSAttributeDescription
