import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import UtilityTypePlugin
import XCTest


final class RequiredTests: XCTestCase {
    func testExample() throws {
        let sf: SourceFileSyntax =
      #"""
      let a = #stringify(x + y)
      let b = #stringify("Hello, \(name)")
      """#
        let context = BasicMacroExpansionContext.init(
            sourceFiles: [sf: .init(moduleName: "MyModule", fullFilePath: "test.swift")]
        )
        let transformedSF = sf.expand(macros: testMacros, in: context)
        XCTAssertEqual(
            transformedSF.description,
      #"""
      let a = (x + y, "x + y")
      let b = ("Hello, \(name)", #""Hello, \(name)""#)
      """#
        )
    }
}
