extends GdUnitTestSuite

var _sm: StateMachine
var _solver: IntentSolver
var _builder: SdtFsmBuilder

var _state_a: FiniteState
var _state_b: FiniteState
var _state_c: FiniteState
var _state_d: FiniteState

var _a_to_b: SdtFsmBuilder.ToggleableCondition
var _a_to_c: SdtFsmBuilder.ToggleableCondition
var _b_to_c: SdtFsmBuilder.ToggleableCondition
var _c_to_d: SdtFsmBuilder.ToggleableCondition


func before_test() -> void:
	_builder = SdtFsmBuilder.new()
	_state_a = _builder.add_state(TestStateNode)
	_state_b = _builder.add_state(TestStateNode)
	_state_c = _builder.add_state(TestStateNode)
	_state_d = _builder.add_state(TestStateNode)

	_a_to_b = SdtFsmBuilder.always_pass()
	_a_to_c = SdtFsmBuilder.always_fail()
	_b_to_c = SdtFsmBuilder.always_pass()
	_c_to_d = SdtFsmBuilder.always_fail()

	_builder.add_transition(_state_a, _state_b, _a_to_b)
	_builder.add_transition(_state_a, _state_c, _a_to_c)
	_builder.add_transition(_state_b, _state_c, _b_to_c)
	_builder.add_transition(_state_c, _state_d, _c_to_d)

	_sm = auto_free(_builder.build())
	_solver = IntentSolver.new()
	_solver.state_machine = _sm
	add_child(_sm)


## Menu lists states reachable through currently-valid transitions.
func test_menu_lists_reachable_states() -> void:
	var intents := _solver.get_available_intents()

	assert_array(intents).contains_exactly([_state_b, _state_c])


## Menu excludes states behind a blocked transition.
func test_menu_excludes_unreachable() -> void:
	_a_to_b.can = false

	var intents := _solver.get_available_intents()

	assert_array(intents).is_empty()


## Menu reflects condition changes at runtime.
func test_menu_is_dynamic() -> void:
	_a_to_b.can = false
	_a_to_c.can = true

	var intents := _solver.get_available_intents()

	assert_array(intents).contains_exactly([_state_c])


## Cycle-safety prevents infinite loops on circular transitions.
func test_menu_handles_cycles() -> void:
	_builder.add_transition(_state_b, _state_a, SdtFsmBuilder.always_pass())

	var intents := _solver.get_available_intents()

	assert_array(intents).contains_exactly([_state_b, _state_c])


## navigate_to accepts a directly reachable state.
func test_navigate_direct_hop() -> void:
	var solved := _solver.navigate_to(_state_b)

	assert_bool(solved).is_true()
	assert_bool(_solver.has_active_plan()).is_true()


## navigate_to solves a multi-hop path.
func test_navigate_multi_hop() -> void:
	var solved := _solver.navigate_to(_state_c)

	assert_bool(solved).is_true()
	assert_bool(_solver.has_active_plan()).is_true()


## navigate_to rejects an unreachable target.
func test_navigate_unreachable() -> void:
	var solved := _solver.navigate_to(_state_d)

	assert_bool(solved).is_false()
	assert_bool(_solver.has_active_plan()).is_false()


## navigate_to to the current state is a no-op success.
func test_navigate_to_current_state() -> void:
	var solved := _solver.navigate_to(_state_a)

	assert_bool(solved).is_true()
	assert_bool(_solver.has_active_plan()).is_false()


## advance walks the plan one hop at a time.
func test_advance_walks_plan() -> void:
	_solver.navigate_to(_state_c)

	assert_bool(_solver.advance()).is_true()
	assert_that(_sm.state).is_equal(_state_b)
	assert_bool(_solver.has_active_plan()).is_true()

	assert_bool(_solver.advance()).is_true()
	assert_that(_sm.state).is_equal(_state_c)
	assert_bool(_solver.has_active_plan()).is_false()

	assert_bool(_solver.advance()).is_false()


## advance returns false when no plan is active.
func test_advance_without_plan() -> void:
	assert_bool(_solver.advance()).is_false()


## advance does nothing while the state machine is disabled.
func test_advance_while_disabled() -> void:
	_solver.navigate_to(_state_b)
	_sm.enabled = false

	assert_bool(_solver.advance()).is_false()
	assert_that(_sm.state).is_equal(_state_a)


## advance replans when the next step becomes invalid and a new path exists.
func test_advance_replans_on_invalid_step() -> void:
	_solver.navigate_to(_state_c)
	_a_to_b.can = false
	_a_to_c.can = true

	assert_bool(_solver.advance()).is_true()
	assert_that(_sm.state).is_equal(_state_c)


## advance abandons the plan when replan finds no path.
func test_advance_abandons_when_replan_fails() -> void:
	_solver.navigate_to(_state_c)
	_a_to_b.can = false

	assert_bool(_solver.advance()).is_false()
	assert_bool(_solver.has_active_plan()).is_false()


class TestStateNode:
	extends FiniteState
