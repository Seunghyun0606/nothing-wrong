## The build gate: `NothingWrong.exe --headless --quit-after 2000 -- --self-check` parses
## every content file, opens each screen of the game once on a throwaway session, and
## prints "Self-check passed" (exit 0) only when nothing is missing and the engine logged
## no error meanwhile. Anything else fails, including a build that never prints the line:
## a script that does not parse stops the check before it can run.
extends Node

const GameState := preload("res://scripts/domain/game_state.gd")
const CONTENT := [
	"res://data/canon.json", "res://data/horizon.json", "res://data/intranet.json",
	"res://data/key_terms.json", "res://data/people.json", "res://data/scenarios.json",
	"res://data/shoply.json", "res://i18n/ko.json",
]


## Collects what the engine logs as an error while the check runs.
class ErrorLog extends Logger:
	var errors: Array[String] = []
	var _lock := Mutex.new()

	func _log_error(_function: String, file: String, line: int, code: String, rationale: String,
			_editor_notify: bool, _error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
		_lock.lock()
		errors.append("%s (%s:%d)" % [rationale if rationale != "" else code, file, line])
		_lock.unlock()


func _ready() -> void:
	if OS.get_cmdline_user_args().has("--self-check"):
		_run.call_deferred()


func _run() -> void:
	var log := ErrorLog.new()
	OS.add_logger(log)
	var problems: Array[String] = []
	for path in CONTENT:
		var parsed := JSON.new()
		if not FileAccess.file_exists(path):
			problems.append("missing %s" % path)
		elif parsed.parse(FileAccess.get_file_as_string(path)) != OK or (parsed.data is Dictionary and parsed.data.is_empty()):
			problems.append("unreadable %s" % path)
	var counts := {
		"tickets": GameSession.catalog.ticket_ids().size(),
		"chapters": GameSession.catalog.chapters.size(),
		"records": GameSession.intranet.documents.size(),
		"views": GameSession.horizon.views.size(),
		"people": GameSession.directory.people.size(),
	}
	for key in counts:
		if counts[key] == 0:
			problems.append("no %s loaded" % key)

	# Every screen once, on a session that saves nothing.
	var main := get_tree().current_scene
	if main == null or not main.has_method("show_desktop"):
		problems.append("the main scene has no script")
	else:
		Settings.persist = false
		GameSession.persist = false
		WorkspaceSession.persist = false
		GameSession.state = GameState.create_initial(GameSession.catalog.ticket_ids())
		WorkspaceSession.reset()
		DesktopSession.instant_messages = true
		for step in [
			func(): main.show_lock(),
			func(): main.show_desktop(),
			func(): GameSession.start_ticket(GameSession.catalog.ticket_ids()[0]),
			func(): DesktopSession.open_url("https://shoply.local/product/everyday-pack"),
			func(): DesktopSession.arrange_for_testing(),
			func(): DesktopSession.open_app("messenger"),
			func(): DesktopSession.open_url("https://people.northstar.local"),
			func(): DesktopSession.show_case_file(),
			func(): main.show_title(),
		]:
			step.call()
			await get_tree().process_frame
			await get_tree().process_frame

	OS.remove_logger(log)
	for error in log.errors:
		problems.append("error: %s" % error)
	if problems.is_empty():
		print("Self-check passed: %s" % JSON.stringify(counts))
	else:
		print("Self-check failed: %s" % JSON.stringify(counts))
		for problem in problems:
			print("  - %s" % problem)
	get_tree().quit(0 if problems.is_empty() else 1)
