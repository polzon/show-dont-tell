# Refactoring Roadmap: Show Not Tell

**Based on:** [ARCHITECTURAL_REVIEW.md](ARCHITECTURAL_REVIEW.md)  
**Created:** March 1, 2026  
**Status:** 📋 Planning Phase

---

## Overview

This document provides an actionable roadmap for implementing the architectural improvements identified in the comprehensive code review. Items are prioritized by impact and organized into implementable phases.

---

## Quick Reference: Issue Priority Matrix

| Priority | Symbol | Count | Description |
|----------|--------|-------|-------------|
| Critical | 🔴 | 3 | Breaks plugin independence, must fix for public release |
| Important | 🟡 | 3 | Affects maintainability and usability, fix soon |
| Suggestion | 🟢 | 2 | Nice to have, improve when time allows |

**Total Issues:** 8 architectural concerns identified

---

## Phase 1: Critical Foundation 🔴

**Timeline:** 4-6 days  
**Goal:** Make plugin independent and testable  
**Status:** 🔲 Not Started

### 1.1 Create Plugin Interface Layer

**Issue:** External dependency coupling (Actor/Action classes)  
**Impact:** Plugin cannot be used independently  
**Effort:** Medium (2-3 days)

**Files to Create:**
- [ ] `core/i_show_not_tell_actor.gd` - Actor interface definition
- [ ] `core/actor_adapter.gd` - Adapter for external Actor classes
- [ ] `core/i_action_provider.gd` - Interface for action execution

**Files to Modify:**
- [ ] `goap/goap_agent.gd` - Use interface instead of direct Actor reference
- [ ] `utility/utility_action.gd` - Accept interface instead of Actor
- [ ] `utility/utility_evaluator.gd` - Accept interface instead of Actor
- [ ] `goap/core/goap_action.gd` - Update create_action() return type

**Acceptance Criteria:**
- ✅ GOAP system can be tested without external Actor class
- ✅ Users can implement custom actor interfaces
- ✅ Existing code still works with adapter pattern
- ✅ Documentation explains how to integrate with existing actors

**Testing Checklist:**
- [ ] Unit test GOAP planning without Actor dependency
- [ ] Integration test with adapter wrapping mock Actor
- [ ] Verify backward compatibility with existing Actor usage

---

### 1.2 Replace Service Locator Pattern

**Issue:** `find_*` methods create hidden dependencies  
**Impact:** Reduces testability and clarity  
**Effort:** Small (1-2 days)

**Files to Modify:**
- [ ] `goap/goap_agent.gd` - Add `initialize(actor)` method
- [ ] `btree/behavior_tree.gd` - Update `find_behavior_tree()`
- [ ] `fsm/state_machine.gd` - Update `find_state_machine()`
- [ ] Add example initialization code to README

**Changes:**
```gdscript
# Before:
func _ready():
	_find_actor()

# After:
@export var actor_node: Node  # Optional: Set in editor
func _ready():
	if actor_node:
		initialize(ActorAdapter.new(actor_node))
	else:
		_auto_find_actor()  # Fallback for convenience
```

**Acceptance Criteria:**
- ✅ Explicit initialization methods added to all agents
- ✅ `find_*` methods kept as optional fallbacks
- ✅ Documentation shows recommended usage
- ✅ Tests use explicit initialization

**Testing Checklist:**
- [ ] Test explicit initialization path
- [ ] Test auto-discovery fallback still works
- [ ] Test error handling when neither method finds dependency

---

### 1.3 Unify GOAP with BaseState

**Issue:** GOAPAgent doesn't inherit from BaseState  
**Impact:** Inconsistent API across AI systems  
**Effort:** Small (1 day)

**Files to Modify:**
- [ ] `goap/goap_agent.gd` - Extend BaseState instead of Node
- [ ] Implement `_tick()` method for continuous planning
- [ ] Implement `_entered_state()` for planning start
- [ ] Implement `_exited_state()` for cleanup

**Changes:**
```gdscript
# Before:
class_name GOAPAgent extends Node

# After:
class_name GOAPAgent extends BaseState

func _tick(delta: float) -> Status:
	if continuous_planning:
		_update_replanning(delta)
	return Status.RUNNING if current_plan.size() > 0 else Status.SUCCESS

func _entered_state() -> void:
	super._entered_state()
	_start_initial_planning()

func _exited_state() -> void:
	super._exited_state()
	current_plan.clear()
```

**Acceptance Criteria:**
- ✅ GOAPAgent inherits from BaseState
- ✅ Lifecycle signals (started/ended) work correctly
- ✅ Can be used alongside FSM/BTree in same architecture
- ✅ Existing functionality preserved

**Testing Checklist:**
- [ ] Verify signals emit correctly
- [ ] Test state lifecycle (enter/exit)
- [ ] Verify planning still works as expected

---

## Phase 2: Refactoring for Clarity 🟡

**Timeline:** 4-5 days  
**Goal:** Improve maintainability and consistency  
**Status:** 🔲 Not Started  
**Dependencies:** Phase 1 complete

### 2.1 Refactor BehaviorTree (Reduce God Object)

**Issue:** BehaviorTree has too many responsibilities  
**Impact:** Difficult to maintain and extend  
**Effort:** Medium (2-3 days)

**Files to Create:**
- [ ] `btree/task_manager.gd` - Extract task orchestration
- [ ] `btree/behavior_tree_debugger.gd` - Extract debug functionality
- [ ] Update tests to work with new structure

**Files to Modify:**
- [ ] `btree/behavior_tree.gd` - Simplify to pure orchestrator
- [ ] `btree/behavior_task.gd` - Update to work with TaskManager

**Extraction Plan:**

**TaskManager responsibilities:**
- Task tracking (current_task, running_task)
- Task lifecycle management
- Task transition logic

**BehaviorTreeDebugger responsibilities:**
- Debug flags (print_active_state, print_task_chain, debug_running_task)
- Debug output methods
- Process chain tracking for debugging

**Simplified BehaviorTree responsibilities:**
- Enable/disable control
- Tick processing delegation
- High-level orchestration

**Acceptance Criteria:**
- ✅ BehaviorTree class under 100 lines
- ✅ Each class has single, clear responsibility
- ✅ All existing functionality preserved
- ✅ Tests updated and passing

**Testing Checklist:**
- [ ] All existing BehaviorTree tests pass
- [ ] Unit test TaskManager in isolation
- [ ] Unit test Debugger in isolation
- [ ] Integration test full BehaviorTree

---

### 2.2 Standardize State Management

**Issue:** Inconsistent state models across FSM/BTree/GOAP  
**Impact:** Confusing mental model, difficult debugging  
**Effort:** Medium (1-2 days)

**Goals:**
1. Document state model for each system clearly
2. Rename confusing variables in BehaviorTree
3. Add state tracking to GOAP
4. Create unified state inspection API

**Files to Modify:**
- [ ] `btree/behavior_tree.gd` - Rename current_task/running_task
- [ ] `goap/goap_agent.gd` - Add execution_state tracking
- [ ] Create documentation in README

**BehaviorTree Renaming:**
```gdscript
# Current (confusing):
var current_task: BehaviorTask
var running_task: BehaviorTask

# Proposed (clear):
var evaluating_task: BehaviorTask  # Currently being ticked
var executing_task: BehaviorTask   # Leaf that returned RUNNING
```

**GOAP State Tracking:**
```gdscript
enum ExecutionState {
	IDLE,
	PLANNING,
	EXECUTING_ACTION,
	WAITING_FOR_COMPLETION,
	REPLANNING,
	ERROR
}
var execution_state: ExecutionState = ExecutionState.IDLE
```

**Acceptance Criteria:**
- ✅ State models clearly documented
- ✅ Code is self-explanatory
- ✅ Can query current state of any AI system
- ✅ Debugging is easier

**Testing Checklist:**
- [ ] Verify renamed variables work correctly
- [ ] Test state transitions in GOAP
- [ ] Update all dependent code

---

### 2.3 Fix GOAP Execution Model

**Issue:** GOAP queues all actions immediately, doesn't wait for completion  
**Impact:** Plans execute incorrectly  
**Effort:** Small (1 day)

**File to Modify:**
- [ ] `goap/goap_agent.gd` - Rewrite `_execute_next_action()`

**Current Issue:**
```gdscript
func _execute_next_action() -> void:
	# ... create action ...
	action_queue.act(action)
	current_action_index += 1
	_execute_next_action()  # ❌ Immediately calls next!
```

**Fixed Implementation:**
```gdscript
func _execute_next_action() -> void:
	if current_action_index >= current_plan.size():
		_on_plan_complete()
		return
	
	execution_state = ExecutionState.EXECUTING_ACTION
	var goap_action := current_plan[current_action_index]
	var action := goap_action.create_action()
	
	# Wait for action completion
	if action.has_signal("completed"):
		action.completed.connect(_on_current_action_completed, CONNECT_ONE_SHOT)
		execution_state = ExecutionState.WAITING_FOR_COMPLETION
	else:
		push_warning("Action has no completion signal, assuming immediate.")
		_on_current_action_completed()
	
	action_queue.act(action)
	world_state.apply_effects(goap_action.effects)

func _on_current_action_completed() -> void:
	current_action_index += 1
	_execute_next_action()
```

**Acceptance Criteria:**
- ✅ Actions execute sequentially, not all at once
- ✅ Agent waits for action completion before next action
- ✅ Handles actions without completion signals gracefully
- ✅ Execution state tracked accurately

**Testing Checklist:**
- [ ] Test plan with multiple actions executes correctly
- [ ] Test action completion triggers next action
- [ ] Test plan failure handling
- [ ] Verify world state updates correctly

---

## Phase 3: Enhancement & Polish 🟢

**Timeline:** 3-5 days  
**Goal:** Add power features and production polish  
**Status:** 🔲 Not Started  
**Dependencies:** Phases 1-2 complete

### 3.1 Enhanced Blackboard

**Issue:** Basic blackboard lacks advanced features  
**Impact:** Limited functionality for power users  
**Effort:** Medium (1-2 days)

**File to Modify:**
- [ ] `btree/blackboard.gd`

**Features to Add:**

**1. Scoping:**
```gdscript
enum Scope { LOCAL, TREE, GLOBAL }

func set_data(key: StringName, value: Variant, scope: Scope = Scope.LOCAL) -> void
func get_data(key: StringName, scope: Scope = Scope.LOCAL) -> Variant
```

**2. Type Validation:**
```gdscript
var schema: Dictionary[StringName, int] = {}

func define_key(key: StringName, type: int) -> void:
	schema[key] = type

func set_data_typed(key: StringName, value: Variant) -> bool:
	if schema.has(key) and typeof(value) != schema[key]:
		return false  # Type mismatch
	data[key] = value
	return true
```

**3. Change Notifications:**
```gdscript
signal data_changed(key: StringName, old_value: Variant, new_value: Variant)

func set_data(key: StringName, value: Variant) -> void:
	var old_value := data.get(key)
	data[key] = value
	if old_value != value:
		data_changed.emit(key, old_value, value)
```

**Acceptance Criteria:**
- ✅ Scoping system works correctly
- ✅ Type validation prevents errors
- ✅ Change notifications can be observed
- ✅ Backward compatible with existing code
- ✅ Documentation with examples

**Testing Checklist:**
- [ ] Test all three scope levels
- [ ] Test type validation rejection
- [ ] Test change notifications emit correctly
- [ ] Verify backward compatibility

---

### 3.2 Improved Error Handling

**Issue:** Silent failures with only console warnings  
**Impact:** Difficult to debug in production  
**Effort:** Small (1 day)

**Files to Create:**
- [ ] `core/ai_errors.gd` - Error types and handler
- [ ] `core/ai_error_handler.gd` - Centralized error management

**Files to Modify:**
- [ ] `goap/goap_agent.gd` - Use error handler
- [ ] `btree/behavior_tree.gd` - Use error handler
- [ ] `fsm/state_machine.gd` - Use error handler

**Implementation:**

**Error Types:**
```gdscript
# core/ai_errors.gd
enum AIError {
	NONE,
	MISSING_ACTOR,
	MISSING_ACTION_QUEUE,
	INVALID_STATE_TRANSITION,
	PLANNING_FAILED,
	EXECUTION_FAILED,
	MISSING_REQUIRED_CHILD,
}
```

**Error Handler:**
```gdscript
# core/ai_error_handler.gd
class_name AIErrorHandler
extends RefCounted

signal error_occurred(error_type: AIErrors.AIError, message: String)

var last_error: AIErrors.AIError = AIErrors.AIError.NONE
var last_error_message: String = ""
var error_count: int = 0

func handle_error(
	error_type: AIErrors.AIError,
	message: String,
	recoverable: bool = false
) -> bool:
	last_error = error_type
	last_error_message = message
	error_count += 1
	error_occurred.emit(error_type, message)
	
	if recoverable:
		push_warning(message)
	else:
		push_error(message)
	
	return recoverable
```

**Acceptance Criteria:**
- ✅ Error types defined for common issues
- ✅ Programmatic error access via signals
- ✅ Still logs to console for development
- ✅ Can track error counts/history
- ✅ Documentation with examples

**Testing Checklist:**
- [ ] Test error signal emission
- [ ] Test error tracking
- [ ] Verify console output still works
- [ ] Test recoverable vs non-recoverable errors

---

### 3.3 Expand FSM Transitions

**Issue:** Only one transition type implemented  
**Impact:** Users must implement common patterns manually  
**Effort:** Medium (1-2 days)

**Files to Create:**
- [ ] `fsm/transitions/transition_on_timer.gd`
- [ ] `fsm/transitions/transition_on_condition.gd`
- [ ] `fsm/transitions/transition_on_signal.gd`
- [ ] Examples in README or examples folder

**Implementation:**

**Timer Transition:**
```gdscript
class_name TransitionOnTimer
extends StateTransition

@export var duration: float = 1.0
var _timer: float = 0.0

func _ready() -> void:
	parent_state.started.connect(_on_state_entered)

func _on_state_entered() -> void:
	_timer = 0.0

func _process(delta: float) -> void:
	if is_current_state():
		_timer += delta
		if _timer >= duration:
			transition_allowed.emit(true)
```

**Condition Transition:**
```gdscript
class_name TransitionOnCondition
extends StateTransition

## Condition to evaluate. Should return bool.
@export var condition: Callable

@export var check_frequency: float = 0.1  # Check every 100ms
var _time_since_check: float = 0.0

func _process(delta: float) -> void:
	if not is_current_state():
		return
	
	_time_since_check += delta
	if _time_since_check >= check_frequency:
		_time_since_check = 0.0
		if condition.call():
			transition_allowed.emit(true)
```

**Signal Transition:**
```gdscript
class_name TransitionOnSignal
extends StateTransition

@export var signal_source: Node
@export var signal_name: StringName

func _ready() -> void:
	if signal_source and signal_source.has_signal(signal_name):
		signal_source.connect(signal_name, _on_signal_received)
	else:
		push_error("Invalid signal configuration")

func _on_signal_received() -> void:
	if is_current_state():
		transition_allowed.emit(true)
```

**Acceptance Criteria:**
- ✅ All three transition types implemented
- ✅ Each works correctly in test scenes
- ✅ Examples provided
- ✅ Documentation updated

**Testing Checklist:**
- [ ] Test timer transition timing accuracy
- [ ] Test condition transition evaluation
- [ ] Test signal transition triggering
- [ ] Test integration with StateMachine

---

## Phase 4: Documentation & Examples 📚

**Timeline:** 2-3 days  
**Goal:** Make plugin accessible to users  
**Status:** 🔲 Not Started  
**Dependencies:** All phases recommended

### 4.1 Update Core Documentation

**Files to Update:**
- [ ] README.md - Complete overview with new features
- [ ] Migration guide for any breaking changes
- [ ] API reference for all public classes

**Content Needed:**
- [ ] Getting started guide
- [ ] Architecture overview
- [ ] Integration guide for Actor/Action
- [ ] Best practices
- [ ] Common patterns
- [ ] Troubleshooting guide

---

### 4.2 Create Example Scenes

**Examples to Create:**
- [ ] FSM example - Simple patrol/chase/attack AI
- [ ] BTree example - Guard AI with complex behavior
- [ ] GOAP example - NPC with multiple goals
- [ ] Utility AI example - Decision-making AI
- [ ] Hybrid example - Combining FSM + BTree
- [ ] Integration example - Using with custom Actor

---

### 4.3 Complete Editor Integration

**Current State:** Non-functional editor UI  
**Goal:** Visual behavior tree/FSM editing

**Tasks:**
- [ ] Complete behavior_graph integration
- [ ] Add visual FSM editor
- [ ] Add GOAP action/goal editor
- [ ] Add node inspector improvements
- [ ] Add runtime debugging tools

**Note:** This is a major undertaking and may warrant its own project phase.

---

## Tracking & Progress

### Completion Status

- **Phase 1:** 0/3 tasks complete (0%)
- **Phase 2:** 0/3 tasks complete (0%)
- **Phase 3:** 0/3 tasks complete (0%)
- **Phase 4:** 0/3 tasks complete (0%)

**Overall Progress:** 0/12 major tasks complete

---

### Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Breaking existing code | Medium | High | Maintain backward compatibility, provide migration guide |
| Phase 1 takes longer than estimated | Medium | Medium | Can work on Phase 2/3 independently |
| Testing complexity increases | High | Medium | Write tests alongside refactoring |
| Editor integration too complex | High | Medium | Phase 4 is optional, defer if needed |

---

## Definition of Done

**Phase 1 Complete When:**
- [ ] Plugin can be used without external Actor class
- [ ] All tests pass
- [ ] No breaking changes to existing API
- [ ] Documentation updated

**Phase 2 Complete When:**
- [ ] BehaviorTree is under 100 lines
- [ ] State management is consistent
- [ ] GOAP execution works correctly
- [ ] All tests updated and passing

**Phase 3 Complete When:**
- [ ] All enhancement features implemented
- [ ] Tests written for new features
- [ ] Documentation includes new features
- [ ] Examples demonstrate new capabilities

**All Phases Complete When:**
- [ ] Full test suite passes
- [ ] Documentation is complete
- [ ] Example scenes work correctly
- [ ] Plugin is ready for public release

---

## Getting Started

**To begin refactoring:**

1. **Read the full architectural review:** [ARCHITECTURAL_REVIEW.md](ARCHITECTURAL_REVIEW.md)
2. **Start with Phase 1.1:** Create interface layer (biggest impact)
3. **Work incrementally:** Complete each task fully before moving to next
4. **Test continuously:** Run tests after each change
5. **Update docs:** Keep documentation in sync with changes
6. **Check this roadmap** regularly to track progress

**Remember:** These are recommendations, not requirements. Prioritize based on your needs and timeline.

---

**Last Updated:** March 1, 2026  
**Next Review:** After Phase 1 completion
