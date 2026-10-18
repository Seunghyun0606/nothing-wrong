## Base class for headless tests. Methods named test_* are run by run_tests.gd.
extends RefCounted

var failures: Array[String] = []
## Set by the runner so UI tests can add scenes to the tree.
var tree: SceneTree


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func check_eq(actual: Variant, expected: Variant, message: String = "") -> void:
	var equal: bool
	if (typeof(actual) == TYPE_INT or typeof(actual) == TYPE_FLOAT) \
		and (typeof(expected) == TYPE_INT or typeof(expected) == TYPE_FLOAT):
		equal = is_equal_approx(float(actual), float(expected))
	else:
		equal = typeof(actual) == typeof(expected) and actual == expected
	if not equal:
		failures.append("%s expected %s but got %s" % [message, var_to_str(expected), var_to_str(actual)])
