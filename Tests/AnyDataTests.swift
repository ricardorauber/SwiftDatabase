import Foundation
import Quick
import Nimble
@testable import SwiftDatabase

class AnyDataTests: QuickSpec {
    override func spec() {
        
        var anyData: AnyData!
        
        describe("AnyData") {
        
            beforeEach {
                anyData = AnyData()
            }
        
            context("Init") {
            
                it("should create an empty description when no value is used") {
                    expect(anyData.typeDescription) == ""
                    expect(anyData.data).to(beNil())
                }
                
                it("should auto load the information when a value is used") {
                    anyData = AnyData(1)
                    expect(anyData.typeDescription) == "Int"
                    expect(anyData.data).toNot(beNil())
                }
            }
            
            context("set") {
                
                it("should set a codable data") {
                    let result = anyData.set(value: 1)
                    expect(result).to(beTrue())
                    expect(anyData.typeDescription) == "Int"
                    expect(anyData.data).toNot(beNil())
                }
            }
            
            context("get") {
            
                it("should return nil when there is no data") {
                    let result: Int? = anyData.get()
                    expect(result).to(beNil())
                }
                
                it("should return nil for an invalid type") {
                    anyData.set(value: 1)
                    let result: String? = anyData.get()
                    expect(result).to(beNil())
                }
                
                it("should return a valid type") {
                    anyData.set(value: 1)
                    let result: Int? = anyData.get()
                    expect(result).toNot(beNil())
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
