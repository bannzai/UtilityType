import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import UtilityTypePlugin
import SwiftSyntaxMacrosTestSupport
import XCTest

final class PartialTests: XCTestCase {
    func testMacro() throws {
        assertMacroExpansion(
      #"""
      @Partial
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
      """#,
      macros: ["Partial": PartialMacro.self]
        )
    }

    func testMacroNest() throws {
        assertMacroExpansion(
      #"""
      @Partial(macros: #"@Pick("Picked", properties: "id")"#)
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
          @Pick("Picked", properties: "id")
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
      """#,
      macros: ["Partial": PartialMacro.self]
        )
    }
}
