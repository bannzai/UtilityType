// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

@attached(member)
public macro Pick(typename: String) = #externalMacro(module: "UtilityTypePlugin", type: "PickMacro")
