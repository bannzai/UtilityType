import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public struct OmitMacro: MemberMacro {
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
            let name = string.segments.first
        else {
            throw CustomError.message(#"@Omit requires the raw type and property names, in the form @Omit("OmitTypeName", "id", "name")"#)
        }
        
        let _macros: [String]?
        var _properties: Slice<TupleExprElementListSyntax>
        if let macrosIndex = arguments.firstIndex(where: { $0.label?.text == "macros"}) {
            _macros = arguments[macrosIndex...]
                .map(\.expression)
                .compactMap { $0.as(StringLiteralExprSyntax.self) }
                .flatMap { $0.segments.children(viewMode: .all) }
                .compactMap { $0.as(StringSegmentSyntax.self) }
                .flatMap { $0.tokens(viewMode: .all) }
                .map(\.text)
            _properties = arguments[arguments.startIndex..<macrosIndex]
        } else {
            _macros = nil
            _properties = arguments.dropFirst()
        }
        let macros = _macros?.joined(separator: "\n") ?? ""

        guard _properties
            .map(\.expression)
            .allSatisfy({ $0.is(StringLiteralExprSyntax.self) }) else {
            throw CustomError.message("@Omit requires the property names to string literal. got: \(_properties)")
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
            
            let access = declaration.modifiers.first(where: \.isNeededAccessLevelModifier)
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
                    !properties.contains { property in
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
            let assignedToSelfPropertyStatementsFromDeclaration = targetStructProperties
                .compactMap { structProperty in
                    structProperty.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
                }
                .map {
                    "self.\($0) = \(structVariableName).\($0)"
                }
                .joined(separator: "\n")
            let eachInitArgument = targetStructProperties
                .map(\.description)
                .joined(separator: ", ")
            let assignedToSelfPropertyStatementsFromRawProperty = targetStructProperties
                .compactMap { structProperty in
                    structProperty.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
                }
                .map {
                    "self.\($0) = \($0)"
                }
                .joined(separator: "\n")
            
            let syntax = try StructDeclSyntax("\(raw: macros)\(access)struct \(name)", membersBuilder: {
                DeclSyntax("\(raw: structRawProperties)")
                try InitializerDeclSyntax("\(access)init(\(raw: structVariableName): \(raw: structName))") {
                    DeclSyntax("\(raw: assignedToSelfPropertyStatementsFromDeclaration)")
                }
                try InitializerDeclSyntax("\(access)init(\(raw: eachInitArgument))") {
                    DeclSyntax("\(raw: assignedToSelfPropertyStatementsFromRawProperty)")
                }
            })
            return [syntax.cast(DeclSyntax.self)]
        case .classDecl:
            guard let declaration = declaration.as(ClassDeclSyntax.self) else {
                fatalError("Unexpected cast fail when kind == .classDecl")
            }
            
            let className = declaration.identifier.text
            let classVariableName = className.prefix(1).lowercased() + className.suffix(className.count - 1)
            
            let access = declaration.modifiers.first(where: \.isNeededAccessLevelModifier)
            let classProperties = declaration.memberBlock.members.children(viewMode: .all)
                .compactMap { $0.as(MemberDeclListItemSyntax.self) }
                .compactMap { $0.decl.as(VariableDeclSyntax.self) }
                .compactMap { $0.bindings.as(PatternBindingListSyntax.self) }
                .compactMap {
                    $0.children(viewMode: .all)
                        .compactMap { $0.as(PatternBindingSyntax.self) }
                }
                .flatMap { $0 }
            
            let targetClassProperties = classProperties
                .filter { classProperty in
                    !properties.contains { property in
                        classProperty.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == property
                    }}
            let classRawProperties = targetClassProperties
                .map { classProperty in
                    let variableDecl = classProperty.parent!.parent!.cast(VariableDeclSyntax.self)
                    let letOrVar = variableDecl.bindingKeyword.text
                    if let access {
                        return "\(access.description)\(letOrVar.trimmingPrefix(while: \.isWhitespace)) \(classProperty)"
                    } else {
                        return "\(letOrVar.trimmingPrefix(while: \.isWhitespace)) \(classProperty)"
                    }
                }
                .joined()
            let assignedToSelfPropertyStatementsFromDeclaration = targetClassProperties
                .compactMap { classProperty in
                    classProperty.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
                }
                .map {
                    "self.\($0) = \(classVariableName).\($0)"
                }
                .joined(separator: "\n")
            let eachInitArgument = targetClassProperties
                .map(\.description)
                .joined(separator: ", ")
            let assignedToSelfPropertyStatementsFromRawProperty = targetClassProperties
                .compactMap { classProperty in
                    classProperty.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
                }
                .map {
                    "self.\($0) = \($0)"
                }
                .joined(separator: "\n")
            
            let syntax = try ClassDeclSyntax("\(access)class \(name)", membersBuilder: {
                DeclSyntax("\(raw: classRawProperties)")
                try InitializerDeclSyntax("\(access)init(\(raw: classVariableName): \(raw: className))") {
                    DeclSyntax("\(raw: assignedToSelfPropertyStatementsFromDeclaration)")
                }
                try InitializerDeclSyntax("\(access)init(\(raw: eachInitArgument))") {
                    DeclSyntax("\(raw: assignedToSelfPropertyStatementsFromRawProperty)")
                }
            })
            return [syntax.cast(DeclSyntax.self)]
        case _:
            throw CustomError.message("@Required can only be applied to a struct or class declarations.")
        }
    }
}

