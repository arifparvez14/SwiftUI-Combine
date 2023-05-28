import UIKit
import Combine

public func example(of description: String,
                    action: () -> Void) {
    print("\n---- Example of:", description, "----")
    action()
}


example(of: "PassthroughSubject") {
    
    enum MyError: Error {
        case test
    }
    
    final class StringSubscriber: Subscriber {
        typealias Input = String
        typealias Failure = MyError
        
        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }
        
        func receive(_ input: String) -> Subscribers.Demand {
            print("Received value", input)
            return input == "World" ? .max(1) : .none
        }
        
        func receive(completion: Subscribers.Completion<MyError>) {
            print("Received completion", completion)
        }
    }
    
    let subscriber = StringSubscriber()
    
    let subject = PassthroughSubject<String, MyError>()
    subject.subscribe(subscriber)
    
    let subscription = subject
        .sink(
            receiveCompletion: {completion in
                print("Received completion (sink)", completion)
            }, receiveValue: {value in
                print("Received value (sink)", value)
            }
        )
    
    subject.send("Hello")
    subject.send("World")
    
    subscription.cancel()
    subject.send("Still there")
    
    subject.send(completion: .failure(MyError.test))
    subject.send(completion: .finished)
    subject.send("How about another one?")
}


example(of: "CurrentValueSubject") {
    var subscriptions = Set<AnyCancellable>()
    
    let subject = CurrentValueSubject<Int, Never>(0)
    
    subject
        .print()
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    subject.send(1)
    subject.send(2)
    print(subject.value)
    
    subject.value = 3
    print(subject.value)
    
    subject
        .print()
        .sink(receiveValue: { print("Second subscription:", $0) })
        .store(in: &subscriptions)
    
    subject.send(completion: .finished)
}

example(of: "Dynamically adjusting Demand") {
  final class IntSubscriber: Subscriber {
    typealias Input = Int
    typealias Failure = Never
    
    func receive(subscription: Subscription) {
      subscription.request(.max(2))
    }
    
    func receive(_ input: Int) -> Subscribers.Demand {
      print("Received value", input)
      
      switch input {
      case 1:
        return .max(2)
      case 3:
        return .max(1)
      default:
        return .none
      }
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
      print("Received completion", completion)
    }
  }
  
  let subscriber = IntSubscriber()
  
  let subject = PassthroughSubject<Int, Never>()
  
  subject.subscribe(subscriber)
  
  subject.send(1)
  subject.send(2)
  subject.send(3)
  subject.send(4)
  subject.send(5)
  subject.send(6)
}

example(of: "Type erasure") {
  let subject = PassthroughSubject<Int, Never>()
  let publisher = subject.eraseToAnyPublisher()
  
  publisher
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
  
  subject.send(0)
}

