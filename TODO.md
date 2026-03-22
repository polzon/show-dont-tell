# CORE:
- [ ] Unify Btree and FSM to be interchangeable.

### Planning thoughts:
I want to unify the two which as far as I know hasn't been done before. Perhaps that's for good reason, but I will commit to the design decision as I think I have a solution.

When I think of both of them, they are essentially states that are executing something. The problem with them interchanging is that FSM stays within its states and doesn't really have an exit, whereas BTree is meant to propagate up from the root node every tick.

I believe btree can be made more generic, and the root behavior tree node can be removed. Essentially btree is kind of a ping-pong. It ticks through the tree and then propagates back up with its return code. When it hits the root node, the node can simply tick again. An issue I would need to solve this this though is that there's still a lot of extra information the btree stores that could perhaps be moved to the blackboard. Also it'd be tricky to seperate physics and process ticks.

I think the main difference between btree and fsm is that btree lacks explicit transitions, but I think this can be solved. For example, "execute nodes" or "action leafs" can be considered a major state for both of these. We can store the previous action leaf, and if the next btree tick executes a different leaf, it can call a transition between the two. However the benefit of FSM is that we can have transition guards and we only have finite states to move between. This kind of breaks that by propagating from the root, so everything is fair game and decided by the condition leafs.

Also when a btree ticks inside of a FSM node, if these are interchangable then it would enter the FSM and never exit. We already have an interrupt in our FSM which could break out of this, or we could add explicit transitions to exit. Or simply break the FSM pattern entirely by doing the btree solution mentioned above but I don't like that solution.

A tree is basically a graph that always ends in a reset state.

# BTREE
- [ ] Rework how Actions are processed. They should propagate similar to how Godot does _input() events.
- [ ] Get rid of the concept of the behavior tree in general.

# FSM
- [ ] Make transitions more explicit in definition.

# GOAP
- [ ] Clean up inital vibe code implementation. It works but I lost track of the plot.
- [ ] GOAP should be able to solve solve goals by parsing FSM and Btree.

# Editor
- [ ] Make it exist.
