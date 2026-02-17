class_name UtilityCurve
extends Resource
## Response curve for mapping input values to 0-1 utility scores.
##
## Used by [UtilityConsideration] to convert raw values (distance, health, etc.)
## into normalized scores. Different curve types provide different responses.

enum CurveType {
	LINEAR,  ## Simple linear mapping
	QUADRATIC,  ## Squared response (slow start, fast finish)
	INVERSE_QUADRATIC,  ## Inverse squared (fast start, slow finish)
	EXPONENTIAL,  ## Exponential growth
	INVERSE_EXPONENTIAL,  ## Exponential decay
	LOGISTIC,  ## S-curve (sigmoid)
	LOGIT,  ## Inverse S-curve
	CONSTANT,  ## Always returns the same value
}

## The type of curve to use.
@export var curve_type: CurveType = CurveType.LINEAR

## The slope/steepness of the curve. Higher = steeper.
@export var slope: float = 1.0:
	set(value):
		slope = value
		_exp_slope_cache = exp(slope)

## The power for exponential curves.
@export var exponent: float = 2.0

## The midpoint for logistic curves (0-1).
@export var midpoint: float = 0.5

## Output value for constant curves.
@export var constant_value: float = 1.0

## Invert the output (1 - result).
@export var invert: bool = false

## Cached exp(slope) to avoid recalculating on every evaluate().
var _exp_slope_cache: float


func _init() -> void:
	_exp_slope_cache = exp(slope)


## Evaluates the curve at the given normalized input (0-1).
## Returns a normalized output (0-1).
func evaluate(normalized_input: float) -> float:
	var input: float = clampf(normalized_input, 0.0, 1.0)
	var output: float = 0.0

	match curve_type:
		CurveType.LINEAR:
			output = input * slope

		CurveType.QUADRATIC:
			output = pow(input, exponent)

		CurveType.INVERSE_QUADRATIC:
			output = 1.0 - pow(1.0 - input, exponent)

		CurveType.EXPONENTIAL:
			var denom: float = _exp_slope_cache - 1.0
			if absf(denom) < 0.000001:
				# For slope ~ 0, the exponential curve tends to linear: output = input.
				output = input
			else:
				output = (exp(input * slope) - 1.0) / denom

		CurveType.INVERSE_EXPONENTIAL:
			var inv_denom: float = _exp_slope_cache - 1.0
			if absf(inv_denom) < 0.000001:
				# For slope ~ 0, the inverse exponential also tends to linear.
				output = input
			else:
				output = (
					1.0 - ((exp((1.0 - input) * slope) - 1.0) / inv_denom)
				)

		CurveType.LOGISTIC:
			var k: float = slope
			var x0: float = midpoint
			output = 1.0 / (1.0 + exp(-k * (input - x0)))

		CurveType.LOGIT:
			var k: float = slope
			var x0: float = midpoint
			output = 1.0 - (1.0 / (1.0 + exp(-k * (input - x0))))

		CurveType.CONSTANT:
			output = constant_value

	output = clampf(output, 0.0, 1.0)

	if invert:
		output = 1.0 - output

	return output


## Creates a linear curve.
static func linear(
	p_slope: float = 1.0, p_invert: bool = false
) -> UtilityCurve:
	var curve := UtilityCurve.new()
	curve.curve_type = CurveType.LINEAR
	curve.slope = p_slope
	curve.invert = p_invert
	return curve


## Creates a quadratic curve (slow start, fast finish).
static func quadratic(
	p_exponent: float = 2.0, p_invert: bool = false
) -> UtilityCurve:
	var curve := UtilityCurve.new()
	curve.curve_type = CurveType.QUADRATIC
	curve.exponent = p_exponent
	curve.invert = p_invert
	return curve


## Creates an inverse quadratic curve (fast start, slow finish).
static func inverse_quadratic(
	p_exponent: float = 2.0, p_invert: bool = false
) -> UtilityCurve:
	var curve := UtilityCurve.new()
	curve.curve_type = CurveType.INVERSE_QUADRATIC
	curve.exponent = p_exponent
	curve.invert = p_invert
	return curve


## Creates a logistic curve (S-curve).
static func logistic(
	p_slope: float = 10.0, p_midpoint: float = 0.5, p_invert: bool = false
) -> UtilityCurve:
	var curve := UtilityCurve.new()
	curve.curve_type = CurveType.LOGISTIC
	curve.slope = p_slope
	curve.midpoint = p_midpoint
	curve.invert = p_invert
	return curve


## Creates a constant curve.
static func constant(p_value: float = 1.0) -> UtilityCurve:
	var curve := UtilityCurve.new()
	curve.curve_type = CurveType.CONSTANT
	curve.constant_value = p_value
	return curve
