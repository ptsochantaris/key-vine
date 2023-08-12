import Foundation

public protocol KeyVineStringConvertible: KeyVineDataConvertible, LosslessStringConvertible {}

public extension KeyVineStringConvertible {
    init?(keyVineData: Data?) {
        guard let string = String(keyVineData: keyVineData) else {
            return nil
        }
        self.init(string)
    }

    var keyVineData: Data? {
        description.keyVineData
    }
}

extension Bool: KeyVineStringConvertible {}
extension Int: KeyVineStringConvertible {}
extension Float: KeyVineStringConvertible {}
extension Double: KeyVineStringConvertible {}
