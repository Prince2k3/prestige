# Prestige

Prestige is a predictable state container, written in Swift. Inspired by [Redux](http://redux.js.org) and [Vuex](https://vuex.vuejs.org), it aims to enforce separation of concerns and a unidirectional data flow by keeping your entire app state in a single data structure that shouldn't be mutated directly, instead relying on an action dispatch mechanism to describe changes. Prestige uses [PromiseKit](https://github.com/mxcl/PromiseKit) for whenever a dispatch is done.

## Usage

Define your app **state**. In this example I am using a `struct`. the state of your application is stored in a single data structure. This makes it easier to understand the behavior of the app state at any given point in time, simplifies state persistence and improves code readability:

```swift
struct AppState: State {
    var counter: Int = 0
}
```

As an example, operations that users might perform within your app would be described as **actions**. State should only be mutated through dispatched **actions**, lightweight objects that mutate the state. Since mutations are centralized, inconsistencies are infrequent and race-conditions become easier to avoid:

```swift
struct IncrementAction {
    let increment: Int
}

extension IncrementAction: Action {
    func aysnc(_ store: Store<AppState>) -> Promise<Void> {
        return after(seconds: 1) {
            store.commit(\.count, store.counter + self.increment) 
        }.asVoid()
    }
}
```

Then you would define a **store**, a data structure used to hold and safeguard your state. A typical application would define only one store and hold it in memory for its lifetime:

The **store** can initialize the AppState itself if default values are set.

```swift
let store = Store<AppState>() 
```
otherwise you can initalize the AppState yourself by overriding the **store** initializer

```swift
let store = Store<AppState>(state: AppState(counter: 0)) 
```

Actions are dispatched through the store, and promise is returned when an **action** is completed or has an error:

```swift
store.dispatch(IncrementAction(increment: 3))
.done {
  print(store.counter) // 3
}
.catch { error in
  print(error)
}
```

You can change a value in the state using the **store**'s commit method

```Swift
store.commit(\.count, 10)
```

commiting a change to the state is immediate.

**Note:** With the addition of `@dyanmicMember` and `Self` Keypath feature. You can now reference **state** from the **store** itself.

```swift 
store.counter
```

vs 

```swift 
store.state.counter
```

**Note:** Prestige supports Combine. When not using `PromiseKit` Prestige will fall back to Combine, only from iOS 13 and above, otherwise you must use `PromiseKit`


## Requirements

- iOS 12.0+
- macOS 10.14+
- Xcode 11.0+

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following commands:

```bash
$ brew update
$ brew install carthage
```

To integrate Prestige into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "Prince2k3/prestige"
```

Run `carthage update` to build the framework and drag the built `Prestige.framework` into your Xcode project.

## Acknowledgements

- [PromiseKit](https://github.com/mxcl/PromiseKit)
- [Redux](http://redux.js.org)
- [Vuex](https://github.com/vuejs/vuex)

## Author
Prince Ugwuh, prince.ugwuh@gmail.com

## Contributors

Louis Daily, louisvdaily@gmail.com

## License

Prestige is available under the MIT license. See the LICENSE file for more info.
