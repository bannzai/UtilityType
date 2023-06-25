import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import UtilityTypePlugin
import SwiftSyntaxMacrosTestSupport
import XCTest

final class ParametersTests: XCTestCase {
    func testMacro() throws {
        assertMacroExpansion(
      #"""
      @Parameters("FunctionArgs")
      func function(a: Int, b: String, c: @escaping () -> Void, e: () -> Void) -> Int {
          return 1
      }
      """#,
      expandedSource:
      #"""

      func function(a: Int, b: String, c: @escaping () -> Void, e: () -> Void) -> Int {
          return 1
      }
      typealias FunctionArgs = (a: Int, b: String, c: () -> Void, e: () -> Void)
      """#,
      macros: ["Parameters": ParametersMacro.self]
        )
    }
}
