# SwiftDatabase - A light Swift database to use in your apps

[![Build Status](https://travis-ci.com/ricardorauber/SwiftDatabase.svg?branch=main)](http://travis-ci.com/)
[![CocoaPods Version](https://img.shields.io/cocoapods/v/SwiftDatabase.svg?style=flat)](http://cocoadocs.org/docsets/SwiftDatabase)
[![License](https://img.shields.io/cocoapods/l/SwiftDatabase.svg?style=flat)](http://cocoadocs.org/docsets/SwiftDatabase)
[![Platform](https://img.shields.io/cocoapods/p/SwiftDatabase.svg?style=flat)](http://cocoadocs.org/docsets/SwiftDatabase)

## TL; DR

`SwiftDatabase` is a light Swift-like database that you can use on your projects, check this out:

```swift
let database = SwiftDatabase()

database.insert(item: Person(id: 0, name: "Ricardo", age: 35))
database.insert(item: Person(id: 1, name: "Mike", age: 23))
database.insert(item: Person(id: 2, name: "Paul", age: 40))

let people: [Person] = database.read { person in
    person.age > 30
}
print(people) // [Ricardo, Paul]
```

## SwiftDatabase

Databases are really important in many kinds of apps. There are already many different solutions out there with incredible capabilities such as cloud synchronization. Why I made this framework then? Well, in many projects I have used Realm, CoreData and SQLite, for instance, but all of them need some customization in the code that increase dependency. I have always thought on building a database where my code will not even know that it is a database, it would think that it is just a new kind of set or dictionary. But I know that showing some code is better than large texts, so let's dig into it.

## Setup

#### CocoaPods

If you are using CocoaPods, add this to your Podfile and run `pod install`.

```Ruby
target 'Your target name' do
    pod 'SwiftDatabase', '~> 1.1'
end
```

#### Manual Installation

If you want to add it manually to your project, without a package manager, just copy all files from the `Classes` folder to your project.

## Usage

#### Creating the Database

To create an instance of the database, you only need to import the framework and instantiate the `SwiftDatabase` class:

```swift
import SwiftDatabase
let database = SwiftDatabase()
```

`SwiftDatabase` uses `JSONEncoder` and `JSONDecoder` to handle the storage of your data, so you can use your custom objects at the initialization or, if you already have some `Data` from a previous session, you can use it at the `init` as well. You can also specify a file url to save and load from:

```swift
let database = SwiftDatabase(
    encoder: myEncoder,
    decoder: myDecoder,
    data: databaseData,
    fileUrl: URL
)
```

#### Loading and Saving Data

Where did I get this `Data` from? Well, there is a property for that.

```swift
let databaseData: Data? = database.data
```

Also, you can load the data later on (it will replace the current data):

```swift
guard let databaseData = databaseData else { return }
database.set(data: databaseData)
```

That's great for runtime, but what about persistence? You can use the `save` and `load` methods to store your database in the file system, for instance:

```swift
database.save()
database.load()
```

You can also specify the file url in these methods:

```swift
database.save(to: fileUrl)
database.load(from: fileUrl)
```

If no file url is informed at init or as a parameter, it will return `false`.

### CRUD

First things first, let's understand how the database works. You can use any kind of `Codable & Equatable` object without any other customization. So, let's take a look at a sample object that we will use here:

```swift
struct Person: Codable, Equatable {

    var id: Int
    var name: String
    var age: Int
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
```

As you can see, it is very simple and it only uses `Swift` stuff, that's all we need to use `SwiftDatabase`. But you may ask, why the `id` property? We need a way to identify the objects and this is a very simple way. You can define your own way to handle the `Equatable` protocol, but it will be used on `SwiftDatabase` for queries.

Every "table" in `SwiftDatabase` is an `array` of items of the same type. You can choose a name for the table if you want, otherwise `SwiftDatabase` will use the name of the type of the object. It will be easy to see in the next topics.

#### Primary Key

`SwiftDatabase` is not a relational database, actually it is as simple as a set of arrays. Because of that, there is no primary or foreign keys, every query will use the `Equatable` protocol to diferentiate objects.

#### Insert

Let's start inserting some data in our database, it is as easy as this:

```swift
let ricardo = Person(id: 0, name: "Ricardo", age: 35)

database.insert(item: ricardo)
```

That's it! `SwiftDatabase` will create a table of the type `Person` and add the object into it, cool right? But if you want to have a different set of `Person`, you can give a name to the table:

```swift
let steve = Person(id: 1, name: "Steve", age: 50)

database.insert(on: "VIP", item: steve)
```

Now, `SwiftDatabase` has a table called `VIP` with an array of `Person`.

Another thing is that you can add multiple values at the same time:

```swift
let people: [Person] = [
    Person(id: 0, name: "Ricardo", age: 35),
    Person(id: 1, name: "Steve", age: 50)
]

database.insert(items: people)
```
#### Read

Now that we have some records in our database, it is time to retrieve them, so we will use the `read` method for that. The cool thing is that you can read all records or use a filter to get only what you need:

```swift
let people: [Person] = database.read()

let vip: [Person] = database.read(from: "VIP")

let adults: [Person] = database.read { person in
    person.age > 18
}
```

Note that `SwiftDatabase` will use type inference to get the correct object types and also use it for the table name, if not informed.

#### Update

For updating your records, you can use the `update` and `updateAllItems` methods. The first one will update a given item or a set of given items. 

```swift
var steve = Person(id: 1, name: "Steve", age: 50)
database.insert(item: steve)

steve.age = steve.age + 1
database.update(item: steve)
...
database.update(item: steve, from: "VIP")
...
database.update(items: [steve, ricardo])
```

The second method, `updateAllItems`, will update all items using a filter just like in the `read` method.

```swift
database.updateAllItems(
    of: Person.self,
    changes: { person in
        var person = person
        person.age = person.age + 1
        return person
    },
    filter: { person in
        person.age >= 18
    }
)
```

#### Delete

Last, but not least, you can delete some items just like you can do in the `update` method:

```swift
database.delete(item: ricardo)
...
database.delete(item: steve, from: "VIP")
...
database.delete(items: [ricardo, steve])
```

Or you can also use a filter for that:

```swift
database.deleteAllItems(
    of: Person.self,
    filter: { person in
        person.age < 18
    }
)
```

### Async Operations

`SwiftDatabase` also supports asynchronous operations. You can even set the quality of service that suits better your needs (the default is `.utility`):

```swift
database.qos = .background

database.insertAsync(item: Person(id: 1, name: "Steve", age: 50)) { result in
    print(result) // true
    self.database.readAsync(itemType: Person.self) { people in
        print(people) // [Person(id: 1, name: "Steve", age: 50)]
    }
}
```

## Thanks 👍

The creation of this framework was possible thanks to these awesome people:

* Poatek: [https://poatek.com/](https://poatek.com/)
* Hacking with Swift: [https://www.hackingwithswift.com/](https://www.hackingwithswift.com/)
* Ricardo Rauber: [http://ricardorauber.com/](http://ricardorauber.com/)

## Feedback is welcome

If you notice any issue, got stuck or just want to chat feel free to create an issue. We will be happy to help you.

## License

SwiftDatabase is released under the [MIT License](LICENSE).
