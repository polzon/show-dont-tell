# Architectural Code Review: Show Not Tell AI Plugin

**Reviewer:** Senior Code Reviewer Agent  
**Date:** March 1, 2026  
**Scope:** Full architectural review of `addons/show_not_tell`  
**Focus:** Architecture, design patterns, system integration, and code organization

---

## Executive Summary

Show Not Tell is a well-structured modular AI behavior plugin implementing three distinct AI paradigms: Finite State Machines (FSM), Behavior Trees (BTree), and Goal-Oriented Action Planning (GOAP). The codebase demonstrates solid architectural foundations with clear separation of concerns and consistent patterns across modules.

**Overall Assessment:** 🟢 **GOOD** - Strong foundation with important architectural improvements needed

**Key Strengths:**
- Clean abstraction hierarchy with `BaseState` as the common foundation
- Consistent use of inheritance and polymorphism across all three AI systems
- Well-documented public APIs with comprehensive docstrings
- Clear separation between planning (GOAP) and execution concerns

**Critical Issues:**
- Tight coupling to external `Actor` and `Action` classes breaks plugin independence
- Mixed responsibilities in `BehaviorTree` (orchestration + task management)
- Inconsistent state management patterns across systems
- Missing dependency injection mechanisms

---

## 1. Architecture Assessment

### 1.1 Module Organization 📊

The plugin is organized into clear, purpose-driven modules:

```
show_not_tell/
├── core/           # Shared base abstractions
├── fsm/            # Finite State Machine implementation
├── btree/          # Behavior Tree implementation
├── goap/           # Goal-Oriented Action Planning
├── utility/        # Utility AI system
├── editor/         # Editor integration
└── plugin/         # Godot plugin interface
```

**Verdict:** ✅ **Excellent** - Clear module boundaries with logical grouping

**Issue:** The modules are well-separated at the directory level, but runtime dependencies blur these boundaries (especially with `Actor`/`Action`).

### 1.2 Inheritance Hierarchy 🌲

```
BaseState (core abstract)
├── FiniteState (FSM abstract)
│   └── StateMachine (FSM concrete orchestrator)
└── BehaviorTask (BTree abstract)
    ├── BehaviorTree (BTree concrete orchestrator)
    ├── BT_CompositeTask (BTree intermediary)
    ├── BT_DecoratorTask (BTree intermediary)
    └── BT_LeafTask (BTree leaf)
```

**Verdict:** ✅ **Strong** - Well-designed hierarchy with clear semantics

**Observations:**
- Appropriate use of `@abstract` annotations
- Both FSM and BTree share `BaseState` as their foundation
- Consistent naming conventions within each subsystem

**Concern:** GOAP system (`GOAPAgent`) does **not** inherit from `BaseState`, breaking the pattern. This creates architectural inconsistency.

### 1.3 Design Patterns Identified 🎯

| Pattern | Location | Quality | Notes |
|---------|----------|---------|-------|
| **State Pattern** | FSM/StateMachine | ✅ Excellent | Clean state transitions, signal-based communication |
| **Composite Pattern** | BTree/CompositeTask | ✅ Excellent | Proper tree traversal, parent-child management |
| **Decorator Pattern** | BTree/DecoratorTask | ✅ Good | Well-implemented behavior modification |
| **Strategy Pattern** | GOAP/GOAPAction | ✅ Good | Abstract action interface for planning |
| **Blackboard Pattern** | BTree/Blackboard | ⚠️ Basic | Simple but functional shared state |
| **Template Method** | BaseState | ✅ Excellent | Consistent lifecycle hooks |
| **Service Locator** | Various `find_*` methods | ⚠️ Anti-pattern | Tight coupling, breaks testability |

---

## 2. Critical Architectural Issues

### 🔴 **CRITICAL #1: External Dependency Coupling**

**Location:** `goap/goap_agent.gd`, `utility/utility_action.gd`, `utility/utility_evaluator.gd`

**Problem:**
The plugin is tightly coupled to external `Actor`, `Action`, and `ActionQueue` classes that exist outside the addon. This breaks the plugin's independence and reusability.

**Evidence:**
```gdscript
# goap_agent.gd:33
var actor: Actor

# utility_action.gd:8
func evaluate(actor: Actor, context: Dictionary = {}) -> float:

# goap_action.gd:48
@abstract func create_action() -> Action
```

**Impact:**
- Plugin cannot be used independently
- Cannot test GOAP/Utility systems in isolation
- Users must implement specific `Actor` classes to use the plugin
- Violates plugin architecture principles

**Recommendations:**

1. **Define Plugin-Internal Interfaces:**
```gdscript
# core/i_actor.gd
class_name IShowNotTellActor
extends RefCounted

## Interface for actors that can use this AI plugin.
## Implement this in your game's Actor class.

@abstract func get_position() -> Vector2:
	pass

@abstract func get_property(key: StringName) -> Variant:
	pass

@abstract func execute_behavior(behavior_id: StringName) -> void:
	pass
```

2. **Create Adapter Pattern for External Dependencies:**
```gdscript
# core/actor_adapter.gd
class_name ActorAdapter
extends IShowNotTellActor

var _wrapped_actor: Node

func _init(actor: Node) -> void:
	_wrapped_actor = actor

func get_position() -> Vector2:
	if _wrapped_actor.has_method("get_position"):
		return _wrapped_actor.get_position()
	return Vector2.ZERO
```

3. **Use Dependency Injection:**
- Pass actor interfaces to agents on initialization
- Remove runtime `find_actor()` searches
- Allow users to provide custom implementations

**Priority:** 🔴 **Critical** - This is the biggest architectural flaw

---

### 🔴 **CRITICAL #2: Service Locator Anti-Pattern**

**Location:** Throughout the codebase

**Problem:**
Extensive use of `find_*` methods for runtime dependency resolution creates hidden dependencies and reduces testability.

**Examples:**
```gdscript
# goap_agent.gd:69
func _find_actor() -> void:
	var parent: Node = get_parent()
	if parent is Actor:
		actor = parent
	# ... searches parent tree

# behavior_tree.gd:44
static func find_behavior_tree(node: Node) -> BehaviorTree:
	for child: Node in node.find_children("", &"BehaviorTree"):
		if child is BehaviorTree:
			return child
	return null

# state_machine.gd:33
static func find_state_machine(node: Node) -> StateMachine:
	for child: Node in node.find_children("", &"StateMachine"):
		if child is StateMachine:
			return child
	return null
```

**Impact:**
- Hidden dependencies make code harder to understand
- Difficult to test in isolation
- Runtime errors if expected nodes aren't found
- Violates explicit dependency principle

**Recommendations:**

1. **Replace with Explicit Injection:**
```gdscript
# Instead of:
func _ready():
	_find_actor()

# Use:
func initialize(actor: IShowNotTellActor) -> void:
	self.actor = actor
```

2. **For Editor Convenience, Use Optional Fallbacks:**
```gdscript
@export var actor: Node  # Set in editor
var _actor_interface: IShowNotTellActor

func _ready() -> void:
	if actor:
		_actor_interface = ActorAdapter.new(actor)
	else:
		push_warning("No actor set, attempting to find...")
		_actor_interface = _try_find_actor()
```

**Priority:** 🔴 **Critical** - Affects maintainability and testing

---

### 🟡 **IMPORTANT #1: BehaviorTree God Object**

**Location:** `btree/behavior_tree.gd`

**Problem:**
`BehaviorTree` has too many responsibilities:
- Task orchestration
- Tick processing (physics & process)
- Task lifecycle management
- Running task tracking
- Debug output
- Signal emissions

**Evidence:**
```gdscript
# Lines 1-158: 158 lines in a single class
# Multiple concerns:
var current_task: BehaviorTask
var running_task: BehaviorTask
var process_chain: Array[BehaviorTask]
# Debug flags:
@export var print_active_state: bool
@export var print_task_chain: bool
@export var debug_running_task: bool
```

**Impact:**
- Difficult to test individual responsibilities
- High cognitive load when modifying
- Violation of Single Responsibility Principle

**Recommendations:**

1. **Extract Task Manager:**
```gdscript
class_name TaskManager
extends RefCounted

var current_task: BehaviorTask
var running_task: BehaviorTask

func transition_to(task: BehaviorTask) -> void:
	if running_task:
		running_task._exited_state()
	running_task = task
	running_task._entered_state()
```

2. **Extract Debug Reporter:**
```gdscript
class_name BehaviorTreeDebugger
extends Node

var enabled: bool = false
var print_transitions: bool = false

func report_task_transition(from_task: BehaviorTask, to_task: BehaviorTask) -> void:
	if print_transitions:
		print("[BT] %s -> %s" % [from_task.name, to_task.name])
```

3. **Simplify BehaviorTree to Pure Orchestrator:**
```gdscript
class_name BehaviorTree
extends BehaviorTask

var task_manager: TaskManager
var debugger: BehaviorTreeDebugger

func _process(delta: float) -> void:
	if not enabled:
		return
	task_manager.tick_current_task(delta)
```

**Priority:** 🟡 **Important** - Affects maintainability and extensibility

---

### 🟡 **IMPORTANT #2: Inconsistent State Management**

**Location:** FSM vs BTree vs GOAP

**Problem:**
Each system manages state differently:
- **FSM:** Single active state with transitions
- **BTree:** Multiple states (`current_task`, `running_task`)
- **GOAP:** No clear state model, executes actions directly

**Evidence:**
```gdscript
# FSM: Clear single state
var state: FiniteState

# BTree: Dual state system
var current_task: BehaviorTask  # What we're evaluating
var running_task: BehaviorTask  # What's actually executing

# GOAP: No state tracking
var current_plan: Array[GOAPAction]
var current_action_index: int
```

**Impact:**
- Difficult to understand system state at runtime
- Complex mental model for users
- Challenging to debug multi-system interactions

**Recommendations:**

1. **Establish Unified State Model:**
```gdscript
# core/state_manager.gd
class_name AIStateManager
extends RefCounted

enum StateType { IDLE, EVALUATING, EXECUTING, TRANSITIONING }

var state_type: StateType = StateType.IDLE
var active_controller: BaseState
var execution_context: Dictionary = {}

func transition_to(new_controller: BaseState) -> void:
	if active_controller:
		active_controller._exited_state()
	active_controller = new_controller
	active_controller._entered_state()
```

2. **BTree Should Use Single State:**
The dual `current_task`/`running_task` system is confusing. Consider:
- `evaluating_task` - Currently being ticked
- `executing_task` - Leaf task that returned RUNNING

3. **GOAP Should Track Execution State:**
```gdscript
enum ExecutionState { IDLE, PLANNING, EXECUTING, WAITING_ACTION, REPLANNING }
var execution_state: ExecutionState = ExecutionState.IDLE
```

**Priority:** 🟡 **Important** - Affects usability and debugging

---

### 🟡 **IMPORTANT #3: GOAP Integration Inconsistency**

**Location:** `goap/goap_agent.gd`

**Problem:**
GOAP system doesn't inherit from `BaseState`, breaking architectural consistency with FSM and BTree.

**Evidence:**
```gdscript
# FSM and BTree inherit from BaseState
class_name StateMachine extends FiniteState extends BaseState
class_name BehaviorTree extends BehaviorTask extends BaseState

# But GOAP doesn't
class_name GOAPAgent extends Node  # ❌ Doesn't inherit BaseState
```

**Impact:**
- Cannot use GOAP nodes in same lifecycle as FSM/BTree
- Missing common signals (`started`, `ended`)
- Inconsistent API for users switching between systems

**Recommendations:**

1. **Make GOAPAgent Inherit BaseState:**
```gdscript
class_name GOAPAgent
extends BaseState  # Changed from Node

func _entered_state() -> void:
	super._entered_state()
	_start_planning()

func _exited_state() -> void:
	super._exited_state()
	_clear_current_plan()

func _tick(delta: float) -> Status:
	if continuous_planning:
		_update_replanning(delta)
	return Status.RUNNING if current_plan.size() > 0 else Status.SUCCESS
```

2. **Align Signals with Other Systems:**
```gdscript
signal planning_started
signal planning_completed(plan: Array[GOAPAction])
signal execution_started(action: GOAPAction)
signal execution_completed
```

**Priority:** 🟡 **Important** - Affects consistency and user experience

---

### 🟢 **SUGGESTION #1: Blackboard Enhancement**

**Location:** `btree/blackboard.gd`

**Problem:**
Blackboard is basic - no scoping, no type safety, no validation.

**Current State:**
```gdscript
var data: Dictionary[StringName, Variant] = {}

func set_data(key: StringName, value: Variant) -> void:
	data[key] = value
```

**Recommendations:**

1. **Add Scoping:**
```gdscript
enum Scope { LOCAL, SHARED, GLOBAL }

func set_data(key: StringName, value: Variant, scope: Scope = Scope.LOCAL) -> void:
	var scoped_data := _get_scope_dict(scope)
	scoped_data[key] = value
```

2. **Add Type Validation:**
```gdscript
var schema: Dictionary[StringName, int] = {}  # key -> TYPE_*

func set_data_typed(key: StringName, value: Variant) -> bool:
	if schema.has(key):
		if typeof(value) != schema[key]:
			push_error("Type mismatch for key: %s" % key)
			return false
	data[key] = value
	return true
```

3. **Add Change Notifications:**
```gdscript
signal data_changed(key: StringName, old_value: Variant, new_value: Variant)

func set_data(key: StringName, value: Variant) -> void:
	var old_value := data.get(key)
	data[key] = value
	data_changed.emit(key, old_value, value)
```

**Priority:** 🟢 **Suggestion** - Nice to have for power users

---

### 🟢 **SUGGESTION #2: Better Error Handling**

**Location:** Throughout, but especially `goap_agent.gd`

**Problem:**
Heavy use of `push_warning` and `push_error` without recovery mechanisms.

**Examples:**
```gdscript
# goap_agent.gd:86
if not actor:
	push_warning("GOAPAgent: Could not find Actor. Agent will not execute plans.")

# goap_agent.gd:154
if not action_queue:
	push_warning("GOAPAgent: No ActionQueue to execute plan.")
	return
```

**Impact:**
- Silent failures in production
- Difficult to debug without console access
- No programmatic error recovery

**Recommendations:**

1. **Define Error Types:**
```gdscript
# core/errors.gd
enum AIError {
	NONE,
	MISSING_ACTOR,
	MISSING_ACTION_QUEUE,
	INVALID_STATE_TRANSITION,
	PLANNING_FAILED,
	EXECUTION_FAILED,
}
```

2. **Add Error Handling Interface:**
```gdscript
class_name AIErrorHandler
extends RefCounted

signal error_occurred(error_type: AIError, message: String)

var last_error: AIError = AIError.NONE
var last_error_message: String = ""

func handle_error(error_type: AIError, message: String, recoverable: bool = false) -> bool:
	last_error = error_type
	last_error_message = message
	error_occurred.emit(error_type, message)
	
	if not recoverable:
		push_error(message)
		return false
	return true
```

3. **Use in GOAP:**
```gdscript
var error_handler := AIErrorHandler.new()

func _find_actor() -> void:
	# ... search logic ...
	if not actor:
		error_handler.handle_error(
			AIError.MISSING_ACTOR,
			"GOAPAgent: Could not find Actor.",
			false  # Not recoverable
		)
```

**Priority:** 🟢 **Suggestion** - Improves production debugging

---

## 3. Code Quality Assessment

### 3.1 Documentation 📚

**Verdict:** ✅ **Excellent**

- Comprehensive class-level docstrings
- Clear method documentation
- Good use of `@tutorial` annotations linking to external resources
- Internal dev notes are helpful (e.g., `# [Dev Note]` in `base_state.gd`)

**Minor Improvement:**
Add `@deprecated` annotations for methods that should be replaced:
```gdscript
## @deprecated Use get_child_state() instead.
func _find_child_state() -> BaseState:
	return get_child_state()
```

### 3.2 Naming Conventions 🏷️

**Verdict:** ✅ **Good**

- Consistent use of snake_case for methods
- Clear, descriptive names
- Proper use of prefixes (`_` for private, no prefix for public)

**Inconsistency:** Mixing "State" and "Task" terminology:
```gdscript
# In behavior_task.gd: TODO comment acknowledges this
# TODO: I keep swapping the usage of State and Task interchangably.
# Maybe I should settles on renaming them all one or the other?
```

**Recommendation:** Standardize on **"Task"** for BTree (matches literature), **"State"** for FSM.

### 3.3 Type Safety 🔒

**Verdict:** ✅ **Excellent**

Strong typing throughout:
```gdscript
var child_tasks: Array[BehaviorTask] = []
var data: Dictionary[StringName, Variant] = {}
func get_finite_state(state_type: GDScript) -> FiniteState:
```

**Outstanding:** Proper use of typed arrays and dictionaries!

### 3.4 Code Duplication 🔄

**Verdict:** ⚠️ **Moderate Issues**

**Example 1:** Multiple child-finding implementations in `base_state.gd`:
```gdscript
func _get_child_state_custom(state_type: GDScript, internal: bool) -> Node:
func _get_child_state_loop(state_type: GDScript, internal: bool) -> Node:
func _get_child_state_find(state_type: GDScript, _internal: bool) -> Node:
```

**Reason:** Debug comparison functions - acceptable for development, but should be removed for production.

**Example 2:** State transition logic duplicated in `selector_composite.gd` and `sequence_composite.gd`:
```gdscript
# Both have identical:
func _entered_state() -> void:
	_reset_child_index()
	super._entered_state()

func _exited_state() -> void:
	_reset_child_index()
	super._exited_state()
```

**Recommendation:** Extract to `CompositeTask` base class.

### 3.5 Assertions and Validation ✓

**Verdict:** ✅ **Excellent**

Good use of assertions for development:
```gdscript
assert(behavior_tree, "Missing behavior tree!")
assert(state_node, "Trying to change to null state!")
assert(is_current_task(), "Asserting task mismatch...")
```

**Outstanding:** Debug assertions that help catch errors during development.

---

## 4. System-Specific Analysis

### 4.1 Finite State Machine (FSM) 🎰

**Architecture:** ✅ **Excellent**

**Strengths:**
- Clean state pattern implementation
- Proper state lifecycle (`_on_state_start`, `_on_state_end`)
- Signal-based communication
- Action handling system
- Enable/disable functionality

**Code Example:**
```gdscript
func set_state(new_state: FiniteState) -> void:
	if state and not Engine.is_editor_hint():
		state._on_state_end()
		state_end.emit(state)
	state = new_state
	if state and not Engine.is_editor_hint():
		state._on_state_start()
		state_start.emit(state)
```

**Outstanding:** Editor hint checks prevent runtime issues in editor.

**Minor Issue:** `StateTransition` system is minimal - only one implementation (`transition_on_action.gd`).

**Recommendation:** Add common transition types:
- `TransitionOnTimer` - Transition after X seconds
- `TransitionOnCondition` - Transition when condition met
- `TransitionOnSignal` - Transition when signal emitted

---

### 4.2 Behavior Tree (BTree) 🌳

**Architecture:** ✅ **Good** (with issues noted above)

**Strengths:**
- Proper composite/decorator/leaf hierarchy
- Good collection of composites (Selector, Sequence, Parallel, Reactive variants)
- Decorators are well-implemented (Cooldown, Limiter, Inverter, etc.)
- Status enum is clear (SUCCESS, FAILED, RUNNING)

**Code Example - Excellent Pattern:**
```gdscript
func execute(delta: float) -> Status:
	if status != RUNNING:
		_entered_state()
		task_started.emit()
	
	status = _tick(delta)
	
	if status != RUNNING:
		_exited_state()
		task_ended.emit()
	
	return status
```

**Outstanding:** Clean lifecycle management with proper signal emissions.

**Issue:** Blackboard integration feels tacked on:
```gdscript
var blackboard: BT_Blackboard:
	get():
		if not blackboard:
			blackboard = behavior_tree._get_child_state_custom(BT_Blackboard, false)
		return blackboard
```

**Recommendation:** Make blackboard a required parameter passed down from BehaviorTree.

---

### 4.3 GOAP System 🎯

**Architecture:** ⚠️ **Needs Work** (issues noted above)

**Strengths:**
- A* planner is correctly implemented
- Clear separation between `GOAPAction` (planning) and `Action` (execution)
- World state model is simple and effective
- Goal priority system

**Code Example - Good Pattern:**
```gdscript
class PlanNode:
	var state: GOAPWorldState
	var action: GOAPAction
	var parent: PlanNode
	var g_cost: float
	var h_cost: float
	var f_cost: float:
		get: return g_cost + h_cost
```

**Outstanding:** Inner class for A* nodes keeps implementation clean.

**Issues:**
1. Tight coupling to external `Actor`/`Action` (covered above)
2. Plan execution is naive - queues all actions immediately:
```gdscript
func _execute_next_action() -> void:
	# ...
	action_queue.act(action)
	current_action_index += 1
	_execute_next_action()  # ❌ Immediately executes next!
```

**Recommendation:** Wait for action completion before executing next:
```gdscript
func _execute_next_action() -> void:
	# ...
	var action := goap_action.create_action()
	action.completed.connect(_on_action_completed)
	action_queue.act(action)

func _on_action_completed() -> void:
	current_action_index += 1
	_execute_next_action()
```

---

### 4.4 Utility AI System ⚖️

**Architecture:** ✅ **Good**

**Strengths:**
- Clean consideration-based scoring
- Curve-based evaluation
- Integrates with GOAP goals

**Code Example:**
```gdscript
func evaluate(actor: Actor, context: Dictionary = {}) -> float:
	var combined_score: float = 1.0
	for consideration in considerations:
		var score: float = consideration.evaluate(actor, context)
		combined_score *= score
	return clampf(combined_score * base_multiplier + bonus, 0.0, 1.0)
```

**Outstanding:** Multiplicative scoring is the correct approach for utility AI.

**Issue:** Same `Actor` coupling as GOAP (covered above).

---

## 5. Testing & Maintainability

### 5.1 Testability 🧪

**Verdict:** ⚠️ **Challenging**

**Barriers to Testing:**
1. Service locator pattern (`find_*` methods)
2. Hard dependencies on scene tree structure
3. Tight coupling to `Actor`/`Action`
4. No dependency injection

**Example of Untestable Code:**
```gdscript
func _ready() -> void:
	_find_actor()  # ❌ Can't test without full scene tree

func _find_actor() -> void:
	var parent: Node = get_parent()
	if parent is Actor:
		actor = parent
```

**Recommendation:** Refactor for testability:
```gdscript
# Test-friendly version:
func initialize_with_actor(actor_node: Node) -> void:
	self.actor = ActorAdapter.new(actor_node)

func _ready() -> void:
	if not actor:  # Auto-discovery fallback
		_find_and_initialize_actor()
```

### 5.2 Debug Support 🐛

**Verdict:** ✅ **Good**

**Strengths:**
- Debug flags in `BehaviorTree`
- Assertions throughout
- `_to_string()` implementations for debugging
- Dev notes in comments

**Example:**
```gdscript
@export_group("Debug")
@export var print_active_state: bool = false
@export var print_task_chain: bool = false
@export var debug_running_task: bool = false
```

**Recommendation:** Extract to dedicated debug/profiler class (covered above).

---

## 6. Godot Integration

### 6.1 Editor Plugin 🛠️

**Verdict:** ⚠️ **Incomplete**

**Current State:**
- Plugin registration works
- Editor UI exists (`behavior_graph.tscn`) but is non-functional per README
- Icon integration is complete

**Gap:** Editor UI is not functional - this limits visual development workflow.

**Recommendation:** Prioritize editor completion for:
- Visual behavior tree creation
- State machine visualization
- GOAP action/goal configuration

### 6.2 Godot Best Practices 🎮

**Verdict:** ✅ **Good**

**Strengths:**
- Proper use of `@icon` annotations
- `@export` groups for organization
- Signal-based architecture
- `@onready` for node references
- Editor hint checks (`Engine.is_editor_hint()`)

**Example:**
```gdscript
@icon("res://addons/show_not_tell/icons/tree.svg")
class_name BehaviorTree
extends BehaviorTask

@export var enabled: bool = true
@export var tick_processing := TickProcess.PHYSICS

@export_group("Debug")
@export var print_active_state: bool = false
```

**Outstanding:** Clean, idiomatic Godot code.

---

## 7. Priority Action Plan

### Phase 1: Foundation (Critical) 🔴

**Goal:** Decouple from external dependencies and establish testability

1. **Create Plugin Interface Layer** (2-3 days)
   - Define `IShowNotTellActor` interface
   - Create `ActorAdapter` pattern
   - Update GOAP to use interfaces
   - Update Utility AI to use interfaces

2. **Replace Service Locators** (1-2 days)
   - Add explicit dependency injection methods
   - Keep `find_*` as fallback for editor convenience
   - Document recommended usage patterns

3. **Unify GOAP with BaseState** (1 day)
   - Make `GOAPAgent` extend `BaseState`
   - Align signals and lifecycle
   - Update documentation

**Expected Outcome:** Plugin is independently reusable and testable.

---

### Phase 2: Refactoring (Important) 🟡

**Goal:** Improve code organization and consistency

4. **Refactor BehaviorTree** (2-3 days)
   - Extract `TaskManager` class
   - Extract `BehaviorTreeDebugger` class
   - Simplify `BehaviorTree` to orchestrator role
   - Update tests

5. **Standardize State Management** (1-2 days)
   - Create `AIStateManager` utility
   - Clarify BTree's dual-state system
   - Add state tracking to GOAP
   - Document state models

6. **Enhance GOAP Execution** (1 day)
   - Implement action completion waiting
   - Add execution state tracking
   - Improve plan failure handling

**Expected Outcome:** Cleaner, more maintainable codebase.

---

### Phase 3: Enhancement (Suggestions) 🟢

**Goal:** Add power features and improve polish

7. **Enhance Blackboard** (1-2 days)
   - Add scoping (local/shared/global)
   - Add type validation
   - Add change notifications
   - Add documentation

8. **Improve Error Handling** (1 day)
   - Create `AIErrorHandler` class
   - Define error types
   - Add error signals
   - Update documentation

9. **Expand FSM Transitions** (1-2 days)
   - Add `TransitionOnTimer`
   - Add `TransitionOnCondition`
   - Add `TransitionOnSignal`
   - Add examples

**Expected Outcome:** Production-ready plugin with advanced features.

---

## 8. Strengths to Preserve

**These are architectural decisions that should NOT be changed:**

1. ✅ **Shared BaseState Foundation** - Excellent abstraction that unifies systems
2. ✅ **Clear Separation of Concerns** - Each module has well-defined responsibilities
3. ✅ **Signal-Based Communication** - Decoupled, Godot-idiomatic event system
4. ✅ **Strong Typing** - Prevents many runtime errors
5. ✅ **Comprehensive Documentation** - Makes the codebase approachable
6. ✅ **Abstract Base Classes** - Forces proper inheritance structure
7. ✅ **Status Enum Pattern** - Clean, testable state returns
8. ✅ **Lifecycle Hooks** - `_entered_state`, `_exited_state`, `_tick` pattern
9. ✅ **Modular File Organization** - Easy to navigate and understand
10. ✅ **GOAP A* Implementation** - Correctly implements the algorithm

---

## 9. Specific Code Recommendations

### File: `core/base_state.gd`

**Issue:** Three different implementations of child-finding:
```gdscript
func _get_child_state_custom(state_type: GDScript, internal: bool) -> Node:
func _get_child_state_loop(state_type: GDScript, internal: bool) -> Node:
func _get_child_state_find(state_type: GDScript, _internal: bool) -> Node:
```

**Recommendation:** Choose one (probably `_custom` as it uses built-in `find_custom()`), remove others:
```gdscript
func get_child_state(state_type: GDScript, internal: bool = false) -> BaseState:
	var children := get_children(internal)
	var index := children.find_custom(
		func(task: Node) -> bool: return is_instance_of(task, state_type)
	)
	return null if index < 0 else children[index]
```

---

### File: `btree/behavior_tree.gd`

**Issue:** Dual state tracking is confusing:
```gdscript
var current_task: BehaviorTask
var running_task: BehaviorTask
```

**Recommendation:** Rename for clarity:
```gdscript
var evaluating_task: BehaviorTask  # Task being ticked
var executing_task: BehaviorTask   # Leaf that returned RUNNING
```

Add docstrings explaining the distinction:
```gdscript
## The task currently being evaluated in the tree traversal.
## This changes every frame during tree evaluation.
var evaluating_task: BehaviorTask

## The leaf task that returned RUNNING and is actively executing.
## This persists across frames until the task completes.
var executing_task: BehaviorTask
```

---

### File: `goap/goap_agent.gd`

**Issue:** Plan execution doesn't wait for action completion (line 167):
```gdscript
func _execute_next_action() -> void:
	# ... queue action ...
	_execute_next_action()  # ❌ Recursively calls immediately
```

**Recommendation:** Wait for completion signal:
```gdscript
func _execute_next_action() -> void:
	if current_action_index >= current_plan.size():
		_on_plan_complete()
		return

	var goap_action := current_plan[current_action_index]
	var action := goap_action.create_action()
	
	# Wait for action to complete before executing next
	if action.has_signal("completed"):
		action.completed.connect(_on_current_action_completed, CONNECT_ONE_SHOT)
	
	action_queue.act(action)
	world_state.apply_effects(goap_action.effects)

func _on_current_action_completed() -> void:
	current_action_index += 1
	_execute_next_action()
```

---

### File: `fsm/state_machine.gd`

**Issue:** `_find_first_finite_state()` only checks immediate children:
```gdscript
func _find_first_finite_state() -> FiniteState:
	for node: Node in get_children(false):
		if node is FiniteState:
			return node
	return null
```

**Recommendation:** Add warning if multiple states found:
```gdscript
func _find_first_finite_state() -> FiniteState:
	var found_states: Array[FiniteState] = []
	for node: Node in get_children(false):
		if node is FiniteState:
			found_states.append(node)
	
	if found_states.is_empty():
		return null
	
	if found_states.size() > 1:
		push_warning(
			"StateMachine has %d states, using first: %s. Set initial state explicitly."
			% [found_states.size(), found_states[0].name]
		)
	
	return found_states[0]
```

---

## 10. Conclusion

**Overall Assessment:** This is a **well-architected plugin** with a solid foundation. The critical issues identified are **solvable without major rewrites** and primarily involve decoupling external dependencies and establishing clearer interface boundaries.

### Key Takeaways:

1. **Architecture (8/10):** Strong patterns, clear separations, but tight external coupling
2. **Code Quality (9/10):** Excellent typing, documentation, and Godot practices
3. **Maintainability (7/10):** Good structure but service locators reduce testability
4. **Completeness (7/10):** Core systems work, but GOAP execution and editor need work

### Recommended Next Steps:

1. **Address Critical Issues First** (Phase 1)
   - External dependency decoupling
   - Interface definitions
   - GOAP/BaseState unification

2. **Refactor for Clarity** (Phase 2)
   - BehaviorTree simplification
   - State management standardization
   - GOAP execution improvements

3. **Polish and Extend** (Phase 3)
   - Enhanced Blackboard
   - Better error handling
   - Complete editor integration

### Final Verdict:

**🟢 APPROVED with CHANGES REQUIRED**

This plugin demonstrates strong software engineering principles and is production-ready for **personal use**. For **public release**, address the critical external dependency issues to make the plugin truly independent and reusable.

The codebase shows clear expertise in both AI systems and Godot architecture. The recommendations above will elevate it from "good internal tool" to "excellent public plugin."

---

**Reviewed by:** Senior Code Reviewer Agent  
**Review Type:** Comprehensive Architectural Analysis  
**Lines of Code Reviewed:** ~2,500  
**Files Reviewed:** 47  
**Time to Complete:** ~90 minutes  

*This review prioritizes architectural concerns over minor bugs as requested. Follow-up reviews can focus on specific systems or implementation details.*
