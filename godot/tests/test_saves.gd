## Saves survive interrupted writes, unreadable files, and a restart mid-story.
extends "res://tests/ui_test_base.gd"

const SaveFile := preload("res://scripts/domain/save_file.gd")
const ReportDraft := preload("res://scripts/domain/report_draft.gd")


func test_tests_keep_away_from_the_players_saves() -> void:
	for path in [GameSession.save_path, GameSession.backup_path, WorkspaceSession.save_path, Settings.settings_path]:
		check(str(path).begins_with("user://tests/"), "%s is a test save" % path)
	check_eq(SaveFile.path("save.json"), "user://tests/save.json", "a custom main loop saves apart")


func test_a_save_cut_short_keeps_the_previous_one() -> void:
	var path := "user://tests/cut_short.json"
	SaveFile.remove(path)
	check(SaveFile.write(path, "first"), "written")
	check(SaveFile.write(path, "second"), "replaced")
	check_eq(SaveFile.read(path), "second", "the new save replaces the old")
	check(not FileAccess.file_exists(path + ".tmp"), "nothing is left behind")
	# A crash while writing leaves a partial temporary file next to the whole save.
	var partial := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	partial.store_string("{\"vers")
	partial.close()
	check_eq(SaveFile.read(path), "second", "the whole save is still the one read")
	# A crash between removing the old file and renaming the new one leaves only the new one.
	SaveFile.write(path + ".tmp", "third")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	check(SaveFile.exists(path), "the finished temporary file counts")
	check_eq(SaveFile.read(path), "third", "and is read")
	# The next save after such a crash puts that copy in place before writing again.
	SaveFile.write(path, "fourth")
	check_eq(SaveFile.read(path), "fourth", "saving goes on")
	SaveFile.remove(path)
	check(not SaveFile.exists(path), "removed with its temporary file")


## A save is never written over the old one in place: when its temporary file cannot be
## written, the old save is untouched.
func test_a_save_is_never_written_in_place() -> void:
	var path := "user://tests/in_place.json"
	SaveFile.remove(path)
	SaveFile.write(path, "old")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path + ".tmp"))
	check(not SaveFile.write(path, "new"), "the write fails")
	check_eq(FileAccess.get_file_as_string(path), "old", "the old save is whole")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path + ".tmp"))
	SaveFile.remove(path)


func test_unreadable_notes_are_kept_aside() -> void:
	WorkspaceSession.persist = true
	for text in ["{not json", JSON.stringify({ "version": 0, "state": {} }), JSON.stringify({ "version": 1, "state": "notes" }),
			JSON.stringify({ "version": 1, "state": { "notes": [] } }),
			JSON.stringify({ "version": 1, "state": { "evidence": [{ "id": "EVIDENCE-1" }] } }),
			JSON.stringify({ "version": 1, "state": { "evidence": [{ "ticketId": "T01" }] } }),
			JSON.stringify({ "version": 1, "state": { "interactions": [{ "ticketId": "T01" }] } }),
			JSON.stringify({ "version": 1, "state": { "notes": { "T01": { "bad": 1 } } } }),
			JSON.stringify({ "version": 1, "state": { "references": { "T01": "bad" } } }),
			JSON.stringify({ "version": 1, "state": { "evidence": [{ "id": "E1", "ticketId": "T01", "context": {}, "snapshot": {} }] } }),
			JSON.stringify({ "version": 1, "state": { "interactions": [{ "id": "A1", "ticketId": "T01", "type": "NAVIGATE", "target": 3 }] } })]:
		SaveFile.remove(WorkspaceSession.backup_path)
		SaveFile.write(WorkspaceSession.save_path, text)
		WorkspaceSession.load_state()
		check(WorkspaceSession.recovered_from_unreadable_save, "%s is set aside" % text)
		check_eq(SaveFile.read(WorkspaceSession.backup_path), text, "and kept as it was")
		check(WorkspaceSession.evidence.is_empty(), "the notes start empty")
		WorkspaceSession.save()
		check_eq(SaveFile.read(WorkspaceSession.backup_path), text, "a new note leaves the backup alone")
	SaveFile.remove(WorkspaceSession.save_path)
	SaveFile.remove(WorkspaceSession.backup_path)
	WorkspaceSession.load_state()
	check(not WorkspaceSession.recovered_from_unreadable_save, "no notes is just empty")
	WorkspaceSession.persist = false


func test_unreadable_and_outdated_saves_start_a_new_game() -> void:
	GameSession.persist = true
	for text in ["{not json", JSON.stringify({ "version": 0, "state": { "tickets": {} } }), JSON.stringify({ "version": 1, "state": [] })]:
		SaveFile.remove(GameSession.backup_path)
		SaveFile.write(GameSession.save_path, text)
		GameSession.load_state()
		check(GameSession.recovered_from_unreadable_save, "%s is set aside" % text)
		check_eq(SaveFile.read(GameSession.backup_path), text, "and kept as it was")
		check(not SaveFile.exists(GameSession.save_path), "the unreadable save is gone")
		check(GameSession.state == GameState.create_initial(GameSession.catalog.ticket_ids()), "a new game starts")
	SaveFile.remove(GameSession.save_path)
	GameSession.load_state()
	check(not GameSession.recovered_from_unreadable_save, "no save is just a new game")
	SaveFile.remove(GameSession.backup_path)
	GameSession.persist = false


## Valid JSON in the wrong shape: missing fields are filled in, wrong kinds are set aside.
func test_saves_in_the_wrong_shape_are_repaired_or_set_aside() -> void:
	GameSession.persist = true
	SaveFile.remove(GameSession.backup_path)
	SaveFile.write(GameSession.save_path, JSON.stringify({ "version": 1, "state": { "tickets": { "T01": { "status": "TESTING" } } } }))
	GameSession.load_state()
	check(not GameSession.recovered_from_unreadable_save, "a save missing fields is still read")
	check_eq(GameSession.ticket_status("T01"), "TESTING", "with its progress")
	check_eq(GameSession.state["reportHistory"], [], "and the missing fields filled in")
	check_eq(GameSession.state["tickets"]["T01"]["reportIds"], [], "per Ticket too")
	check(MessengerLog.build(GameSession.catalog, GameSession.state).has("entries"), "the chat builds from it")
	# The first Godot builds kept numbers (level, xp, reputation) in the profile.
	SaveFile.write(GameSession.save_path, JSON.stringify({ "version": 1, "state": { "tickets": { "T01": { "status": "RESOLVED", "reportIds": [] } },
		"profile": { "name": "J. PARK", "level": 1, "career": "JUNIOR_QA", "xp": 0, "reputation": 100 } } }))
	GameSession.load_state()
	check(not GameSession.recovered_from_unreadable_save, "a first-build save is still read")
	check_eq(GameSession.ticket_status("T01"), "RESOLVED", "with its progress")
	var damaged := [
		{ "tickets": { "T01": "TESTING" } },
		{ "tickets": { "T01": { "status": "DONE" } } },
		{ "tickets": {}, "reportHistory": {} },
		{ "tickets": {}, "currentTicketId": "T99" },
		{ "tickets": {}, "story": { "deductions": [] } },
		# Found by the Codex save probe (2026-10-26): wrong kinds one level down.
		{ "tickets": {}, "story": { "deliveredCount": { "bad": 1 } } },
		{ "tickets": {}, "reportHistory": ["bad"] },
		{ "tickets": {}, "story": { "deductions": { "D01": "bad" } } },
		{ "tickets": { "T01": { "status": "NEW", "reportIds": [1] } } },
		# Found by review: fields the game reads without checking.
		{ "tickets": {}, "profile": { "career": "JUNIOR_QA" } },
		{ "tickets": {}, "story": { "leads": [{ "term": "release-bot" }] } },
		{ "tickets": {}, "story": { "deductions": { "DED-T01": {} } } },
		{ "tickets": {}, "reportHistory": [{ "id": "R1" }], "reviewHistory": [] },
	]
	for state in damaged:
		var text := JSON.stringify({ "version": 1, "state": state })
		SaveFile.remove(GameSession.backup_path)
		SaveFile.write(GameSession.save_path, text)
		GameSession.load_state()
		check(GameSession.recovered_from_unreadable_save, "%s is set aside" % text)
		check_eq(SaveFile.read(GameSession.backup_path), text, "and kept as it was")
	SaveFile.remove(GameSession.save_path)
	SaveFile.remove(GameSession.backup_path)
	GameSession.persist = false


## A long session forgets its oldest actions, but never the last visit to a screen, so
## NO ISSUE FOUND still sees that the screen under test was opened.
func test_a_long_session_keeps_the_visit_to_each_screen() -> void:
	WorkspaceSession.reset()
	WorkspaceSession.record_interaction("T20", "NAVIGATE", "/horizon/identity-matching")
	# A reload on the same screen is not a report step, so it must not stand in for the visit.
	WorkspaceSession.record_interaction("T20", "RELOAD_PAGE", "/horizon/identity-matching")
	for index in WorkspaceSession.MAX_INTERACTIONS_PER_TICKET + 20:
		WorkspaceSession.record_interaction("T20", "NAVIGATE", "/shoply/product/%d" % (index % 7))
	var actions := WorkspaceSession.interactions_for("T20")
	check_eq(actions.size(), WorkspaceSession.MAX_INTERACTIONS_PER_TICKET, "the log stays capped")
	check(ReportDraft.steps_until(actions, "").any(func(step): return step.get("target", "") == "/horizon/identity-matching"), "the visit to the screen under test is kept as a step")
	WorkspaceSession.reset()


func test_a_game_reloaded_mid_chapter_picks_up_where_it_was() -> void:
	var desktop := _start()
	GameSession.persist = true
	WorkspaceSession.persist = true
	_accept(desktop, "T01")
	_address(desktop, "shoply.local")
	press(desktop, "View product →")
	press(desktop, "Add to bag")
	press(desktop, "View bag")
	press(desktop, "Continue to checkout")
	_note(desktop, "checkout.confirmButton")
	_report(desktop, "Confirm order button", "final confirmation control")
	check_eq(GameSession.ticket_status("T01"), "RESOLVED", "T01 resolved before the restart")
	var before: Dictionary = DesktopSession.messenger_log()
	var notes := WorkspaceSession.evidence_for("T01").size()
	var noted: Dictionary = WorkspaceSession.notes.duplicate(true)
	var leads := GameState.lead_terms(GameSession.state)
	var delivered: String = GameSession.state["story"].get("deliveredId", "")
	check(delivered != "", "the chat was delivered")
	_finish()

	# The game closes and starts again from the files.
	GameSession.state = {}
	WorkspaceSession.evidence = []
	GameSession.load_state()
	WorkspaceSession.load_state()
	check(not GameSession.recovered_from_unreadable_save, "the save is read back")
	desktop = _open()
	check_eq(GameSession.ticket_status("T01"), "RESOLVED", "T01 is still resolved")
	check_eq(WorkspaceSession.evidence_for("T01").size(), notes, "the notes are still there")
	check_eq(WorkspaceSession.notes, noted, "word for word")
	check_eq(GameState.lead_terms(GameSession.state), leads, "the leads from the console too")
	var after: Dictionary = DesktopSession.messenger_log()
	check_eq(after["entries"].size(), before["entries"].size(), "the same chat")
	check_eq(after["pendingDiscovery"], before["pendingDiscovery"], "still pointing at the same record")
	check_eq(GameSession.state["story"].get("deliveredId", ""), delivered, "no message is delivered twice")
	# The story goes on from there.
	_find_record(desktop, "release-bot", "DOC-CHECKOUT-HISTORY")
	DesktopSession.open_app("messenger")
	_deduce(desktop, { "changed": "did change", "when": "02:14", "who": "release-bot" })
	check(DesktopSession.messenger_log()["entries"].any(func(entry): return entry.get("ticketId", "") == "T02"), "T02 arrives after the restart")
	_finish()
	GameSession.persist = false
	WorkspaceSession.persist = false
	SaveFile.remove(GameSession.save_path)
	SaveFile.remove(WorkspaceSession.save_path)
