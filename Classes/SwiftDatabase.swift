import Foundation

public class SwiftDatabase {
    
    // MARK: - Properties
    
    var data: [String: [Any]] = [:]
}

// MARK: - Tables
extension SwiftDatabase {

    func makeTableName<Item>(name: String? = nil, itemType: Item.Type) -> String {
        name ?? String(describing: Item.self)
    }

    func createTable(name: String) {
        if data[name] == nil {
            data[name] = []
        }
    }
}

// MARK: - Insert
extension SwiftDatabase {
    
    @discardableResult
    public func insert<Item: Codable & Equatable>(on name: String? = nil,
                                           item: Item) -> Bool {
        
        let name = makeTableName(name: name, itemType: Item.self)
        createTable(name: name)
        data[name]?.append(item)
        return true
    }
    
    @discardableResult
    public func insert<Item: Codable & Equatable>(on name: String? = nil,
                                           items: [Item]) -> Bool {
        
        let name = makeTableName(name: name, itemType: Item.self)
        createTable(name: name)
        data[name]?.append(contentsOf: items)
        return true
    }
}
