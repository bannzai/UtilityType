import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import UtilityTypePlugin
import XCTest

final class PickTests: XCTestCase {
    func testMacro() throws {
        let sourceFile: SourceFileSyntax =
      #"""
      @Pick("Pickted", properties: "id", "name")
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
            "Pick": PickMacro.self
        ], in: context)

        XCTAssertEqual(
            expanded.formatted().description,
      #"""

      public struct User {
          let id: UUID
          let name: String
          let age: Int
          let optional: Void?
          public struct Pickted {
              public let id: UUID
              public let name: String
              public init(user: User) {
                  self.id = user.id
                  self.name = user.name
              }
              public init(id: UUID, name: String) {
                  self.id = id
                  self.name = name
              }
          }
      }
      """#
        )
    }
}
