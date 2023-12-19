//
//  KeychainManager.swift
//  Keychain
//
//  Created by Mayur Bendale on 07/12/23.
//

import LocalAuthentication
import Foundation

class KeychainManager {
    enum KeychainError: Error {
        case duplicateEntry
        case readError
        case noPassword
        case unknown(OSStatus)
    }

    static func save(service: String, username: String, password: String) throws {
        let passwordData = password.data(using: .utf8)
        let access = SecAccessControlCreateWithFlags(nil, // Use the default allocator.
                                                     kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                     .biometryCurrentSet,
                                                     nil) // Ignore any error.
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccessControl as String: access as Any,
            kSecAttrAccount as String: username,
            kSecValueData as String: passwordData as Any,
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status != errSecDuplicateItem else {
            throw KeychainError.duplicateEntry
        }

        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }

    static func get(service: String, username: String) throws -> String? {
        let context = LAContext()
        context.localizedReason = "Access your password on the keychain"

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: username,
            kSecReturnData as String: true,
            kSecUseAuthenticationContext as String: context,
            kSecUseAuthenticationUI as String: kSecUseAuthenticationUI,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary,
                                         &result)
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }

        guard let data = result as? Data else {
            throw KeychainError.readError
        }

        return String(data: data, encoding: .utf8)
    }

    static func update(service: String, username: String, password: String) throws {
        let passwordData = password.data(using: .utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        let attributes: [String: Any] = [
            kSecAttrAccount as String: username,
            kSecValueData as String: passwordData as Any
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == errSecSuccess else { throw KeychainError.unknown(status) }
    }

    static func delete(service: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.unknown(status) }
    }

    static func clearKeychain() {
        let secClasses: [AnyObject] = [kSecClassGenericPassword,
                                      kSecClassInternetPassword,
                                      kSecClassCertificate,
                                      kSecClassKey,
                                      kSecClassIdentity]
        secClasses.forEach { secClass in
            let query: [String: Any] = [
                kSecClass as String: secClass
            ]
            let _ = SecItemDelete(query as CFDictionary)
        }
    }
}
