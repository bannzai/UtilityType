
## UtilityType
UtilityType is an innovative library designed to realize TypeScript's UtilityTypes in Swift. This groundbreaking library allows Swift developers to incorporate the simplicity and power of TypeScript's UtilityTypes directly into their codebase.
See more details: https://www.typescriptlang.org/docs/handbook/utility-types.html

The UtilityTypes supported are as follows:

- Partial
- Required
- Pick
- Omit
- Exclude
- Extract
- Parameters
- ReturnType

UtilityType offers an extensive set of tools to enhance your flexibility and productivity when coding in Swift, by capitalizing on its robust type system. By exploiting the capabilities of Swift's Macro feature, we've succeeded in reproducing TypeScript's UtilityTypes, offering a more refined and sophisticated Swift programming experience. Experience the difference with UtilityType!

## Partial
Constructs a type with all properties of Type set to optional. This utility will return a type that represents all subsets of a given type.

Example

```swift
@Partial
public struct User {
    let id: UUID
    let name: String
    let age: Int
    let optional: Void?
}

// All properties are to optional.
let partialUser = User.Partial(id: nil, name: nil, age: nil, optional: nil)

// OR
let user = User(id: .init(), name: "bannzai", age: 30, optional: nil)
let partialUser = User.Partial(user: user)

```

## Required
Constructs a type consisting of all properties of Type set to required. The opposite of [Partial](./#Partial).

Example

```swift
@Required
public struct User {
    let id: UUID
    let name: String
    let age: Int
    let optional: Void?
}

// All properties are to non optional.
let requiredUser = User.Required(id: UUID(), name: "bannzai", age: 30, optional: ())

// OR
let user = User(id: UUID(), name: "bannzai", age: 30, optional: ())
let partialUser = User.Partial(user: user)
```

## Pick
Constructs a type by picking the set of properties keys (only string literal) from attached Type.

Example

```swift
@Pick("Picked", properties: "id", "name")
public struct User {
    let id: UUID
    let name: String
    let age: Int
    let optional: Void?
}

// Pick is picked properties from User.
let pickedUser = User.Picked(id: UUID(), name: "bannzai")

// OR
let user = User(id: UUID(), name: "bannzai", age: 30, optional: ())
let pickedUser = User.Picked(user: user)
```

## Omit
Constructs a type by picking all properties from Type and then removing Keys (only string literal). The opposite of Pick.

Example

```swift
@Omit("Omitted", properties: "id")
public struct User {
    let id: UUID
    let name: String
    let age: Int
    let optional: Void?
}

// Omit is omitted properties from User.
let omittedUser = User.Omitted(name: "bannzai", age: 30, optional: nil)

// OR
let user = User(id: UUID(), name: "bannzai", age: 30, optional: ())
let omittedUser = User.Omitted(user: user)
```
