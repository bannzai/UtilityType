import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import UtilityTypePlugin
import XCTest

final class ExtractTests: XCTestCase {
    func testMacro() throws {
        let sourceFile: SourceFileSyntax =
      #"""
      @Extract("ExtractedOne", exlcudes: "one")
      public enum E {
          case one
          case two(Int)
          case three(String, Int)
          case four(a: String, b: Int)
      }
      """#
        let context = BasicMacroExpansionContext.init(
            sourceFiles: [sourceFile: .init(moduleName: "MyModule", fullFilePath: "test.swift")]
        )
        let expanded = sourceFile.expand(macros: [
            "Extract": ExtractMacro.self
        ], in: context)

        XCTAssertEqual(
            expanded.formatted().description,
      #"""

      public enum E {
          case one
          case two(Int)
          case three(String, Int)
          case four(a: String, b: Int)
          public enum ExtractedOne {
              case one
              public init?(_ enumType: E) {
                  switch enumType {
                  case .one:
                      self = .one
                  default:
                      return nil
                  }
              }
          }
      }
      """#
        )
    }
}
