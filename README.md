# What is this?

_Show Don't Tell_ is a Node-based Godot 4+ plugin written in pure gd-script for modular behavior AI. The best story-telling is done through _showing, not telling_.

Currently supports a basic implementation of [**FSM**](https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine/) ([_Finite State Machines_](https://en.wikipedia.org/wiki/Finite-state_machine)), **[Behavior](https://www.behaviortree.dev/docs/learn-the-basics/BT_basics) [Trees](https://www.gamedeveloper.com/programming/behavior-trees-for-ai-how-they-work)**, **Utility AI**, and an early but functional version of [**GOAP**]((https://web.archive.org/web/20230603190318/http://alumni.media.mit.edu/~jorkin/goap.html)) (_Goal-Orrientted Action Planning_)

> [!IMPORTANT]
> The AI referred to in this project is [classical automata behavior](https://en.wikipedia.org/wiki/Automata_theory) AI that is frequently used in games. It's not referring to the current AI hype for things like LLMs (_Large Language Models_).

## Project Goals

This project is my intepretation of these systems, and the design goal is to make them as interchangable as possible so they can easily be mixed and matched. This means Behavior Trees and Finite State Machines which are very different concepts that usually incompatible are redesigned to work together.

The AI should shouldn't be exclusive to NPCs either. Since the AI planinng patterns are controlled by the Action type, this can be implemented by playable characters and non-playable. Both are simply controllers in this design that are interchangable.

There is also an editor in early development, however it is not functional yet.

## Stability

> [!WARNING]
> As this project is under active development and is rapidly changing primarily for my own use-cases, this is **not** meant to be used as-is in projects. It is more intended as a reference to copy/steal for your own code and projects.

This project is a shared library with my internal game I'm working on. The goal is to keep this library as dimension-agnostic as possible, however in practice it may show that my game is done in 2D, and support for 3D games has not been tested or developed.

Because of this library being written internally for my game, it targets my currently used Godot version which is more often than not the current pre-release As such, I may implement and replace things with newer gdscript features, such as `@abstract`.

If you're looking for a more mature AI solution, I recommend [Beehave](https://github.com/bitbrain/beehave) or [LimboAI](https://github.com/limbonaut/limboai). Both are fantastic and very mature addons. There are many more fantastic AI tools out there, but these are the ones I know of.

## Credits

* Icons are being used from [Beehave](https://github.com/bitbrain/beehave)/[BitBrain](https://github.com/bitbrain). This project credits them to being created by [@lostptr](https://github.com/lostptr).
