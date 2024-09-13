import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public struct ConstructorParametersMacro: PeerMacro {
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
            throw CustomError.message(#"@ConstructorParameters requires the type name, in the form @ConstructorParameters("TypeName")"#)
        }

        guard let initDecl = declaration.as(InitializerDeclSyntax.self) else {
            throw CustomError.message("@ConstructorParameters should attach to `function`)")
        }

        let access = initDecl.modifiers.first(where: \.isNeededAccessLevelModifier)

        let parameters = initDecl.signature.input.parameterList.children(viewMode: .all)
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

        let nameText = try name.text
        let initParams = TypealiasDeclSyntax(
            modifiers: ModifierListSyntax(access != nil ? [access!] : []),
            identifier: TokenSyntax(stringLiteral: nameText),
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
        )

        let variableName = nameText.prefix(1).lowercased() + nameText.suffix(nameText.count - 1)
        let assignedToSelfPropertyStatementsFromDeclaration = parameters
            .map(\.firstName.text)
            .map { "\($0): \(variableName).\($0)" }
            .joined(separator: ", ")

        let initFunc = try InitializerDeclSyntax("\(access)init(\(raw: variableName): \(raw: nameText))") {
            DeclSyntax("self.init(\(raw: assignedToSelfPropertyStatementsFromDeclaration))")
        }

        return try [initParams.tryCast(DeclSyntax.self), initFunc.tryCast(DeclSyntax.self)]
    }
}
