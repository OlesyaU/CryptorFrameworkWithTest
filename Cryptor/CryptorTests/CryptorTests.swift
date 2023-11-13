//
//  CryptorTests.swift
//  CryptorTests
//
//  Created by Олеся on 10.11.2023.
//

import XCTest
@testable import Cryptor

final class CryptorTests: XCTestCase {
    let array1 = ["1","2","3","4"]
    var array2 = [String]()
    var array3 = [String]()

    func testSaveValue() async throws {
        for item in array1 {
            guard let itemID =  UUID(uuidString: item) else {return}
            try await Cryptor.store(string: itemID.uuidString)

            array2 = await Cryptor().strings
        }
        XCTAssertEqual(array1, array2)
    }

    func testDeleteValue() async throws {
        let one = "1"
        guard let arrayElement = array1.first else {return}
        try await Cryptor.deleteValue(string: one)
        XCTAssertEqual(one, arrayElement)
    }
    
    func testDeleteAll() async {
         Cryptor.deleteAll()
        array3 = await Cryptor().strings
        XCTAssertEqual(array2, array3)
    }
}
