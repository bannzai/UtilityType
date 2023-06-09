import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public struct PickMacro: MemberMacro {
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
            throw CustomError.message(#"@Pick requires the raw type and property names, in the form @Pick("PickTypeName", "id", "name")"#)
        }

        let _properties = arguments.dropFirst()
        guard _properties
            .map(\.expression)
            .allSatisfy({ $0.is(StringLiteralExprSyntax.self) }) else {
            throw CustomError.message("@Pick requires the property names to string literal. got: \(_properties)")
        }
        let properties = _properties
            .map(\.expression)
            .compactMap { $0.as(StringLiteralExprSyntax.self) }
            .flatMap { $0.segments.children(viewMode: .all) }
            .compactMap { $0.as(StringSegmentSyntax.self) }
            .flatMap { $0.tokens(viewMode: .all) }
            .map(\.text)

        switch declaration.kind {
        case .structDecl:
            guard let declaration = declaration.as(StructDeclSyntax.self) else {
                fatalError("Unexpected cast fail when kind == .structDecl")
            }

            let structName = declaration.identifier.text
            let structVariableName = structName.prefix(1).lowercased() + structName.suffix(structName.count - 1)

            let access = declaration.modifiers?.first(where: \.isNeededAccessLevelModifier)
            let structProperties = declaration.memberBlock.members.children(viewMode: .all)
                .compactMap { $0.as(MemberDeclListItemSyntax.self) }
                .compactMap { $0.decl.as(VariableDeclSyntax.self) }
                .compactMap { $0.bindings.as(PatternBindingListSyntax.self) }
                .compactMap {
                    $0.children(viewMode: .all)
                        .compactMap { $0.as(PatternBindingSyntax.self) }
                }
                .flatMap { $0 }

            let targetStructProperties = structProperties
                .filter { structProperty in
                    properties.contains { property in
                        structProperty.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == property
                    }}
            let structRawProperties = targetStructProperties
                .map { structProperty in
                    let variableDecl = structProperty.parent!.parent!.cast(VariableDeclSyntax.self)
                    let letOrVar = variableDecl.bindingKeyword.text
                    if let access {
                        return "\(access.description)\(letOrVar.trimmingPrefix(while: \.isWhitespace)) \(structProperty)"
                    } else {
                         return "\(letOrVar.trimmingPrefix(while: \.isWhitespace)) \(structProperty)"
                    }
                }
                .joined()
            let assignedToSelfPropertyStatements = targetStructProperties
                .compactMap { structProperty in
                    structProperty.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
                }
                .map {
                    "self.\($0) = \(structVariableName).\($0)"
                }
                .joined(separator: "\n")

            let syntax = try! StructDeclSyntax("\(access)struct \(name)", membersBuilder: {
                DeclSyntax("\(access)let _type: \(declaration.identifier.trimmed).Type = \(declaration.identifier.trimmed).self")
                DeclSyntax("\(raw: structRawProperties)")
                try InitializerDeclSyntax("\(access)init(\(raw: structVariableName): \(raw: structName))") {
                    DeclSyntax("\(raw: assignedToSelfPropertyStatements)")
                }
            })
            return [syntax.formatted().cast(DeclSyntax.self)]
        case .classDecl:
            guard let declaration = declaration.as(ClassDeclSyntax.self) else {
                fatalError("Unexpected cast fail when kind == .classDecl")
            }

            let access = declaration.modifiers?.first(where: \.isNeededAccessLevelModifier)
            let structProperties = declaration.memberBlock.members.children(viewMode: .all)
                .compactMap { $0.as(MemberDeclListItemSyntax.self) }
                .compactMap { $0.decl.as(VariableDeclSyntax.self) }
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
                "\(access)typealias \(name) = (_type: \(declaration.identifier.trimmed).Type, \(raw: tupleElements))",
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
