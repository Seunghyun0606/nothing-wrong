## The Browser's flag sheet: what looks wrong on this screen, and which rule it breaks.
## Steps, Evidence, and severity are filled in (see report_draft.gd), so flagging is a
## quick check that keeps the player moving toward the story.
extends PanelContainer

signal closed

const Kit := preload("res://scripts/ui/kit.gd")
const P := preload("res://scripts/ui/palette.gd")
const Observations := preload("res://scripts/domain/observations.gd")
const Draft := preload("res://scripts/domain/report_draft.gd")

var scenario: Dictionary
var evidence: Dictionary

var _observation: Dictionary = {}
var _requirement: Dictionary = {}
var _send: Button
var _result: VBoxContainer
var _questions: VBoxContainer


func setup(source_scenario: Dictionary, capture: Dictionary) -> void:
	scenario = source_scenario
	evidence = capture


func _ready() -> void:
	name = "FlagPanel"
	add_theme_stylebox_override("panel", Kit.style(P.SURFACE, P.ACCENT, 0, 16, 12, 2))
	var body := Kit.vbox(10)
	add_child(body)

	var top := Kit.hbox(8)
	var title := Kit.heading(Kit.tf("🚩 Flag · %s", evidence.get("snapshot", {}).get("heading", "")), 17)
	title.autowrap_mode = TextServer.AUTOWRAP_OFF
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	top.add_child(Kit.button("✕", func(): closed.emit()))
	body.add_child(top)
	_result = Kit.vbox(6)
	body.add_child(_result)
	_questions = Kit.vbox(10)
	body.add_child(_questions)
	body = _questions

	body.add_child(Kit.label("1. What looks wrong?", 14, P.MUTED))
	var values := HFlowContainer.new()
	values.add_theme_constant_override("h_separation", 8)
	values.add_theme_constant_override("v_separation", 8)
	var value_group := ButtonGroup.new()
	var listed := Observations.observations_of(evidence)
	if listed.is_empty():
		body.add_child(Kit.label("Nothing on this screen can be flagged.", 14, P.MUTED))
	for observation in listed:
		var entry := { "evidenceId": evidence["id"], "target": observation["target"], "label": observation["label"], "value": observation["value"] }
		var chip := _choice(Observations.describe(observation), value_group)
		# Short value chips sit side by side in a flow row; wrapping would squeeze them.
		chip.autowrap_mode = TextServer.AUTOWRAP_OFF
		chip.pressed.connect(func():
			_observation = entry
			_refresh())
		values.add_child(chip)
	body.add_child(values)

	body.add_child(Kit.label("2. Which rule does it break?", 14, P.MUTED))
	var rule_group := ButtonGroup.new()
	for requirement in scenario["ticket"]["requirements"]:
		var choice := _choice("%s  %s" % [str(requirement["id"]).trim_prefix("REQ-"), Kit.t(requirement["description"])], rule_group)
		choice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var picked: Dictionary = requirement
		choice.pressed.connect(func():
			_requirement = picked
			_refresh())
		body.add_child(choice)

	var footer := Kit.hbox(12)
	var note := Kit.label("Steps and Evidence are filled in for you.", 13, P.MUTED)
	note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(note)
	_send = Kit.primary("Send flag", _submit)
	_send.name = "SendFlag"
	footer.add_child(_send)
	body.add_child(footer)
	_refresh()


func _choice(text: String, group: ButtonGroup) -> Button:
	var choice := Kit.button(text, func(): pass, "ChoiceButton")
	choice.toggle_mode = true
	choice.button_group = group
	choice.alignment = HORIZONTAL_ALIGNMENT_LEFT
	return choice


func _refresh() -> void:
	_send.disabled = _observation.is_empty() or _requirement.is_empty()


func _submit() -> void:
	var interactions := WorkspaceSession.interactions_for(scenario["ticket"]["id"])
	var review: Dictionary = GameSession.submit_report(Draft.bug_report(scenario, interactions, _requirement, _observation))
	Sfx.play("success" if review["valid"] else "fail")
	Kit.clear(_result)
	if review["valid"]:
		_questions.visible = false
		_result.add_child(Kit.heading(Kit.tf("Flag accepted · +%d XP", int(review["xp"])), 16, P.SUCCESS))
		var next := Kit.primary("The team replied · Open Messenger", func():
			closed.emit()
			DesktopSession.open_app("messenger"))
		next.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		_result.add_child(next)
		return
	_result.add_child(Kit.heading("Not quite.", 16, P.DANGER))
	for line in hints_from(review):
		var hint := Kit.label("• %s" % Kit.t(line), 14)
		hint.custom_minimum_size = Vector2(320, 0)
		_result.add_child(hint)


## Only the parts the player controls are worth explaining: the value and the rule,
## and whether the failure was on screen.
static func hints_from(review: Dictionary) -> Array:
	var feedback: Array = review.get("feedback", [])
	var scores: Dictionary = review.get("scores", {})
	var lines: Array = []
	if feedback.size() >= 4:
		for index in 3:
			var key: String = ["detection", "reproduction", "evidence"][index]
			if int(scores.get(key, 0)) == 0:
				lines.append(feedback[index])
	else:
		lines = feedback
	return lines.slice(0, 2)
