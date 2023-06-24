import Foundation
import UtilityType

@Pick("Picked", properties: "id")
public struct Item {
    let id: UUID
    let name: String
}

@Partial
@Required
@Readonly
@Omit("Omitted", properties: "id")
@Pick("Picked", properties: "id", "name")
@Pick("PickedNest", properties: "id", "name", macros: #"@Required"#, #"@Partial"#, #"@Omit("Omitted", properties: "id")"#)
@Omit("OmittedNest", properties: "name", macros: #"@Required"#, #"@Partial"#, #"@Pick("Picked", properties: "id")"#)
public struct User {
    let id: UUID
    let name: String
    let age: Int
    let optional: Void?

    @ConstructorParameters("InitValue")
    init(id: UUID, name: String, age: Int, optional: Void?) {
        self.id = id
        self.name = name
        self.age = age
        self.optional = optional
    }
}

let user = User(id: .init(), name: "bannzai", age: 30, optional: nil)
let partial = User.Partial(id: nil, name: nil, age: nil, optional: nil)
let required = User.Required(id: UUID(), name: "bannzai", age: 30, optional: ())
let pickedUser = User.Picked(id: UUID(), name: "bannzai")
let pickedNestRequierd = User.PickedNest.Required(id: .init(), name: "bannzai")
let pickedNestPartial = User.PickedNest.Partial(id: .init(), name: "bannzai")
let pickedNestOmit = User.PickedNest.Omitted(name: "bannzai")
let omittedNestPartial = User.OmittedNest.Partial(id: nil, age: nil, optional: nil)
let omittedNestRequired = User.OmittedNest.Required(id: UUID(), age: 30, optional: ())
let omittedNestPick = User.OmittedNest.Picked(id: .init())
let omittedUser = User.Omitted(name: "bannzai", age: 30, optional: nil)

@Exclude("ExcludedThree", exlcudes: "three")
@Extract("ExtractedOne", extracts: "one")
public enum Enum {
    case one
    case two(Int)
    case three(String, Int)
    case four(a: String, b: Int)
}

let testEnum = Enum.four(a: "value", b: 10)
let excluded = Enum.ExcludedThree(testEnum)

switch excluded {
case .one:
    print("one")
case .two(let value):
    print("two: value:\(value)")
case .four(a: let a, b: let b):
    print("four: a:\(a), b: \(b)")
case nil:
    print("nil")
}

let testEnum2 = Enum.one
let extracted = Enum.ExtractedOne(testEnum2)

switch extracted {
case .one:
    print("one")
case nil:
    print("nil")
}

@Parameters("FunctionArgs")
@ReturnType("FunctionReturnType")
func function(a: Int, b: String, c: @escaping () -> Void, e: () -> Void) -> Int {
    return 1
}

let returnType = FunctionReturnType(rawValue: 100)
let args: FunctionArgs = (a: 10, b: "value", c: { print("c") }, e: { print("e") })
