//
//  main.swift
//  Sonic
//
//  Created by Chris on 6/11/21.
//

import Foundation

func lexWithNiceError(sonic: String) {
    do {
        let tokens = try lex(sonic: sonic)
        for token in tokens {
            print(token)
        }
    } catch LexError.lexError(let type, let position) {
        print("Lex error: \(type)")
        let index = sonic.index(sonic.startIndex, offsetBy: position)
        let context = upToNewline(from: String(sonic.suffix(from: index)))
        print("Near: " + context)
    } catch {
        fatalError("Unexpected: \(error)")
    }
}

func main() {
    lexWithNiceError(sonic: """
        class NamedShape {
            var numberOfSides: Int = 0
            var name: String

            init(name: String) {
                self.name = name
                let a = 123
                let b = a * 3 + 2
                a += 10
                let x = &foo
                let y = foo!
            }

            func simpleDescription() -> String {
                return "A shape with \\(numberOfSides) sides."
            }
        }
        """)
}

main()
