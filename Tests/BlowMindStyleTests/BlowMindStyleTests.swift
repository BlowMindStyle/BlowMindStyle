import XCTest
@testable import BlowMindStyle

final class BlowMindStyleTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(BlowMindStyle().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
