//
//  ViewController.swift
//  CoreDataExample005
//
//  Created by Alessandro Marzoli on 20/04/21.
//

import UIKit
import CoreData

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    appDelegate.persistentContainer.performBackgroundTask { (context) in
      try! fill(in: context)
    }
  }

}

func fill(in context: NSManagedObjectContext) throws {
  let fetchRequest = NSFetchRequest<Author>(entityName: "Author")
  let count = try context.count(for: fetchRequest)
  guard count == 0 else {
    print("sample data already created")
    return
  }

  for a in 1...10 {
    let name = "author\(a)"
    print("creating \(name)")
    let author = Author(context: context)
    author.name = name

    for i in 0...10_000 {
      let book = Book(context: context)
      book.uniqueID = UUID()
      book.title = "Book \(i) by \(name)"
      book.author = author
    }
  }
  try context.save()
  print("saved")
}
