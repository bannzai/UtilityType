import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public struct RequiredMacro: MemberMacro {
    public static func expansion<Declaration, Context>(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] where Declaration : DeclGroupSyntax, Context : MacroExpansionContext {
        guard
            case .argumentList(let arguments) = node.argument,
            arguments.count >= 2,
            let string = arguments.first?.expression.as(StringLiteralExprSyntax.self),
            string.segments.count == 1,
            let name = string.segments.first else {
            throw malformedError
        }
        let _properties = arguments.dropFirst()
        guard _properties.allSatisfy({ $0.is(StringLiteralExprSyntax.self) }) else {
            throw malformedError
        }
        let properties = _properties.compactMap { $0.as(StringLiteralExprSyntax.self) }
            .flatMap { $0.segments.children(viewMode: .all) }
            .compactMap { $0.as(StringSegmentSyntax.self) }
            .flatMap { $0.tokens(viewMode: .all) }
            .map(\.text)


        switch declaration.kind {
        case .structDecl:
            guard let declaration = declaration.as(StructDeclSyntax.self) else {
                fatalError("Unexpected cast fail when kind == .structDecl")
            }

            let access = declaration.modifiers?.first(where: \.isNeededAccessLevelModifier)
            let structProperties = declaration.memberBlock.members.children(viewMode: .all)
                .compactMap { $0.as(MemberDeclListItemSyntax.self) }
                .compactMap { $0.as(VariableDeclSyntax.self) }
                .compactMap { $0.bindings.as(PatternBindingListSyntax.self) }
                .compactMap {
                    $0.children(viewMode: .all).compactMap { $0.as(PatternBindingSyntax.self) }
                }
                .flatMap { $0 }
            let tupleElements = structProperties
                .filter { structProperty in
                    properties.contains { property in
                        structProperty.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == property
                    }}
                .map(\.description).joined(separator: ", ")

            return [
                "\(access)typealias \(name) = (_type: \(declaration.identifier).self, \(raw: tupleElements)",
            ]
        case .classDecl:
            guard let declaration = declaration.as(ClassDeclSyntax.self) else {
                fatalError("Unexpected cast fail when kind == .classDecl")
            }

            let access = declaration.modifiers?.first(where: \.isNeededAccessLevelModifier)
            let structProperties = declaration.memberBlock.members.children(viewMode: .all)
                .compactMap { $0.as(MemberDeclListItemSyntax.self) }
                .compactMap { $0.as(VariableDeclSyntax.self) }
                .compactMap { $0.bindings.as(PatternBindingListSyntax.self) }
                .compactMap {
                    $0.children(viewMode: .all).compactMap { $0.as(PatternBindingSyntax.self) }
                }
                .flatMap { $0 }
            let tupleElements = structProperties
                .filter { structProperty in
                    properties.contains { property in
                        structProperty.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == property
                    }}
                .map(\.description).joined(separator: ", ")

            return [
                "\(access)typealias \(name) = (_type: \(declaration.identifier).self, \(raw: tupleElements)",
            ]
        case _:
            throw CustomError.message("@Required can only be applied to a struct or class declarations.")
        }
    }

    private static var malformedError: Error {
        CustomError.message(#"@Pick requires the raw type and property name, in the form @Pick("PickTypeName", "id", "name")"#)
    }

}

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
