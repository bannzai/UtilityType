import Foundation
import UtilityType

@Pick("Picked", properties: "id", "name")
@Pick("Picked2", properties: "name", "age")
@Required()
public struct User {
    let id: UUID
    let name: String
    let age: Int
    let optional: Never?
}

let user = User(id: .init(), name: "bannzai", age: 30, optional: nil)
let pickedUser: User.Picked = .init(user: user)
let picked2User: User.Picked2 = .init(user: user)
