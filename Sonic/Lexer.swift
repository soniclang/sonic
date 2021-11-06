//
//  Lexer.swift
//  Lexinator
//
//  © Chris Hulbert 2021.
//

import Foundation

//////////////////////////////////////////////////////////////////////////////////////////////
// This file is responsible for the first stage of lexing: splitting a raw string into tokens.
// This is loosely based on: https://docs.swift.org/swift-book/ReferenceManual/LexicalStructure.html

/// From my reading of the Swift reference, it seems that punctuation is a subset of operators. Eg operators is
/// an umbrella that includes puncts.
enum Punctuation: String {
    case parenOpen = "("
    case parenClose = ")"
    case braceOpen = "{"
    case braceClose = "}"
    case bracketOpen = "["
    case bracketClose = "]"
    case fullStop = "." // Americans may call this a 'period'.
    case comma = ","
    case colon = ":"
    case semicolon = ";"
    case equals = "=" // We've decided = is punct, not an operator.
    case at = "@"
    case hash = "#"
    case ampersand = "&" // Prefix operator eg &foo, according to the Swift docs.
    case arrow = "->"
    case backtick = "`"
    case questionMark = "?"
    case exclamation = "!" // Postfix operator eg foo!.
}

/// Built-in operators.
/// https://developer.apple.com/documentation/swift/swift_standard_library/operator_declarations
enum Operator: String {
    // Unary prefix eg !b; Unary postfix eg c!
    // Binary/infix eg 2 + 3 ('infix' means in between two target operands).
    // Only one Ternary: a ? b : c
    
    // Basic: https://docs.swift.org/swift-book/LanguageGuide/BasicOperators.html
    // case assignment = "=" // We've decided that this should be punctuation for now.
    case addition = "+"
    case subtraction = "-"
    case multiplication = "*"
    case division = "/"
    case remainder = "%" // Aka modulo
    // case unaryMinus = "-" // Eg -a - just use subtraction?
    case addAndAssign = "+="
    case subtractAndAssign = "-="
    case multiplyAndAssign = "*="
    case divideAndAssign = "/="
    case equals = "=="
    case notEquals = "!="
    case greaterThan = ">"
    case lessThan = "<"
    case greaterThanOrEqualTo = ">="
    case lessThanOrEqualTo = "<="
    case nilCoalescing = "??"
    case closedRange = "..."
    case halfOpenRange = "..<"
    case logicalNot = "!"
    case logicalAnd = "&&"
    case logicalOr = "||"

    // Advanced: https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html
    case bitwiseNot = "~" // eg let initialBits: UInt8 = 0b00001111; let invertedBits = ~initialBits
    case bitwiseAnd = "&"
    case bitwiseOr = "|"
    case bitwiseXor = "^"
    case bitwiseLeftShift = "<<"
    case bitwiseRightShift = ">>"
    case overflowAddition = "&+"
    case overflowSubtraction = "&-"
    case overflowMultiplication = "&*"
    case identical = "==="
    case notIdentical = "!=="
}

enum Keyword: String { // The names all start with _ because they're reserved keywords.
    case _associatedtype = "associatedtype"
    case _class = "class"
    case _deinit = "deinit"
    case _enum = "enum"
    case _extension = "extension"
    case _fileprivate = "fileprivate"
    case _func = "func"
    case _import = "import"
    case _init = "init"
    case _inout = "inout"
    case _internal = "internal"
    case _let = "let"
    case _open = "open"
    case _operator = "operator"
    case _private = "private"
    case _precedencegroup = "precedencegroup"
    case _protocol = "protocol"
    case _public = "public"
    case _rethrows = "rethrows"
    case _static = "static"
    case _struct = "struct"
    case _subscript = "subscript"
    case _typealias = "typealias"
    case _var = "var"
    case _break = "break"
    case _case = "case"
    case _catch = "catch"
    case _continue = "continue"
    case _default = "default"
    case _defer = "defer"
    case _do = "do"
    case _else = "else"
    case _fallthrough = "fallthrough"
    case _for = "for"
    case _guard = "guard"
    case _if = "if"
    case _in = "in"
    case _repeat = "repeat"
    case _return = "return"
    case _throw = "throw"
    case _switch = "switch"
    case _where = "where"
    case _while = "while"
    case _Any = "Any"
    case _as = "as"
    case _false = "false"
    case _is = "is"
    case _nil = "nil"
    case _self = "self"
    case _Self = "Self"
    case _super = "super"
    case _throws = "throws"
    case _true = "true"
    case _try = "try"
    case _underscore = "_"
    case _associativity = "associativity"
    case _convenience = "convenience"
    case _didSet = "didSet"
    case _dynamic = "dynamic"
    case _final = "final"
    case _get = "get"
    case _indirect = "indirect"
    case _infix = "infix"
    case _lazy = "lazy"
    case _left = "left"
    case _mutating = "mutating"
    case _none = "none"
    case _nonmutating = "nonmutating"
    case _optional = "optional"
    case _override = "override"
    case _postfix = "postfix"
    case _precedence = "precedence"
    case _prefix = "prefix"
    case _Protocol = "Protocol"
    case _required = "required"
    case _right = "right"
    case _set = "set"
    case _some = "some"
    case _Type = "Type"
    case _unowned = "unowned"
    case _weak = "weak"
    case _willSet = "willSet"
}

enum TokenType {
    case comment
    case whitespace
    case identifier
    case keyword(Keyword)
    case implicitParameterName // Eg $0
    case propertyWrapperProjection // Eg $foo
    case binaryLiteral // Eg -0b01_01.
    // case octalLiteral // Eg -0o01_67. Octals removed because of rare usage, and it's just one more slowdown.
    case decimalLiteral // Eg -12_34
    case hexadecimalLiteral // Eg -12_34
    case floatLiteral // Eg -12_34.56_78e[+-]90_12
    case staticStringLiteral
    case interpolatedStringLiteral
    case builtinOperator(Operator)
    case customOperator // TBD: Do we want to support custom operators?
    case punctuation(Punctuation)
    // The below are punctuation or operator depending on location, so just make them a special case and let the parser handle it.
    case ampersand
    case exclamation
    // Should we add a lexer step to move ampersand/excl where it should go? Or is this a parser's responsibility?
    // I'm thinking that if anything is complex or vague or a special case, just make it its own token type and let the parser deal with it
}

struct Token {
    let tokenType: TokenType
    let content: String
}

class MyIterator {
    private var iterator: String.Iterator
    private var pushedStack: [Character] = []
    private(set) var position: Int = 0
    
    init(string: String) {
        iterator = string.makeIterator()
    }
    
    func next() -> Character? {
        if let p = pushedStack.popLast() {
            position += 1
            return p
        } else {
            if let c = iterator.next() {
                position += 1
                return c
            } else {
                return nil
            }
        }
    }
    
    /// Functions are only responsible for pushing something that they themselves 'next'-ed.
    /// Say you read X then Y then Z, and it fails to lex at point Z, you should push Z then Y then X, so
    /// the next lexing effort re-starts at X.
    func push(c: Character) {
        position -= 1
        pushedStack.append(c)
    }
}

func lexWhitespace(head: Character, iterator: MyIterator) -> Token {
    var content = String(head)
    while let c = iterator.next() {
        if c.myIsWhitespace {
            content.append(c)
        } else {
            iterator.push(c: c) // This character isn't ours, push this back on the stack.
            return Token(tokenType: .whitespace, content: content)
        }
    }
    return Token(tokenType: .whitespace, content: content) // Reached EOF.
}

func lexComment(head: Character, iterator: MyIterator) throws -> Token? {
    var content = String(head)
    if let c = iterator.next() {
        if c == "/" { // Go until the newline.
            content.append(c)
            while let c = iterator.next() {
                if c.myIsNewline {
                    content.append(c)
                    return Token(tokenType: .comment, content: content) // Success.
                } else {
                    content.append(c)
                }
            }
            return Token(tokenType: .comment, content: content) // Reached EOF, that's fine.
        } else if c == "*" {
            content.append(c)
            var hasFoundAsterisk = true // So that '/*/' is valid.
            while let c = iterator.next() {
                content.append(c)
                if c == "/" && hasFoundAsterisk {
                    return Token(tokenType: .comment, content: content)
                } else {
                    hasFoundAsterisk = c == "*"
                }
            }
            throw LexError.lexError(.unterminatedComment, iterator.position)
        } else { // Not a comment, so put it back.
            iterator.push(c: c)
            return nil
        }
    } else { // Was only one /, so put it back.
        return nil
    }
}

func lexIdentifier(head: Character, iterator: MyIterator) -> Token {
    var content = String(head)
    while let c = iterator.next() {
        if c.isIdentifierCharacter {
            content.append(c)
        } else { // Not part of the identifier any more, so put it back.
            iterator.push(c: c)
            return Token(tokenType: .identifier, content: content) // Done!
        }
    }
    return Token(tokenType: .identifier, content: content) // Hit EOF, which is fine.
}

func lexIdentifierOrKeyword(head: Character, iterator: MyIterator) -> Token {
    let token = lexIdentifier(head: head, iterator: iterator)
    if let keyword = Keyword(rawValue: token.content) { // See if this ident is actually a keyword.
        return Token(tokenType: .keyword(keyword), content: token.content)
    } else {
        return token
    }
}

// Lex eg $0
func lexImplicitParameterName(head: Character, iterator: MyIterator) -> Token? {
    var content = String(head)
    var hasAnyDigits = false
    while let c = iterator.next() {
        if c.myIsDecimalDigit {
            content.append(c)
            hasAnyDigits = true
        } else { // Past the end.
            iterator.push(c: c)
            if hasAnyDigits {
                return Token(tokenType: .implicitParameterName, content: content)
            } else {
                return nil
            }
        }
    }
    if hasAnyDigits {
        return Token(tokenType: .implicitParameterName, content: content)
    } else {
        return nil
    }
}

// Lex eg $foo (eg the projection of @Published var foo)
func lexPropertyWrapperProjection(head: Character, iterator: MyIterator) -> Token? {
    var content = String(head)
    var hasAnyCharacters = false
    while let c = iterator.next() {
        if c.isIdentifierCharacter {
            content.append(c)
            hasAnyCharacters = true
        } else { // Past the end.
            iterator.push(c: c)
            if hasAnyCharacters {
                return Token(tokenType: .propertyWrapperProjection, content: content)
            } else {
                return nil
            }
        }
    }
    if hasAnyCharacters {
        return Token(tokenType: .implicitParameterName, content: content)
    } else {
        return nil
    }
}

// Eg [-]0b0_1
func lexBinaryLiteral(head: Character, iterator: MyIterator) -> Token? {
    if head == "0" {
        // Look for 'b' next.
        guard let c2 = iterator.next() else {
            return nil // Reached EOF.
        }
        guard c2 == "b" else {
            iterator.push(c: c2) // Not a binary literal. Replace it.
            return nil // Give up.
        }
        var content = String(head)
        content.append(c2)
        // Look for a binary digit (0 or 1) next.
        guard let c3 = iterator.next() else {
            iterator.push(c: c2) // EOF. Replace c2 for correctness sake.
            return nil
        }
        guard c3.isBinaryDigit else {
            iterator.push(c: c3)
            iterator.push(c: c2)
            return nil
        }
        content.append(c3)
        // Look for any further binary literal characters (0 or 1 or _).
        while let c = iterator.next() {
            if c.isBinaryLiteralCharacter {
                content.append(c)
            } else { // We've read past the end of this binary literal.
                iterator.push(c: c) // Push it back.
                return Token(tokenType: .binaryLiteral, content: content)
            }
        }
        return Token(tokenType: .binaryLiteral, content: content) // Hit EOF.
    } else if head == "-" {
        // Recurse.
        guard let c = iterator.next() else {
            return nil // Hit EOF.
        }
        guard let token = lexBinaryLiteral(head: c, iterator: iterator) else {
            iterator.push(c: c) // Didn't parse.
            return nil
        }
        return Token(tokenType: .binaryLiteral, content: String(head) + token.content)
    } else {
        return nil
    }
}

//func lexOctalLiteral(head: Character, iterator: MyIterator) -> Token? {
//    if head == "0" {
//        // Look for 'o' next.
//        guard let c2 = iterator.next() else {
//            return nil // Reached EOF.
//        }
//        guard c2 == "o" else {
//            iterator.push(c: c2) // Not an octal literal. Replace it.
//            return nil // Give up.
//        }
//        var content = String(head)
//        content.append(c2)
//        // Look for an octal digit (0 or 1) next.
//        guard let c3 = iterator.next() else {
//            iterator.push(c: c2) // EOF. Replace c2 for correctness sake.
//            return nil
//        }
//        guard c3.isOctalDigit else {
//            iterator.push(c: c3)
//            iterator.push(c: c2)
//            return nil
//        }
//        content.append(c3)
//        // Look for any further octal literal characters (0-7_).
//        while let c = iterator.next() {
//            if c.isOctalLiteralCharacter {
//                content.append(c)
//            } else { // We've read past the end of this literal.
//                iterator.push(c: c) // Push it back.
//                return Token(tokenType: .octalLiteral, content: content)
//            }
//        }
//        return Token(tokenType: .octalLiteral, content: content) // Hit EOF.
//    } else if head == "-" {
//        // Recurse.
//        guard let c = iterator.next() else {
//            return nil // Hit EOF.
//        }
//        guard let token = lexOctalLiteral(head: c, iterator: iterator) else {
//            iterator.push(c: c) // Didn't parse.
//            return nil
//        }
//        return Token(tokenType: .octalLiteral, content: String(head) + token.content)
//    } else {
//        return nil
//    }
//}

// Take over lexing a decimal after encountering a . (head will = '.')
// This is infallible: if anything goes wrong, this will simply push everything back and return
// the original decimal, so the caller doesn't have to recover and push it's entire content back.
// Floats look like eg -12_34.56_78e[+-]90_12
func lexFloatLiteral(decimalContent: String, head: Character, iterator: MyIterator) -> Token {
    var content = decimalContent + String(head)
    var state = 0 // 0 = has read the '.', is expecting a digit.
    // 1 = has read the first digit after the '.', is expecting digits/_/e
    // 2 = has read the e, is expecting digit/+-
    // 3 = has read the +-, is expecting a digit.
    // 4 = has read the first post-e digit, is expecting digit/_
    while let c = iterator.next() {
        if state == 0 {
            if c.myIsDecimalDigit {
                content.append(c)
                state = 1
            } else {
                iterator.push(c: c) // Not in the float any more. Not reaaaaly a legitimate float in this case eg "0."
                return Token(tokenType: .floatLiteral, content: content)
            }
        } else if state == 1 {
            if c.isDecimalLiteralCharacter {
                content.append(c)
            } else if c == "e" || c == "E" {
                content.append(c)
                state = 2
            } else {
                iterator.push(c: c) // Not in the float any more.
                return Token(tokenType: .floatLiteral, content: content)
            }
        } else if state == 2 {
            if c == "+" || c == "-" {
                content.append(c)
                state = 3
            } else if c.myIsDecimalDigit {
                content.append(c)
                state = 4
            } else {
                iterator.push(c: c) // Not in the float any more.
                return Token(tokenType: .floatLiteral, content: content)
            }
        } else if state == 3 {
            if c.myIsDecimalDigit {
                content.append(c)
                state = 4
            } else {
                iterator.push(c: c) // Not in the float any more.
                return Token(tokenType: .floatLiteral, content: content)
            }
        } else if state == 4 {
            if c.isDecimalLiteralCharacter {
                content.append(c)
            } else {
                iterator.push(c: c) // Not in the float any more.
                return Token(tokenType: .floatLiteral, content: content)
            }
        }
    }
    return Token(tokenType: .floatLiteral, content: content) // EOF.
}

// Start lexing a decimal, and after the 1st decimal we're eligible to start lexing a float.
func lexDecimalOrFloatLiteral(head: Character, iterator: MyIterator) -> Token? {
    if head.myIsDecimalDigit {
        var content = String(head)
        while let c = iterator.next() {
            if c.isDecimalLiteralCharacter {
                content.append(c)
            } else if c == "." { // Ok we've crossed the rubicon: this is a float now.
                return lexFloatLiteral(decimalContent: content, head: c, iterator: iterator)
            } else {
                iterator.push(c: c) // We've read past the end.
                return Token(tokenType: .decimalLiteral, content: content)
            }
        }
        return Token(tokenType: .decimalLiteral, content: content)
    } else if head == "-" {
        guard let c = iterator.next() else {
            return nil // Hit EOF.
        }
        guard let token = lexDecimalOrFloatLiteral(head: c, iterator: iterator) else { // Recurse.
            iterator.push(c: c) // Didn't parse.
            return nil
        }
        return Token(tokenType: token.tokenType, content: String(head) + token.content) // Keep the type in case it changed to float.
    } else {
        return nil
    }
}

func lexHexadecimalLiteral(head: Character, iterator: MyIterator) -> Token? {
    if head == "0" {
        // Look for 'x' next.
        guard let c2 = iterator.next() else {
            return nil // Reached EOF.
        }
        guard c2 == "x" else {
            iterator.push(c: c2) // Not an hex literal. Replace it.
            return nil // Give up.
        }
        var content = String(head)
        content.append(c2)
        // Look for an hex digit next.
        guard let c3 = iterator.next() else {
            iterator.push(c: c2) // EOF. Replace c2 for correctness sake.
            return nil
        }
        guard c3.myIsHexDigit else {
            iterator.push(c: c3)
            iterator.push(c: c2)
            return nil
        }
        content.append(c3)
        // Look for any further hex literal characters.
        while let c = iterator.next() {
            if c.myIsHexLiteralCharacter {
                content.append(c)
            } else { // We've read past the end of this literal.
                iterator.push(c: c) // Push it back.
                return Token(tokenType: .hexadecimalLiteral, content: content)
            }
        }
        return Token(tokenType: .hexadecimalLiteral, content: content) // Hit EOF.
    } else if head == "-" {
        // Recurse.
        guard let c = iterator.next() else {
            return nil // Hit EOF.
        }
        guard let token = lexHexadecimalLiteral(head: c, iterator: iterator) else {
            iterator.push(c: c) // Didn't parse.
            return nil
        }
        return Token(tokenType: .hexadecimalLiteral, content: String(head) + token.content)
    } else {
        return nil
    }
}

/// If passed a decimal literal, this can't return a nil.
func lexNumericLiteral(head: Character, iterator: MyIterator) -> Token? {
    if let token = lexBinaryLiteral(head: head, iterator: iterator) {
        return token
//    } else if let token = lexOctalLiteral(head: head, iterator: iterator) {
//        return token
    } else if let token = lexHexadecimalLiteral(head: head, iterator: iterator) {
        return token
    } else if let token = lexDecimalOrFloatLiteral(head: head, iterator: iterator) {
        return token
    } else {
        return nil
    }
}

enum LexErrorType {
    case unterminatedString
    case unterminatedComment
    case unexpectedStringEscape
    case escapedUnicodeInStringMissingOpeningBrace
    case escapedUnicodeInStringMissingHexValue
    case escapedUnicodeInStringMissingHexValueOrBrace
    case expectedIdentifierInStringInterpolation
    case expectedIdentifierOrClosingBraceInStringInterpolation
    case newlineWithinString
    case unexpectedCharacterAfterDollarSign
    case failedParsingNumeric
    case unrecognisedCharacter
}

enum LexError: Error {
    case lexError(LexErrorType, Int) // Type, position.
}

// I'm going simpler than swift: interpolations must be identifiers eg variables.
// No spaces inside, as per the swift grammar examples. Eg no \( foo ), has to be \(foo).
// For simplicity, i'm not supporting multiline strings yet eg """foo"""
func lexString(head: Character, iterator: MyIterator) throws -> Token {
    var content = String(head)
    var isInterpolated = false
    var state = 1
    // 1 = reading chars
    // 2 = just read \, now looking for escaped thing
    // 3 = just read \u, expecting {
    // 4 = just read \u{, expecting hex
    // 5 = just read \u{x, expecting hex or }
    // 6 = just read \(, expecting an identifier head now.
    // 7 = just read \(a, expecting identifier body or ) now.
    while let c = iterator.next() {
        if state == 1 {
            if c == "\\" {
                content.append(c)
                state = 2
            } else if c == "\"" {
                content.append(c)
                let type: TokenType = isInterpolated ? .interpolatedStringLiteral : .staticStringLiteral
                return Token(tokenType: type, content: content)
            } else if c.myIsNewline {
                throw LexError.lexError(.newlineWithinString, iterator.position)
            } else {
                content.append(c)
            }
        } else if state == 2 {
            if c == "0" || c == "\\" || c == "t" || c == "n" || c == "r" || c == "\"" || c == "'" {
                content.append(c)
                state = 1
            } else if c == "u" {
                content.append(c)
                state = 3
            } else if c == "(" {
                content.append(c)
                state = 6
            } else {
                throw LexError.lexError(.unexpectedStringEscape, iterator.position)
            }
        } else if state == 3 {
            if c == "{" {
                content.append(c)
                state = 4
            } else {
                throw LexError.lexError(.escapedUnicodeInStringMissingOpeningBrace, iterator.position)
            }
        } else if state == 4 {
            if c.myIsHexDigit {
                content.append(c)
                state = 5
            } else {
                throw LexError.lexError(.escapedUnicodeInStringMissingHexValue, iterator.position)
            }
        } else if state == 5 {
            if c.myIsHexDigit {
                content.append(c)
            } else if c == "}" {
                content.append(c)
                state = 1
            } else {
                throw LexError.lexError(.escapedUnicodeInStringMissingHexValueOrBrace, iterator.position)
            }
        } else if state == 6 {
            if c.isIdentifierHead {
                content.append(c)
                state = 7
            } else {
                throw LexError.lexError(.expectedIdentifierInStringInterpolation, iterator.position)
            }
        } else if state == 7 {
            if c.isIdentifierCharacter {
                content.append(c)
            } else if c == ")" {
                content.append(c)
                state = 1
                isInterpolated = true
            } else {
                throw LexError.lexError(.expectedIdentifierOrClosingBraceInStringInterpolation, iterator.position)
            }
        }
    }
    throw LexError.lexError(.unterminatedString, iterator.position)
}

// This is a simplified version of swift's operators:
// https://docs.swift.org/swift-book/ReferenceManual/LexicalStructure.html#grammar_operator-head
func lexOperator(head: Character, iterator: MyIterator) throws -> Token {
    var content = String(head)
    while let c = iterator.next() {
        if c.isOperator {
            content.append(c)
        } else {
            iterator.push(c: c)
            break
        }
    }
    if let op = Operator(rawValue: content) {
        return Token(tokenType: .builtinOperator(op), content: content)
    } else {
        return Token(tokenType: .customOperator, content: content)
    }
}

/// Lex something that looks like an operator but might be punctuation.
func lexOperatorOrPunctuation(head: Character, iterator: MyIterator) throws -> Token {
    let token = try lexOperator(head: head, iterator: iterator)
    if token.content == "&" {
        return Token(tokenType: .ampersand, content: token.content)
    } else if token.content == "!" {
        return Token(tokenType: .exclamation, content: token.content)
    } else if token.content.isPunctuationAndOperator, let p = Punctuation(rawValue: token.content) {
        return Token(tokenType: .punctuation(p), content: token.content)
    } else {
        return token
    }
}

// At the root level of lexing, this determines what to do with a character.
func token(from c: Character, iterator: MyIterator) throws -> Token {
    if c.myIsWhitespace {
        return lexWhitespace(head: c, iterator: iterator)
    } else if c=="/" {
        if let token = try lexComment(head: c, iterator: iterator) {
            return token
        } else { // Just a divide operator (or custom op beginning with divide).
            return try lexOperator(head: c, iterator: iterator)
        }
    } else if c.isIdentifierHead { // a-zA-Z_
        return lexIdentifierOrKeyword(head: c, iterator: iterator)
    } else if c=="$" {
        if let token = lexImplicitParameterName(head: c, iterator: iterator) {
            return token
        } else if let token = lexPropertyWrapperProjection(head: c, iterator: iterator) {
            return token
        } else {
            throw LexError.lexError(.unexpectedCharacterAfterDollarSign, iterator.position)
        }
    } else if c=="-" {
        if let token = lexNumericLiteral(head: c, iterator: iterator) {
            return token
        } else { // Just a minus operator (or custom op beginning with minus, or -> punctuation).
            return try lexOperatorOrPunctuation(head: c, iterator: iterator)
        }
    } else if c.myIsDecimalDigit {
        if let token = lexNumericLiteral(head: c, iterator: iterator) {
            return token
        } else {
            // This realistically cannot happen if it started as a decimal.
            throw LexError.lexError(.failedParsingNumeric, iterator.position)
        }
    } else if c=="\"" {
        return try lexString(head: c, iterator: iterator)
    } else if c.isOperator {
        return try lexOperatorOrPunctuation(head: c, iterator: iterator)
    } else if c.isPunctuation, let p = Punctuation(rawValue: String(c)) {
        // The only 2-digit punctuation is '->' but it gets parsed by lexOperatorOrPunctuation starting with the '-'
        // special case earlier. The rest are single digits.
        return Token(tokenType: .punctuation(p), content: String(c))
    } else {
        throw LexError.lexError(.unrecognisedCharacter, iterator.position)
    }
}

// This lexes a root string.
func lex(sonic: String) throws -> [Token] {
    let iterator = MyIterator(string: sonic)
    var tokens: [Token] = []
    while let c = iterator.next() {
        let t = try token(from: c, iterator: iterator)
        tokens.append(t)
    }
    return tokens
}

func upToNewline(from: String) -> String {
    var s = ""
    for c in from {
        if c.myIsNewline {
            break
        } else {
            s.append(c)
        }
    }
    return s
}

extension String {
    /// Some punctuation are also valid operators. eg <?> is a custom operator, but ? on its own is punctuation.
    /// We prioritise them being punctuation if they're both.
    /// ! and & aren't handled here, because they belong to yet another special class: position-dependant types.
    /// TODO: Make ? surrounded by spaces an operator, and after an identifier optional-chaining?
    var isPunctuationAndOperator: Bool {
        self == "->" || self == "=" || self == "?"
    }
}

extension Character {
    // Punctuation should be prioritised over operators, because a punctuation character
    // may be part of a several-characters-long custom operator. (or should we nix custom ops?)
    var isPunctuation: Bool {
        self == "(" || self == ")" || self == "{" || self == "}" || self == "[" || self == "]" ||
        self == "." || self == "," || self == ":" || self == ";" || self == "@" || self == "#" ||
        self == "`" || self == "=" ||
        self == "!" || // (as a postfix operator eg foo!).
        self == "&"    // (as a prefix operator eg &foo).
    }
    var isOperator: Bool {
        self == "/" || self == "=" || self == "-" || self == "+" || self == "!" || self == "*" || self == "%" ||
        self == "<" || self == ">" || self == "&" || self == "|" || self == "^" || self == "~" || self == "?"
    }
    var isBinaryDigit: Bool {
        self == "0" || self == "1"
    }
    var isBinaryLiteralCharacter: Bool { // _ can't be the head of a binary literal.
        self == "0" || self == "1" || self == "_"
    }
//    var isOctalDigit: Bool {
//        "0" <= self && self <= "7"
//    }
//    var isOctalLiteralCharacter: Bool {
//        ("0" <= self && self <= "7") || self == "_"
//    }
    var myIsHexDigit: Bool {
        ("0" <= self && self <= "9") || ("a" <= self && self <= "f") || ("A" <= self && self <= "F")
    }
    var myIsHexLiteralCharacter: Bool {
        ("0" <= self && self <= "9") || ("a" <= self && self <= "f") || ("A" <= self && self <= "F") || self == "_"
    }
    /// Prefixed 'my' vs the builtin 'isWhitespace' which might be slower as it's fully unicode compliant.
    var myIsWhitespace: Bool {
        switch self {
        case " ", "\r", "\n", "\t": return true
        default: return false
        }
    }
    var myIsNewline: Bool {
        switch self {
        case "\r", "\n": return true
        default: return false
        }
    }
    /// Is the start of an identifier.
    var isIdentifierHead: Bool {
        if "a" <= self && self <= "z" { return true }
        if "A" <= self && self <= "Z" { return true }
        if self == "_" { return true }
        return false
    }
    /// Is part of an identifier after the head.
    var isIdentifierCharacter: Bool {
        if isIdentifierHead { return true }
        if "0" <= self && self <= "9" { return true }
        return false
    }
    var myIsDecimalDigit: Bool {
        "0" <= self && self <= "9"
    }
    var isDecimalLiteralCharacter: Bool {
        ("0" <= self && self <= "9") || self == "_"
    }
}
