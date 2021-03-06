import Foundation
import Quick
import Nimble
@testable import SwiftDatabase

class SwiftDatabaseTests: QuickSpec {
    override func spec() {
        
        var database: SwiftDatabase!
        let timeout: TimeInterval = 3
        
        describe("SwiftDatabase") {
            
            beforeEach {
                database = SwiftDatabase()
            }
            
            context("Init") {
            
                it("should create an empty database without data") {
                    expect(database.tables.count) == 0
                }
                
                it("should create an empty database from an incorrect data parameter") {
                    do {
                        let data = try JSONEncoder().encode(1)
                        database = SwiftDatabase(data: data)
                        expect(database.tables.count) == 0
                    } catch {
                        fail()
                    }
                }
                
                it("should create a database from a correct data parameter") {
                    database.insert(item: Person(id: 0, name: "Mike", age: 25))
                    guard let data = database.data else {
                        fail()
                        return
                    }
                    database = SwiftDatabase(data: data)
                    let items: [Person] = database.read()
                    expect(items.count) == 1
                }
            }
            
            context("Data") {
            
                context("data") {
            
                    it("should get the Data value from an empty database") {
                        let result = database.data
                        expect(result).toNot(beNil())
                    }
                    
                    it("should get the Data value from a database") {
                        database.insert(item: Person(id: 0, name: "Mike", age: 25))
                        let data = database.data
                        expect(data).toNot(beNil())
                    }
                }
                
                context("set(data:)") {
                
                    it("should return false if the data type is incorrect") {
                        do {
                            let data = try JSONEncoder().encode(1)
                            let result = database.set(data: data)
                            expect(result).to(beFalse())
                        } catch {
                            fail()
                        }
                    }
                    
                    it("should return true if the data type is correct") {
                        database.insert(item: Person(id: 0, name: "Mike", age: 25))
                        guard let data = database.data else {
                            fail()
                            return
                        }
                        let result = database.set(data: data)
                        expect(result).to(beTrue())
                        let items: [Person] = database.read()
                        expect(items.count) == 1
                    }
                }
            
                context("clearDatabase") {
            
                    it("should clear the database") {
                        database.insert(item: Person(id: 0, name: "Mike", age: 25))
                        database.clearDatabase()
                        let items: [Person] = database.read()
                        expect(items.count) == 0
                    }
                }
            }
            
            context("Files") {
            
                let fileUrl: URL = {
                    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                    let documentsDirectory = paths[0]
                    return documentsDirectory.appendingPathComponent("database").appendingPathExtension("sdb")
                }()
            
                context("save") {
                    
                    it("should not save the database in an invalid URL") {
                        let url = URL(string: "www.google.com")!
                        let result = database.save(to: url)
                        expect(result).to(beFalse())
                    }
                    
                    it("should save the database in a valid URL") {
                        let result = database.save(to: fileUrl)
                        expect(result).to(beTrue())
                    }
                    
                    it("should save the database in a valid URL from init") {
                        database = SwiftDatabase(fileUrl: fileUrl)
                        let result = database.save()
                        expect(result).to(beTrue())
                    }
                    
                    it("should be false if no url is informed") {
                        let result = database.save()
                        expect(result).to(beFalse())
                    }
                }
                
                context("load") {
                
                    it("should not load the database from an invalid URL") {
                        let url = URL(string: "www.google.com")!
                        let result = database.load(from: url)
                        expect(result).to(beFalse())
                    }
                    
                    it("should load the database from a valid URL") {
                        var items: [Int] = [1, 2, 3]
                        database.deleteAllItems(of: Int.self)
                        database.insert(items: items)
                        var result = database.save(to: fileUrl)
                        expect(result).to(beTrue())
                        database = SwiftDatabase()
                        result = database.load(from: fileUrl)
                        expect(result).to(beTrue())
                        items = database.read()
                        expect(items.count) > 0
                    }
                    
                    it("should load the database from a valid URL from init") {
                        var items: [Int] = [1, 2, 3]
                        database = SwiftDatabase(fileUrl: fileUrl)
                        database.deleteAllItems(of: Int.self)
                        database.insert(items: items)
                        var result = database.save()
                        expect(result).to(beTrue())
                        database = SwiftDatabase(fileUrl: fileUrl)
                        result = database.load()
                        expect(result).to(beTrue())
                        items = database.read()
                        expect(items.count) > 0
                    }
                    
                    it("should be false if no url is informed") {
                        let result = database.load()
                        expect(result).to(beFalse())
                    }
                }
            }
            
            context("Tables") {
            
                context("makeTableName") {
                    
                    it("should return the specified name") {
                        let result = database.makeTableName(name: "test", itemType: Person.self)
                        expect(result) == "test"
                    }
                    
                    it("should return the name of the item type") {
                        let result = database.makeTableName(itemType: Person.self)
                        expect(result) == "Person"
                    }
                }
                
                context("createTable") {
                    
                    it("should create a table if not exists") {
                        expect(database.tables["Int"]).to(beNil())
                        database.createTable(name: "Int")
                        expect(database.tables["Int"]).toNot(beNil())
                        expect(database.tables.count) == 1
                    }
                    
                    it("should create a table if not exists") {
                        database.createTable(name: "Int")
                        expect(database.tables["Int"]).toNot(beNil())
                        expect(database.tables.count) == 1
                        database.createTable(name: "Int")
                        expect(database.tables["Int"]).toNot(beNil())
                        expect(database.tables.count) == 1
                    }
                }
                
                context("setTable") {
                
                    it("should return false if the table doesn't exists") {
                        let result = database.setTable(name: "dummy", rows: [1])
                        expect(result).to(beFalse())
                    }
                    
                    it("should return true if the table exists") {
                        database.insert(item: 1)
                        let result = database.setTable(name: "Int", rows: [2])
                        expect(result).to(beTrue())
                    }
                }
                
                context("getTable") {
                
                    it("should return nil if the table doesn't exists") {
                        let result: [Int]? = database.getTable(name: "Int")
                        expect(result).to(beNil())
                    }
                    
                    it("should return the type if the table exists") {
                        database.insert(item: 1)
                        let result: [Int]? = database.getTable(name: "Int")
                        expect(result).toNot(beNil())
                    }
                }
            }
            
            context("Insert") {
                
                context("Single item") {
                
                    context("Sync") {
                    
                        it("should insert an item without the table name") {
                            let result = database.insert(item: Person(id: 1, name: "Ricardo", age: 35))
                            expect(result).to(beTrue())
                            let table: [Person] = database.read()
                            expect(table.count) == 1
                        }
                        
                        it("should insert an item with the table name") {
                            let result = database.insert(on: "people", item: Person(id: 1, name: "Ricardo", age: 35))
                            expect(result).to(beTrue())
                            let table: [Person] = database.read(from: "people")
                            expect(table.count) == 1
                        }
                        
                        it("should insert a new item when the table already exists") {
                            var result = database.insert(item: Person(id: 1, name: "Ricardo", age: 35))
                            expect(result).to(beTrue())
                            var table: [Person] = database.read()
                            expect(table.count) == 1
                            result = database.insert(item: Person(id: 2, name: "Paul", age: 40))
                            expect(result).to(beTrue())
                            table = database.read()
                            expect(table.count) == 2
                        }
                    }
                
                    context("Async") {
                    
                        it("should insert an item without the table name") {
                            var completed = false
                            database.insertAsync(item: Person(id: 1, name: "Ricardo", age: 35)) { result in
                                expect(result).to(beTrue())
                                let table: [Person] = database.read()
                                expect(table.count) == 1
                                completed = true
                            }
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                        
                        it("should insert an item with the table name") {
                            var completed = false
                            database.insertAsync(on: "people", item: Person(id: 1, name: "Ricardo", age: 35)) { result in
                                expect(result).to(beTrue())
                                let table: [Person] = database.read(from: "people")
                                expect(table.count) == 1
                                completed = true
                            }
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                        
                        it("should insert a new item when the table already exists") {
                            var completed = false
                            database.insertAsync(item: Person(id: 1, name: "Ricardo", age: 35)) { result in
                                expect(result).to(beTrue())
                                var table: [Person] = database.read()
                                expect(table.count) == 1
                                database.insertAsync(item: Person(id: 2, name: "Paul", age: 40)) { result in
                                    expect(result).to(beTrue())
                                    table = database.read()
                                    expect(table.count) == 2
                                    completed = true
                                }
                            }
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                    }
                }
                
                context("Multiple Items") {
                
                    context("Sync") {
                    
                        it("should insert multiple items without the table name") {
                            let items: [Person] = [
                                Person(id: 1, name: "Ricardo", age: 35),
                                Person(id: 2, name: "Paul", age: 40)
                            ]
                            let result = database.insert(items: items)
                            expect(result).to(beTrue())
                            let table: [Person] = database.read()
                            expect(table.count) == 2
                        }
                        
                        it("should insert multiple items with the table name") {
                            let items: [Person] = [
                                Person(id: 1, name: "Ricardo", age: 35),
                                Person(id: 2, name: "Paul", age: 40)
                            ]
                            let result = database.insert(on: "people", items: items)
                            expect(result).to(beTrue())
                            let table: [Person] = database.read(from: "people")
                            expect(table.count) == 2
                        }
                        
                        it("should insert a set of new items when the table already exists") {
                            var result = database.insert(item: Person(id: 0, name: "Mike", age: 25))
                            expect(result).to(beTrue())
                            var table: [Person] = database.read()
                            expect(table.count) == 1
                            let items: [Person] = [
                                Person(id: 1, name: "Ricardo", age: 35),
                                Person(id: 2, name: "Paul", age: 40)
                            ]
                            result = database.insert(items: items)
                            expect(result).to(beTrue())
                            table = database.read()
                            expect(table.count) == 3
                        }
                    }
                    
                    context("Async") {
                    
                        it("should insert multiple items without the table name") {
                            var completed = false
                            let items: [Person] = [
                                Person(id: 1, name: "Ricardo", age: 35),
                                Person(id: 2, name: "Paul", age: 40)
                            ]
                            database.insertAsync(items: items) { result in
                                expect(result).to(beTrue())
                                let table: [Person] = database.read()
                                expect(table.count) == 2
                                completed = true
                            }
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                        
                        it("should insert multiple items with the table name") {
                            var completed = false
                            let items: [Person] = [
                                Person(id: 1, name: "Ricardo", age: 35),
                                Person(id: 2, name: "Paul", age: 40)
                            ]
                            database.insertAsync(on: "people", items: items) { result in
                                expect(result).to(beTrue())
                                let table: [Person] = database.read(from: "people")
                                expect(table.count) == 2
                                completed = true
                            }
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                        
                        it("should insert a set of new items when the table already exists") {
                            var completed = false
                            database.insertAsync(item: Person(id: 0, name: "Mike", age: 25)) { result in
                                expect(result).to(beTrue())
                                var table: [Person] = database.read()
                                expect(table.count) == 1
                                let items: [Person] = [
                                    Person(id: 1, name: "Ricardo", age: 35),
                                    Person(id: 2, name: "Paul", age: 40)
                                ]
                                database.insertAsync(items: items) { result in
                                    expect(result).to(beTrue())
                                    table = database.read()
                                    expect(table.count) == 3
                                    completed = true
                                }
                            }
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                    }
                }
            }
            
            context("Read") {
            
                beforeEach {
                    database.insert(on: "people", item: Person(id: 0, name: "John", age: 50))
                    let items: [Person] = [
                        Person(id: 0, name: "Mike", age: 25),
                        Person(id: 1, name: "Ricardo", age: 35),
                        Person(id: 2, name: "Paul", age: 40)
                    ]
                    database.insert(items: items)
                }
                
                context("Sync") {
                
                    it("should get an empty array from a non existent table") {
                        let result: [Person] = database.read(from: "dummy")
                        expect(result.count) == 0
                    }
                    
                    it("should get an empty array if the table is not from the same item type") {
                        database.insert(on: "dummy", item: 10)
                        let result: [Person] = database.read(from: "dummy")
                        expect(result.count) == 0
                    }
                    
                    it("should read all items from an existing table") {
                        let result: [Person] = database.read()
                        expect(result.count) == 3
                    }
                    
                    it("should read all items from a table with a specific name") {
                        let result: [Person] = database.read(from: "people")
                        expect(result.count) == 1
                    }
                    
                    it("should read all items using a filter") {
                        let result: [Person] = database.read() { item in
                            item.age < 40
                        }
                        expect(result.count) == 2
                    }
                    
                    it("should read all items using a filter from a table with a specific name") {
                        let result: [Person] = database.read(from: "people") { item in
                            item.age >= 40
                        }
                        expect(result.count) == 1
                    }
                }
                
                context("Async") {
                
                    it("should get an empty array from a non existent table") {
                        var completed = false
                        database.readAsync(from: "dummy", itemType: Person.self) { result in
                            expect(result.count) == 0
                            completed = true
                        }
                        expect(completed).toEventually(beTrue(), timeout: timeout)
                    }
                    
                    it("should get an empty array if the table is not from the same item type") {
                        var completed = false
                        database.insert(on: "dummy", item: 10)
                        database.readAsync(from: "dummy", itemType: Person.self) { result in
                            expect(result.count) == 0
                            completed = true
                        }
                        expect(completed).toEventually(beTrue(), timeout: timeout)
                    }
                    
                    it("should read all items from an existing table") {
                        var completed = false
                        database.readAsync(itemType: Person.self) { result in
                            expect(result.count) == 3
                            completed = true
                        }
                        expect(completed).toEventually(beTrue(), timeout: timeout)
                    }
                    
                    it("should read all items from a table with a specific name") {
                        var completed = false
                        database.readAsync(from: "people", itemType: Person.self) { result in
                            expect(result.count) == 1
                            completed = true
                        }
                        expect(completed).toEventually(beTrue(), timeout: timeout)
                    }
                    
                    it("should read all items using a filter") {
                        var completed = false
                        database.readAsync(
                            itemType: Person.self,
                            filter: { item in
                                item.age < 40
                            },
                            completion: { result in
                                expect(result.count) == 2
                                completed = true
                            }
                        )
                        expect(completed).toEventually(beTrue(), timeout: timeout)
                    }
                    
                    it("should read all items using a filter from a table with a specific name") {
                        var completed = false
                        database.readAsync(
                            from: "people",
                            itemType: Person.self,
                            filter: { item in
                                item.age >= 40
                            },
                            completion: { result in
                                expect(result.count) == 1
                                completed = true
                            }
                        )
                        expect(completed).toEventually(beTrue(), timeout: timeout)
                    }
                }
            }
            
            context("Update") {
            
                beforeEach {
                    database.insert(on: "people", item: Person(id: 0, name: "John", age: 50))
                    let items: [Person] = [
                        Person(id: 0, name: "Mike", age: 25),
                        Person(id: 1, name: "Ricardo", age: 35),
                        Person(id: 2, name: "Paul", age: 40)
                    ]
                    database.insert(items: items)
                }
            
                context("Single Item") {
                
                    context("Sync") {
                    
                        it("should return false from a non existent table") {
                            let item = Person(id: 0, name: "Mike", age: 25)
                            let result = database.update(item: item, from: "dummy")
                            expect(result).to(beFalse())
                        }
                        
                        it("should return false from a non existent item") {
                            let item = Person(id: 99, name: "Steve", age: 55)
                            let result = database.update(item: item)
                            expect(result).to(beFalse())
                        }
                        
                        it("should return true when the update worked") {
                            let item = Person(id: 0, name: "Mike", age: 26)
                            let result = database.update(item: item)
                            expect(result).to(beTrue())
                            let items: [Person] = database.read { item in
                                item.id == 0
                            }
                            expect(items.count) == 1
                            expect(items.first?.age) == 26
                        }
                    }
                
                    context("Async") {
                    
                        it("should return false from a non existent table") {
                            var completed = false
                            let item = Person(id: 0, name: "Mike", age: 25)
                            database.updateAsync(item: item, from: "dummy") { result in
                                expect(result).to(beFalse())
                                completed = true
                            }
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                        
                        it("should return false from a non existent item") {
                            var completed = false
                            let item = Person(id: 99, name: "Steve", age: 55)
                            database.updateAsync(item: item) { result in
                                expect(result).to(beFalse())
                                completed = true
                            }
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                        
                        it("should return true when the update worked") {
                            var completed = false
                            let item = Person(id: 0, name: "Mike", age: 26)
                            database.updateAsync(item: item) { result in
                                expect(result).to(beTrue())
                                let items: [Person] = database.read { item in
                                    item.id == 0
                                }
                                expect(items.count) == 1
                                expect(items.first?.age) == 26
                                completed = true
                            }
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                    }
                }
            
                context("Multiple Items") {
                
                    context("Sync") {
                    
                        it("should return false from a non existent table") {
                            let items: [Person] = [
                                Person(id: 0, name: "Mike", age: 25)
                            ]
                            let result = database.update(items: items, from: "dummy")
                            expect(result).to(beFalse())
                        }
                        
                        it("should return false from non existent items") {
                            let items: [Person] = [
                                Person(id: 99, name: "Steve", age: 55)
                            ]
                            let result = database.update(items: items)
                            expect(result).to(beFalse())
                        }
                        
                        it("should return true when the update worked") {
                            let items: [Person] = [
                                Person(id: 0, name: "Mike", age: 26),
                                Person(id: 1, name: "Richard", age: 35)
                            ]
                            let result = database.update(items: items)
                            expect(result).to(beTrue())
                            let results: [Person] = database.read { item in
                                item.id == 0 || item.id == 1
                            }
                            expect(results.count) == 2
                            expect(results.first?.age) == 26
                            expect(results.last?.name) == "Richard"
                        }
                    }
                
                    context("Async") {
                    
                        it("should return false from a non existent table") {
                            var completed = false
                            let items: [Person] = [
                                Person(id: 0, name: "Mike", age: 25)
                            ]
                            database.updateAsync(items: items, from: "dummy") { result in
                                expect(result).to(beFalse())
                                completed = true
                            }
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                        
                        it("should return false from non existent items") {
                            var completed = false
                            let items: [Person] = [
                                Person(id: 99, name: "Steve", age: 55)
                            ]
                            database.updateAsync(items: items) { result in
                                expect(result).to(beFalse())
                                completed = true
                            }
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                        
                        it("should return true when the update worked") {
                            var completed = false
                            let items: [Person] = [
                                Person(id: 0, name: "Mike", age: 26),
                                Person(id: 1, name: "Richard", age: 35)
                            ]
                            database.updateAsync(items: items) { result in
                                expect(result).to(beTrue())
                                let results: [Person] = database.read { item in
                                    item.id == 0 || item.id == 1
                                }
                                expect(results.count) == 2
                                expect(results.first?.age) == 26
                                expect(results.last?.name) == "Richard"
                                completed = true
                            }
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                    }
                }
                
                context("All Items") {
                
                    context("Sync") {
                
                        it("should return false from a non existent table") {
                            let result = database.updateAllItems(
                                of: Person.self,
                                from: "dummy",
                                changes: { item in
                                    var item = item
                                    item.age = item.age + 1
                                    return item
                                }
                            )
                            expect(result).to(beFalse())
                        }
                        
                        it("should return false from non existent items") {
                            let result = database.updateAllItems(
                                of: Person.self,
                                changes: { item in
                                    var item = item
                                    item.age = item.age + 1
                                    return item
                                },
                                filter: { item in
                                    item.id == 99
                                }
                            )
                            expect(result).to(beFalse())
                        }
                        
                        it("should return true when the update worked") {
                            let result = database.updateAllItems(
                                of: Person.self,
                                changes: { item in
                                    var item = item
                                    item.age = 0
                                    return item
                                }
                            )
                            expect(result).to(beTrue())
                            let results: [Person] = database.read()
                            expect(results.count) == 3
                            for person in results {
                                expect(person.age) == 0
                            }
                        }
                        
                        it("should return true when the update worked with filter") {
                            let result = database.updateAllItems(
                                of: Person.self,
                                changes: { item in
                                    var item = item
                                    item.age = 0
                                    return item
                                },
                                filter: { item in
                                    item.age < 40
                                }
                            )
                            expect(result).to(beTrue())
                            let results: [Person] = database.read(filter: { item in
                                item.age < 40
                            })
                            expect(results.count) == 2
                            for person in results {
                                expect(person.age) == 0
                            }
                        }
                    }
                    
                    context("Async") {
                
                        it("should return false from a non existent table") {
                            var completed = false
                            database.updateAllItemsAsync(
                                of: Person.self,
                                from: "dummy",
                                changes: { item in
                                    var item = item
                                    item.age = item.age + 1
                                    return item
                                },
                                completion: { result in
                                    expect(result).to(beFalse())
                                    completed = true
                                }
                            )
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                        
                        it("should return false from non existent items") {
                            var completed = false
                            database.updateAllItemsAsync(
                                of: Person.self,
                                changes: { item in
                                    var item = item
                                    item.age = item.age + 1
                                    return item
                                },
                                filter: { item in
                                    item.id == 99
                                },
                                completion: { result in
                                    expect(result).to(beFalse())
                                    completed = true
                                }
                            )
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                        
                        it("should return true when the update worked") {
                            var completed = false
                            database.updateAllItemsAsync(
                                of: Person.self,
                                changes: { item in
                                    var item = item
                                    item.age = 0
                                    return item
                                },
                                completion: { result in
                                    expect(result).to(beTrue())
                                    let results: [Person] = database.read()
                                    expect(results.count) == 3
                                    for person in results {
                                        expect(person.age) == 0
                                    }
                                    completed = true
                                }
                            )
                            
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                        
                        it("should return true when the update worked with filter") {
                            var completed = false
                            database.updateAllItemsAsync(
                                of: Person.self,
                                changes: { item in
                                    var item = item
                                    item.age = 0
                                    return item
                                },
                                filter: { item in
                                    item.age < 40
                                },
                                completion: { result in
                                    expect(result).to(beTrue())
                                    let results: [Person] = database.read(filter: { item in
                                        item.age < 40
                                    })
                                    expect(results.count) == 2
                                    for person in results {
                                        expect(person.age) == 0
                                    }
                                    completed = true
                                }
                            )
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                        
                        it("should return true when the update worked with filter from a table with specific name") {
                            var completed = false
                            database.updateAllItemsAsync(
                                of: Person.self,
                                from: "people",
                                changes: { item in
                                    var item = item
                                    item.age = 0
                                    return item
                                },
                                filter: { item in
                                    item.age >= 40
                                },
                                completion: { result in
                                    expect(result).to(beTrue())
                                    let results: [Person] = database.read(from: "people", filter: { item in
                                        item.age < 40
                                    })
                                    expect(results.count) == 1
                                    for person in results {
                                        expect(person.age) == 0
                                    }
                                    completed = true
                                }
                            )
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                    }
                }
            }
            
            context("Delete") {
            
                beforeEach {
                    database.insert(on: "people", item: Person(id: 0, name: "John", age: 50))
                    let items: [Person] = [
                        Person(id: 0, name: "Mike", age: 25),
                        Person(id: 1, name: "Ricardo", age: 35),
                        Person(id: 2, name: "Paul", age: 40)
                    ]
                    database.insert(items: items)
                }
                
                context("Single Item") {
                
                    context("Sync") {
                
                        it("should return false from a non existent table") {
                            let item = Person(id: 0, name: "Mike", age: 25)
                            let result = database.delete(item: item, from: "dummy")
                            expect(result).to(beFalse())
                        }
                        
                        it("should return false from a non existent item") {
                            let item = Person(id: 99, name: "Steve", age: 55)
                            let result = database.delete(item: item)
                            expect(result).to(beFalse())
                        }
                        
                        it("should return true when the removal worked") {
                            let item = Person(id: 0, name: "Mike", age: 26)
                            let result = database.delete(item: item)
                            expect(result).to(beTrue())
                            let items: [Person] = database.read { item in
                                item.id == 0
                            }
                            expect(items.count) == 0
                        }
                    }
                
                    context("Async") {
                
                        it("should return false from a non existent table") {
                            var completed = false
                            let item = Person(id: 0, name: "Mike", age: 25)
                            database.deleteAsync(item: item, from: "dummy") { result in
                                expect(result).to(beFalse())
                                completed = true
                            }
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                        
                        it("should return false from a non existent item") {
                            var completed = false
                            let item = Person(id: 99, name: "Steve", age: 55)
                            database.deleteAsync(item: item) { result in
                                expect(result).to(beFalse())
                                completed = true
                            }
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                        
                        it("should return true when the removal worked") {
                            var completed = false
                            let item = Person(id: 0, name: "Mike", age: 26)
                            database.deleteAsync(item: item) { result in
                                expect(result).to(beTrue())
                                let items: [Person] = database.read { item in
                                    item.id == 0
                                }
                                expect(items.count) == 0
                                completed = true
                            }
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                    }
                }
                
                context("Multiple Items") {
                
                    context("Sync") {
                    
                        it("should return false from a non existent table") {
                            let items: [Person] = [
                                Person(id: 0, name: "Mike", age: 25)
                            ]
                            let result = database.delete(items: items, from: "dummy")
                            expect(result).to(beFalse())
                        }
                        
                        it("should return false from non existent items") {
                            let items: [Person] = [
                                Person(id: 99, name: "Steve", age: 55)
                            ]
                            let result = database.delete(items: items)
                            expect(result).to(beFalse())
                        }
                        
                        it("should return true when the update worked") {
                            let items: [Person] = [
                                Person(id: 0, name: "Mike", age: 26),
                                Person(id: 1, name: "Richard", age: 35)
                            ]
                            let result = database.delete(items: items)
                            expect(result).to(beTrue())
                            let results: [Person] = database.read { item in
                                item.id == 0 || item.id == 1
                            }
                            expect(results.count) == 0
                        }
                    }
                
                    context("Async") {
                    
                        it("should return false from a non existent table") {
                            var completed = false
                            let items: [Person] = [
                                Person(id: 0, name: "Mike", age: 25)
                            ]
                            database.deleteAsync(items: items, from: "dummy") { result in
                                expect(result).to(beFalse())
                                completed = true
                            }
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                        
                        it("should return false from non existent items") {
                            var completed = false
                            let items: [Person] = [
                                Person(id: 99, name: "Steve", age: 55)
                            ]
                            database.deleteAsync(items: items) { result in
                                expect(result).to(beFalse())
                                completed = true
                            }
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                        
                        it("should return true when the update worked") {
                            var completed = false
                            let items: [Person] = [
                                Person(id: 0, name: "Mike", age: 26),
                                Person(id: 1, name: "Richard", age: 35)
                            ]
                            database.deleteAsync(items: items) { result in
                                expect(result).to(beTrue())
                                let results: [Person] = database.read { item in
                                    item.id == 0 || item.id == 1
                                }
                                expect(results.count) == 0
                                completed = true
                            }
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                    }
                }
                
                context("All Items") {
                
                    context("Sync") {
                
                        it("should return false from a non existent table") {
                            let result = database.deleteAllItems(
                                of: Person.self,
                                from: "dummy"
                            )
                            expect(result).to(beFalse())
                        }
                        
                        it("should return false from non existent items") {
                            let result = database.deleteAllItems(
                                of: Person.self,
                                filter: { item in
                                    item.id == 99
                                }
                            )
                            expect(result).to(beFalse())
                        }
                        
                        it("should return true when the update worked") {
                            let result = database.deleteAllItems(
                                of: Person.self
                            )
                            expect(result).to(beTrue())
                            let results: [Person] = database.read()
                            expect(results.count) == 0
                        }
                        
                        it("should return true when the update worked with filter") {
                            let result = database.deleteAllItems(
                                of: Person.self,
                                filter: { item in
                                    item.age < 40
                                }
                            )
                            expect(result).to(beTrue())
                            let results: [Person] = database.read(filter: { item in
                                item.age < 40
                            })
                            expect(results.count) == 0
                        }
                    }
                
                    context("Async") {
                
                        it("should return false from a non existent table") {
                            var completed = false
                            database.deleteAllItemsAsync(
                                of: Person.self,
                                from: "dummy",
                                completion: { result in
                                    expect(result).to(beFalse())
                                    completed = true
                                }
                            )
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                        
                        it("should return false from non existent items") {
                            var completed = false
                            database.deleteAllItemsAsync(
                                of: Person.self,
                                filter: { item in
                                    item.id == 99
                                },
                                completion: { result in
                                    expect(result).to(beFalse())
                                    completed = true
                                }
                            )
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                        
                        it("should return true when the update worked") {
                            var completed = false
                            database.deleteAllItemsAsync(
                                of: Person.self,
                                completion: { result in
                                    expect(result).to(beTrue())
                                    let results: [Person] = database.read()
                                    expect(results.count) == 0
                                    completed = true
                                }
                            )
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                        
                        it("should return true when the update worked with filter") {
                            var completed = false
                            database.deleteAllItemsAsync(
                                of: Person.self,
                                filter: { item in
                                    item.age < 40
                                },
                                completion: { result in
                                    expect(result).to(beTrue())
                                    let results: [Person] = database.read(filter: { item in
                                        item.age < 40
                                    })
                                    expect(results.count) == 0
                                    completed = true
                                }
                            )
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                        
                        it("should return true when the update worked with filter from a table with specific name") {
                            var completed = false
                            database.deleteAllItemsAsync(
                                of: Person.self,
                                from: "people",
                                filter: { item in
                                    item.age >= 40
                                },
                                completion: { result in
                                    expect(result).to(beTrue())
                                    let results: [Person] = database.read(from: "people", filter: { item in
                                        item.age >= 40
                                    })
                                    expect(results.count) == 0
                                    completed = true
                                }
                            )
                            expect(completed).toEventually(beTrue(), timeout: timeout)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Test Helpers
private struct Person: Codable, Equatable {

    var id: Int
    var name: String
    var age: Int
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
