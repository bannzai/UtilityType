import Foundation
import UtilityType

@Pick("Picked", properties: "id", "name", "getter")
@Pick("Picked2", properties: "name", "age")
public struct User {
    let id: UUID
    let name: String
    let age: Int

    var getter: String {
        return "getter"
    }
}

let user = User(id: .init(), name: "bannzai", age: 30)
let pickedUser: User.Picked = .init(user: user)
let picked2User: User.Picked2 = .init(user: user)
