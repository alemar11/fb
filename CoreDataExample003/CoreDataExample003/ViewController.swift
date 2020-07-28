//
//  ViewController.swift
//  CoreDataExample003
//
//  Created by Alessandro Marzoli on 02/10/2019.
//  Copyright © 2019 com.alessandromarzoli. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  var frc: NSFetchedResultsController<Car>!
  var dataSource: DataSource!

  @IBAction func clean(_ sender: UIBarButtonItem) {
    context.performAndWait {
      let request = NSFetchRequest<Car>(entityName: "Car")
      request.includesPropertyValues = false
      let cars = try! context.fetch(request)

      cars.forEach { context.delete($0) }
      try! context.save()
    }
  }

  // Adds a new car with a random generated name and plate number
  @IBAction func addCar(_ sender: UIBarButtonItem) {
    context.performAndWait {
      let newCar = Car(context: context)
      let textLength = [5,6,7,8].randomElement()!
      newCar.name = String.random(length: textLength)
      newCar.plateNumber = String.random(length: 3)

      precondition(newCar.name != nil)
      precondition(newCar.plateNumber != nil)

      try! context.save()
    }
  }

  func deleteCar(indexPath: IndexPath) {
    context.performAndWait {
      let id = dataSource.itemIdentifier(for: indexPath)!
      let car = context.object(with: id) as! Car
      context.delete(car)
      try! context.save()
    }
  }

  // Updates only a car plate number
  func updateCar(indexPath: IndexPath) {
    let id = dataSource.itemIdentifier(for: indexPath)!
    let car = context.object(with: id) as! Car
    let textLength = [5,6,7,8].randomElement()!
    let prevPlate = car.plateNumber
    let nextPlate = String.random(length: textLength)
    print(prevPlate, "->", nextPlate)
    car.plateNumber = nextPlate

    precondition(car.name != nil)
    precondition(car.plateNumber != nil)

    try! context.save()
    var s = dataSource.snapshot()
    s.reloadItems([car.objectID])
    dataSource.apply(s, animatingDifferences: true)
  }

  private func makeDataSource() -> DataSource? {
    let ds = DataSource(tableView: self.tableView) { (tableView, indexPath, id) -> UITableViewCell? in
      let cell = tableView.dequeueReusableCell(withIdentifier: Cell.id, for: indexPath) as! Cell
      cell.accessoryType = .disclosureIndicator
      cell.textLabel?.font = .monospacedSystemFont(ofSize: 14.0, weight: .regular)

      // ⚠️ "Attempt to access an object not found in store."
      let car = try! self.context.existingObject(with: id) as! Car
      precondition(car.name != nil)

      cell.name?.text = car.name ?? "⁉️"
      cell.textLabel?.numberOfLines = 1
      cell.plateNumber?.text = car.plateNumber
      cell.plateNumber?.textColor = UIColor.systemRed
      return cell
    }

    ds.defaultRowAnimation = .fade
    return ds
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    dataSource = makeDataSource()!
    self.tableView.delegate = self
    self.tableView.dataSource = dataSource

    let request = NSFetchRequest<Car>(entityName: "Car")
    request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Car.name), ascending: true)]
    frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    frc.delegate = self
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    try! frc.performFetch()
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 70
  }

  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, sourceView, completionHandler) in
      self?.deleteCar(indexPath: indexPath)
      completionHandler(true)
    }

    let rename = UIContextualAction(style: .normal, title: "Update") { [weak self] (action, sourceView, completionHandler) in
      // UITableView must be updated via the UITableViewDiffableDataSource APIs when acting as the UITableView's dataSource: please do not call mutation APIs directly on UITableView.
      self?.updateCar(indexPath: indexPath)
      completionHandler(true)
    }
    let swipeActionConfig = UISwipeActionsConfiguration(actions: [delete, rename])
    swipeActionConfig.performsFirstActionWithFullSwipe = false
    return swipeActionConfig
  }
}

extension ViewController: NSFetchedResultsControllerDelegate {
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
    let s = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
    dataSource.apply(s, animatingDifferences: true)
  }
}

extension String {
  static func random(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyz0123456789"
    return String((1..<length).map{ _ in letters.randomElement()! })
  }
}

class DataSource: UITableViewDiffableDataSource<String, NSManagedObjectID> {
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
}
