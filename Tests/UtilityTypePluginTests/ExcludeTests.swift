import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import UtilityTypePlugin
import XCTest

final class ExcludeTests: XCTestCase {
    func testMacro() throws {
        let sourceFile: SourceFileSyntax =
      #"""
      @Exclude("ExcludedThree", exlcudes: "three")
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
            "Exclude": ExcludeMacro.self
        ], in: context)

        XCTAssertEqual(
            expanded.formatted().description,
      #"""

      public enum E {
          case one
          case two(Int)
          case three(String, Int)
          case four(a: String, b: Int)
          public enum ExcludedThree {
              case one
              case two(Int)
              case four(a: String, b: Int)
              public init?(_ enumType: E) {
                  switch enumType {
                  case .one:
                      self = .one
                  case .two ( let param0 ):
                      self = .two ( param0 )
                  case .four ( let param0, let param1 ):
                      self = .four ( a: param0, b: param1 )
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
