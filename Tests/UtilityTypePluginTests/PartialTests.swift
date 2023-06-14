import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import UtilityTypePlugin
import XCTest

final class PartialTests: XCTestCase {
    func testMacro() throws {
        let sourceFile: SourceFileSyntax =
      #"""
      @Partial
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
            "Partial": PartialMacro.self
        ], in: context)

        XCTAssertEqual(
            expanded.formatted().description,
      #"""

      public struct User {
          let id: UUID
          let name: String
          let age: Int
          let optional: Void?
          public struct Partial {
              public let id: UUID?
              public let name: String?
              public let age: Int?
              public let optional: Void?
              public init(user: User) {
                  self.id = user.id
                  self.name = user.name
                  self.age = user.age
                  self.optional = user.optional
              }
              public init(id: UUID?, name: String?, age: Int?, optional: Void?) {
                  self.id = id
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
