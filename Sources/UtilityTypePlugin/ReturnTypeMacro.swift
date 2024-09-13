import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public struct ReturnTypeMacro: PeerMacro {
    public static func expansion<Context, Declaration>(
        of node: AttributeSyntax,
        providingPeersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] where Context : MacroExpansionContext, Declaration : DeclSyntaxProtocol {
        guard
            case .argumentList(let arguments) = node.argument, arguments.count > 0,
            let string = arguments.first?.expression.as(StringLiteralExprSyntax.self),
            string.segments.count == 1,
            let name = string.segments.first
        else {
            throw CustomError.message(#"@ReturnType requires the type name, in the form @ReturnType("ReturnType")"#)
        }
        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            throw CustomError.message("@ReturnType should attach to `function`)")
        }

        let _macros: [String]?
        if let macrosIndex = arguments.firstIndex(where: { $0.label?.text == "macros"}) {
            _macros = arguments[macrosIndex...]
                .map(\.expression)
                .compactMap { $0.as(StringLiteralExprSyntax.self) }
                .flatMap { $0.segments.children(viewMode: .all) }
                .compactMap { $0.as(StringSegmentSyntax.self) }
                .flatMap { $0.tokens(viewMode: .all) }
                .map(\.text)
        } else {
            _macros = nil
        }
        let macros = _macros?.joined(separator: "\n") ?? ""

        let access = funcDecl.modifiers.first(where: \.isNeededAccessLevelModifier)
        let returnType = funcDecl.signature.output?.returnType ?? TypeSyntax(stringLiteral: "Void")
        return [try StructDeclSyntax("\(raw: macros)\n\(access)struct \(name)") {
            DeclSyntax("\(access)\(raw: "typealias RawValue = \(returnType)")")
            DeclSyntax("\(access)\(raw: "let rawValue: RawValue")")
            try InitializerDeclSyntax("\(access)init(\(raw: "_ rawValue: RawValue"))", bodyBuilder: {
                DeclSyntax("\(raw: "self.rawValue = rawValue")")
            })
        }.tryCast(DeclSyntax.self)]
    }
}
