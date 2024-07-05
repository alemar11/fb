# CoreDataExample004

 I've created programmatically a simple model with only a "Book" entity with these attributes:
 - "uniqueID" (UUID)
 - "title" (String)
 - "price" (Decimal)

 Details:
 - "title" has a validation predicate to ensure a length between 3 and 20
 - "price" is defined as Decimal but its accessors use the "primitivePrice" (NSDecimalNumber).

 Steps:
 I've created a sample app to reproduce the issue:
 - If we try to insert a valid book, everything works fine (press the "Create valid book" button)
 - If we try to insert a not valid book (i.e. title with length < 3), the app crashes while printing the error generated during the context save (press the "Create not valid book" button); the catch block doesn't prevent the crash as I was expecting. The problem occurs in unit tests too.

 I've also noticed that if I discard my "price" implementation as Decimal, and I define it as NSDecimalNumber, the app won't crash anymore and the print command will work fine.

 My questions are:
 1. Is this crash really related on how I've implemented the "price" property? If so, is there a better way to define "price" as scalar type?
 
 **DTS**  
 I believe it is the inconsistency between the types of `primitivePrice` and `price` triggering a memory issue, and then the crash. In Core Data, a `primitive<Key>` property acts as the back store of the `<key>` property, so it doesn’t make sense that they have different types.

 If your code simply needs an interface with the `Decimal` type, it makes more sense to add a computed property, such as ”decimalPrice”, to your Book class, doesn’t? 
 
 2. Out of curiosity, why NSEntityDescription "uniquenessConstraints" is defined as [[Any]] ? I was expecting something like [Any].
 
 **DTS**  
 That is relevant to inheritance in Core Data model. For an entity that has a parent entity, `uniquenessConstraints` returns the constraints of both entities:
[ [parent’s constraint1, parent’s constraint2, ...], [child’s constraint1, child’s constraint2, ...] ]
 
 Thanks for the help.
