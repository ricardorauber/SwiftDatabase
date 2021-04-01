import Foundation

open class SwiftDatabase: SwiftDatabaseProtocol {
    
    // MARK: - Dependencies
    
    open var encoder: JSONEncoder
    open var decoder: JSONDecoder
    
    // MARK: - Properties
    
    open var fileUrl: URL?
    open var qos: DispatchQoS.QoSClass = .utility
    var tables: [String: AnyData] = [:]
    
    // MARK: - Initialization
    
    public init(encoder: JSONEncoder = JSONEncoder(),
                decoder: JSONDecoder = JSONDecoder(),
                data: Data? = nil,
                fileUrl: URL? = nil) {
        
        self.encoder = encoder
        self.decoder = decoder
        self.fileUrl = fileUrl
        tables = [:]
        if let data = data {
            set(data: data)
        }
        if let fileUrl = fileUrl {
            load(from: fileUrl)
        }
    }

    // MARK: - Data
    
    open var data: Data? {
        try? encoder.encode(tables)
    }
    
    @discardableResult
    open func set(data: Data) -> Bool {
        guard let tables = try? decoder.decode([String: AnyData].self, from: data) else { return false }
        self.tables = tables
        return true
    }
    
    open func clearDatabase() {
        tables = [:]
    }

    // MARK: - Files
    
    @discardableResult
    open func save(to fileUrl: URL) -> Bool {
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
    open func save() -> Bool {
        guard let fileUrl = fileUrl else { return false }
        return save(to: fileUrl)
    }
    
    @discardableResult
    open func load(from fileUrl: URL) -> Bool {
        do {
            let data = try Data(contentsOf: fileUrl)
            return set(data: data)
        } catch {
            return false
        }
    }
    
    @discardableResult
    open func load() -> Bool {
        guard let fileUrl = fileUrl else { return false }
        return load(from: fileUrl)
    }

    // MARK: - Tables
    
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

    // MARK: - Insert
    
    // MARK: Sync
    
    @discardableResult
    open func insert<Item: Codable & Equatable>(on name: String,
                                                item: Item) -> Bool {
        let name = makeTableName(name: name, itemType: Item.self)
        createTable(name: name)
        var rows: [Item] = getTable(name: name) ?? []
        rows.append(item)
        return setTable(name: name, rows: rows)
    }
    
    @discardableResult
    open func insert<Item: Codable & Equatable>(item: Item) -> Bool {
        let name = makeTableName(name: nil, itemType: Item.self)
        return insert(on: name, item: item)
    }
    
    @discardableResult
    open func insert<Item: Codable & Equatable>(on name: String,
                                                items: [Item]) -> Bool {
        let name = makeTableName(name: name, itemType: Item.self)
        createTable(name: name)
        var rows: [Item] = getTable(name: name) ?? []
        rows.append(contentsOf: items)
        return setTable(name: name, rows: rows)
    }
    
    @discardableResult
    open func insert<Item: Codable & Equatable>(items: [Item]) -> Bool {
        let name = makeTableName(name: nil, itemType: Item.self)
        return insert(on: name, items: items)
    }
    
    // MARK: Async
    
    open func insertAsync<Item: Codable & Equatable>(on name: String,
                                                     item: Item,
                                                     completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: qos).async {
            completion(self.insert(on: name, item: item))
        }
    }
    
    open func insertAsync<Item: Codable & Equatable>(item: Item,
                                                     completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: qos).async {
            completion(self.insert(item: item))
        }
    }
    
    open func insertAsync<Item: Codable & Equatable>(on name: String,
                                                     items: [Item],
                                                     completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: qos).async {
            completion(self.insert(on: name, items: items))
        }
    }
    
    open func insertAsync<Item: Codable & Equatable>(items: [Item],
                                                     completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: qos).async {
            completion(self.insert(items: items))
        }
    }

    // MARK: - Read
    
    // MARK: Sync
    
    open func read<Item: Codable & Equatable>(from name: String,
                                              filter: @escaping ((Item) -> Bool)) -> [Item] {
        let name = makeTableName(name: name, itemType: Item.self)
        let items: [Item] = getTable(name: name) ?? []
        return items.filter { item in filter(item) }
    }
    
    open func read<Item: Codable & Equatable>(filter: @escaping ((Item) -> Bool)) -> [Item] {
        let name = makeTableName(name: nil, itemType: Item.self)
        return read(from: name, filter: filter)
    }
    
    open func read<Item: Codable & Equatable>(from name: String) -> [Item] {
        let name = makeTableName(name: name, itemType: Item.self)
        let filter: ((Item) -> Bool) = { _ in true }
        let items: [Item] = getTable(name: name) ?? []
        return items.filter { item in filter(item) }
    }
    
    open func read<Item: Codable & Equatable>() -> [Item] {
        let name = makeTableName(name: nil, itemType: Item.self)
        let filter: ((Item) -> Bool) = { _ in true }
        return read(from: name, filter: filter)
    }
    
    // MARK: Async
    
    open func readAsync<Item: Codable & Equatable>(from name: String,
                                                   itemType: Item.Type,
                                                   filter: @escaping ((Item) -> Bool),
                                                   completion: @escaping ([Item]) -> Void) {
        DispatchQueue.global(qos: qos).async {
            let items: [Item] = self.read(from: name, filter: filter)
            completion(items)
        }
    }
    
    open func readAsync<Item: Codable & Equatable>(itemType: Item.Type,
                                                   filter: @escaping ((Item) -> Bool),
                                                   completion: @escaping ([Item]) -> Void) {
        DispatchQueue.global(qos: qos).async {
            let items: [Item] = self.read(filter: filter)
            completion(items)
        }
    }
    
    open func readAsync<Item: Codable & Equatable>(from name: String,
                                                   itemType: Item.Type,
                                                   completion: @escaping ([Item]) -> Void) {
        DispatchQueue.global(qos: qos).async {
            let items: [Item] = self.read(from: name)
            completion(items)
        }
    }
    
    open func readAsync<Item: Codable & Equatable>(itemType: Item.Type,
                                                   completion: @escaping ([Item]) -> Void) {
        DispatchQueue.global(qos: qos).async {
            let items: [Item] = self.read()
            completion(items)
        }
    }

    // MARK: - Update
    
    // MARK: Sync
    
    @discardableResult
    open func update<Item: Codable & Equatable>(item: Item,
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
    open func update<Item: Codable & Equatable>(item: Item) -> Bool {
        let name = makeTableName(name: nil, itemType: Item.self)
        return update(item: item, from: name)
    }
    
    @discardableResult
    open func update<Item: Codable & Equatable>(items: [Item],
                                                from name: String) -> Bool {
        for item in items {
            if !update(item: item, from: name) {
                return false
            }
        }
        return true
    }
    
    @discardableResult
    open func update<Item: Codable & Equatable>(items: [Item]) -> Bool {
        let name = makeTableName(name: nil, itemType: Item.self)
        return update(items: items, from: name)
    }
    
    @discardableResult
    open func updateAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                        from name: String,
                                                        changes: @escaping (Item) -> Item,
                                                        filter: @escaping ((Item) -> Bool)) -> Bool {
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
    open func updateAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                        changes: @escaping (Item) -> Item,
                                                        filter: @escaping ((Item) -> Bool)) -> Bool {
        let name = makeTableName(name: nil, itemType: Item.self)
        return updateAllItems(of: itemType, from: name, changes: changes, filter: filter)
    }
    
    @discardableResult
    open func updateAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                        from name: String,
                                                        changes: @escaping (Item) -> Item) -> Bool {
        let filter: ((Item) -> Bool) = { _ in true }
        return updateAllItems(of: itemType, from: name, changes: changes, filter: filter)
    }
    
    @discardableResult
    open func updateAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                        changes: @escaping (Item) -> Item) -> Bool {
        let name = makeTableName(name: nil, itemType: Item.self)
        let filter: ((Item) -> Bool) = { _ in true }
        return updateAllItems(of: itemType, from: name, changes: changes, filter: filter)
    }
    
    // MARK: Async
    
    open func updateAsync<Item: Codable & Equatable>(item: Item,
                                                     from name: String,
                                                     completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: qos).async {
            completion(self.update(item: item, from: name))
        }
    }
    
    open func updateAsync<Item: Codable & Equatable>(item: Item,
                                                     completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: qos).async {
            completion(self.update(item: item))
        }
    }
    
    open func updateAsync<Item: Codable & Equatable>(items: [Item],
                                                     from name: String,
                                                     completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: qos).async {
            completion(self.update(items: items, from: name))
        }
    }
    
    open func updateAsync<Item: Codable & Equatable>(items: [Item],
                                                     completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: qos).async {
            completion(self.update(items: items))
        }
    }
    
    open func updateAllItemsAsync<Item: Codable & Equatable>(of itemType: Item.Type,
                                                             from name: String,
                                                             changes: @escaping (Item) -> Item,
                                                             filter: @escaping ((Item) -> Bool),
                                                             completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: qos).async {
            completion(self.updateAllItems(of: itemType, from: name, changes: changes, filter: filter))
        }
    }
    
    open func updateAllItemsAsync<Item: Codable & Equatable>(of itemType: Item.Type,
                                                             changes: @escaping (Item) -> Item,
                                                             filter: @escaping ((Item) -> Bool),
                                                             completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: qos).async {
            completion(self.updateAllItems(of: itemType, changes: changes, filter: filter))
        }
    }
    
    open func updateAllItemsAsync<Item: Codable & Equatable>(of itemType: Item.Type,
                                                             from name: String,
                                                             changes: @escaping (Item) -> Item,
                                                             completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: qos).async {
            completion(self.updateAllItems(of: itemType, from: name, changes: changes))
        }
    }
    
    open func updateAllItemsAsync<Item: Codable & Equatable>(of itemType: Item.Type,
                                                             changes: @escaping (Item) -> Item,
                                                             completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: qos).async {
            completion(self.updateAllItems(of: itemType, changes: changes))
        }
    }

    // MARK: - Delete
    
    // MARK: Sync
    
    @discardableResult
    open func delete<Item: Codable & Equatable>(item: Item,
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
    open func delete<Item: Codable & Equatable>(item: Item) -> Bool {
        let name = makeTableName(name: nil, itemType: Item.self)
        return delete(item: item, from: name)
    }
    
    @discardableResult
    open func delete<Item: Codable & Equatable>(items: [Item],
                                                from name: String) -> Bool {
        for item in items {
            if !delete(item: item, from: name) {
                return false
            }
        }
        return true
    }
    
    @discardableResult
    open func delete<Item: Codable & Equatable>(items: [Item]) -> Bool {
        let name = makeTableName(name: nil, itemType: Item.self)
        return delete(items: items, from: name)
    }
    
    @discardableResult
    open func deleteAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                        from name: String,
                                                        filter: @escaping ((Item) -> Bool)) -> Bool {
        
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
    open func deleteAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                        filter: @escaping ((Item) -> Bool)) -> Bool {
        
        let name = makeTableName(name: nil, itemType: Item.self)
        return deleteAllItems(of: itemType, from: name, filter: filter)
    }
    
    @discardableResult
    open func deleteAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                        from name: String) -> Bool {
        let filter: ((Item) -> Bool) = { _ in true }
        return deleteAllItems(of: itemType, from: name, filter: filter)
    }
    
    @discardableResult
    open func deleteAllItems<Item: Codable & Equatable>(of itemType: Item.Type) -> Bool {
        let name = makeTableName(name: nil, itemType: Item.self)
        let filter: ((Item) -> Bool) = { _ in true }
        return deleteAllItems(of: itemType, from: name, filter: filter)
    }
    
    // MARK: Async
    
    open func deleteAsync<Item: Codable & Equatable>(item: Item,
                                                     from name: String,
                                                     completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: qos).async {
            completion(self.delete(item: item, from: name))
        }
    }
    
    open func deleteAsync<Item: Codable & Equatable>(item: Item,
                                                     completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: qos).async {
            completion(self.delete(item: item))
        }
    }
    
    open func deleteAsync<Item: Codable & Equatable>(items: [Item],
                                                     from name: String,
                                                     completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: qos).async {
            completion(self.delete(items: items, from: name))
        }
    }
    
    open func deleteAsync<Item: Codable & Equatable>(items: [Item],
                                                     completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: qos).async {
            completion(self.delete(items: items))
        }
    }
    
    open func deleteAllItemsAsync<Item: Codable & Equatable>(of itemType: Item.Type,
                                                             from name: String,
                                                             filter: @escaping ((Item) -> Bool),
                                                             completion: @escaping (Bool) -> Void) {
        
        DispatchQueue.global(qos: qos).async {
            completion(self.deleteAllItems(of: itemType, from: name, filter: filter))
        }
    }
    
    open func deleteAllItemsAsync<Item: Codable & Equatable>(of itemType: Item.Type,
                                                             filter: @escaping ((Item) -> Bool),
                                                             completion: @escaping (Bool) -> Void) {
        
        DispatchQueue.global(qos: qos).async {
            completion(self.deleteAllItems(of: itemType, filter: filter))
        }
    }
    
    open func deleteAllItemsAsync<Item: Codable & Equatable>(of itemType: Item.Type,
                                                             from name: String,
                                                             completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: qos).async {
            completion(self.deleteAllItems(of: itemType, from: name))
        }
    }
    
    open func deleteAllItemsAsync<Item: Codable & Equatable>(of itemType: Item.Type,
                                                             completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: qos).async {
            completion(self.deleteAllItems(of: itemType))
        }
    }
}
