# CoreDataExample005

 I'm trying to understand how to report migrations progress to the users.  
 I've started my investigation testing how to observe NSMigrationManager "migrationProgress" property.  
 While it works fine for heavyweight migrations, I've noticed that it doesn't work with lightweight ones:  

 ### Case 1
 NSMigrationManager "migrationProgress" property isn't updated during a lightweight migration unless the "usesStoreSpecificMigrationManager" is the to false.
 Once "usesStoreSpecificMigrationManager" is set to false, I'm able to observe "migrationProgress" but the migration phase is way longer, it consumes more memory and the the migration cannot happen "in place" anymore (I need to specify a different destination URL).

### Case 2
 I've created a subclass of NSMigrationManager, MyMigrationManager, and I've used it to do the migration; I'm able to observe "migrationProgress" (in this scenario setting "usesStoreSpecificMigrationManager" to true or false doesn't matter) but the tradeoff are the same as in Case 1: longer migration time and more memory usage.

 Is it possible to have some insights on how to properly do it?
 Am I missing something? Which is the role of the "usesStoreSpecificMigrationManager" property? the documentation didn't help me that much.
 Thanks

**DTS**  
The behavior you see is as-designed, as mentioned in the following API reference of `usesStoreSpecificMigrationManager`:
“A store-specific migration manager class is not guaranteed to perform any of the migration manager delegate callbacks or update values for the observable properties."
This also explains that a store-specific migration manager has a better performance because it can ignore the delegate callbacks and key value observations.
When you use a custom `NSMigrationManager`, Core Data ignores `usesStoreSpecificMigrationManager`, because you are using a custom manager class.

---

 I've prepared a sample project here: https://github.com/alemar11/CoreDataExample005

### Test 1 (default)
 - The first time the app is launched, it will populate the database with some data (read the target outputs).
 - The second time the app is launched, it will try to do a migration from v1 to v2 using NSMigrationManager with "usesStoreSpecificMigrationManager" se to true.
 - The progress won't be reported. ❌

### Test 2 (usesStoreSpecificMigrationManager set to false)
 - Uninstall the app and change "usesStoreSpecificMigrationManager" to false (AppDelegate, line 74).
 - The first time the app is launched, it will populate the database with some data (read the target outputs).
 - The second time the app is launched, it will try to do a migration from v1 to v2.
 The progress will be reported. ✅

### Test 2 (MyMigrationManager)
 - Uninstall the app and change in AppDelegate, line 59:
    let manager = NSMigrationManager(sourceModel: v1Model, destinationModel: v2Model)
    with
    let manager = MyMigrationManager(sourceModel: v1Model, destinationModel: v2Model)
 - The first time the app is launched, it will populate the database with some data (read the target outpus).
 - The second time the app is launched, it will try to do a migration from v1 to v2.
 The progress will be reported. ✅

