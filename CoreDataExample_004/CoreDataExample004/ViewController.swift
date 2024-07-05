//
//  ViewController.swift
//  CoreDataExample004
//
//  Created by Alessandro Marzoli on 11/04/21.
//

import UIKit
import Model
import CoreData

let appDelegate = UIApplication.shared.delegate as! AppDelegate

class ViewController: UIViewController {
  let context = appDelegate.persistentContainer.viewContext

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }

  @IBAction func insertValidBook(_ sender: UIButton) {
    _ = context.createValidBook()
    do {
      try context.save()
      print("✅")

      let request = NSFetchRequest<Book>(entityName: "Book")
      let res = try context.count(for: request)
      print("books: \(res)")

    } catch {
      print("❌")
      print(error)
    }
  }

  @IBAction func insertNotValidBook(_ sender: UIButton) {
    // insert in the context a Book instance with a title with length = 1 (min required 3)
    let book = context.createNotValidBook()
    do {
      try context.save()
      print("✅")
    } catch {
      print("❌")
      print(error) // trying to print the error will cause a crash
//      let nserror = error as NSError
//      print(nserror.domain)
//      print(nserror.localizedDescription)
      context.delete(book)
    }
  }

}

