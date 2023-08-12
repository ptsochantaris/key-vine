import Foundation

public protocol KeyVineDataConvertible {
    var keyVineData: Data? { get }
    init?(keyVineData: Data?)
}

extension Date: KeyVineDataConvertible {
    public init?(keyVineData: Data?) {
        guard let timestamp = TimeInterval(keyVineData: keyVineData) else {
            return nil
        }
        self.init(timeIntervalSinceReferenceDate: timestamp)
    }

    public var keyVineData: Data? {
        timeIntervalSinceReferenceDate.keyVineData
    }
}

extension String: KeyVineDataConvertible {
    public init?(keyVineData: Data?) {
        guard let keyVineData else { return nil }
        self.init(data: keyVineData, encoding: .utf8)
    }

    public var keyVineData: Data? {
        data(using: .utf8)
    }
}

extension Data: KeyVineDataConvertible {
    public init?(keyVineData: Data?) {
        guard let keyVineData else {
            return nil
        }
        self = keyVineData
    }

    public var keyVineData: Data? {
        self
    }
}
