import Foundation

public final class KeyVine {
    @propertyWrapper
    public struct Property<Value: KeyVineDataConvertible> {
        let key: String
        let vine: KeyVine

        init(key: String, appIdentifier: String, teamId: String, accessibility: Accessibility) {
            self.key = key
            vine = KeyVine(appIdentifier: appIdentifier, teamId: teamId, accessibility: accessibility)
        }

        public var wrappedValue: Value? {
            get { vine[key] }
            set { vine[key] = newValue }
        }
    }

    public enum KeyVineError: LocalizedError {
        case readFailure(OSStatus)
        case writeFailure(OSStatus)

        public var errorDescription: String? {
            switch self {
            case let .readFailure(status):
                return "Keychain read failed with error \(status)"
            case let .writeFailure(status):
                return "Keychain write failed with error \(status)"
            }
        }
    }

    public enum Accessibility {
        /// The data in the keychain can only be accessed when the device is unlocked. Only available if a passcode is set on the device.
        case whenPasscodeSetThisDeviceOnly
        /// The data in the keychain item can be accessed only while the device is unlocked by the user.
        case whenUnlockedThisDeviceOnly
        /// The data in the keychain item can be accessed only while the device is unlocked by the user.
        case whenUnlocked
        /// The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
        case afterFirstUnlockThisDeviceOnly
        /// The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
        case afterFirstUnlock

        var cfValue: CFString {
            switch self {
            case .afterFirstUnlock:
                return kSecAttrAccessibleAfterFirstUnlock
            case .afterFirstUnlockThisDeviceOnly:
                return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            case .whenPasscodeSetThisDeviceOnly:
                return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
            case .whenUnlocked:
                return kSecAttrAccessibleWhenUnlocked
            case .whenUnlockedThisDeviceOnly:
                return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            }
        }
    }

    private let templateQuery: [CFString: Any]

    public init(appIdentifier: String, teamId: String, accessibility: Accessibility = .afterFirstUnlock) {
        templateQuery = [kSecClass: kSecClassGenericPassword,
                         kSecAttrService: appIdentifier,
                         kSecUseDataProtectionKeychain: kCFBooleanTrue!,
                         kSecAttrAccessible: accessibility.cfValue,
                         kSecAttrAccessGroup: "\(teamId).\(appIdentifier)"]
    }

    public func read(from key: String) throws -> Data? {
        var query = templateQuery
        query[kSecAttrAccount] = key
        query[kSecMatchLimit] = kSecMatchLimitOne
        query[kSecReturnData] = kCFBooleanTrue

        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &itemCopy)
        switch status {
        case errSecSuccess:
            return itemCopy as? Data
        case errSecItemNotFound:
            return nil
        default:
            throw KeyVineError.readFailure(status)
        }
    }

    public func write(data: Data?, to key: String) throws {
        var query = templateQuery
        var status: OSStatus

        query[kSecAttrAccount] = key

        if let data {
            query[kSecValueData] = data
            status = SecItemAdd(query as CFDictionary, nil)

            switch status {
            case errSecDuplicateItem:
                query[kSecValueData] = nil
                status = SecItemUpdate(query as CFDictionary, [kSecValueData: data] as CFDictionary)

            default:
                break
            }

        } else {
            status = SecItemDelete(query as CFDictionary)
            switch status {
            case errSecItemNotFound, errSecSuccess:
                return
            default:
                break
            }
        }

        if status != errSecSuccess {
            throw KeyVineError.writeFailure(status)
        }
    }

    public subscript<T: KeyVineDataConvertible>(key: String) -> T? {
        get { try! T(keyVineData: read(from: key)) }
        set { try! write(data: newValue?.keyVineData, to: key) }
    }
}
