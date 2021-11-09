# Sonic

Sonic programming language: Heavily inspired by Swift, but compiles to C so you can use it anywhere.

Brought to you by [Chris Hulbert](https://www.splinter.com.au) and [Andres Kievsky](https://github.com/anknetau)!

Please considering sponsoring the work: [github.com/sponsors/chrishulbert](https://github.com/sponsors/chrishulbert)

## Getting started

![You call this a programming language? You call this a super computer?](https://frinkiac.com/img/S07E17/704136.jpg)

Open the project in Xcode, run it, and see what it output in the console. So far we only have a Lexer and ambition.

## About

![WHAT'S WRONG WITH THIS SONIC LANGUAGE? IT'S MAKING CRAZY NOISES.](https://frinkiac.com/img/S05E03/1015563.jpg)

Swift is a fantastic language, but is tied really strongly to the Apple ecosystem, as well as LLVM. I've been thinking for years that it'd be great if we could make a Swift -> C compiler that could be used anywhere. When we started doing this, it became apparent that Swift is a vastly complex language, and so rather than making another Swift compiler, we're starting a new language that is more or less a simplified subset of Swift, and calling it Sonic.

* Memory management is intended to use automatic reference counting.
* We're aiming for the standard library to be comparably featureful to Go's stdlib. We find that several popular languages with skinny stdlibs to suffer from '1000 dependencies to get anything done' syndrome, and for this to be really scary in terms of supply-chain poisoning. A high-quality stdlib will mitigage this.
* We've been inspired by Zig's success and hope to emulate this! In that vein, I'm accepting donations.
* We'd love to make an incremental compiler that is as fast as TCC, to "Optimize for programmer happiness" as the Rails folk like to say. We might kill a few sacred cows to this end.
* The [BHAG](https://www.jimcollins.com/article_topics/articles/BHAG.html) is to use Sonic as the foundation for a cross-platform mobile app development framework, something akin to React Native.
* Where this readme says 'I' it means Chris; where it says 'We' it means Chris and Andres.

## Syntax

![Syntax](https://frinkiac.com/img/S05E10/146195.jpg)

The semantics and syntax boils down to 'as close as we can reasonably get to Swift' at this stage. I fully expect we'll end up with a subset though. For instance: generics might not happen on first release.

Plus, we may take the liberty to add non-Swift features that we deem useful / interesting / fun.

## Self-hosting compiler

![WITHOUT A DOUBT, THE WORST COMPILER EVER.](https://frinkiac.com/img/S08E14/944125.jpg)

Once we have implemented enough, we hope (dream?) to make this compiler self-hosting (eg the sonic compiler will be written in sonic, and compile itself). I imagine that since we will be a a subset of swift, we'll have to refactor the compiler somewhat to allow that to happen.

We aim to implement a faithful-enough subset that the compiler will then compile with either Sonic or proper Swift. That way we can always bootstrap using the Swift compiler.

## Roadmap

![And you call it a language despite the fact it is obviously just a lexer.](https://frinkiac.com/img/S07E21/597980.jpg)

So far we have a lexer! This is the first step. I'm now working on the parser.

The lexer takes source code and outputs tokens. The parser takes the tokens and outputs an Abstract Syntax Tree. Andres has already begun work on the final step: converting an AST into C.

## License

![WHEW! ALL THIS LICENSING IS MAKING ME THIRSTY.](https://frinkiac.com/img/S07E07/648413.jpg)

I've decided to go with the LGPL. I am not a lawyer, but the gist of it is: You can't fork this and make it closed-source. However if you use this as part of a larger project, the larger project can be licensed as you wish. I think that's a healthy balance. If this project proves popular and there is a lot of demand for relicensing to eg MIT, we'll certainly consider it!
