import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import UtilityTypePlugin
import XCTest

final class ConstructorParametersTests: XCTestCase {
    func testMacro() throws {
        let sourceFile: SourceFileSyntax =
      #"""
      public struct User {
          let id: UUID
          let name: String
          let age: Int
          let optional: Void?

          @ConstructorParameters("InitValue")
          init(id: UUID, name: String, age: Int, optional: Void?) {
              self.id = id
              self.name = name
              self.age = age
              self.optional = optional
          }
      }
      """#
        let context = BasicMacroExpansionContext.init(
            sourceFiles: [sourceFile: .init(moduleName: "MyModule", fullFilePath: "test.swift")]
        )
        let expanded = sourceFile.expand(macros: [
            "ConstructorParameters": ConstructorParametersMacro.self
        ], in: context)

        XCTAssertEqual(
            expanded.formatted().description,
      #"""
      public struct User {
          let id: UUID
          let name: String
          let age: Int
          let optional: Void?
          init(id: UUID, name: String, age: Int, optional: Void?) {
              self.id = id
              self.name = name
              self.age = age
              self.optional = optional
          }
          typealias InitValue = (id: UUID, name: String, age: Int, optional: Void?)
          init(initValue: InitValue) {
              self.init(id: initValue.id, name: initValue.name, age: initValue.age, optional: initValue.optional)
          }
      }
      """#
        )
    }
}
