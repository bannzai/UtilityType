// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

@attached(member, names: arbitrary)
public macro Pick(_ typename: String, properties: String...) = #externalMacro(module: "UtilityTypePlugin", type: "PickMacro")
