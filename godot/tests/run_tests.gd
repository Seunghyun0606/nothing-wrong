## Headless test runner:
##   godot --headless --path godot --script res://tests/run_tests.gd
## Exits with code 1 when any test fails.
extends SceneTree

const TEST_DIR := "res://tests"


func _initialize() -> void:
	# Autoloads become ready after the first frame starts.
	_run.call_deferred()


func _run() -> void:
	var files: Array[String] = []
	for file in DirAccess.get_files_at(TEST_DIR):
		if file.begins_with("test_") and file.ends_with(".gd") and file != "test_case.gd":
			files.append(file)
	files.sort()

	var passed := 0
	var failed := 0
	for file in files:
		var script: GDScript = load("%s/%s" % [TEST_DIR, file])
		var methods: Array = script.get_script_method_list().map(func(method): return method["name"])
		for method in methods:
			if not str(method).begins_with("test_"):
				continue
			var instance: RefCounted = script.new()
			instance.tree = self
			instance.call(method)
			if instance.failures.is_empty():
				passed += 1
			else:
				failed += 1
				print("FAIL %s :: %s" % [file, method])
				for failure in instance.failures:
					print("     - %s" % failure)

	print("Tests: %d passed, %d failed" % [passed, failed])
	quit(1 if failed > 0 else 0)
