import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

extension DeclModifierSyntax {
    var isNeededAccessLevelModifier: Bool {
        switch self.name.tokenKind {
        case .keyword(.public): return true
        default: return false
        }
    }
}

extension SyntaxStringInterpolation {
    // It would be nice for SwiftSyntaxBuilder to provide this out-of-the-box.
    mutating func appendInterpolation<Node: SyntaxProtocol>(_ node: Node?) {
        if let node {
            appendInterpolation(node)
        }
    }
}

extension String.StringInterpolation {
    mutating func appendInterpolation<Node: SyntaxProtocol>(_ node: Node?) {
        if let node {
            appendInterpolation(node)
        }
    }
}

extension EnumDeclSyntax {
    var cases: [EnumCaseElementSyntax] {
        memberBlock.members.flatMap { member in
            guard let caseDecl = member.decl.as(EnumCaseDeclSyntax.self) else {
                return Array<EnumCaseElementSyntax>()
            }

            return Array(caseDecl.elements)
        }
    }
}

extension SyntaxProtocol {
  func tryCast<S: SyntaxProtocol>(_ syntaxType: S.Type) throws -> S {
      if let t = self.as(S.self) {
          return t
      } else {
          throw CustomError.message("Cast fail to \(syntaxType) from \(self)")
      }
  }
}

extension Optional {
    func tryUnwrap() throws -> Wrapped {
        switch self {
        case .some(let value):
            return value
        case .none:
            throw CustomError.message("Unwrap fail for \(Self.self)")
        }
    }
}

extension StringLiteralSegmentsSyntax.Element {
    var text: String {
        get throws {
            switch self {
            case .stringSegment(let stringSyntax):
                return stringSyntax.content.text
            case .expressionSegment(_):
                throw CustomError.message("StringLiteralSegmentsSyntax.Element necessary stringSegment")
            }
        }
    }
}
