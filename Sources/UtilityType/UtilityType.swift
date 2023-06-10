// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

@attached(member, names: arbitrary)
public macro Pick(_ typename: String, properties: String...) = #externalMacro(module: "UtilityTypePlugin", type: "PickMacro")

@attached(member, names: arbitrary)
public macro Required() = #externalMacro(module: "UtilityTypePlugin", type: "RequiredMacro")

@attached(member, names: arbitrary)
public macro Exclude(_ typename: String, exlcudes: String...) = #externalMacro(module: "UtilityTypePlugin", type: "ExcludeMacro")
