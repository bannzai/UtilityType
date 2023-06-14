import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import UtilityTypePlugin
import XCTest

final class OmitTests: XCTestCase {
    func testMacro() throws {
        let sourceFile: SourceFileSyntax =
      #"""
      @Omit("Omitted", properties: "id")
      public struct User {
          let id: UUID
          let name: String
          let age: Int
          let optional: Void?
      }
      """#
        let context = BasicMacroExpansionContext.init(
            sourceFiles: [sourceFile: .init(moduleName: "MyModule", fullFilePath: "test.swift")]
        )
        let expanded = sourceFile.expand(macros: [
            "Omit": OmitMacro.self
        ], in: context)

        XCTAssertEqual(
            expanded.formatted().description,
      #"""

      public struct User {
          let id: UUID
          let name: String
          let age: Int
          let optional: Void?
          public struct Omitted {
              public let name: String
              public let age: Int
              public let optional: Void?
              public init(user: User) {
                  self.name = user.name
                  self.age = user.age
                  self.optional = user.optional
              }
              public init(name: String, age: Int, optional: Void?) {
                  self.name = name
                  self.age = age
                  self.optional = optional
              }
          }
      }
      """#
        )
    }
}
