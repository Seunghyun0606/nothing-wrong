## Evaluates Scenario conditions against a runtime context.
## Context shape: { "test": {...}, "product": {...}, "workspace": {...} }.
## Port of src/game/mutations/resolveMutation.ts (condition part).
extends RefCounted

const MISSING := &"__nothing_wrong_missing__"


static func read_path(source: Variant, path: String) -> Variant:
	var current: Variant = source
	for segment in path.split(".", false):
		if typeof(current) != TYPE_DICTIONARY or not (current as Dictionary).has(segment):
			return MISSING
		current = current[segment]
	return current


static func read_value(field: String, context: Dictionary) -> Variant:
	if field.begins_with("test."):
		return read_path(context.get("test", {}), field.substr(5))
	if field.begins_with("product."):
		return read_path(context.get("product", {}), field.substr(8))
	if field.begins_with("workspace."):
		return read_path(context.get("workspace", {}), field.substr(10))
	var test_value: Variant = read_path(context.get("test", {}), field)
	if is_missing(test_value):
		return read_path(context.get("product", {}), field)
	return test_value


static func is_missing(value: Variant) -> bool:
	return typeof(value) == TYPE_STRING_NAME and value == MISSING


static func is_number(value: Variant) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT


## Strict equality that treats 2 and 2.0 as equal (JSON numbers load as floats).
static func same_value(a: Variant, b: Variant) -> bool:
	if is_number(a) and is_number(b):
		return is_equal_approx(float(a), float(b))
	if typeof(a) != typeof(b):
		return false
	return a == b


static func compare_ordered(actual: Variant, expected: Variant, operator: String) -> bool:
	var comparable := (is_number(actual) and is_number(expected)) \
		or (typeof(actual) == TYPE_STRING and typeof(expected) == TYPE_STRING)
	if not comparable:
		return false
	match operator:
		"GT":
			return actual > expected
		"GTE":
			return actual >= expected
		"LT":
			return actual < expected
		_:
			return actual <= expected


static func matches(condition: Dictionary, context: Dictionary) -> bool:
	var actual: Variant = read_value(str(condition.get("field", "")), context)
	if is_missing(actual):
		return false
	var expected: Variant = condition.get("value")
	match str(condition.get("operator", "")):
		"EQ":
			return same_value(actual, expected)
		"NEQ":
			return not same_value(actual, expected)
		"GT", "GTE", "LT", "LTE":
			return compare_ordered(actual, expected, str(condition.get("operator")))
		"IN":
			if typeof(expected) != TYPE_ARRAY:
				return false
			for candidate in expected:
				if same_value(candidate, actual):
					return true
			return false
		"INCLUDES":
			if typeof(actual) != TYPE_ARRAY:
				return false
			for candidate in actual:
				if same_value(candidate, expected):
					return true
			return false
		"STARTS_WITH":
			return typeof(actual) == TYPE_STRING and typeof(expected) == TYPE_STRING \
				and (actual as String).begins_with(expected)
	return false


static func all_match(conditions: Array, context: Dictionary) -> bool:
	for condition in conditions:
		if not matches(condition, context):
			return false
	return true
