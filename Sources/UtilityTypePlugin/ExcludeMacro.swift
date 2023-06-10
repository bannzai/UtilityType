import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public struct ExcludeMacro: MemberMacro {
    public static func expansion<Declaration, Context>(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] where Declaration : DeclGroupSyntax, Context : MacroExpansionContext {
        guard
            case .argumentList(let arguments) = node.argument,
            arguments.count >= 2,
            let string = arguments.first?.expression.as(StringLiteralExprSyntax.self),
            string.segments.count == 1
        else {
            throw CustomError.message(#"@Exclude requires the raw type and property names, in the form @Exclude("PickTypeName", "one", "two")"#)
        }

        let _cases = arguments.dropFirst()
        guard _cases
            .map(\.expression)
            .allSatisfy({ $0.is(StringLiteralExprSyntax.self) }) else {
            throw CustomError.message("@Exclude requires the exclude case names to string literal. got: \(_cases)")
        }
        let cases = _cases
            .map(\.expression)
            .compactMap { $0.as(StringLiteralExprSyntax.self) }
            .flatMap { $0.segments.children(viewMode: .all) }
            .compactMap { $0.as(StringSegmentSyntax.self) }
            .flatMap { $0.tokens(viewMode: .all) }
            .map(\.text)

        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            throw CustomError.message(#"@Exclude requires the raw type and property names, in the form @Exclude("PickTypeName", "one", "two")"#)
        }

        let typeName = enumDecl.identifier.with(\.trailingTrivia, [])
        let access = enumDecl.modifiers?.first(where: \.isNeededAccessLevelModifier)
        let uniqueVariableName = context.makeUniqueName("ExcludeMacro.Enum")
        let excludedCases = enumDecl.cases.filter { enumCase in
            cases.contains { c in enumCase.identifier.text == c }
        }

        let syntax = try EnumDeclSyntax(
            "\(access)enum \(typeName)",
            membersBuilder: {
                MemberDeclListSyntax(
                    excludedCases.map { excludedCase in
                        MemberDeclListItemSyntax(
                            decl: EnumCaseDeclSyntax(
                                elements: EnumCaseElementListSyntax(
                                    [excludedCase]
                                )
                            )
                        )
                    }
                )
                try InitializerDeclSyntax("\(access) init?(\(uniqueVariableName): \(typeName)") {
                    try CodeBlockItemListSyntax {
                        try SwitchExprSyntax("switch \(uniqueVariableName)") {
                            SwitchCaseListSyntax(try excludedCases.map {
                                excludedCase in
                                let identifier = excludedCase.identifier
                                let parameters = excludedCase.associatedValue?.parameterList

                                return .switchCase(
                                    SwitchCaseSyntax(
                                        label: .case(
                                            SwitchCaseLabelSyntax(
                                                caseItems: CaseItemListSyntax(itemsBuilder: {
                                                    if let parameters {
                                                        CaseItemSyntax(
                                                            pattern: ExpressionPatternSyntax(
                                                                expression: FunctionCallExprSyntax(
                                                                    calledExpression: MemberAccessExprSyntax(
                                                                        name: identifier
                                                                    ),
                                                                    argumentList: TupleExprElementListSyntax(
                                                                        parameters.map { parameter in
                                                                            TupleExprElementSyntax(
                                                                                expression: UnresolvedPatternExprSyntax(
                                                                                    pattern: ValueBindingPatternSyntax(
                                                                                        bindingKeyword: TokenSyntax(
                                                                                            stringLiteral: "let"
                                                                                        ),
                                                                                        valuePattern: IdentifierPatternSyntax(
                                                                                            identifier: TokenSyntax(
                                                                                                stringLiteral: "TODO"
                                                                                            )
                                                                                        )
                                                                                    )
                                                                                )
                                                                            )
                                                                        }
                                                                    )
                                                                )
                                                            )
                                                        )
                                                    } else {
                                                        CaseItemSyntax(
                                                            pattern: ExpressionPatternSyntax(
                                                                expression: MemberAccessExprSyntax(
                                                                    name: identifier
                                                                )
                                                            )
                                                        )
                                                    }
                                                })
                                            )
                                        ),
                                        statements: try CodeBlockItemListSyntax(itemsBuilder: {
                                            if let parameters {
                                                try CodeBlockItemSyntax(
                                                    item: .expr(
                                                        SequenceExprSyntax(
                                                            elements: ExprListSyntax(
                                                                [
                                                                    IdentifierExprSyntax(identifier: .init(stringLiteral: "self")),
                                                                    AssignmentExprSyntax(assignToken: .equalToken()),
                                                                    FunctionCallExprSyntax(
                                                                        calledExpression: MemberAccessExprSyntax(
                                                                            name: identifier
                                                                        ),
                                                                        argumentList: TupleExprElementListSyntax(
                                                                            parameters.map { parameter in
                                                                                TupleExprElementSyntax(
                                                                                    expression: UnresolvedPatternExprSyntax(
                                                                                        pattern: ValueBindingPatternSyntax(
                                                                                            bindingKeyword: TokenSyntax(
                                                                                                stringLiteral: "let"
                                                                                            ),
                                                                                            valuePattern: IdentifierPatternSyntax(
                                                                                                identifier: TokenSyntax(
                                                                                                    stringLiteral: "TODO"
                                                                                                )
                                                                                            )
                                                                                        )
                                                                                    )
                                                                                )
                                                                            }
                                                                        )
                                                                    )
                                                                ]
                                                            )
                                                        ).tryCast(ExprSyntax.self)
                                                    )
                                                )
                                            } else {
                                                CodeBlockItemSyntax(
                                                    item: .expr(
                                                        try SequenceExprSyntax(
                                                            elements: ExprListSyntax(
                                                                [
                                                                    IdentifierExprSyntax(identifier: .init(stringLiteral: "self")),
                                                                    AssignmentExprSyntax(),
                                                                    MemberAccessExprSyntax(
                                                                        name: identifier
                                                                    )
                                                                ]
                                                            )
                                                        ).tryCast(ExprSyntax.self)
                                                    )
                                                )
                                            }
                                        })
                                    )
                                )
                            })
                        }
                    }
                }
            })

        return [syntax.formatted().cast(DeclSyntax.self)]
    }
}
