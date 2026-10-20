## Saved Game State and the actions that change it. Port of GameSessionProvider.tsx
## plus versioned persistence (gameStateStorage.ts).
extends Node

signal changed

const Catalog := preload("res://scripts/domain/catalog.gd")
const GameState := preload("res://scripts/domain/game_state.gd")
const Intranet := preload("res://scripts/domain/intranet.gd")
const Review := preload("res://scripts/domain/review.gd")
const HorizonData := preload("res://scripts/domain/horizon_data.gd")
const Directory := preload("res://scripts/domain/directory.gd")

const SAVE_PATH := "user://save.json"
const BACKUP_PATH := "user://save.unreadable.json"

var catalog: RefCounted
var intranet: RefCounted
## Record views of the ONE HORIZON QA portal (data/horizon.json).
var horizon: RefCounted
## The Northstar directory: people and the client contacts (data/people.json).
var directory: RefCounted
var state: Dictionary = {}
## True when an unreadable save was set aside and a fresh game started.
var recovered_from_unreadable_save := false
## Tests turn this off to keep the player's save untouched.
var persist := true


func _ready() -> void:
	catalog = Catalog.load_from()
	intranet = Intranet.load_from()
	horizon = HorizonData.load_from()
	directory = Directory.load_from()
	load_state()


func load_state() -> void:
	recovered_from_unreadable_save = false
	if not FileAccess.file_exists(SAVE_PATH):
		state = GameState.create_initial(catalog.ticket_ids())
		return
	var text := FileAccess.get_file_as_string(SAVE_PATH)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) == TYPE_DICTIONARY and int(parsed.get("version", 0)) == GameState.SAVE_VERSION \
		and typeof(parsed.get("state")) == TYPE_DICTIONARY and parsed["state"].has("tickets"):
		state = GameState.reconcile(parsed["state"], catalog)
		return
	var backup := FileAccess.open(BACKUP_PATH, FileAccess.WRITE)
	if backup:
		backup.store_string(text)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	recovered_from_unreadable_save = true
	state = GameState.create_initial(catalog.ticket_ids())


func save() -> void:
	if not persist:
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({ "version": GameState.SAVE_VERSION, "state": state }))


func commit(next: Dictionary) -> void:
	if next == state:
		return
	state = next
	save()
	changed.emit()


func reset_progress() -> void:
	state = GameState.create_initial(catalog.ticket_ids())
	save()
	changed.emit()


## Opening an available record marks it found; story records reveal their clue.
func open_document(document_id: String) -> bool:
	var document: Variant = intranet.get_document(document_id)
	if document == null or not Intranet.is_available(document, state):
		return false
	var first_time := not GameState.has_found(state, document_id)
	commit(GameState.find_document(state, document_id))
	return first_time


## Records lead terms; returns the ones the player had not seen before.
func note_leads(terms: Array, ticket_id: String) -> Array:
	var known := GameState.lead_terms(state)
	var fresh: Array = terms.filter(func(term): return not known.has(term))
	if not fresh.is_empty():
		commit(GameState.note_leads(state, fresh, ticket_id))
	return fresh


## Reviews a report from Messenger (a defect or NO ISSUE FOUND) and applies the result.
func submit_report(input: Dictionary) -> Dictionary:
	var target: Variant = scenario(input["ticketId"])
	var report := input.duplicate(true)
	report["id"] = WorkspaceSession.new_id("REPORT")
	report["submittedAt"] = int(Time.get_unix_time_from_system() * 1000)
	var evidence := WorkspaceSession.evidence_for(input["ticketId"])
	var review := Review.review_report(report, target, evidence)
	var bugs: Array = target["expectedBugs"]
	if review["valid"] and bugs.size() > 1 and review.has("matchedBugId"):
		var found: Array = state["tickets"][input["ticketId"]].get("foundBugIds", []).duplicate()
		if not found.has(review["matchedBugId"]):
			found.append(review["matchedBugId"])
		review["partial"] = found.size() < bugs.size()
	if not review["valid"] and report.get("kind", "BUG") == "BUG":
		var noted: Array = evidence.filter(func(item): return report["evidenceIds"].has(item["id"]))
		review["hint"] = Review.reply_hint(report, target, noted[0] if not noted.is_empty() else {})
	complete_review(report, review, target.get("progression", {}))
	return review


func inspect(view_id: String, key: String, budget: int) -> void:
	commit(GameState.inspect(state, view_id, key, budget))


## A search that missed the record the team is waiting for; enough of them bring help.
func ask_hint(ticket_id: String) -> void:
	commit(GameState.ask_hint(state, ticket_id))


func note_search_miss(document_id: String) -> void:
	commit(GameState.note_search_miss(state, document_id))


func has_progress() -> bool:
	if not state["reportHistory"].is_empty():
		return true
	for id in state["tickets"]:
		if state["tickets"][id]["status"] != "NEW":
			return true
	return false


func start_ticket(ticket_id: String) -> void:
	if not catalog.is_ticket_unlocked(state, ticket_id):
		push_warning("Ticket is locked: %s" % ticket_id)
		return
	commit(GameState.start_ticket(state, ticket_id, Time.get_ticks_msec()))


func complete_review(report: Dictionary, review: Dictionary, reward: Dictionary) -> void:
	commit(GameState.apply_review(state, report, review, reward, int(Time.get_unix_time_from_system() * 1000)))


func answer_deduction(deduction: Dictionary, filled: Dictionary) -> void:
	commit(GameState.answer_deduction(state, deduction, filled))


## `last_id` is the newest entry delivered; it survives story changes that a count does not.
func mark_messages_delivered(count: int, last_id: String) -> void:
	if last_id == str(state["story"].get("deliveredId", "")):
		return
	var next := state.duplicate(true)
	next["story"]["deliveredCount"] = count
	next["story"]["deliveredId"] = last_id
	commit(next)


## Each conversation is read separately, up to its newest entry `last_id`.
## (story.readId and readCount are what older saves kept for the single chat.)
func mark_chat_read(conversation: String, last_id: String) -> void:
	var read_in: Dictionary = state["story"].get("readIn", {})
	if str(read_in.get(conversation, "")) == last_id:
		return
	var next := state.duplicate(true)
	read_in = read_in.duplicate()
	read_in[conversation] = last_id
	next["story"]["readIn"] = read_in
	commit(next)


func ticket_status(ticket_id: String) -> String:
	return state["tickets"].get(ticket_id, {}).get("status", "NEW")


func active_ticket_id() -> String:
	var current: Variant = state.get("currentTicketId")
	if current != null and ticket_status(str(current)) == "TESTING":
		return str(current)
	return ""


## The Ticket under test, or the next one waiting.
func focus_ticket_id() -> String:
	var active := active_ticket_id()
	if active != "":
		return active
	var next: Variant = catalog.find_next_open_ticket(state)
	return next["id"] if next != null else ""


func scenario(ticket_id: String) -> Variant:
	return catalog.get_scenario(ticket_id) if ticket_id != "" else null
