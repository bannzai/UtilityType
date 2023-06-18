
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

### Partial
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

### Required
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

### Pick
Constructs a type by picking the set of specific properties keys (only string literal) from attached Type.

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

### Omit
Constructs a type by picking all properties from Type and then removing specific properties (only string literal). The opposite of Pick.

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

### Exclude
Constructs a type by excluding from enum all cases that are assignable to `exlcudes`.

Example

```swift
@Exclude("ExcludedThree", exlcudes: "three")
public enum Enum {
    case one
    case two(Int)
    case three(String, Int)
    case four(a: String, b: Int)
}

let testEnum = Enum.four(a: "value", b: 10)
let excluded = Enum.ExcludedThree(testEnum)

// The switch statement without `three`.
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

```

### Extract
Constructs a type by extracting from enum all cases that are assignable to `extracts`.

Example

```swift
@Extract("ExtractedOne", extracts: "one")
public enum Enum {
    case one
    case two(Int)
    case three(String, Int)
    case four(a: String, b: Int)
}

let testEnum2 = Enum.one
let extracted = Enum.ExtractedOne(testEnum2)

// The switch statement only `one`.
switch extracted {
case .one:
    print("one")
case nil:
    print("nil")
}

```

### Parameters
Constructs a tuple type from the types used in the parameters of a function type.


Example

```swift

@Parameters("FunctionArgs")
func function(a: Int, b: String, c: @escaping () -> Void, e: () -> Void) -> Int {
    return 1
}

let args: FunctionArgs = (a: 10, b: "value", c: { print("c") }, e: { print("e") })

```

### ReturnType
Constructs a type consisting of the return type of function.

Example

```swift
@ReturnType("FunctionReturnType")
func function(a: Int, b: String, c: @escaping () -> Void, e: () -> Void) -> Int {
    return 1
}

let returnType = FunctionReturnType(rawValue: 100)

```

## UtilityType macro allow attached other macro that pass macro string literal to `macros:`.

For example:

```swift
@Pick("PickedNest", properties: "id", "name", macros: #"@Required"#, #"@Partial"#, #"@Omit("Omitted", properties: "id")"#)
@Omit("OmittedNest", properties: "name", macros: #"@Required"#, #"@Partial"#, #"@Pick("Picked", properties: "id")"#)
public struct User {
    let id: UUID
    let name: String
    let age: Int
    let optional: Void?
}

let pickedNestRequierd = User.PickedNest.Required(id: UUID), name: "bannzai")
let pickedNestPartial = User.PickedNest.Partial(id: UUID), name: "bannzai")
let pickedNestOmit = User.PickedNest.Omitted(name: "bannzai")
let omittedNestPartial = User.OmittedNest.Partial(id: nil, age: nil, optional: nil)
let omittedNestRequired = User.OmittedNest.Required(id: UUID(), age: 30, optional: ())
let omittedNestPick = User.OmittedNest.Picked(id: UUID())

```
## LICENSE
[Ocha](https://github.com/bannzai/UtilityType/) is released under the MIT license. See [LICENSE](./LICENSE) for details.
