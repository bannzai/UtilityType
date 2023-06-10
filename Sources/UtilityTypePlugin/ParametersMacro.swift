import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public struct ParametersMacro: PeerMacro {
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

        let parameters = funcDecl.signature.input.parameterList.children(viewMode: .all)
            .compactMap { $0.as(FunctionParameterSyntax.self) }
            .map { functionParameter in
                if let attributedFunctionParameter = functionParameter.type.as(AttributedTypeSyntax.self) {
                    // for c: @escaping () -> Void
                    return FunctionParameterSyntax(
                        firstName: functionParameter.firstName,
                        type: attributedFunctionParameter.baseType
                    )
                } else {
                    return functionParameter
                }
            }

        return [try TypealiasDeclSyntax(
            modifiers: ModifierListSyntax(access != nil ? [access!] : []),
            identifier: TokenSyntax(stringLiteral: try name.text),
            initializer: TypeInitializerClauseSyntax(
                value:
                    TupleTypeSyntax(
                        elements: TupleTypeElementListSyntax(parameters.indices.map { index in
                            let parameter = parameters[index]
                            return TupleTypeElementSyntax(
                                name: parameter.firstName,
                                colon: .colonToken(),
                                type: parameter.type,
                                trailingComma: index + 1 == parameters.count ? nil : .commaToken()
                            )
                        })
                    )
            )
        ).tryCast(DeclSyntax.self)]
    }
}
