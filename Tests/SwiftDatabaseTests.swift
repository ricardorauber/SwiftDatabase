import Foundation
import Quick
import Nimble
@testable import SwiftDatabase

class SwiftDatabaseTests: QuickSpec {
    override func spec() {
        
        var database: SwiftDatabase!
        
        describe("SwiftDatabase") {
            
            context("CRUD") {
                    
                beforeEach {
                    database = SwiftDatabase()
                }
                
                context("Insert") {
                
                    it("should insert a row without the table name") {
                        let row = Person(id: 1, name: "Ricardo", age: 35)
                        let result = database.insert(item: row)
                        expect(result).to(beTrue())
                        expect(database.data["Person"]?.count) == 1
                    }
                    
                    it("should insert a row with the table name") {
                        let row = Person(id: 1, name: "Ricardo", age: 35)
                        let result = database.insert(on: "people", item: row)
                        expect(result).to(beTrue())
                        expect(database.data["people"]?.count) == 1
                    }
                    
                    it("should insert a new row when the table already exists") {
                        var result = database.insert(item: Person(id: 1, name: "Ricardo", age: 35))
                        expect(result).to(beTrue())
                        expect(database.data["Person"]?.count) == 1
                        result = database.insert(item: Person(id: 2, name: "Paul", age: 40))
                        expect(result).to(beTrue())
                        expect(database.data["Person"]?.count) == 2
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
