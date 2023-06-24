#if canImport(SwiftCompilerPlugin)
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct UtilityTypePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        PickMacro.self,
        OmitMacro.self,
        RequiredMacro.self,
        PartialMacro.self,
        ExtractMacro.self,
        ExcludeMacro.self,
        ParametersMacro.self,
        ReturnTypeMacro.self,
        ReadonlyMacro.self,
    ]
}
#endif
