//
//  ViewController.swift
//  CoreDataExample
//
//  Created by Alessandro Marzoli on 08/10/18.
//  Copyright © 2018 Alessandro Marzoli. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

  lazy var container: NSPersistentContainer = {
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

  override func viewDidLoad() {
    super.viewDidLoad()
    populate()
  }

  let data = UIImage(named: "River.jpg")!.pngData()!

  /// Adds 10 images and 10 pictures.
  func populate() {
    let context = container.viewContext
    (0..<10).forEach { i in
      let description1 = Description(context: context)
      description1.content = "\(i)"

      let description2 = Description(context: context)
      description2.content = "\(i)"

      let image = Image(context: context)
      image.info = description1
      image.data = data

      let picture = Picture(context: context)
      picture.info = description2
      picture.data = data
    }
    try! context.save()
  }

  @IBAction func add(_ sender: Any) {
    populate()
  }

  @IBAction func removePictures(_ sender: Any) {
    deleteAllPictures()
  }

  @IBAction func removeImages(_ sender: Any) {
    deleteAllImages()
  }

  /// The batch delete works fine.
  func deleteAllPictures() {
    let context = container.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Picture")
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
    deleteRequest.resultType = .resultTypeCount
    do {
      let result = try context.execute(deleteRequest)
      print(result)
    } catch {
      print(error)
    }
  }

  /// The batch delete causes an error.
  /// Image is a subclass of File (abstract)
  /// I/O error for database. SQLite error code:1, 'no such trigger: ZQ_EDR_ZFILE_ZDATA'
  func deleteAllImages() {
    let context = container.viewContext
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
    deleteRequest.resultType = .resultTypeCount
    do {
      let result = try context.execute(deleteRequest)
      print(result)
    } catch {
      print(error)
    }
  }
  

}

