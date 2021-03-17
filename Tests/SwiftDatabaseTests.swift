import Foundation
import Quick
import Nimble
@testable import SwiftDatabase

class SwiftDatabaseTests: QuickSpec {
    override func spec() {
        
        var database: SwiftDatabase!
        
        describe("SwiftDatabase") {
            
            context("dummy") {
                    
                beforeEach {
                    database = SwiftDatabase()
                }
                
                it("should do something") {
                    expect(database.dummy()).to(beTrue())
                }
            }
        }
    }
}
