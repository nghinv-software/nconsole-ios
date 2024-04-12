//
//  nconsoleTests.swift
//  nconsoleTests
//
//  Created by NghiNV on 03/04/2024.
//

import XCTest
@testable import nconsole

struct DataTest {
    var name: String
    var old: Int
    var className: Int
}

final class nconsoleTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let dataTest = DataTest(name: "Thanh", old: 22, className: 11)
        NConsole.isEnable = true
        
        NConsole.log("Data:::", dataTest)
        NConsole.log("Hello")
        NConsole.groupCollapsed("Hi, how are you?")
        NConsole.log("Data=", dataTest)
        NConsole.groupEnd()
        // wait 3s
        sleep(3)
        NConsole.isEnable = false
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
