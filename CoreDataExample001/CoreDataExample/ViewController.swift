//
//  ViewController.swift
//  CoreDataExample
//

import UIKit
import CoreData

class ViewController: UIViewController {
  var container: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Model")
    container.loadPersistentStores { (storeDescription, error) in
      if let error = error {
        print(error)
        fatalError()
      } else if let url = storeDescription.url {
        print(url)
      }
    }
    return container
  }()
  
  let notificationCenter = NotificationCenter.default
  var token: NSObjectProtocol?
  var cars = Set<Car>()

  override func viewDidLoad() {
    super.viewDidLoad()

    /// cleaning between relaunches
    let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
    do {
      let objects = try container.viewContext.fetch(fetchRequest)
      for object in objects {
        container.viewContext.delete(object)
      }
      try container.viewContext.save()
    } catch {
      print(error)
    }

    container.viewContext.automaticallyMergesChangesFromParent = true
    setupNotifications()
  }

  func setupNotifications() {
    let observedContext = container.viewContext
    token = notificationCenter.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: observedContext, queue: nil) { [weak self] notification in
      guard notification.name == .NSManagedObjectContextObjectsDidChange else {
        fatalError("Invalid NSManagedObjectContextObjectsDidChange notification object.")
      }

      let inserted = notification.userInfo?[NSInsertedObjectsKey] as? Set<Car>
      let udpated = notification.userInfo?[NSUpdatedObjectsKey] as? Set<Car>
      let deleted = notification.userInfo?[NSDeletedObjectsKey] as? Set<Car>
      let refreshed = notification.userInfo?[NSRefreshedObjectsKey] as? Set<Car>
      let invalidated = notification.userInfo?[NSInvalidatedObjectsKey] as? Set<Car>

      // make sure that new inserted cars are "in use" by the app
      if let insertedObjects = inserted, !insertedObjects.isEmpty {
        insertedObjects.forEach {
          $0.willAccessValue(forKey: nil)
          self?.cars.insert($0)
        }
      }

      print("-----")
      print("inserted:", inserted?.count ?? 0)
      print("udpated:", udpated?.count ?? 0)
      print("deleted:", deleted?.count ?? 0)
      print("refreshed:", refreshed?.count ?? 0)
      print("invalidated:", invalidated?.count ?? 0)
      print("-----\n")
    }
  }

  @IBAction func addTenCarsPressed(_ sender: UIButton) {
    addSomeCars()
  }

  @IBAction func addTenCarsInViewContextPressed(_ sender: UIButton) {
    addSomeCarsInViewContext()
  }

  @IBAction func updateCar(_ sender: UIButton) {
    updateCar()
  }

  @IBAction func updateCarInViewContext(_ sender: UIButton) {
     updateCarInViewContext()
   }

  @IBAction func deleteCar(_ sender: UIButton) {
    deletedCar()
  }

  func addSomeCars() {
    // adds 10 news cars
    // every time the save is completed, the notification is observed
    let context = container.newBackgroundContext()
    context.performAndWait {
      (0...9).forEach {
        let car = Car(context: context)
        car.id = UUID().uuidString
        car.name = "name-\($0)"
      }
      do {
        try context.save()
      } catch {
        print(error)
      }
    }
  }

  func addSomeCarsInViewContext() {
    // adds 10 news cars
    // every time the save is completed, the notification is observed
    // ❌ on catalyst 2 notifications are sent
    let context = container.viewContext
    context.performAndWait {
      (0...9).forEach {
        let car = Car(context: context)
        car.id = UUID().uuidString
        car.name = "name-\($0)"
      }
      do {
        try context.save()
      } catch {
        print(error)
      }
    }
  }

  func updateCar() {
    // updates a random car
    // a refresh notification is observed
    let context = container.newBackgroundContext()
    context.performAndWait {
      do {
        let request = NSFetchRequest<Car>(entityName: "Car")
        let cars = try context.fetch(request)

        if let randomCar = cars.randomElement() {
          //print("updating \(randomCar.name ?? "noname")")
          let oldName = randomCar.name ?? ""
          randomCar.name = oldName + " 🏁"
          try context.save()
        } else {
          print("⚠️ add some cars first\n")
        }
      } catch {
        print(error)
      }
    }
  }

  func updateCarInViewContext() {
    // updates a random car
    // an update notification is observed
    // ❌ on catalyst 2 notifications are sent
    let context = container.viewContext
    context.performAndWait {
      do {
        let request = NSFetchRequest<Car>(entityName: "Car")
        let cars = try context.fetch(request)

        if let randomCar = cars.randomElement() {
          //print("updating \(randomCar.name ?? "noname")")
          let oldName = randomCar.name ?? ""
          randomCar.name = oldName + " 🏁"
          try context.save()
        } else {
          print("⚠️ add some cars first\n")
        }
      } catch {
        print(error)
      }
    }
  }

  func deletedCar() {
    // deletes a random car
    let context = container.newBackgroundContext()
    context.performAndWait {
      do {
        let request = NSFetchRequest<Car>(entityName: "Car")
        let cars = try context.fetch(request)

        if let randomCar = cars.randomElement() {
          //print("deleting \(randomCar.name ?? "noname")")
          context.delete(randomCar)
          try context.save()
        } else {
          print("⚠️ add some cars first\n")
        }
      } catch {
        print(error)
      }
    }
  }
}
