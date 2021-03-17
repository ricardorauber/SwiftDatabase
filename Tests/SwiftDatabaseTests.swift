import Foundation
import Quick
import Nimble
@testable import SwiftDatabase

class SwiftDatabaseTests: QuickSpec {
    override func spec() {
        
        var database: SwiftDatabase!
        
        describe("SwiftDatabase") {
            
            beforeEach {
                database = SwiftDatabase()
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
                        expect(database.data["Int"]).to(beNil())
                        database.createTable(name: "Int")
                        expect(database.data["Int"]).toNot(beNil())
                        expect(database.data.count) == 1
                    }
                    
                    it("should create a table if not exists") {
                        database.createTable(name: "Int")
                        expect(database.data["Int"]).toNot(beNil())
                        expect(database.data.count) == 1
                        database.createTable(name: "Int")
                        expect(database.data["Int"]).toNot(beNil())
                        expect(database.data.count) == 1
                    }
                }
            }
            
            context("Insert") {
                
                context("Single item") {
                    
                    it("should insert an item without the table name") {
                        let result = database.insert(item: Person(id: 1, name: "Ricardo", age: 35))
                        expect(result).to(beTrue())
                        expect(database.data["Person"]?.count) == 1
                    }
                    
                    it("should insert an item with the table name") {
                        let result = database.insert(on: "people", item: Person(id: 1, name: "Ricardo", age: 35))
                        expect(result).to(beTrue())
                        expect(database.data["people"]?.count) == 1
                    }
                    
                    it("should insert a new item when the table already exists") {
                        var result = database.insert(item: Person(id: 1, name: "Ricardo", age: 35))
                        expect(result).to(beTrue())
                        expect(database.data["Person"]?.count) == 1
                        result = database.insert(item: Person(id: 2, name: "Paul", age: 40))
                        expect(result).to(beTrue())
                        expect(database.data["Person"]?.count) == 2
                    }
                }
                
                context("Multiple Items") {
                    
                    it("should insert multiple items without the table name") {
                        let items: [Person] = [
                            Person(id: 1, name: "Ricardo", age: 35),
                            Person(id: 2, name: "Paul", age: 40)
                        ]
                        let result = database.insert(items: items)
                        expect(result).to(beTrue())
                        expect(database.data["Person"]?.count) == 2
                    }
                    
                    it("should insert multiple items with the table name") {
                        let items: [Person] = [
                            Person(id: 1, name: "Ricardo", age: 35),
                            Person(id: 2, name: "Paul", age: 40)
                        ]
                        let result = database.insert(on: "people", items: items)
                        expect(result).to(beTrue())
                        expect(database.data["people"]?.count) == 2
                    }
                    
                    it("should insert a set of new items when the table already exists") {
                        var result = database.insert(item: Person(id: 0, name: "Mike", age: 25))
                        expect(result).to(beTrue())
                        expect(database.data["Person"]?.count) == 1
                        let items: [Person] = [
                            Person(id: 1, name: "Ricardo", age: 35),
                            Person(id: 2, name: "Paul", age: 40)
                        ]
                        result = database.insert(items: items)
                        expect(result).to(beTrue())
                        expect(database.data["Person"]?.count) == 3
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
            }
            
            context("Update") {
            
                beforeEach {
                    let items: [Person] = [
                        Person(id: 0, name: "Mike", age: 25),
                        Person(id: 1, name: "Ricardo", age: 35),
                        Person(id: 2, name: "Paul", age: 40)
                    ]
                    database.insert(items: items)
                }
            
                context("Single Item") {
                    
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
