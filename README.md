# What is this?

_Show Not Tell_ is a Godot 4+ plugin for advanced behavior AI. Hopefully better character AI creates better immersion through showing rather then just telling! (dialogue, yuck)

This is used internally for my current project, but I wanted to share the code for reference and am trying to keep it project agonostic as possible.

Currently it just supports basic [FSM](https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine/) (_Finite State Machines_), but I will be adding additional libraries for [Behavior Trees](https://www.gamedeveloper.com/programming/behavior-trees-for-ai-how-they-work) and [GOAP](https://web.archive.org/web/20230603190318/http://alumni.media.mit.edu/~jorkin/goap.html) (_Goal-Oriented Action Planning_).

I'm also looking into [SHOP](https://www.cs.umd.edu/projects/shop/description.html) (_Simple Hierarchical Ordered Planning_), [POP](https://en.wikipedia.org/wiki/Partial-order_planning) (_Partial Ordered Planning_) and [Boids](https://people.ece.cornell.edu/land/courses/ece4760/labs/s2021/Boids/Boids.html).

## Stability

This is an actively developed library without a stable API and is mostly meant for my use-cases. Hopefully it can be used as reference for your own code.

If you're looking for a more mature AI solution, I reccomend [Beehave](https://github.com/bitbrain/beehave) or [LimboAI](https://github.com/limbonaut/limboai). Both are fantastic and very mature addons. I'm sure there are many more great AI tools out there as well, but these are just the ones I know of.
