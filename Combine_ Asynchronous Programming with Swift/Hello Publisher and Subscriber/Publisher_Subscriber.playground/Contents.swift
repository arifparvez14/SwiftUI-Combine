import UIKit
import Combine

public func example(of description: String,
                    action: () -> Void) {
    print("\n---- Example of:", description, "----")
    action()
}

example(of: "Publisher") {
    let myNotification = Notification.Name("MyNotification")
    
    let publisher = NotificationCenter.default
        .publisher(for: myNotification, object: nil)
    
    let center = NotificationCenter.default
    
    let observer = center.addObserver(
        forName: myNotification,
        object: nil,
        queue: nil) { notification in
            print("Notification received!")
        }
    
    center.post(name: myNotification, object: nil)
    center.removeObserver(observer)
}

example(of: "Subscriber") {
    let myNotification = Notification.Name("MyNotification")
    
    let publisher = NotificationCenter.default
        .publisher(for: myNotification, object: nil)
    
    let center = NotificationCenter.default
    
    let subscriber = publisher
        .sink{ _ in
            print("Notification received from a publisher!")
        }
    
    center.post(name: myNotification, object: nil)
    subscriber.cancel()
}

example(of: "Just") {
    let just = Just("Hello world!")
    
    _ = just
      .sink(
        receiveCompletion: {
            print("Received completion", $0)
        },
        receiveValue: {
            print("Received value", $0)
    })
    
    _ = just
      .sink(
        receiveCompletion: {
          print("Received completion (another)", $0)
        },
        receiveValue: {
          print("Received value (another)", $0)
      })
}

example(of: "assign(to:on)") {
    class SomeObject {
        var value: String = "" {
            didSet {
                print(value)
            }
        }
    }
    
    let object = SomeObject()
    let publisher = ["Hello", "World!"].publisher
    
    _ = publisher
        .assign(to: \.value, on: object)
}

example(of: "assign(to:)") {
    class SomeObjcet {
        @Published var value = 0
    }
    
    let object = SomeObjcet()
    
    object.$value
        .sink {
            print($0)
        }
    (0..<10).publisher
        .assign(to: &object.$value)
}

example(of: "assign(to:) cancellable") {
    class SomeObjcet {
        @Published var word: String = ""
        var subscriptions = Set<AnyCancellable>()
        
        init() {
            ["A", "B", "C"].publisher
                .assign(to: \.word, on: self)
                .store(in: &subscriptions)
        }
    }
}

example(of: "Future") {
    var subscriptions = Set<AnyCancellable>()

    func futureIncrement(
      integer: Int,
      afterDelay delay: TimeInterval) -> Future<Int, Never> {
          
          Future<Int, Never> { promise in
              print("Original")
              //DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                  promise(.success(integer + 1))
              //}
          }

    }
    
    let future = futureIncrement(integer: 1, afterDelay: 3)
    
    future
        .sink(receiveCompletion: {print($0)},
                receiveValue: {print($0)})
        .store(in: &subscriptions)
    
    future
      .sink(receiveCompletion: { print("Second", $0) },
            receiveValue: { print("Second", $0) })
      .store(in: &subscriptions)
}


