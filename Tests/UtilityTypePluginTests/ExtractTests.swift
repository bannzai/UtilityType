import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import UtilityTypePlugin
import SwiftSyntaxMacrosTestSupport
import XCTest

final class ExtractTests: XCTestCase {
    func testMacro() throws {
        assertMacroExpansion(
      #"""
      @Extract("ExtractedOne", exlcudes: "one")
      public enum E {
          case one
          case two(Int)
          case three(String, Int)
          case four(a: String, b: Int)
      }
      """#,
      expandedSource:
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
      """#,
      macros: [
        "Extract": ExtractMacro.self
      ])
    }
}
