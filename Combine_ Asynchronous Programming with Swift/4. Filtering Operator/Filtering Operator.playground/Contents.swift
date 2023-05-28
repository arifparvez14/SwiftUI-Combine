import UIKit
import Combine

public func example(of description: String,
                    action: () -> Void) {
    print("\n---- Example of:", description, "----")
    action()
}

var subscriptions = Set<AnyCancellable>()

example(of: "filter") {
    let number = (1...10).publisher
    
    number
        .filter{ $0.isMultiple(of: 3)}
        .sink(receiveValue: { n in
            print("\(n) is a multiple of 3!")
        })
        .store(in: &subscriptions)
}

example(of: "removeDuplicates") {
  let words = "hey hey there! want to listen to mister mister ?"
                  .components(separatedBy: " ")
                  .publisher
  words
    .removeDuplicates()
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
}

example(of: "compactMap") {
    let string = ["a", "1.24", "3", "def", "45", "0.23"].publisher
    
    string
        .compactMap{ Float($0)}
        .sink(receiveValue: {
            print($0)
        })
        .store(in: &subscriptions)
}

example(of: "ignoreOutput") {
    let number = (1...10_000).publisher
    
    number
        .ignoreOutput()
        .sink(receiveCompletion: { print("Completion with: \($0)") },
              receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "first(where:)") {
  let numbers = (1...9).publisher
  
  numbers
    .print("numbers")
    .first(where: { $0 % 2 == 0 })
    .sink(receiveCompletion: { print("Completed with: \($0)") },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
}

example(of: "last(where:)") {
  let numbers = (1...9).publisher
  
  numbers
    .last(where: { $0 % 2 == 0 })
    .sink(receiveCompletion: { print("Completed with: \($0)") },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
}

example(of: "last(where:), PassthroughSubject") {
  let numbers = PassthroughSubject<Int, Never>()
  
  numbers
    .last(where: { $0 % 2 == 0 })
    .sink(receiveCompletion: { print("Completed with: \($0)") },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
    
    numbers.send(1)
    numbers.send(2)
    numbers.send(3)
    numbers.send(4)
    numbers.send(5)
    numbers.send(completion: .finished)
}

example(of: "dropFirst") {
  let numbers = (1...10).publisher
  
  numbers
    .dropFirst(8)
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
}

example(of: "drop(while:)") {
  let numbers = (1...10).publisher
  
  numbers
    .drop(while: { $0 % 5 != 0 })
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
}
