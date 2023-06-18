// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

@attached(member, names: arbitrary)
public macro Pick(_ typename: String, properties: String..., macros: String... = []) = #externalMacro(module: "UtilityTypePlugin", type: "PickMacro")

@attached(member, names: arbitrary)
public macro Omit(_ typename: String, properties: String...) = #externalMacro(module: "UtilityTypePlugin", type: "OmitMacro")

@attached(member, names: arbitrary)
public macro Required() = #externalMacro(module: "UtilityTypePlugin", type: "RequiredMacro")

@attached(member, names: arbitrary)
public macro Partial() = #externalMacro(module: "UtilityTypePlugin", type: "PartialMacro")

@attached(member, names: arbitrary)
public macro Exclude(_ typename: String, exlcudes: String...) = #externalMacro(module: "UtilityTypePlugin", type: "ExcludeMacro")

@attached(member, names: arbitrary)
public macro Extract(_ typename: String, extracts: String...) = #externalMacro(module: "UtilityTypePlugin", type: "ExtractMacro")

@attached(peer, names: arbitrary)
public macro Parameters(_ typename: String) = #externalMacro(module: "UtilityTypePlugin", type: "ParametersMacro")

@attached(peer, names: arbitrary)
public macro ReturnType(_ typename: String) = #externalMacro(module: "UtilityTypePlugin", type: "ReturnTypeMacro")
