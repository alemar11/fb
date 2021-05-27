import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as! AppDelegate

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  // MARK: - Core Data stack

  lazy var persistentContainer: NSPersistentContainer = {
    let dbURL = getDocumentsDirectory().appendingPathComponent("CoreDataExample005.sqlite")
    let description = NSPersistentStoreDescription(url: dbURL)
    description.shouldMigrateStoreAutomatically = false
    description.shouldInferMappingModelAutomatically = false
    description.url = dbURL

    let momdURL = Bundle.main.url(forResource: "CoreDataExample005", withExtension: "momd", subdirectory: nil)!
    let momV1URL = momdURL.appendingPathComponent("CoreDataExample005.mom")
    let momV2URL = momdURL.appendingPathComponent("CoreDataExample005V2.mom")
    let v1Model = NSManagedObjectModel(contentsOf: momV1URL)!
    let v2Model = NSManagedObjectModel(contentsOf: momV2URL)!

    var model = v1Model // model used by the container

    if FileManager.default.fileExists(atPath: dbURL.path) {
      let metadata = try! NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType,
                                                                                  at: dbURL,
                                                                                  options: nil)
      let isMigrationNeeded = !v2Model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
      model = v2Model

      if isMigrationNeeded {
        print("Migration from V1 to V2 needed")

        // ✅ Inferred mapping model works fine
        //let mapping = try! NSMappingModel.inferredMappingModel(forSourceModel: v1Model, destinationModel: v2Model)

        // ⚠️ Custom mapping model doesn't work unless we adjust programatically the version hashes
        let migrationFile = Bundle.main.url(forResource: "V1toV2", withExtension: "cdm")!
        var mapping = NSMappingModel(contentsOf: migrationFile)!

        var entityMappings = [NSEntityMapping]()
        for em in mapping.entityMappings {
          let sourceName = em.sourceEntityName!
          let mappingSourceHash = em.sourceEntityVersionHash!
          let sourceHash = v1Model.entityVersionHashesByName[sourceName]!
          if mappingSourceHash != sourceHash, v1Model.entitiesByName[sourceName]!.canBugMigration() {
            print("BUG: adjusting the sourceEntityVersionHash")
            em.sourceEntityVersionHash = sourceHash
          }
          let destName = em.destinationEntityName!
          let mappingDestHash = em.destinationEntityVersionHash!
          let destHash = v2Model.entityVersionHashesByName[destName]!
          if mappingDestHash != destHash, v2Model.entitiesByName[destName]!.canBugMigration() {
            print("BUG: adjusting the destinationEntityVersionHash")
            em.destinationEntityVersionHash = destHash
          }
          entityMappings.append(em)
        }
        mapping.entityMappings = entityMappings

        print("➡️ Migration started")
        let manager = NSMigrationManager(sourceModel: v1Model, destinationModel: v2Model)
        let tempURL = getDocumentsDirectory().appendingPathComponent("CoreDataExample005v2.sqlite")

        let start = DispatchTime.now()
        manager.usesStoreSpecificMigrationManager = true
        try! manager.migrateStore(from: dbURL,
                             sourceType: NSSQLiteStoreType,
                             options: nil,
                             with: mapping,
                             toDestinationURL: tempURL,
                             destinationType: NSSQLiteStoreType,
                             destinationOptions: nil)
        let end = DispatchTime.now()

        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel())
        try! persistentStoreCoordinator.replacePersistentStore(at: dbURL,
                                                              destinationOptions: nil,
                                                              withPersistentStoreFrom: tempURL,
                                                              sourceOptions: nil,
                                                              ofType: NSSQLiteStoreType)
        try! persistentStoreCoordinator.destroyPersistentStore(at: tempURL,
                                                               ofType: NSSQLiteStoreType,
                                                               options: nil)

        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000_000
        print("✅ Migration done in: \(timeInterval) seconds")
      } else {
        print("▶️ Migration from V1 to V2 NOT needed")
      }
    } else {
      print("➡️ Starting with V1")
    }

    let container = NSPersistentContainer(name: "CoreDataExample005", managedObjectModel: model)
    container.persistentStoreDescriptions = [description]
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
}

func getDocumentsDirectory() -> URL {
  let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
  let documentsDirectory = paths[0]
  return documentsDirectory
}

private extension NSEntityDescription {
    func canBugMigration() -> Bool {
      properties.compactMap { $0 as?  NSDerivedAttributeDescription }.count != 0
    }
}
