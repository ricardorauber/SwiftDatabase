import Foundation

public protocol SwiftDatabaseProtocol: AnyObject {
    
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
    func load(from fileUrl: URL) -> Bool
    
    // MARK: - Insert
    
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
    
    // MARK: - Read
    
    func read<Item: Codable & Equatable>(from name: String,
                                         filter: ((Item) -> Bool)) -> [Item]
                                         
    func read<Item: Codable & Equatable>(filter: ((Item) -> Bool)) -> [Item]
    
    func read<Item: Codable & Equatable>(from name: String) -> [Item]
                                         
    func read<Item: Codable & Equatable>() -> [Item]
    
    // MARK: - Update
    
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
                                                   filter: ((Item) -> Bool)) -> Bool
    
    @discardableResult
    func updateAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                   changes: @escaping (Item) -> Item,
                                                   filter: ((Item) -> Bool)) -> Bool
    
    @discardableResult
    func updateAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                   from name: String,
                                                   changes: @escaping (Item) -> Item) -> Bool
    
    @discardableResult
    func updateAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                   changes: @escaping (Item) -> Item) -> Bool
    
    // MARK: - Delete
    
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
                                                   filter: ((Item) -> Bool)) -> Bool
    
    @discardableResult
    func deleteAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                   filter: ((Item) -> Bool)) -> Bool
    
    @discardableResult
    func deleteAllItems<Item: Codable & Equatable>(of itemType: Item.Type,
                                                   from name: String) -> Bool
    
    @discardableResult
    func deleteAllItems<Item: Codable & Equatable>(of itemType: Item.Type) -> Bool
}
