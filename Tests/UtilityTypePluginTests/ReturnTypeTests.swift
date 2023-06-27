import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import UtilityTypePlugin
import SwiftSyntaxMacrosTestSupport
import XCTest

final class ReturnTypeTests: XCTestCase {
    func testMacro() throws {
        assertMacroExpansion(
      #"""
      @ReturnType("FunctionReturnType")
      func function(a: Int, b: String, c: @escaping () -> Void, e: () -> Void) -> Int {
          return 1
      }
      """#,
      expandedSource:
      #"""

      func function(a: Int, b: String, c: @escaping () -> Void, e: () -> Void) -> Int {
          return 1
      }
      struct FunctionReturnType {
          typealias RawValue = Int
          let rawValue: RawValue
          init(_ rawValue: RawValue) {
              self.rawValue = rawValue
          }
      }
      """#,
      macros: ["ReturnType": ReturnTypeMacro.self]
        )
    }

    func testMacroNest() throws {
        assertMacroExpansion(
      #"""
      @ReturnType("FunctionReturnType", macros: #"@Pick("Picked", properties: "a")"#)
      func function(a: Int, b: String, c: @escaping () -> Void, e: () -> Void) -> Int {
          return 1
      }
      """#,
      expandedSource:
      #"""

      func function(a: Int, b: String, c: @escaping () -> Void, e: () -> Void) -> Int {
          return 1
      }
      @Pick("Picked", properties: "a")
      struct FunctionReturnType {
          typealias RawValue = Int
          let rawValue: RawValue
          init(_ rawValue: RawValue) {
              self.rawValue = rawValue
          }
      }
      """#,
      macros: ["ReturnType": ReturnTypeMacro.self]
        )
    }
}
