
[![CI Status](http://img.shields.io/travis/Roman Kovtunenko/SwiftActionCableClient.svg?style=flat)](https://travis-ci.org/Roman Kovtunenko/SwiftActionCableClient)
[![Version](https://img.shields.io/cocoapods/v/SwiftActionCableClient.svg?style=flat)](http://cocoapods.org/pods/SwiftActionCableClient)
[![License](https://img.shields.io/cocoapods/l/SwiftActionCableClient.svg?style=flat)](http://cocoapods.org/pods/SwiftActionCableClient)
[![Platform](https://img.shields.io/cocoapods/p/SwiftActionCableClient.svg?style=flat)](http://cocoapods.org/pods/SwiftActionCableClient)
# SwiftActionCableClient
Super simple implementation of Rails ActionCable client written in Swift.
Working on top of swift websocket library: https://github.com/tidwall/SwiftWebSocket

## Example

```swift
// Initiate client with NSMutableURLRequest
let request = NSMutableURLRequest(URL: NSURL(string: "ws://localhost:3000/cable")!)
let client = ActionCableClient(mutableRequest: request)

// Create new channel
let exampleChannel = ActionChannel.init(name: "ExampleChannel")

// callback on message from server
exampleChannel.onMessage = { json in
  print(json)
  // send unsubscribe event to the server
  client.unsubscribeFrom(exampleChannel)
}

// callback on succesfull subsbscription
exampleChannel.onSubscribed  = {
    print("succesfully subscribed!")
}

// send subscribe to request to server and start listening
client.subscribeTo(exampleChannel)
exampleChannel.perform("say_hello")
```

## Installation

SwiftActionCableClient is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SwiftyActionCable"
```

## Dependencies
  * SwiftyJSON https://github.com/SwiftyJSON/SwiftyJSON
  * WebSockets https://github.com/tidwall/SwiftWebSocket

## Author

Roman Kovtunenko, roman.kovtunenko@gmail.com

## License

SwiftActionCableClient is available under the MIT license. See the LICENSE file for more info.
