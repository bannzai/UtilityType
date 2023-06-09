import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public struct RequiredMacro: MemberMacro {
    public static func expansion<Declaration, Context>(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] where Declaration : DeclGroupSyntax, Context : MacroExpansionContext {
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
                        // Ignore readonly proeperty
                        .filter { $0.accessor == nil }
                }
                .flatMap { $0 }

            let structRawProperties = structProperties
                .map { _structProperty in
                    var structProperty = _structProperty
                    let variableDecl = structProperty.parent!.parent!.cast(VariableDeclSyntax.self)
                    let letOrVar = variableDecl.bindingKeyword.text

                    let propertyType = structProperty.typeAnnotation?.type
                    if let propertyType, let optionalProperty = propertyType.as(OptionalTypeSyntax.self) {
                        structProperty = structProperty.with(\.typeAnnotation!.type, optionalProperty.wrappedType)
                    }

                    return "\(access)\(letOrVar.trimmingPrefix(while: \.isWhitespace)) \(structProperty)"
                }
                .joined()
            let assignedToSelfPropertyStatementsFromDeclaration = structProperties
                .compactMap { structProperty in
                    structProperty.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
                }
                .map {
                    "self.\($0) = \(structVariableName).\($0)"
                }
                .joined(separator: "\n")
            let eachInitArgument = structProperties
                .map(\.description)
                .joined(separator: ", ")
            let assignedToSelfPropertyStatementsFromRawProperty = structProperties
                .compactMap { structProperty in
                    structProperty.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
                }
                .map {
                    "self.\($0) = \($0)"
                }
                .joined(separator: "\n")

            let syntax = try! StructDeclSyntax("\(access)struct Required", membersBuilder: {
                DeclSyntax("\(raw: structRawProperties)")
                try InitializerDeclSyntax("\(access)init(\(raw: structVariableName): \(raw: structName))") {
                    DeclSyntax("\(raw: assignedToSelfPropertyStatementsFromDeclaration)")
                }
                try InitializerDeclSyntax("\(access)init(\(raw: eachInitArgument))") {
                    DeclSyntax("\(raw: assignedToSelfPropertyStatementsFromRawProperty)")
                }
            })
            return [syntax.formatted().cast(DeclSyntax.self)]
        case .classDecl:
            fatalError("WIP")
//            guard let declaration = declaration.as(ClassDeclSyntax.self) else {
//                fatalError("Unexpected cast fail when kind == .classDecl")
//            }
//
//            let className = declaration.identifier.text
//            let classVariableName = className.prefix(1).lowercased() + className.suffix(className.count - 1)
//
//            let access = declaration.modifiers?.first(where: \.isNeededAccessLevelModifier)
//            let classProperties = declaration.memberBlock.members.children(viewMode: .all)
//                .compactMap { $0.as(MemberDeclListItemSyntax.self) }
//                .compactMap { $0.decl.as(VariableDeclSyntax.self) }
//                .compactMap { $0.bindings.as(PatternBindingListSyntax.self) }
//                .compactMap {
//                    $0.children(viewMode: .all)
//                        .compactMap { $0.as(PatternBindingSyntax.self) }
//                }
//                .flatMap { $0 }
//
//            let targetClassProperties = classProperties
//                .filter { classProperty in
//                    properties.contains { property in
//                        classProperty.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == property
//                    }}
//            let classRawProperties = targetClassProperties
//                .map { classProperty in
//                    let variableDecl = classProperty.parent!.parent!.cast(VariableDeclSyntax.self)
//                    let letOrVar = variableDecl.bindingKeyword.text
//                    if let access {
//                        return "\(access.description)\(letOrVar.trimmingPrefix(while: \.isWhitespace)) \(classProperty)"
//                    } else {
//                        return "\(letOrVar.trimmingPrefix(while: \.isWhitespace)) \(classProperty)"
//                    }
//                }
//                .joined()
//            let assignedToSelfPropertyStatementsFromDeclaration = targetClassProperties
//                .compactMap { classProperty in
//                    classProperty.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
//                }
//                .map {
//                    "self.\($0) = \(classVariableName).\($0)"
//                }
//                .joined(separator: "\n")
//            let eachInitArgument = targetClassProperties
//                .map(\.description)
//                .joined(separator: ", ")
//            let assignedToSelfPropertyStatementsFromRawProperty = targetClassProperties
//                .compactMap { classProperty in
//                    classProperty.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
//                }
//                .map {
//                    "self.\($0) = \($0)"
//                }
//                .joined(separator: "\n")
//
//            let syntax = try! ClassDeclSyntax("\(access)class \(name)", membersBuilder: {
//                DeclSyntax("\(raw: classRawProperties)")
//                try InitializerDeclSyntax("\(access)init(\(raw: classVariableName): \(raw: className))") {
//                    DeclSyntax("\(raw: assignedToSelfPropertyStatementsFromDeclaration)")
//                }
//                try InitializerDeclSyntax("\(access)init(\(raw: eachInitArgument))") {
//                    DeclSyntax("\(raw: assignedToSelfPropertyStatementsFromRawProperty)")
//                }
//            })
//            return [syntax.formatted().cast(DeclSyntax.self)]
        case _:
            throw CustomError.message("@Required can only be applied to a struct or class declarations.")
        }
    }
}
