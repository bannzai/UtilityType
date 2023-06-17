import Foundation
import UtilityType

@ReturnType("FunctionReturnType")
@Parameters("FunctionArgs")
func function(a: Int, b: String, c: @escaping () -> Void, e: () -> Void) -> Int {
    return 1
}

@Exclude("ExcludedThree", exlcudes: "three")
@Extract("ExtractedOne", exlcudes: "one")
public enum E {
    case one
    case two(Int)
    case three(String, Int)
    case four(a: String, b: Int)
}

let testEnum = E.four(a: "value", b: 10)
let testEnumExclude = E.ExcludedThree(testEnum)

let testEnum2 = E.one
let testEnumExtract = E.ExtractedOne(testEnum2)

@Omit("Omitted", properties: "id")
@Required
@Partial
@Pick("Picked", properties: "id", "name")
public struct User {
    let id: UUID
    let name: String
    let age: Int
    let optional: Void?
}

let user = User(id: .init(), name: "bannzai", age: 30, optional: nil)
let omittedUser = User.Omitted(name: "bannzai", age: 30, optional: nil)
let pickedUser = User.Picked(id: UUID(), name: "bannzai")
let required = User.Required(id: UUID(), name: "bannzai", age: 30, optional: ())
let partial = User.Partial(id: nil, name: nil, age: nil, optional: nil)



