import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import UtilityTypePlugin
import SwiftSyntaxMacrosTestSupport
import XCTest

final class OmitTests: XCTestCase {
    func testMacro() throws {
        assertMacroExpansion(
      #"""
      @Omit("Omitted", properties: "id")
      public struct User {
          let id: UUID
          let name: String
          let age: Int
          let optional: Void?
      }
      """#,
      expandedSource:
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
      """#,
      macros: ["Omit": OmitMacro.self]
        )
    }

    func testNestMacro() throws {
        assertMacroExpansion(
      #"""
      @Omit("Omitted", properties: "name", macros: #"@Required"#, #"@Partial"#, #"@Pick("Picked", properties: "id")"#)
      public struct User {
          let id: UUID
          let name: String
          let age: Int
          let optional: Void?
      }
      """#,
      expandedSource:
      #"""

      public struct User {
          let id: UUID
          let name: String
          let age: Int
          let optional: Void?
          @Required
          @Partial
          @Pick("Picked", properties: "id")
          public struct Omitted {
              public let id: UUID
              public let age: Int
              public let optional: Void?
              public init(user: User) {
                  self.id = user.id
                  self.age = user.age
                  self.optional = user.optional
              }
              public init(id: UUID, age: Int, optional: Void?) {
                  self.id = id
                  self.age = age
                  self.optional = optional
              }
          }
      }
      """#,
      macros: ["Omit": OmitMacro.self]
        )
    }
}
