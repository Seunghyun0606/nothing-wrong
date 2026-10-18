## Messenger's report form: tell the Ticket's sender what you noted and which
## requirement it breaks, or that nothing does. Steps, Evidence, and severity are filled
## in from what you did (see report_draft.gd). The reply arrives in the chat.
extends VBoxContainer

const Kit := preload("res://scripts/ui/kit.gd")
const P := preload("res://scripts/ui/palette.gd")
const Observations := preload("res://scripts/domain/observations.gd")
const Draft := preload("res://scripts/domain/report_draft.gd")

## Notes shown as choices, newest first.
const MAX_NOTES := 6

var scenario: Dictionary
var ticket_id := ""
var expanded := false

var _confirm_no_issue := false
var _note: Dictionary = {}
var _requirement: Dictionary = {}
var _outcome := ""

const OUTCOME_LABELS := {
	"BUG": "A feature is broken (BUG)",
	"DATA_INTEGRITY": "Records disagree with each other (DATA INTEGRITY)",
	"DOC_GAP": "The requirement leaves something out (DOC GAP)",
}
var _send: Button


func setup(source_scenario: Dictionary) -> void:
	scenario = source_scenario
	ticket_id = scenario["ticket"]["id"]


func _ready() -> void:
	name = "ReportComposer"
	add_theme_constant_override("separation", 8)
	WorkspaceSession.changed.connect(func():
		if expanded:
			refresh())
	refresh()


## Distinct notes on this Ticket, newest first: the same value on the same screen
## counts once.
func notes() -> Array:
	var seen := {}
	var result: Array = []
	var items := WorkspaceSession.evidence_for(ticket_id)
	for index in range(items.size() - 1, -1, -1):
		var item: Dictionary = items[index]
		if not item.has("focus"):
			continue
		var key := "%s|%s|%s" % [item["context"]["currentPath"], item["focus"]["target"], item["focus"]["value"]]
		if seen.has(key):
			continue
		seen[key] = true
		result.append(item)
	return result.slice(0, MAX_NOTES)


func refresh() -> void:
	if not is_inside_tree():
		return
	Kit.clear(self)
	var sender: String = scenario["ticket"]["sender"]["name"]
	var listed := notes()
	if not expanded:
		var row := Kit.hbox(10)
		var open := Kit.primary(Kit.tf("📝 Report %s to %s", [ticket_id, sender]), func():
			expanded = true
			refresh())
		open.name = "OpenReport"
		row.add_child(open)
		row.add_child(Kit.label(Kit.tf("%d noted", listed.size()) if not listed.is_empty() else Kit.t("Nothing noted yet"), 13, P.MUTED, false))
		add_child(row)
		return

	var header := Kit.hbox(8)
	var title := Kit.kicker(Kit.tf("Report %s to %s", [ticket_id, sender]))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	header.add_child(Kit.link("✕", func():
		expanded = false
		_confirm_no_issue = false
		refresh()))
	add_child(header)

	if _confirm_no_issue:
		add_child(Kit.label(Kit.tf("Tell %s that every requirement holds?", sender), 14))
		var row := Kit.hbox(8)
		var confirm := Kit.primary("Send NO ISSUE FOUND", _send_no_issue)
		confirm.name = "SendNoIssue"
		row.add_child(confirm)
		row.add_child(Kit.button("Back", func():
			_confirm_no_issue = false
			refresh()))
		add_child(row)
		return

	add_child(Kit.label("What did you notice?", 14, P.MUTED))
	if listed.is_empty():
		add_child(Kit.label("Nothing noted yet. In the Browser, press 📌 Note and click what looks wrong.", 14, P.WARNING))
	var chips := HFlowContainer.new()
	chips.add_theme_constant_override("h_separation", 6)
	chips.add_theme_constant_override("v_separation", 6)
	var note_group := ButtonGroup.new()
	for index in listed.size():
		var item: Dictionary = listed[index]
		var chip := _choice("%s · %s" % [item["snapshot"].get("heading", ""), Observations.describe(item["focus"])], note_group)
		chip.name = "Note%d" % index
		chip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		chip.custom_minimum_size = Vector2(380, 0)
		if not _note.is_empty() and _note["id"] == item["id"]:
			chip.set_pressed_no_signal(true)
		chip.pressed.connect(func():
			_note = item
			_refresh_send())
		chips.add_child(chip)
	add_child(chips)

	add_child(Kit.label("Which requirement does it break?", 14, P.MUTED))
	var rule_group := ButtonGroup.new()
	for requirement in scenario["ticket"]["requirements"]:
		var choice := _choice("%s  %s" % [str(requirement["id"]).trim_prefix("REQ-"), Kit.t(requirement["description"])], rule_group)
		choice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		choice.custom_minimum_size = Vector2(380, 0)
		if not _requirement.is_empty() and _requirement["id"] == requirement["id"]:
			choice.set_pressed_no_signal(true)
		var picked: Dictionary = requirement
		choice.pressed.connect(func():
			_requirement = picked
			_refresh_send())
		add_child(choice)

	if _outcomes().size() > 1:
		add_child(Kit.label("What kind of problem is it?", 14, P.MUTED))
		var kind_group := ButtonGroup.new()
		for outcome in _outcomes():
			var kind := _choice(OUTCOME_LABELS.get(outcome, outcome), kind_group)
			kind.name = "Outcome%s" % outcome
			if _outcome == outcome:
				kind.set_pressed_no_signal(true)
			var picked_outcome: String = outcome
			kind.pressed.connect(func():
				_outcome = picked_outcome
				_refresh_send())
			add_child(kind)

	var footer := Kit.hbox(10)
	_send = Kit.primary("Send report", _send_report)
	_send.name = "SendReport"
	footer.add_child(_send)
	footer.add_child(Kit.spacer())
	var clean := Kit.button("Nothing is wrong", func():
		_confirm_no_issue = true
		refresh())
	clean.name = "ReportNoIssue"
	clean.tooltip_text = "Report NO ISSUE FOUND"
	footer.add_child(clean)
	add_child(footer)
	_refresh_send()


func _choice(text: String, group: ButtonGroup) -> Button:
	var choice := Kit.button(text, func(): pass, "ChoiceButton")
	choice.toggle_mode = true
	choice.button_group = group
	choice.alignment = HORIZONTAL_ALIGNMENT_LEFT
	return choice


func _outcomes() -> Array:
	return scenario["ticket"].get("outcomes", ["BUG"])


func _refresh_send() -> void:
	_send.disabled = _note.is_empty() or _requirement.is_empty() or (_outcomes().size() > 1 and _outcome == "")


func _send_report() -> void:
	var focus: Dictionary = _note["focus"]
	var observation := { "evidenceId": _note["id"], "target": focus["target"], "label": focus["label"], "value": focus["value"] }
	var report := Draft.bug_report(scenario, WorkspaceSession.interactions_for(ticket_id), _requirement, observation,
		"", str(_note["snapshot"].get("heading", "")), _outcome if _outcome != "" else "BUG")
	_reset()
	Sfx.play("click")
	GameSession.submit_report(report)


func _send_no_issue() -> void:
	var report := Draft.no_issue_report(scenario, WorkspaceSession.interactions_for(ticket_id), WorkspaceSession.evidence_for(ticket_id))
	_reset()
	Sfx.play("click")
	GameSession.submit_report(report)


func _reset() -> void:
	expanded = false
	_confirm_no_issue = false
	_note = {}
	_requirement = {}
	_outcome = ""
