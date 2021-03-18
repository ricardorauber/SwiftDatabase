import Foundation

struct AnyData: Codable {
    
    // MARK: - Properties
    
    var typeDescription: String
    var data: Data?
    
    // MARK: - Initialization
    
    init() {
        typeDescription = ""
    }
    
    init<Type: Codable>(_ value: Type) {
        typeDescription = ""
        set(value: value)
    }
    
    // MARK: - Interaction
    
    @discardableResult
    mutating func set<Type: Codable>(value: Type, encoder: JSONEncoder = JSONEncoder()) -> Bool {
        data = try? encoder.encode(value)
        if data != nil {
            typeDescription = String(describing: Type.self)
        }
        return data != nil
    }
    
    func get<Type: Codable>(decoder: JSONDecoder = JSONDecoder()) -> Type? {
        guard let data = data else { return nil }
        return try? decoder.decode(Type.self, from: data)
    }
}
