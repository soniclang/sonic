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

## Current status

![And you call it a language despite the fact it is obviously just a lexer.](https://frinkiac.com/img/S07E21/597980.jpg)

So far we have a lexer! This is the first step. We're working on the parser next. The lexer takes source code and outputs tokens. The parser takes the tokens and outputs an Abstract Syntax Tree. Andres has already begun work on the final step: converting an AST into C.

## License

![WHEW! ALL THIS LICENSING IS MAKING ME THIRSTY.](https://frinkiac.com/img/S07E07/648413.jpg)

I've decided to go with the LGPL. I am not a lawyer, but the gist of it is: You can't fork this and make it closed-source. However if you use this as part of a larger project, the larger project can be licensed as you wish. I think that's a healthy balance. If this project proves popular and there is a lot of demand for relicensing to eg MIT, we'll certainly consider it!
