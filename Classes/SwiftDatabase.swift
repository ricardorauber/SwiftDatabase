import Foundation

public class SwiftDatabase {

    // MARK: - Dependencies
    
    public var encoder: JSONEncoder
    public var decoder: JSONDecoder
    
    // MARK: - Properties
    
    var tables: [String: AnyData] = [:]
    
    // MARK: - Initialization
    
    public init(data: Data? = nil,
                encoder: JSONEncoder = JSONEncoder(),
                decoder: JSONDecoder = JSONDecoder()) {
                
        self.encoder = encoder
        self.decoder = decoder
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

    public func load(from fileUrl: URL) -> Bool {
        do {
            let data = try Data(contentsOf: fileUrl)
            return set(data: data)
        } catch {
            return false
        }
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
    public func insert<Item: Codable & Equatable>(on name: String? = nil,
                                                  item: Item) -> Bool {

        let name = makeTableName(name: name, itemType: Item.self)
        createTable(name: name)
        var rows: [Item] = getTable(name: name) ?? []
        rows.append(item)
        return setTable(name: name, rows: rows)
    }

    @discardableResult
    public func insert<Item: Codable & Equatable>(on name: String? = nil,
                                                  items: [Item]) -> Bool {

        let name = makeTableName(name: name, itemType: Item.self)
        createTable(name: name)
        var rows: [Item] = getTable(name: name) ?? []
        rows.append(contentsOf: items)
        return setTable(name: name, rows: rows)
    }
}

// MARK: - Read
extension SwiftDatabase {

    public func read<Item: Codable & Equatable>(from name: String? = nil,
                                                filter: ((Item) -> Bool) = { _ in true }) -> [Item] {

        let name = makeTableName(name: name, itemType: Item.self)
        let items: [Item] = getTable(name: name) ?? []
        return items.filter { item in filter(item) }
    }
}

// MARK: - Update
extension SwiftDatabase {

    @discardableResult
    public func update<Item: Codable & Equatable>(item: Item,
                                                  from name: String? = nil) -> Bool {

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
}

// MARK: - Delete
extension SwiftDatabase {

    @discardableResult
    public func delete<Item: Codable & Equatable>(item: Item,
                                                  from name: String? = nil) -> Bool {

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
        var items: [Item] = getTable(name: name) ?? []
        let indexes = items.enumerated().compactMap { filter($0.element) ? $0.offset : nil }
        if indexes.count == 0 { return false }
        for index in indexes.reversed() {
            items.remove(at: index)
        }
        return setTable(name: name, rows: items)
    }
}
