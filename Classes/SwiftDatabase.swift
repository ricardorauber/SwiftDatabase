import Foundation

public class SwiftDatabase {
    
    // MARK: - Properties

    var data: [String: [Any]] = [:]
}

// MARK: - CRUD
extension SwiftDatabase {

    @discardableResult
    func insert<Item: Codable & Equatable>(on name: String? = nil,
                                           item: Item) -> Bool {
        
        let name = name ?? String(describing: type(of: item))
        if data[name] == nil {
            data[name] = []
        }
        data[name]?.append(item)
        return true
    }
}
