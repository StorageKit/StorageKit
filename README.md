<h3 align="center">
  <img src="https://raw.githubusercontent.com/StorageKit/StorageKit/master/Resources/logo.jpg" alt="StorageKit"/>

  Your Data Storage Troubleshooter 🛠
</h3>

<div align="center">
<img src="https://img.shields.io/cocoapods/v/StorageKit.svg">
<img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat">
<img src="https://cocoapod-badges.herokuapp.com/l/StorageKit/badge.png">
<img src="https://img.shields.io/badge/Swift-3.2-orange.svg">
</div>

<br />

StorageKit is a framework which reduces the complexity of managing a persistent layer. You can easily manage your favorite persistent framework (*Core Data* / *Realm* at the moment), accessing them through a high-level interface.

Our mission is keeping the persistence layer isolated as much as possible from the client codebase. In this way, you can just focus on developing your app. Moreover, you can migrate to another persistent framework easily, keeping the same interface: StorageKit will do almost everything for you.

* Hassle free setup 👍
* Easy to use 🤖
* Extensible 🚀
* Support for background queries 🙌🏼
* Fully tested ( well, almost, ... ☺️ )

*StorageKit* is a **Swift 3** and **XCode 8** compatible project.

# Table of Contents
1. [How it works](#how-it-works)
2. [Define entities](#define-entities)
3. [CRUD](#crud)
3. [Background operations](#background-operations)
4. [Installation](#installation)
5. [Core Mantainers](#core-mantainers)
6. [Known issues](#known-issues)
7. [TODO](#todo)
8. [License](#license)
9. [Credits](#credits)

## How it works
The first step is creating a new `Storage` object with a specific type (either `.CoreData` or `.Realm`) which is the entry-point object to setup `StorageKit`:

```
let storage = StorageKit.addStorage(type: .Realm)
```
or
```
let storage = StorageKit.addStorage(type: .CoreData(dataModelName: "Example")
```

The storage exposes a `context` which is the object you will use to perform the common *CRUD operations*, for instance:

```
storage.mainContext?.fetch(predicate: NSPredicate(format: "done == false"), sortDescriptors: nil, completion: { (fetchedTasks: [RTodoTask]?) in
    self.tasks = fetchedTasks
        // do whatever you want
    }
)
```

or 

```
let task = functionThatRetrieveASpecificTaskFromDatabase()

do {
    try storage.mainContext?.delete(task)
} catch {
    // manage the error specific for CoreData or Realm
}
```

That's it! 🎉

In just few lines of code you are able to use your favorite database (`Storage`) and perform any CRUD operations through the `StorageContext`.

## Define Entities
Both [Core Data](https://developer.apple.com/documentation/coredata/nsmanagedobject) and [Realm](https://realm.io/docs/swift/latest/#models) relies on two base
 objects to define the entities:

![Code Data Entity](https://raw.githubusercontent.com/StorageKit/StorageKit/master/Resources/entity_dog.png)

```
import RealmSwift

class RTodoTask: Object {
    dynamic var name = ""
    dynamic var done = false
    
    override static func primaryKey() -> String? {
        return "taskID"
    }
}
```

*StorageKit is not able to define your entity class. It means that you must define all your entities manually. It's the only thing you have to do by yourself, please bear with us.*

You can create a new entity using in this way:
```
do {
    try let entity: MyEntity = context.create()
} catch {}
```

> If you are using `Realm`, `entity` is an unmanaged object and it should be explicitily added to the database with:

```
do {
    try storage.mainContext?.add(entity)
} catch {}
```

## CRUD
### C as Create

```
do {
    try let entity: MyEntity = context.create()
} catch {}
```

This method creates a new entity object: an `NSManagedObject` for `Core Data` and an `Object` for `Realm`.

Note
> You must create a class entity by yourself before using `StorageKit`. Therefore, for Core Data you must add an entity in the data model, for Realm you must create a new class which extends the base class Object.
> If you are using the Realm configuration, you have to add it in the storage before performing any update operations.


```
do {
    try let entity: MyEntity = context.create()
    entity.myProperty = "Hello"

    try context.add(entity)
} catch {}
```

### R as Read

```
    context.fetch(predicate: nil, sortDescriptors: nil) { (result: [MyEntity]?) in
        // do whatever you want with `result`
    }
```

### U as Update

```
do {
    try context.update {
        entity.myProperty = "Hello"
        entity2.myProperty = "Hello 2"
    }
} catch {}
```

Note
> If you are using the Realm configuration, you have to add the entity in the `storage` (with the method `add`) before performing any update operations.

### D as Delete

```
do {
    try let entity: MyEntity = context.create()
    entity.myProperty = "Hello"

    try context.delete(entity)
} catch {}
```

## Background Operations
Good news for you! `StorageKit` has been implemented with the focus on background operations and concurrency to improve the user experience of your applications and making your life easier 🎉

`Storage` (link to the class once on github) exposes the following method:

```
storage.performBackgroundTask {[weak self] (backgroundContext, backgroundQueue) in
    // the backgroundContext might be nil because of internal errors
    guard let backgroundContext = backgroundContext else { return }
    
    // perform your background CRUD operations here on the `backgroundContext`
    backgroundContext.fetch(predicate: nil, sortDescriptors: nil, completion: {[weak self] (entities: [MyEntity]?) in
    // do something with `entities`
    })
}
```

Now the point is `entities` are retrieved in a background context, so if you need to *use* these entities in another queue (for example in the main one to update the UI), you *must* pass them to the other context through another method exposed by the `Storage`:

```
storage.getThreadSafeEntities(for: context, originalContext: backgroundContext, originalEntities: fetchedTasks, completion: { safeFetchedTaks in
    self?.tasks = safeFetchedTaks
                    
    DispatchQueue.main.async {
        dispatchGroup.leave()
    }
})
```

The method `func getThreadSafeEntities<T: StorageEntityType>(for destinationContext: StorageContext, originalContext: StorageContext, originalEntities: [T], completion: @escaping ([T]) -> Void)` create an array of entity with the same data of `originalEntities` but thread safe, ready to be used in `destinatinationContext`.

This means that, once `getThreadSafeEntities` is called, you will be able to use the entities returned by `completion: @escaping ([T]) -> Void)` in the choosen context.

The common use of this method is:
1. perform a background operation (for instance a fetch) in `performBackgroundTask`
2. move the entities retrieved to the main context using `getThreadSafeEntities`

```
   storage.performBackgroundTask {[weak self] (backgroundContext, backgroundQueue) in
        guard let backgroundContext = backgroundContext else { return }
     
        // 1
        backgroundContext.fetch(predicate: nil, sortDescriptors: nil, completion: {[weak self] (entities: [MyEntity]?) in
            // 2
            storage.getThreadSafeEntities(for: context, originalContext: backgroundContext, originalEntities: entities, completion: { safeEntities in
                self?.entities = safeEntities
            })
        })
    }
```

## Installation
## CocoaPods
Add `StorageKit` to your Podfile

```ruby
use_frameworks!
target 'MyTarget' do
    pod 'StorageKit', '~> 0.1.2'
end
```

```bash
$ pod install
```

## Carthage
```ruby
github "StorageKit/StorageKit" ~> "0.1.2"
```

Then on your application target *Build Phases* settings tab, add a "New Run Script Phase". Create a Run Script with the following content:

```ruby
/usr/local/bin/carthage copy-frameworks
```

and add the following paths under "Input Files":

```ruby
$(SRCROOT)/Carthage/Build/iOS/StorageKit.framework
```

## Core Mantainers 
| Guardians | |
| ------------- | ------------- |
| Ennio Masi | [@ennioma](https://twitter.com/ennioma) |
| Marco Santarossa | [@MarcoSantaDev](https://twitter.com/MarcoSantaDev) |

## Known Issues
* Now it's not possible to exclude `Realm.framework` and `RealmSwift.framework` from the installation;
* UI Test target doesn't work in the example project;

## TODO
* Add a common errors interface
* Remove Realm dependency if not needed (the user can decide between Core Data or Realm)
* Add Reactive interface
* Distribute through the Swift Package Manager
* Add more functionalities to the context
* Add notifications

## License
StorageKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## Credits:
Boxes icon provided by `Nuon Project` ([LLuisa Iborra](https://thenounproject.com/marialuisa.iborra/)). We have changed the boxes color.