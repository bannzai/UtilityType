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
            throw CustomError.message(#"@Parameters requires the raw type and property names, in the form @Parameters("PickTypeName")"#)
        }

        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            throw CustomError.message("@Parameters should attach to Enum)")
        }

        let access = funcDecl.modifiers?.first(where: \.isNeededAccessLevelModifier)

        let returnType = funcDecl.signature.output?.returnType ?? TypeSyntax(stringLiteral: "Void")

        return [try StructDeclSyntax("\(access)struct \(name)") {
            DeclSyntax("\(access)\(raw: "typealias RawValue = \(returnType)")")
            DeclSyntax("\(access)\(raw: "let rawValue: RawValue")")
            try InitializerDeclSyntax("\(access)init(\(raw: "rawValue: RawValue"))", bodyBuilder: {
                DeclSyntax("\(raw: "self.rawValue = rawValue")")
            })
        }.tryCast(DeclSyntax.self)]
    }
}
