// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

@attached(member, names: arbitrary)
public macro Pick<T, each U>(_ typename: String, properties: repeat KeyPath<T, each U>) = #externalMacro(module: "UtilityTypePlugin", type: "PickMacro")
