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

// MARK: - Read
extension SwiftDatabase {
    
    public func read<Item: Codable & Equatable>(from name: String? = nil,
                                                filter: ((Item) -> Bool) = { _ in true }) -> [Item] {
        
        let name = makeTableName(name: name, itemType: Item.self)
        guard let items = data[name] as? [Item] else { return [] }
        return items.filter { item in filter(item) }
    }
}

// MARK: - Update
extension SwiftDatabase {
    
    @discardableResult
    public func update<Item: Codable & Equatable>(item: Item,
                                                  from name: String? = nil) -> Bool {
        
        let name = makeTableName(name: name, itemType: Item.self)
        guard let items = data[name] as? [Item] else { return false }
        let indexes = items.enumerated().compactMap { $0.element == item ? $0.offset : nil }
        if indexes.count == 0 { return false }
        for index in indexes {
            data[name]?[index] = item
        }
        return true
    }
    
    @discardableResult
    public func update<Item: Codable & Equatable>(items: [Item],
                                                  from name: String? = nil) -> Bool {
        
        for item in items {
            if !update(item: item, from: name) {
                return false
            }
        }
        return true
    }
    
    @discardableResult
    public func updateAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                          from name: String? = nil,
                                                          changes: @escaping (Item) -> Item,
                                                          filter: ((Item) -> Bool) = { _ in true }) -> Bool {
        
        let name = makeTableName(name: name, itemType: Item.self)
        guard let items = data[name] as? [Item] else { return false }
        let indexes = items.enumerated().compactMap { filter($0.element) ? $0.offset : nil }
        if indexes.count == 0 { return false }
        for index in indexes {
            var newItem: Item = items[index]
            newItem = changes(newItem)
            data[name]?[index] = newItem
        }
        return true
    }
}

// MARK: - Delete
extension SwiftDatabase {
    
    @discardableResult
    public func delete<Item: Codable & Equatable>(item: Item,
                                                  from name: String? = nil) -> Bool {
        
        let name = makeTableName(name: name, itemType: Item.self)
        guard let items = data[name] as? [Item] else { return false }
        let indexes = items.enumerated().compactMap { $0.element == item ? $0.offset : nil }
        if indexes.count == 0 { return false }
        for index in indexes.reversed() {
            data[name]?.remove(at: index)
        }
        return true
    }
    
    @discardableResult
    public func delete<Item: Codable & Equatable>(items: [Item],
                                                  from name: String? = nil) -> Bool {
        
        for item in items {
            if !delete(item: item, from: name) {
                return false
            }
        }
        return true
    }
    
    @discardableResult
    public func deleteAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                          from name: String? = nil,
                                                          filter: ((Item) -> Bool) = { _ in true }) -> Bool {
        
        let name = name ?? String(describing: Item.self)
        guard let items = data[name] as? [Item] else { return false }
        let indexes = items.enumerated().compactMap { filter($0.element) ? $0.offset : nil }
        if indexes.count == 0 { return false }
        for index in indexes.reversed() {
            data[name]?.remove(at: index)
        }
        return true
    }
}
