import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import UtilityTypePlugin
import SwiftSyntaxMacrosTestSupport
import XCTest

final class PickTests: XCTestCase {
    func testMacro() throws {
        assertMacroExpansion(
      #"""
      @Pick("Pickted", properties: "id", "name")
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
      """#,
      macros: ["Pick": PickMacro.self]
        )
    }

    func testNestMacro() throws {
        assertMacroExpansion(
      #"""
      @Pick("PickedNest", properties: "id", "name", macros: #"@Required"#, #"@Partial"#, #"@Omit("Omitted", properties: "id")"#)
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
          @Omit("Omitted", properties: "id")
          public struct PickedNest {
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
      """#,
      macros: ["Pick": PickMacro.self]
        )
    }
}
