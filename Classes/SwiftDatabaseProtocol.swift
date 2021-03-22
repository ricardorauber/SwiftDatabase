import Foundation

public protocol SwiftDatabaseProtocol {
    
    // MARK: - Dependencies
    
    var encoder: JSONEncoder { get set }
    var decoder: JSONDecoder { get set }
    
    // MARK: - Data
    
    var data: Data? { get }
    func set(data: Data) -> Bool
    
    // MARK: - Files
    
    @discardableResult
    func save(to fileUrl: URL) -> Bool
    
    @discardableResult
    func save() -> Bool
    
    @discardableResult
    func load(from fileUrl: URL) -> Bool
    
    @discardableResult
    func load() -> Bool
    
    // MARK: - Insert
    
    // MARK: Sync
    
    @discardableResult
    func insert<Item: Codable & Equatable>(on name: String,
                                           item: Item) -> Bool
    
    @discardableResult
    func insert<Item: Codable & Equatable>(item: Item) -> Bool
    
    @discardableResult
    func insert<Item: Codable & Equatable>(on name: String,
                                           items: [Item]) -> Bool
    
    @discardableResult
    func insert<Item: Codable & Equatable>(items: [Item]) -> Bool
    
    // MARK: Async
    
    func insertAsync<Item: Codable & Equatable>(on name: String,
                                                item: Item,
                                                completion: @escaping (Bool) -> Void)
    
    func insertAsync<Item: Codable & Equatable>(item: Item,
                                                completion: @escaping (Bool) -> Void)
    
    func insertAsync<Item: Codable & Equatable>(on name: String,
                                                items: [Item],
                                                completion: @escaping (Bool) -> Void)
    
    func insertAsync<Item: Codable & Equatable>(items: [Item],
                                                completion: @escaping (Bool) -> Void)
    
    // MARK: - Read
    
    // MARK: Sync
    
    func read<Item: Codable & Equatable>(from name: String,
                                         filter: @escaping ((Item) -> Bool)) -> [Item]
    
    func read<Item: Codable & Equatable>(filter: @escaping ((Item) -> Bool)) -> [Item]
    
    func read<Item: Codable & Equatable>(from name: String) -> [Item]
    
    func read<Item: Codable & Equatable>() -> [Item]
    
    // MARK: Async
    
    func readAsync<Item: Codable & Equatable>(from name: String,
                                              itemType: Item.Type,
                                              filter: @escaping ((Item) -> Bool),
                                              completion: @escaping ([Item]) -> Void)
    
    func readAsync<Item: Codable & Equatable>(itemType: Item.Type,
                                              filter: @escaping ((Item) -> Bool),
                                              completion: @escaping ([Item]) -> Void)
    
    func readAsync<Item: Codable & Equatable>(from name: String,
                                              itemType: Item.Type,
                                              completion: @escaping ([Item]) -> Void)
    
    func readAsync<Item: Codable & Equatable>(itemType: Item.Type,
                                              completion: @escaping ([Item]) -> Void)
    
    // MARK: - Update
    
    // MARK: Sync
    
    @discardableResult
    func update<Item: Codable & Equatable>(item: Item,
                                           from name: String) -> Bool
    
    @discardableResult
    func update<Item: Codable & Equatable>(item: Item) -> Bool
    
    @discardableResult
    func update<Item: Codable & Equatable>(items: [Item],
                                           from name: String) -> Bool
    
    @discardableResult
    func update<Item: Codable & Equatable>(items: [Item]) -> Bool
    
    @discardableResult
    func updateAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                   from name: String,
                                                   changes: @escaping (Item) -> Item,
                                                   filter: @escaping ((Item) -> Bool)) -> Bool
    
    @discardableResult
    func updateAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                   changes: @escaping (Item) -> Item,
                                                   filter: @escaping ((Item) -> Bool)) -> Bool
    
    @discardableResult
    func updateAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                   from name: String,
                                                   changes: @escaping (Item) -> Item) -> Bool
    
    @discardableResult
    func updateAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                   changes: @escaping (Item) -> Item) -> Bool
    
    // MARK: Async
    
    func updateAsync<Item: Codable & Equatable>(item: Item,
                                                from name: String,
                                                completion: @escaping (Bool) -> Void)
    
    func updateAsync<Item: Codable & Equatable>(item: Item,
                                                completion: @escaping (Bool) -> Void)
    
    func updateAsync<Item: Codable & Equatable>(items: [Item],
                                                from name: String,
                                                completion: @escaping (Bool) -> Void)
    
    func updateAsync<Item: Codable & Equatable>(items: [Item],
                                                completion: @escaping (Bool) -> Void)
    
    func updateAllItemsAsync<Item: Codable & Equatable>(of itemType: Item.Type,
                                                        from name: String,
                                                        changes: @escaping (Item) -> Item,
                                                        filter: @escaping ((Item) -> Bool),
                                                        completion: @escaping (Bool) -> Void)
    
    func updateAllItemsAsync<Item: Codable & Equatable>(of itemType: Item.Type,
                                                        changes: @escaping (Item) -> Item,
                                                        filter: @escaping ((Item) -> Bool),
                                                        completion: @escaping (Bool) -> Void)
    
    func updateAllItemsAsync<Item: Codable & Equatable>(of itemType: Item.Type,
                                                        from name: String,
                                                        changes: @escaping (Item) -> Item,
                                                        completion: @escaping (Bool) -> Void)
    
    func updateAllItemsAsync<Item: Codable & Equatable>(of itemType: Item.Type,
                                                        changes: @escaping (Item) -> Item,
                                                        completion: @escaping (Bool) -> Void)
    
    // MARK: - Delete
    
    // MARK: Sync
    
    @discardableResult
    func delete<Item: Codable & Equatable>(item: Item,
                                           from name: String) -> Bool
    
    @discardableResult
    func delete<Item: Codable & Equatable>(item: Item) -> Bool
    
    @discardableResult
    func delete<Item: Codable & Equatable>(items: [Item],
                                           from name: String) -> Bool
    
    @discardableResult
    func delete<Item: Codable & Equatable>(items: [Item]) -> Bool
    
    @discardableResult
    func deleteAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                   from name: String,
                                                   filter: @escaping ((Item) -> Bool)) -> Bool
    
    @discardableResult
    func deleteAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                   filter: @escaping ((Item) -> Bool)) -> Bool
    
    @discardableResult
    func deleteAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                   from name: String) -> Bool
    
    @discardableResult
    func deleteAllItems<Item: Codable & Equatable>(of itemType: Item.Type) -> Bool
    
    // MARK: Async
    
    func deleteAsync<Item: Codable & Equatable>(item: Item,
                                                from name: String,
                                                completion: @escaping (Bool) -> Void)
    
    func deleteAsync<Item: Codable & Equatable>(item: Item,
                                                completion: @escaping (Bool) -> Void)
    
    func deleteAsync<Item: Codable & Equatable>(items: [Item],
                                                from name: String,
                                                completion: @escaping (Bool) -> Void)
    
    func deleteAsync<Item: Codable & Equatable>(items: [Item],
                                                completion: @escaping (Bool) -> Void)
    
    func deleteAllItemsAsync<Item: Codable & Equatable>(of itemType: Item.Type,
                                                        from name: String,
                                                        filter: @escaping ((Item) -> Bool),
                                                        completion: @escaping (Bool) -> Void)
    
    func deleteAllItemsAsync<Item: Codable & Equatable>(of itemType: Item.Type,
                                                        filter: @escaping ((Item) -> Bool),
                                                        completion: @escaping (Bool) -> Void)
    
    func deleteAllItemsAsync<Item: Codable & Equatable>(of itemType: Item.Type,
                                                        from name: String,
                                                        completion: @escaping (Bool) -> Void)
    
    func deleteAllItemsAsync<Item: Codable & Equatable>(of itemType: Item.Type,
                                                        completion: @escaping (Bool) -> Void)
}
