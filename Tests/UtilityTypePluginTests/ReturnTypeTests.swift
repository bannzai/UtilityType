import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import UtilityTypePlugin
import XCTest

final class ReturnTypeTests: XCTestCase {
    func testMacro() throws {
        let sourceFile: SourceFileSyntax =
      #"""
      @ReturnType("FunctionReturnType")
      func function(a: Int, b: String, c: @escaping () -> Void, e: () -> Void) -> Int {
          return 1
      }
      """#
        let context = BasicMacroExpansionContext.init(
            sourceFiles: [sourceFile: .init(moduleName: "MyModule", fullFilePath: "test.swift")]
        )
        let expanded = sourceFile.expand(macros: [
            "ReturnType": ReturnTypeMacro.self
        ], in: context)

        XCTAssertEqual(
            expanded.formatted().description,
      #"""

      func function(a: Int, b: String, c: @escaping () -> Void, e: () -> Void) -> Int {
          return 1
      }
      struct FunctionReturnType {
          typealias RawValue = Int
          let rawValue: RawValue
          init(rawValue: RawValue) {
              self.rawValue = rawValue
          }
      }
      """#
        )
    }
}
