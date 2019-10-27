import XCTest
import BlowMindStyle

final class BlowMindStyleTests: XCTestCase {
    func testParseSemanticStringWithTags() {
        let semanticString = SemanticString(xml: "hello <bold>world</bold>!")

        let environment = MockEnvironment()

        let plainString = semanticString.getString(environment.locale)
        XCTAssertEqual(plainString, "hello world!")

        var style = MockSemanticStringStyle()
        let font = UIFont.boldSystemFont(ofSize: 14)
        style.setAttributes([.font: font], for: .bold)

        let attributedString = semanticString.getAttributedString(for: style, environment: environment)

        let expectedAttributedString = NSMutableAttributedString(string: "hello world!")
        expectedAttributedString.addAttribute(.font, value: font, range: NSRange(location: 6, length: 5))
        XCTAssertEqual(attributedString, expectedAttributedString)
    }

    func testParseSemanticStringWithNestedTags() {
        let semanticString = SemanticString(xml: "Lorem <_>ipsum <bold>dolor</bold> sit</_> amet")

        let environment = MockEnvironment()

        let plainString = semanticString.getString(environment.locale)
        XCTAssertEqual(plainString, "Lorem ipsum dolor sit amet")

        var style = MockSemanticStringStyle()
        let font = UIFont.boldSystemFont(ofSize: 14)
        style.setAttributes([.font: font], for: .bold)
        style.setAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], for: SemanticString.TextStyle(rawValue: "_"))

        let attributedString = semanticString.getAttributedString(for: style, environment: environment)

        let expectedAttributedString = NSMutableAttributedString(string: "Lorem ipsum dolor sit amet")
        expectedAttributedString.addAttribute(.font, value: font, range: NSRange(location: 12, length: 5))
        expectedAttributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 6, length: 15))

        XCTAssertEqual(attributedString, expectedAttributedString)
    }

    func testParseSemanticString_nestedTagsShouldOverrideAttributesFromOuterTags() {
        let semanticString = SemanticString(xml: "Lorem <boldRed>ipsum <blue>dolor</blue> sit</boldRed> amet")

        let environment = MockEnvironment()

        let plainString = semanticString.getString(environment.locale)
        XCTAssertEqual(plainString, "Lorem ipsum dolor sit amet")

        var style = MockSemanticStringStyle()
        let font = UIFont.boldSystemFont(ofSize: 14)
        style.setAttributes([.foregroundColor: UIColor.blue], for: .init(rawValue: "blue"))
        style.setAttributes([.foregroundColor: UIColor.red, .font: font], for: SemanticString.TextStyle(rawValue: "boldRed"))

        let attributedString = semanticString.getAttributedString(for: style, environment: environment)

        let expectedAttributedString = NSMutableAttributedString(string: "Lorem ipsum dolor sit amet")
        expectedAttributedString.addAttributes([.foregroundColor: UIColor.red, .font: font], range: NSRange(location: 6, length: 15))
        expectedAttributedString.setAttributes([.foregroundColor: UIColor.blue, .font: font], range: NSRange(location: 12, length: 5))

        XCTAssertEqual(attributedString, expectedAttributedString)
    }

    static var allTests = [
        ("testParseSemanticStringWithTags", testParseSemanticStringWithTags),
        ("testParseSemanticStringWithNestedTags", testParseSemanticStringWithNestedTags),
        ("testParseSemanticString_nestedTagsShouldOverrideAttributesFromOuterTags", testParseSemanticString_nestedTagsShouldOverrideAttributesFromOuterTags)
    ]
}
