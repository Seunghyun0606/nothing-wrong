## Notes, Evidence, and the interaction log. Port of WorkspaceSessionProvider.tsx.
extends Node

signal changed
signal notes_changed

const SaveFile := preload("res://scripts/domain/save_file.gd")
const SAVE_VERSION := 1
const MAX_INTERACTIONS_PER_TICKET := 200

var notes: Dictionary = {}
var evidence: Array = []
var interactions: Array = []
## Reference documents pinned to each Ticket's notes: { ticket_id: [attachment_id, ...] }.
var references: Dictionary = {}
var persist := true
var save_path := SaveFile.path("workspace.json")
## Unreadable notes are kept here before the notes start empty.
var backup_path := SaveFile.path("workspace.unreadable.json")
## True when unreadable notes were set aside.
var recovered_from_unreadable_save := false
var _counter := 0


func _ready() -> void:
	load_state()


func load_state() -> void:
	notes = {}
	evidence = []
	interactions = []
	references = {}
	recovered_from_unreadable_save = false
	if not SaveFile.exists(save_path):
		return
	var parsed: Variant = JSON.parse_string(SaveFile.read(save_path))
	if typeof(parsed) == TYPE_DICTIONARY and int(parsed.get("version", 0)) == SAVE_VERSION \
		and typeof(parsed.get("state")) == TYPE_DICTIONARY:
		var saved: Dictionary = parsed["state"]
		notes = saved.get("notes", {})
		evidence = saved.get("evidence", [])
		interactions = saved.get("interactions", [])
		references = saved.get("references", {})
		return
	# The next note would replace it; keep it whole first.
	recovered_from_unreadable_save = SaveFile.set_aside(save_path, backup_path)


func save() -> void:
	if not persist:
		return
	SaveFile.write(save_path, JSON.stringify({
		"version": SAVE_VERSION,
		"state": { "notes": notes, "evidence": evidence, "interactions": interactions, "references": references },
	}))


func reset() -> void:
	notes = {}
	evidence = []
	interactions = []
	references = {}
	save()
	changed.emit()
	notes_changed.emit()


func new_id(prefix: String) -> String:
	_counter += 1
	return "%s-%d-%d-%d" % [prefix, Time.get_ticks_msec(), _counter, randi() % 100000]


func set_note(ticket_id: String, content: String) -> void:
	notes[ticket_id] = content
	save()
	notes_changed.emit()


func pin_reference(ticket_id: String, attachment_id: String) -> void:
	var pinned: Array = references.get(ticket_id, [])
	if not pinned.has(attachment_id):
		pinned.append(attachment_id)
		references[ticket_id] = pinned
		save()
	changed.emit()


func unpin_reference(ticket_id: String, attachment_id: String) -> void:
	var pinned: Array = references.get(ticket_id, [])
	pinned.erase(attachment_id)
	references[ticket_id] = pinned
	save()
	changed.emit()


func references_for(ticket_id: String) -> Array:
	return references.get(ticket_id, [])


func add_evidence(item: Dictionary) -> void:
	evidence.append(item)
	save()
	changed.emit()


func record_interaction(ticket_id: String, type: String, target: String = "", payload: Dictionary = {}) -> void:
	var action := { "id": new_id("ACTION"), "ticketId": ticket_id, "timestamp": int(Time.get_unix_time_from_system() * 1000), "type": type }
	if target != "":
		action["target"] = target
	if not payload.is_empty():
		action["payload"] = payload
	if not interactions.is_empty():
		var last: Dictionary = interactions[-1]
		if last["ticketId"] == ticket_id and last["type"] == type and last.get("target") == action.get("target") \
			and JSON.stringify(last.get("payload", {})) == JSON.stringify(payload):
			return
	interactions.append(action)
	var for_ticket := interactions.filter(func(item): return item["ticketId"] == ticket_id)
	if for_ticket.size() > MAX_INTERACTIONS_PER_TICKET:
		var dropped: Array = for_ticket.slice(0, for_ticket.size() - MAX_INTERACTIONS_PER_TICKET).map(func(item): return item["id"])
		interactions = interactions.filter(func(item): return not dropped.has(item["id"]))
	save()
	changed.emit()


func evidence_for(ticket_id: String) -> Array:
	return evidence.filter(func(item): return item["ticketId"] == ticket_id)


func interactions_for(ticket_id: String) -> Array:
	return interactions.filter(func(item): return item["ticketId"] == ticket_id)
