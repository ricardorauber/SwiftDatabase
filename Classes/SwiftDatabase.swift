import Foundation

public class SwiftDatabase {

    // MARK: - Dependencies
    
    public var encoder: JSONEncoder
    public var decoder: JSONDecoder
    
    // MARK: - Properties
    
    var fileUrl: URL?
    var tables: [String: AnyData] = [:]
    
    // MARK: - Initialization
    
    public init(data: Data? = nil,
                fileUrl: URL? = nil,
                encoder: JSONEncoder = JSONEncoder(),
                decoder: JSONDecoder = JSONDecoder()) {
                
        self.encoder = encoder
        self.decoder = decoder
        self.fileUrl = fileUrl
        tables = [:]
        if let data = data {
            set(data: data)
        }
    }
}

// MARK: - Data
extension SwiftDatabase {

    public var data: Data? {
        try? encoder.encode(tables)
    }
    
    @discardableResult
    public func set(data: Data) -> Bool {
        guard let tables = try? decoder.decode([String: AnyData].self, from: data) else { return false }
        self.tables = tables
        return true
    }
}

// MARK: - Files
extension SwiftDatabase {
    
    @discardableResult
    public func save(to fileUrl: URL) -> Bool {
        var result = false
        if let data = data {
            do {
                try data.write(to: fileUrl)
                result = true
            } catch {}
        }
        return result
    }
    
    @discardableResult
    public func save() -> Bool {
        guard let fileUrl = fileUrl else { return false }
        return save(to: fileUrl)
    }

    @discardableResult
    public func load(from fileUrl: URL) -> Bool {
        do {
            let data = try Data(contentsOf: fileUrl)
            return set(data: data)
        } catch {
            return false
        }
    }

    @discardableResult
    public func load() -> Bool {
        guard let fileUrl = fileUrl else { return false }
        return load(from: fileUrl)
    }
}

// MARK: - Tables
extension SwiftDatabase {

    func makeTableName<Item: Codable & Equatable>(name: String? = nil, itemType: Item.Type) -> String {
        name ?? String(describing: Item.self)
    }

    func createTable(name: String) {
        if tables[name] == nil {
            tables[name] = AnyData()
        }
    }
    
    @discardableResult
    func setTable<Type: Codable & Equatable>(name: String, rows: Type) -> Bool {
        tables[name]?.set(value: rows) ?? false
    }
    
    func getTable<Type: Codable & Equatable>(name: String) -> Type? {
        if let anyData = tables[name] {
            return anyData.get()
        }
        return nil
    }
}

// MARK: - Insert
extension SwiftDatabase {

    @discardableResult
    public func insert<Item: Codable & Equatable>(on name: String,
                                                  item: Item) -> Bool {
        let name = makeTableName(name: name, itemType: Item.self)
        createTable(name: name)
        var rows: [Item] = getTable(name: name) ?? []
        rows.append(item)
        return setTable(name: name, rows: rows)
    }

    @discardableResult
    public func insert<Item: Codable & Equatable>(item: Item) -> Bool {
        let name = makeTableName(name: nil, itemType: Item.self)
        return insert(on: name, item: item)
    }

    @discardableResult
    public func insert<Item: Codable & Equatable>(on name: String,
                                                  items: [Item]) -> Bool {
        let name = makeTableName(name: name, itemType: Item.self)
        createTable(name: name)
        var rows: [Item] = getTable(name: name) ?? []
        rows.append(contentsOf: items)
        return setTable(name: name, rows: rows)
    }

    @discardableResult
    public func insert<Item: Codable & Equatable>(items: [Item]) -> Bool {
        let name = makeTableName(name: nil, itemType: Item.self)
        return insert(on: name, items: items)
    }
}

// MARK: - Read
extension SwiftDatabase {

    public func read<Item: Codable & Equatable>(from name: String,
                                                filter: ((Item) -> Bool)) -> [Item] {
        let name = makeTableName(name: name, itemType: Item.self)
        let items: [Item] = getTable(name: name) ?? []
        return items.filter { item in filter(item) }
    }

    public func read<Item: Codable & Equatable>(filter: ((Item) -> Bool)) -> [Item] {
        let name = makeTableName(name: nil, itemType: Item.self)
        return read(from: name, filter: filter)
    }

    public func read<Item: Codable & Equatable>(from name: String) -> [Item] {
        let name = makeTableName(name: name, itemType: Item.self)
        let filter: ((Item) -> Bool) = { _ in true }
        let items: [Item] = getTable(name: name) ?? []
        return items.filter { item in filter(item) }
    }

    public func read<Item: Codable & Equatable>() -> [Item] {
        let name = makeTableName(name: nil, itemType: Item.self)
        let filter: ((Item) -> Bool) = { _ in true }
        return read(from: name, filter: filter)
    }
}

// MARK: - Update
extension SwiftDatabase {

    @discardableResult
    public func update<Item: Codable & Equatable>(item: Item,
                                                  from name: String) -> Bool {
        let name = makeTableName(name: name, itemType: Item.self)
        var items: [Item] = getTable(name: name) ?? []
        let indexes = items.enumerated().compactMap { $0.element == item ? $0.offset : nil }
        if indexes.count == 0 { return false }
        for index in indexes {
            items[index] = item
        }
        return setTable(name: name, rows: items)
    }

    @discardableResult
    public func update<Item: Codable & Equatable>(item: Item) -> Bool {
        let name = makeTableName(name: nil, itemType: Item.self)
        return update(item: item, from: name)
    }

    @discardableResult
    public func update<Item: Codable & Equatable>(items: [Item],
                                                  from name: String) -> Bool {
        for item in items {
            if !update(item: item, from: name) {
                return false
            }
        }
        return true
    }

    @discardableResult
    public func update<Item: Codable & Equatable>(items: [Item]) -> Bool {
        let name = makeTableName(name: nil, itemType: Item.self)
        return update(items: items, from: name)
    }

    @discardableResult
    public func updateAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                          from name: String,
                                                          changes: @escaping (Item) -> Item,
                                                          filter: ((Item) -> Bool)) -> Bool {
        let name = makeTableName(name: name, itemType: Item.self)
        var items: [Item] = getTable(name: name) ?? []
        let indexes = items.enumerated().compactMap { filter($0.element) ? $0.offset : nil }
        if indexes.count == 0 { return false }
        for index in indexes {
            var newItem: Item = items[index]
            newItem = changes(newItem)
            items[index] = newItem
        }
        return setTable(name: name, rows: items)
    }

    @discardableResult
    public func updateAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                          changes: @escaping (Item) -> Item,
                                                          filter: ((Item) -> Bool)) -> Bool {
        let name = makeTableName(name: nil, itemType: Item.self)
        return updateAllItems(of: itemType, from: name, changes: changes, filter: filter)
    }

    @discardableResult
    public func updateAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                          from name: String,
                                                          changes: @escaping (Item) -> Item) -> Bool {
        let filter: ((Item) -> Bool) = { _ in true }
        return updateAllItems(of: itemType, from: name, changes: changes, filter: filter)
    }

    @discardableResult
    public func updateAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                          changes: @escaping (Item) -> Item) -> Bool {
        let name = makeTableName(name: nil, itemType: Item.self)
        let filter: ((Item) -> Bool) = { _ in true }
        return updateAllItems(of: itemType, from: name, changes: changes, filter: filter)
    }
}

// MARK: - Delete
extension SwiftDatabase {

    @discardableResult
    public func delete<Item: Codable & Equatable>(item: Item,
                                                  from name: String) -> Bool {
        let name = makeTableName(name: name, itemType: Item.self)
        var items: [Item] = getTable(name: name) ?? []
        let indexes = items.enumerated().compactMap { $0.element == item ? $0.offset : nil }
        if indexes.count == 0 { return false }
        for index in indexes.reversed() {
            items.remove(at: index)
        }
        return setTable(name: name, rows: items)
    }

    @discardableResult
    public func delete<Item: Codable & Equatable>(item: Item) -> Bool {
        let name = makeTableName(name: nil, itemType: Item.self)
        return delete(item: item, from: name)
    }

    @discardableResult
    public func delete<Item: Codable & Equatable>(items: [Item],
                                                  from name: String) -> Bool {
        for item in items {
            if !delete(item: item, from: name) {
                return false
            }
        }
        return true
    }

    @discardableResult
    public func delete<Item: Codable & Equatable>(items: [Item]) -> Bool {
        let name = makeTableName(name: nil, itemType: Item.self)
        return delete(items: items, from: name)
    }

    @discardableResult
    public func deleteAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                          from name: String,
                                                          filter: ((Item) -> Bool)) -> Bool {

        let name = makeTableName(name: name, itemType: Item.self)
        var items: [Item] = getTable(name: name) ?? []
        let indexes = items.enumerated().compactMap { filter($0.element) ? $0.offset : nil }
        if indexes.count == 0 { return false }
        for index in indexes.reversed() {
            items.remove(at: index)
        }
        return setTable(name: name, rows: items)
    }

    @discardableResult
    public func deleteAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                          filter: ((Item) -> Bool)) -> Bool {

        let name = makeTableName(name: nil, itemType: Item.self)
        return deleteAllItems(of: itemType, from: name, filter: filter)
    }

    @discardableResult
    public func deleteAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                          from name: String) -> Bool {
        let filter: ((Item) -> Bool) = { _ in true }
        return deleteAllItems(of: itemType, from: name, filter: filter)
    }

    @discardableResult
    public func deleteAllItems<Item: Codable & Equatable>(of itemType: Item.Type) -> Bool {
        let name = makeTableName(name: nil, itemType: Item.self)
        let filter: ((Item) -> Bool) = { _ in true }
        return deleteAllItems(of: itemType, from: name, filter: filter)
    }
}

// MARK: - SwiftDatabaseProtocol
extension SwiftDatabase: SwiftDatabaseProtocol {}
