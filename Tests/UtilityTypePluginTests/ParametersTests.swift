import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import UtilityTypePlugin
import XCTest

final class ParametersTests: XCTestCase {
    func testMacro() throws {
        let sourceFile: SourceFileSyntax =
      #"""
      @Parameters("FunctionArgs")
      func function(a: Int, b: String, c: @escaping () -> Void, e: () -> Void) -> Int {
          return 1
      }
      """#
        let context = BasicMacroExpansionContext.init(
            sourceFiles: [sourceFile: .init(moduleName: "MyModule", fullFilePath: "test.swift")]
        )
        let expanded = sourceFile.expand(macros: [
            "Parameters": ParametersMacro.self
        ], in: context)

        XCTAssertEqual(
            expanded.formatted().description,
      #"""

      func function(a: Int, b: String, c: @escaping () -> Void, e: () -> Void) -> Int {
          return 1
      }
      typealias FunctionArgs = (a: Int, b: String, c: () -> Void, e: () -> Void)
      """#
        )
    }
}
