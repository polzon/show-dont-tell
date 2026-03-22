_Somewhat structured thoughts and to-do list to myself for planning the design of this library._

## CORE:

- [ ] Unify Btree and FSM to be interchangeable.
- [ ] Come up with a plan a move more logic into actions.
- [ ] Have blackboarding handle actions better.
- [ ] Decide on a documentation framework.

### Planning thoughts:

I want to unify the two which as far as I know hasn't been done before. Perhaps that's for good reason, but I will commit to the design decision as I think I have a solution.

When I think of both of them, they are essentially states that are executing something. The problem with them interchanging is that FSM stays within its states and doesn't really have an exit, whereas BTree is meant to propagate up from the root node every tick.

I believe btree can be made more generic, and the root behavior tree node can be removed. Essentially btree is kind of a ping-pong. It ticks through the tree and then propagates back up with its return code. When it hits the root node, the node can simply tick again. An issue I would need to solve this this though is that there's still a lot of extra information the btree stores that could perhaps be moved to the blackboard. Also it'd be tricky to seperate physics and process ticks.

I think the main difference between btree and fsm is that btree lacks explicit transitions, but I think this can be solved. For example, "execute nodes" or "action leafs" can be considered a major state for both of these. We can store the previous action leaf, and if the next btree tick executes a different leaf, it can call a transition between the two. However the benefit of FSM is that we can have transition guards and we only have finite states to move between. This kind of breaks that by propagating from the root, so everything is fair game and decided by the condition leafs.

Also when a btree ticks inside of a FSM node, if these are interchangable then it would enter the FSM and never exit. We already have an interrupt in our FSM which could break out of this, or we could add explicit transitions to exit. Or simply break the FSM pattern entirely by doing the btree solution mentioned above but I don't like that solution.

  - When a node or leaf enters it's "running" result, the root behavior tree or fsm will handle the physics and process ticks. Aka the current implementation already.

A tree is basically a graph that always ends in a reset state.

Every node in a FSM and BTREE essentially has a tick and transition between them. They're still essentially graphs.

An easier way to clarify this is that this is essentially nesting fsm inside of behavior trees and vice versa.

Seems like this design is similar to a StateTree?

## BTREE

- [ ] Rework how Actions are processed. They should propagate similar to how Godot does _input() events.

## FSM

- [ ] Make transitions more explicit in definition.
- [ ] Create FSM leaf node for btree to handle integration better.
- [ ] Do we need a centralized FSM in our design? With FSM, only one node should be active at once, therefore we only need to allow that one to be running every tick.
- [ ] Add interrupt logic.

## GOAP

- [ ] Clean up inital vibe code implementation. It works but I lost track of the plot.
- [ ] GOAP should be able to solve solve goals by parsing FSM and btree.
- [ ] Implement accessing the same blackboard that is used by btree (and optionally FSM).
- [ ] Should be able to parse behavior trees and build a list of possible actions for planning.

## UTILITY AI

- [ ] Also clean up this vibe code mess. Hasn't actually been tested.

## ACTIONS

- [ ] Move code from personal project to this library.
- [ ] Should move logic be moved to inside of the action?
- [ ] Integrate better with blackboards.

## EDITOR

- [ ] Make it exist.

## DEBUG

- [ ] Enforce either extensive signalling on all AI logic, or spying on the behavior nodes so we can trace the path the AI is taking.
- [ ] Profile execution time per behavior node.
- [ ] Similar to the editor, create a graph inside of the debugger that shows the logic being ran.
- [ ] Move my gdunit4 test cases from my game into this library. However I don't want the gdunit4 reliant test cases to throw not-found errors for those who don't use gdunit4...
