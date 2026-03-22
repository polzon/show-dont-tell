# StateTree V1 Specification

## Purpose

Define a single runtime model that unifies Behavior Tree style selection and FSM style lifecycle/transitions, while keeping authoring flexible.

This spec explicitly supports your current design intent: BT and FSM can be nested in authored graphs, but runtime ownership remains centralized.

This document is a design target for refactors in show_not_tell. It is intentionally implementation-agnostic, but strict about runtime behavior.

## Scope

This spec focuses on:

- Runtime ownership and execution phases
- Transition intent and arbitration
- State/task lifecycle
- Blackboard contract
- Canonical integration rules for BT and FSM style authoring

This spec does not define editor UX, serialization format, or GOAP/Utility details.

## Design Intent Alignment

This spec incorporates the following intent from planning:

1. BT and FSM should be interchangeable in authored graphs.
2. BT and FSM nesting is acceptable as an authoring pattern.
3. Running nodes (especially action leaves) receive process/physics ticks from a central owner.
4. BT traversal can be treated as a looped graph walk ("ping-pong") instead of requiring a special conceptual root node.
5. BT transitions should become explicit enough to match FSM transition guarantees.

## Core Principles

1. Single runtime owner: exactly one scheduler controls activation, transition, and ticking.
2. One active execution path: execution ownership must be deterministic.
3. Explicit transitions: all state changes happen through transition intents and central arbitration.
4. Fail closed: invalid transitions or guard errors are denied by default.
5. Observability first: all state changes and transition decisions are traceable.

## Terms

- Node: Authoring unit in the graph.
- State: A node with lifecycle hooks and optional child nodes.
- Task: Executable logic attached to a state (condition, action, or utility evaluator).
- Active path: Ordered root-to-leaf state path currently entered.
- Transition intent: Request to move from current active path to another target state/path.
- Arbiter: Central component that selects one transition intent per update.
- Running node: The currently active executable node receiving continuous process/physics ticks.

## Runtime Invariants

The runtime must always satisfy:

1. Only one scheduler instance owns execution for a StateTree instance.
2. Nodes never start independent controllers/runners.
3. At most one transition is committed per domain update (process or physics).
4. Enter and exit callbacks are called exactly once per activation change.
5. A state cannot be both entering and exiting in the same phase.
6. Guards are pure (no side effects) and must be safe to evaluate multiple times.
7. If arbitration fails or is ambiguous, no transition is committed.
8. Exactly one running node is ticked per execution lane unless a state explicitly declares safe parallel policy.
9. Any conceptual BT root behavior must remain deterministic even if hidden from authoring.

## Update Phases

Each enabled update domain executes in this order:

1. Collect intents
- Gather transition intents from active path, event handlers, and reevaluation results.

2. Evaluate guards
- Evaluate all guard conditions for collected intents.
- Any guard error marks that intent denied.

3. Arbitrate
- Pick the winning intent using deterministic priority rules.
- If tie remains unresolved, deny all tied intents and keep current path.

4. Commit transition
- Exit old path from leaf upward to divergence point.
- Enter new path from divergence point downward.

5. Tick active path
- Execute ticks for current active path according to domain.

6. Emit trace
- Emit structured trace event(s) for decisions, transition result, and timing.

### Running Node Tick Ownership

The runtime owner is responsible for continuous ticks of running nodes:

1. The runtime determines the running node after transition commit.
2. The runtime dispatches process/physics ticks to that running node.
3. Nodes must not self-register as independent tick owners.
4. If running node changes, old running node is interrupted/exited per policy before new one begins receiving ticks.

## Transition Intent Model

A transition intent must include:

- Source state id
- Target state id (or target path id)
- Domain (process, physics, or both)
- Priority (integer)
- Trigger type (event, condition, timeout, manual)
- Guard references
- Interrupt policy
- Cooldown/debounce metadata
- Timestamp/frame index
- Optional reason payload for debug trace

## Transition Arbitration Rules

Arbiter selects exactly one transition intent by:

1. Keep only intents with passing guards.
2. Discard intents blocked by cooldown/debounce.
3. Sort by:
- Higher priority first
- Narrower scope first (leaf-local before global)
- Newer explicit event triggers before passive reevaluation
- Stable tie-breaker by deterministic id
4. Validate interrupt policy against current active state.
5. Commit winner, deny all others.

If no valid intent remains, stay on current active path.

### BT Leaf-Switch As Transition

When BT traversal selects a different executable leaf than previous update:

1. Generate a transition intent from previous leaf to new leaf.
2. Evaluate with the same guard/priority/interrupt pipeline as FSM transitions.
3. Apply lifecycle callbacks exactly like any other transition.

This is the core mechanism that makes BT and FSM semantics interoperable.

## Interrupt Policy

Each state declares one of:

- Not interruptible: cannot be preempted except by forced transition.
- Soft interruptible: can be preempted only by higher priority intents.
- Hard interruptible: can be preempted by any valid intent.

Forced transitions are reserved for explicit external control and must be logged distinctly.

## Lifecycle Contract

Each state/task supports:

- on_enter(context)
- on_tick_process(context, delta)
- on_tick_physics(context, delta)
- on_event(context, event)
- on_interrupt(context, reason)
- on_exit(context)

Contract rules:

1. on_enter runs once when state becomes active.
2. on_exit runs once when state stops being active.
3. on_interrupt runs before on_exit when preempted.
4. No lifecycle callback may call transition commit directly.
- Callbacks can only submit transition intents.
5. A running callback may request transition, but never bypass arbitration.

## Blackboard Contract

Blackboard is shared context, but typed and governed.

Each key has metadata:

- Key name
- Value type
- Scope (tree, subtree, state, frame)
- Owner (system or state id)
- Mutability (readonly, write-once, mutable)
- Optional ttl or reset policy

Rules:

1. Writes that violate type/scope policy are denied.
2. Missing required keys fail closed for affected guard/task.
3. Guards should read blackboard only; task writes must be explicit.
4. Frame-scope keys are cleared automatically at phase end.

### Action-Focused Blackboard Support

Because more logic is expected to move into actions:

1. Actions must declare read keys and write keys.
2. Runtime validates key access against blackboard metadata.
3. Optional action-local scratch scope may be provided and auto-cleared on action exit.

## BT and FSM Authoring Compatibility

BT style mapping:

- Selector/Sequence become decision states/tasks that emit intents.
- Conditions become guard producers.
- Action leaves become executable states/tasks.

FSM style mapping:

- Finite states map directly to executable states.
- Transitions map directly to transition intents with explicit guards.

Important:

- Both styles compile to the same runtime primitives.
- Neither style can bypass the arbiter.

### BT "Ping-Pong" Traversal Clarification

To align with planning language:

1. BT traversal may be implemented as repeated graph walk and propagate-back behavior.
2. Implementation may hide a concrete root task/node from authoring.
3. Runtime still preserves deterministic entry point and transition ordering.

## Canonical Nested Behavior Rules

To avoid controller nesting issues:

1. A state may contain BT-like or FSM-like child graph definitions.
2. Child graphs do not own a runner.
3. Parent and child logic both submit intents to the same arbiter.
4. Exit from nested behavior is always an intent to parent target.
5. Infinite residency is prevented with explicit exit intents or timeout policies.

### Nested FSM-in-BT and BT-in-FSM

Canonical rule set:

1. Nested graph boundaries are authoring boundaries, not runtime ownership boundaries.
2. A nested graph can suggest next runnable node, but scheduler confirms it.
3. Entering nested graph must define at least one explicit exit strategy:
- Guarded transition to parent
- Interrupt channel
- Timeout fallback
4. If no exit strategy is valid at runtime, fail closed to parent-safe fallback state.

## Domain Rules for Process and Physics

1. Domains are independent update lanes with shared active path state.
2. An intent can target one domain or both.
3. If both domains propose transitions in same frame:
- Physics intent wins by default for movement-critical trees.
- This precedence is configurable per tree profile.
4. Cross-domain commits must remain deterministic and logged.

Additional domain constraint:

5. Running node tick source must be centralized and consistent across both domains.

## Observability and Debug Requirements

Every phase emits structured events with:

- tree_id, frame, timestamp
- active_path_before, active_path_after
- intent_count, denied_count, winning_intent_id
- denial reasons (guard_failed, cooldown, interrupt_blocked, tie_denied)
- per-state enter/exit timing
- running_node_before, running_node_after
- transition_reason payload (if present)

Tracing must be append-only and safe in production with sampling options.

## Error Handling Policy

1. Guard exceptions deny that intent.
2. Arbiter exceptions deny all intents for that phase.
3. Lifecycle exceptions trigger safe interrupt and rollback to last valid active path.
4. Runtime never commits partially applied transitions.

## Migration Plan From Current Architecture

1. Introduce a central runtime scheduler class.
2. Convert existing FSM transition logic into transition intents.
3. Convert BT leaf change and branch reevaluation into transition intents.
4. Remove direct state switch calls outside runtime.
5. Add blackboard metadata and typed key enforcement.
6. Add structured tracing and transition diagnostics.
7. Enable compatibility adapters for legacy BT/FSM nodes.
8. Add explicit leaf-switch transition emission for BT branch changes.
9. Add declared action read/write key metadata and validation hooks.

## Non-Goals for V1

- Visual editor parity
- Automatic conversion of all old graph assets
- GOAP and Utility full integration
- Multi-agent shared blackboard federation

## Success Criteria

V1 is successful when:

1. All state changes happen through one arbiter.
2. BT-like and FSM-like authored graphs run with identical lifecycle guarantees.
3. Process and physics behavior are deterministic across runs.
4. Debug traces can explain every transition decision.
5. Nested graph deadlock and livelock cases are prevented by policy.
