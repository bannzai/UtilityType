import Foundation
import UtilityType

@Exclude("ExcludedThree", exlcudes: "three")
public enum E {
    case one
    case two(Int)
    case three(String, Int)
    case four(a: String, b: Int)
}

let testEnum = E.four(a: "value", b: 10)
let textEnumExclude = E.ExcludedThree(testEnum)

@Pick("Picked", properties: "id", "name")
@Pick("Picked2", properties: "name", "age")
@Required
public struct User {
    let id: UUID
    let name: String
    let age: Int
    let optional: Void?
}

let user = User(id: .init(), name: "bannzai", age: 30, optional: nil)
let pickedUser: User.Picked = .init(user: user)
let picked2User: User.Picked2 = .init(user: user)
let required = User.Required(user: user)


