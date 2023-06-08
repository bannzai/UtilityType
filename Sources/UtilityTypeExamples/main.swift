import Foundation
import UtilityType

@Pick("Picked", properties: "id", "name")
struct User {
    let id: UUID
    let name: String
    let age: Int
}

let user = User(id: .init(), name: "bannzai", age: 30)
let pickedUser: User.Picked = .init(user: user)
