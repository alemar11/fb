// Questions:
//
// - 1. Why I can’t mark the “user” relationship in CDCurrentUser as NOT optional?
//
// - 2. Why updating the CDUser entity associated with the only CDCurrentUser present in the DB (using the NSMergeByPropertyObjectTrumpMergePolicy), the save operation resets the “user” relationship to nil?

import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as! AppDelegate

@objc(CDCurrentUser)
public class CDCurrentUser: NSManagedObject {
  @NSManaged public var user: CDUser! // <- can't mark is as not optional in the 
  @NSManaged private var uniqueKey: String // a default value is set inside the editor to ensure only a single CDCurrentUser is inserted
  @NSManaged public var customerID: Int
  
  static var defaultFetchRequest: NSFetchRequest<CDCurrentUser> {
    NSFetchRequest<CDCurrentUser>(entityName: String(describing: CDCurrentUser.self))
  }
  
  public static func fetch(in context: NSManagedObjectContext) throws -> CDCurrentUser? {
    let request = defaultFetchRequest
    request.fetchLimit = 2
    request.includesPendingChanges = true
    request.relationshipKeyPathsForPrefetching = [#keyPath(CDCurrentUser.user)]
    
    let result = try context.fetch(request)
    
    if result.count > 1 {
      preconditionFailure("CurrentUser must be unique")
    }
    
    return result.first
  }
}

@objc(CDUser)
public class CDUser: NSManagedObject {
  @NSManaged public var id: Int
  @NSManaged public var name: String!
  @NSManaged public var displayName: String!
  @NSManaged public var currentUser: CDCurrentUser?
  
  static var defaultFetchRequest: NSFetchRequest<CDUser> {
    NSFetchRequest<CDUser>(entityName: String(describing: CDUser.self))
  }
  
  public static func fetch(byID id: Int, in context: NSManagedObjectContext) throws -> CDUser? {
    let request = defaultFetchRequest
    request.fetchLimit = 2
    request.predicate = NSPredicate(format: "\(#keyPath(CDUser.id)) == %d", id)
    
    let result = try context.fetch(request)
    
    if result.count > 1 {
      preconditionFailure("User fetched by id \(id) must be unique")
    }
    
    return result.first
  }
}

class ViewController: UIViewController {

  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    let viewContext = appDelegate.persistentContainer.viewContext // the policy is set to NSMergeByPropertyObjectTrumpMergePolicy
    
    print("=== Make sure to delete the app between multiple runs ===")
    
    do {
      print("> Step 1: insert initial data")
      let user = CDUser(context: viewContext)
      user.id = 1
      user.name = "main"
      user.displayName = "first user"
      
      let user2 = CDUser(context: viewContext)
      user2.id = 2
      user2.name = "2"
      user2.displayName = "second user"
      
      let user3 = CDUser(context: viewContext)
      user3.id = 3
      user3.name = "3"
      user3.displayName = "third user"
      
      let currentUser = CDCurrentUser(context: viewContext)
      currentUser.user = user
      currentUser.customerID = 1
      
      try! viewContext.save()
      viewContext.reset()
    }
    
    do {
      let currentUser = try! CDCurrentUser.fetch(in: viewContext)
      assert(currentUser?.user.id == 1)
      print("CDCurrentUser has user 1 as one-to-one relationship")
      viewContext.reset()
    }
    
    do {
      print("> Step 2: update user 2")
      let user = CDUser(context: viewContext)
      user.id = 2
      user.name = "2 updated"
      user.displayName = "second user updated"
      
      try! viewContext.save()
      viewContext.reset()
    }
    
    do {
      let user2 = try! CDUser.fetch(byID: 2, in: viewContext)
      assert(user2!.name == "2 updated")
      assert(user2!.currentUser == nil)
      print("User 2 has been updated with an UPSERT")
      viewContext.reset()
    }
    
    do {
      print("> Step 3 update the current user")
      let currentUser = try! CDCurrentUser.fetch(in: viewContext)
      currentUser!.customerID = 2
      
      try! viewContext.save()
      viewContext.reset()
    }
    
    do {
      let user1 = try! CDUser.fetch(byID: 1, in: viewContext)
      assert(user1!.name == "main")
      assert(user1!.currentUser?.customerID == 2)
      viewContext.reset()
    }
    
    do {
      print("Step 4 update user 1")
      let user = CDUser(context: viewContext)
      user.id = 1
      user.name = "main updated"
      user.displayName = "display name updated"
      
      // This step won't fix assertion failures below
      // let currentUser = try! CDCurrentUser.fetch(in: viewContext)
      // user.currentUser = currentUser
      
      try! viewContext.save()
      viewContext.reset()
    }
    
    do {
      // If user with id 1 is updated with an UPSERT, it will loose his
      // relationship with current user
      let user1 = try! CDUser.fetch(byID: 1, in: viewContext)
      assert(user1!.name == "main updated")
      assert(user1!.currentUser != nil) // 🔴 failure
      
      let currentUser = try! CDCurrentUser.fetch(in: viewContext)
      assert(currentUser?.user.id == 1) // 🔴 failure
      viewContext.reset()
    }
    
  }

}

