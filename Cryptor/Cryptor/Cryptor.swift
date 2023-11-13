//
// Cryptor.swift
//  CryptoApp
//
//  Created by Олеся on 09.11.2023.

import Foundation

public final class Cryptor {
    public var strings: [String] {
        get async {
            CoreDataManager.shared.getValues()
        }
    }

    public static func store(string: String) async throws {
        CoreDataManager.shared.addString(string: string)
    }

    public static func deleteValue(string: String) async throws {
        CoreDataManager.shared.deleteEncryptString(string: string)
    }

    public static func deleteAll() {
        CoreDataManager.shared.deleteAll()
    }
}
