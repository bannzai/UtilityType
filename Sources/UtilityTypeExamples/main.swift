import Foundation
import UtilityType

@Pick("Picked", properties: "id", "name")
@Pick("Picked2", properties: "name", "age")
public struct User {
    let id: UUID
    let name: String
    let age: Int

    init(id: UUID, name: String, age: Int) {
        self.id = id
        self.name = name
        self.age = age
    }
}

let user = User(id: .init(), name: "bannzai", age: 30)
let nest: User.Picked.Nest = User.Picked.Nest(picked: .init(user: user))
print(nest.id)
