import Foundation
import UtilityType

@Pick("Picked", properties: \User.id, \User.name)
public struct User {
    let id: UUID
    let name: String
    let age: Int
}

let user = User(id: .init(), name: "bannzai", age: 30)
let pickedUser: User.Picked = .init(user: user)
let picked2User: User.Picked2 = .init(user: user)
