//
//  AppDelegate.swift
//  CoreDataExample005
//
//  Created by Alessandro Marzoli on 20/04/21.
//

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
        print("⚠️ Migration from V1 to V2 needed")

        let mapping = try! NSMappingModel.inferredMappingModel(forSourceModel: v1Model, destinationModel: v2Model)

        print("➡️ Migration started")
        let manager = NSMigrationManager(sourceModel: v1Model, destinationModel: v2Model)
        //let manager = MyMigrationManager(sourceModel: v1Model, destinationModel: v2Model)

        // Progress:
        // ❌ 1. If the migration is done using NSMigrationManager (no subclass) with usesStoreSpecificMigrationManager set to true, migrationProgress isn't updated
        // ✅ 2. If the migration is done using NSMigrationManager (no subclass) with usesStoreSpecificMigrationManager set to true, migrationProgress is updated
        // ✅ 3. If the migration is done using MyMigrationManager (a NSMigrationManager subclass), migrationProgress is updated (usesStoreSpecificMigrationManager can be set to true or false regardless)
        let token = manager.observe(\.migrationProgress, options: [.new]) { (manager, change) in
          print("🚩🚩 \(String(describing: change.newValue))")
        }

        // with usesStoreSpecificMigrationManager set to false or with MyMigrationManager we can't do a "in place migration", we need to specify a different destination URL for the migration
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

internal final class MyMigrationManager: NSMigrationManager {


  // MARK: NSObject
  override func didChangeValue(forKey key: String) {
    super.didChangeValue(forKey: key)
    guard key == #keyPath(NSMigrationManager.migrationProgress) else { return }
    print("🚩 \(migrationProgress)")
  }

  override func cancelMigrationWithError(_ error: Error) {
    super.cancelMigrationWithError(error)
  }
}
