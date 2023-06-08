import Foundation
import UtilityType

@Pick("PickedUser", properties: "id", "name")
struct User {
    let id: UUID
    let name: String
    let age: Int
}
