## QA Tracker: profile, Ticket queue, Ticket detail, Review, and Case File.
## Defects are flagged from the Browser; a clean Ticket is closed here as NO ISSUE FOUND.
extends VBoxContainer

const Kit := preload("res://scripts/ui/kit.gd")
const P := preload("res://scripts/ui/palette.gd")
const Addresses := preload("res://scripts/domain/addresses.gd")
const GameState := preload("res://scripts/domain/game_state.gd")
const Draft := preload("res://scripts/domain/report_draft.gd")


var _header: HBoxContainer
var _body: Control
var _signature := ""
var _confirm_no_issue := false


func _ready() -> void:
	name = "TrackerApp"
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 0)
	var header_panel := Kit.panel(P.SUBTLE, Color.TRANSPARENT, 0, 12)
	_header = Kit.hbox(22)
	header_panel.add_child(_header)
	add_child(header_panel)
	_body = Kit.vbox(0)
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_body)
	for source in [GameSession.changed, DesktopSession.changed, WorkspaceSession.changed]:
		source.connect(_render)
	Settings.language_changed.connect(func():
		_signature = ""
		_render())
	_render()


func _selected_id() -> String:
	if DesktopSession.tracker_ticket_id != "":
		return DesktopSession.tracker_ticket_id
	var focus := GameSession.focus_ticket_id()
	return focus if focus != "" else "T01"


func _render() -> void:
	var state: Dictionary = GameSession.state
	var selected := _selected_id()
	var statuses := []
	for id in GameSession.catalog.ticket_ids():
		statuses.append(GameSession.ticket_status(id))
	var signature := "%s|%s|%s|%s|%s|%d|%d" % [
		DesktopSession.tracker_view, selected, ",".join(statuses), str(state["profile"]),
		str(_confirm_no_issue), state["reportHistory"].size(), WorkspaceSession.evidence_for(selected).size()] + Settings.language \
		+ str(state["story"]["deductions"]) + str(state["story"].get("foundDocuments", [])) \
		+ str(DesktopSession.messenger_log()["delivered"] >= DesktopSession.messenger_log()["entries"].size()) \
		+ str(state["story"].get("leads", []))
	if signature == _signature:
		return
	_signature = signature
	_render_header()
	Kit.clear(_body)
	if DesktopSession.tracker_view == "casefile":
		_body.add_child(Kit.scroll(Kit.margin(_case_file(), 20, 16, 20, 20)))
		return
	var split := Kit.hbox(0)
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.add_child(split)
	split.add_child(_queue(selected))
	var pane := Kit.vbox(0)
	pane.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var content: Control
	var scenario: Variant = GameSession.scenario(selected)
	if scenario == null or not GameSession.catalog.is_ticket_unlocked(state, selected):
		content = Kit.label("Resolve the previous Ticket to unlock this one.", 15, P.MUTED)
	elif DesktopSession.tracker_view == "review":
		content = _review(scenario)
	else:
		content = _detail(scenario)
	split.add_child(Kit.scroll(Kit.margin(content, 22, 18, 22, 22)))


func _render_header() -> void:
	Kit.clear(_header)
	var profile: Dictionary = GameSession.state["profile"]
	var who := Kit.hbox(10)
	who.add_child(Kit.avatar("JP", 40))
	var name_column := Kit.vbox(0)
	name_column.add_child(Kit.heading(profile["name"], 15))
	name_column.add_child(Kit.label("Junior QA" if profile["career"] == "JUNIOR_QA" else "QA Engineer", 13, P.MUTED, false))
	who.add_child(name_column)
	_header.add_child(who)
	var level := int(profile["level"])
	var xp := int(profile["xp"])
	var reputation := int(profile["reputation"])
	_header.add_child(_stat("Level", "%02d" % level, ""))
	_header.add_child(_stat("Experience", "%d XP" % xp, Kit.tf("%d XP to next level", level * 100 - xp)))
	_header.add_child(_stat("Reputation", str(reputation), _reputation_label(reputation)))
	_header.add_child(Kit.spacer())
	var queue := Kit.button("Ticket queue", DesktopSession.set_tracker_view.bind("detail"), "ChoiceButton")
	var case_file := Kit.button("Case File", DesktopSession.set_tracker_view.bind("casefile"), "ChoiceButton")
	var active: Button = case_file if DesktopSession.tracker_view == "casefile" else queue
	active.add_theme_stylebox_override("normal", Kit.style(P.ACCENT, P.ACCENT, 6, 12, 9))
	active.add_theme_color_override("font_color", Color.WHITE)
	active.add_theme_color_override("font_hover_color", P.ACCENT)
	_header.add_child(queue)
	_header.add_child(case_file)


func _stat(title: String, value: String, note: String) -> Control:
	var column := Kit.vbox(0)
	column.add_child(Kit.kicker(title))
	var value_label := Kit.heading(value, 18)
	value_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	column.add_child(value_label)
	if note != "":
		column.add_child(Kit.label(note, 12, P.MUTED, false))
	return column


static func _reputation_label(reputation: int) -> String:
	if reputation >= 110:
		return "Highly trusted"
	if reputation >= 100:
		return "Trusted"
	if reputation >= 90:
		return "Under watch"
	return "Needs improvement"


func _queue(selected: String) -> Control:
	var panel := Kit.panel(P.SUBTLE, Color.TRANSPARENT, 0, 8)
	panel.custom_minimum_size = Vector2(230, 0)
	var column := Kit.vbox(4)
	column.name = "TicketQueue"
	panel.add_child(column)
	for ticket in GameSession.catalog.scenarios.map(func(scenario): return scenario["ticket"]):
		var id: String = ticket["id"]
		var unlocked: bool = GameSession.catalog.is_ticket_unlocked(GameSession.state, id)
		var row := Kit.button("%s\n%s\n%s" % [id, Kit.t(ticket["title"]), Kit.status_label(GameSession.ticket_status(id)) if unlocked else Kit.t("Locked")],
			DesktopSession.show_ticket.bind(id, "detail"), "ChoiceButton")
		row.name = "Queue%s" % id
		row.alignment = HORIZONTAL_ALIGNMENT_LEFT
		row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.disabled = not unlocked
		if id == selected:
			row.add_theme_stylebox_override("normal", Kit.style(P.ACCENT_SOFT, P.ACCENT, 6, 12, 9, 2))
		column.add_child(row)
	return panel


func _detail(scenario: Dictionary) -> Control:
	var ticket: Dictionary = scenario["ticket"]
	var id: String = ticket["id"]
	var status := GameSession.ticket_status(id)
	var column := Kit.vbox(14)
	column.name = "TicketDetail"

	var top := Kit.hbox(16)
	var title_column := Kit.vbox(4)
	title_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var meta := Kit.hbox(8)
	meta.add_child(Kit.kicker(id))
	meta.add_child(Kit.kicker(ticket["priority"], P.WARNING))
	meta.add_child(Kit.kicker(Kit.STATUS_LABELS[status], P.MUTED))
	title_column.add_child(meta)
	title_column.add_child(Kit.heading(ticket["title"], 26))
	title_column.add_child(Kit.label(Kit.tf("From %s · %s", [ticket["sender"]["name"], Kit.t(ticket["sender"]["role"])]), 14, P.MUTED))
	top.add_child(title_column)
	var actions := Kit.vbox(8)
	if status == "NEW" or status == "ACCEPTED":
		actions.add_child(Kit.primary("Start test", GameSession.start_ticket.bind(id)))
	elif status == "TESTING":
		actions.add_child(Kit.button("Close as NO ISSUE FOUND", func():
			_confirm_no_issue = true
			_render()))
		if not GameSession.state["tickets"][id]["reportIds"].is_empty():
			actions.add_child(Kit.button("Last review", DesktopSession.show_ticket.bind(id, "review")))
	else:
		actions.add_child(Kit.button("View review", DesktopSession.show_ticket.bind(id, "review")))
	top.add_child(actions)
	column.add_child(top)

	var start_url := Addresses.shoply_url(ticket["startingContext"]["currentPath"])
	if status == "TESTING" and _confirm_no_issue:
		column.add_child(_no_issue_confirm(scenario))
	if status == "TESTING":
		var callout := Kit.panel(P.ACCENT_SOFT, Color.TRANSPARENT, 6, 12)
		var callout_body := Kit.vbox(4)
		callout_body.add_child(Kit.label("Testing. Open this address in the Browser. If something breaks a rule, press 🚩 Flag there.", 14))
		callout_body.add_child(Kit.link(Addresses.display(start_url), DesktopSession.open_url.bind(start_url)))
		callout.add_child(callout_body)
		column.add_child(callout)

	var intro: Variant = scenario.get("guide", {}).get("ticketIntro", null)
	if intro != null and status != "RESOLVED":
		var intro_panel := Kit.panel(P.SUBTLE, P.BORDER, 8, 18)
		intro_panel.name = "TicketIntro"
		var intro_row := Kit.hbox(24)
		var intro_text := Kit.vbox(6)
		intro_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		intro_text.add_child(Kit.kicker(scenario["guide"]["label"]))
		intro_text.add_child(Kit.heading(intro["heading"], 20))
		intro_text.add_child(Kit.label(intro["body"], 14))
		intro_row.add_child(intro_text)
		var steps := Kit.vbox(6)
		steps.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		for index in intro["steps"].size():
			steps.add_child(Kit.label("%d. %s" % [index + 1, Kit.t(intro["steps"][index])], 14))
		intro_row.add_child(steps)
		intro_panel.add_child(intro_row)
		column.add_child(intro_panel)

	var grid := Kit.hbox(28)
	var left := Kit.vbox(8)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 1.6
	left.add_child(Kit.kicker("Request"))
	left.add_child(Kit.label(ticket["request"], 16))
	left.add_child(Kit.kicker("Acceptance requirements"))
	for requirement in ticket["requirements"]:
		var row := Kit.hbox(10)
		var code := Kit.label(requirement["id"], 13, P.MUTED, false)
		code.custom_minimum_size = Vector2(96, 0)
		row.add_child(code)
		row.add_child(Kit.label(requirement["description"], 15))
		left.add_child(row)
	grid.add_child(left)
	var right := Kit.vbox(8)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_child(Kit.kicker("Test scope"))
	for item in ticket["scope"]:
		right.add_child(Kit.label("✓ %s" % Kit.t(item), 15))
	right.add_child(Kit.kicker("Starting context"))
	var context: Dictionary = ticket["startingContext"]
	right.add_child(Kit.label(Kit.tf("Account %s · Viewport %s · Locale %s", [context["account"], context["viewport"], context["locale"]]), 14, P.MUTED))
	if not ticket.get("attachments", []).is_empty():
		right.add_child(Kit.kicker("Attachments"))
		for attachment in ticket["attachments"]:
			right.add_child(Kit.link("📎 %s" % Kit.t(attachment["name"]), DesktopSession.open_url.bind(Addresses.doc_url(attachment["name"]))))
	var hints: Array = ticket.get("hints", [])
	if not hints.is_empty():
		var hint_text := Kit.label("", 14, P.TEXT)
		hint_text.visible = false
		hint_text.text = "\n".join(hints.map(func(hint): return "• %s" % Kit.t(hint["text"])))
		right.add_child(Kit.link("Need a hint?", func(): hint_text.visible = not hint_text.visible))
		right.add_child(hint_text)
	grid.add_child(right)
	column.add_child(grid)
	return column


## Review feedback is stored in English; two lines carry values and need their template.
static func feedback_text(line: String) -> String:
	if line.begins_with("Your steps skip: "):
		var labels: Array = Array(line.trim_prefix("Your steps skip: ").trim_suffix(".").split("; "))
		return Kit.tf("Your steps skip: %s.", "; ".join(labels.map(func(item): return Kit.t(item))))
	var noisy := RegEx.create_from_string("^Another tester could repeat this, but (\\d+) steps is a lot").search(line)
	if noisy:
		return Kit.tf("Another tester could repeat this, but %d steps is a lot. Keep only the actions that matter.", int(noisy.get_string(1)))
	return Kit.t(line)


func _no_issue_confirm(scenario: Dictionary) -> Control:
	var id: String = scenario["ticket"]["id"]
	var panel := Kit.panel(P.WARNING_SOFT, Color("#e6d27a"), 8, 14)
	panel.name = "NoIssueConfirm"
	var body := Kit.vbox(8)
	panel.add_child(body)
	body.add_child(Kit.heading("Nothing breaks a rule?", 18))
	body.add_child(Kit.label("If every requirement holds, close the Ticket as NO ISSUE FOUND. Missing a real defect costs Reputation.", 14))
	var row := Kit.hbox(8)
	row.add_child(Kit.primary("Confirm NO ISSUE FOUND", func():
		_confirm_no_issue = false
		var review: Dictionary = GameSession.submit_report(Draft.no_issue_report(scenario,
			WorkspaceSession.interactions_for(id), WorkspaceSession.evidence_for(id)))
		Sfx.play("success" if review["valid"] else "fail")
		DesktopSession.show_ticket(id, "review")))
	row.add_child(Kit.button("Keep testing", func():
		_confirm_no_issue = false
		_render()))
	body.add_child(row)
	return panel


func _review(scenario: Dictionary) -> Control:
	var id: String = scenario["ticket"]["id"]
	var latest: Variant = GameState.latest_review(GameSession.state, id)
	if latest == null:
		return Kit.label("No Review is available for this Ticket yet.", 15, P.MUTED)
	var result: Dictionary = latest["result"]
	var valid: bool = result["valid"]
	var column := Kit.vbox(14)
	column.name = "ReviewResult"

	var banner := Kit.panel(P.SUCCESS_SOFT if valid else P.DANGER_SOFT, P.SUCCESS if valid else P.DANGER, 10, 20)
	var banner_body := Kit.vbox(4)
	banner_body.add_child(Kit.kicker("QA Review", P.SUCCESS if valid else P.DANGER))
	banner_body.add_child(Kit.heading("VALID" if valid else "INVALID", 48, P.SUCCESS if valid else P.DANGER))
	banner_body.add_child(Kit.label("%d / 100" % int(result["totalScore"]), 18, P.TEXT, false))
	banner.add_child(banner_body)
	column.add_child(banner)

	var scores := Kit.hbox(10)
	for key in ["detection", "reproduction", "evidence", "severity"]:
		var cell := Kit.panel(P.SURFACE, P.BORDER, 8, 12)
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var cell_body := Kit.vbox(2)
		cell_body.add_child(Kit.label(key.capitalize(), 13, P.MUTED, false))
		cell_body.add_child(Kit.heading(str(int(result["scores"][key])), 24))
		cell.add_child(cell_body)
		scores.add_child(cell)
	column.add_child(scores)

	var reward := Kit.hbox(24)
	reward.add_child(_stat("XP", "+%d" % int(result["xp"]), ""))
	var delta := int(result["reputationDelta"])
	reward.add_child(_stat("Reputation", ("+%d" if delta >= 0 else "%d") % delta, ""))
	column.add_child(reward)

	var feedback := Kit.panel(P.SUBTLE, P.BORDER, 8, 14)
	var feedback_body := Kit.vbox(6)
	feedback_body.add_child(Kit.kicker("Lead feedback"))
	for line in result["feedback"]:
		feedback_body.add_child(Kit.label("• %s" % feedback_text(line), 15))
	feedback.add_child(feedback_body)
	column.add_child(feedback)

	var state: Dictionary = GameSession.state
	var is_latest: bool = latest["index"] == state["reportHistory"].size() - 1
	var previous_level := int(floor((int(state["profile"]["xp"]) - int(result["xp"])) / 100.0)) + 1
	if valid and is_latest and int(state["profile"]["level"]) > previous_level:
		var level_up := Kit.panel(P.ACCENT, Color.TRANSPARENT, 8, 14)
		level_up.add_child(Kit.heading(Kit.tf("Level up! You are now Level %d.", int(state["profile"]["level"])), 17, Color.WHITE))
		column.add_child(level_up)
	var review_guide: Variant = scenario.get("guide", {}).get("review", null)
	if review_guide != null:
		column.add_child(Kit.label(review_guide["valid"] if valid else review_guide["invalid"], 15, P.MUTED))

	var actions := Kit.hbox(10)
	if valid:
		if scenario.get("story", null) != null:
			actions.add_child(Kit.primary("The team replied · Open Messenger", DesktopSession.open_app.bind("messenger")))
		actions.add_child(Kit.button("Open Case File", DesktopSession.set_tracker_view.bind("casefile")))
	else:
		actions.add_child(Kit.primary(Kit.tf("Back to %s", id), DesktopSession.show_ticket.bind(id, "detail")))
	column.add_child(actions)
	return column


func _case_file() -> Control:
	var column := Kit.vbox(16)
	column.name = "CaseFile"
	var state: Dictionary = GameSession.state
	var log := DesktopSession.messenger_log()
	var pending: Variant = log["pendingDeduction"]
	if pending != null and pending.get("mode", "") == "board" and log["delivered"] >= log["entries"].size():
		column.add_child(_clue_board(pending))
	for chapter in GameSession.catalog.chapters:
		var beats: Array = GameSession.catalog.scenarios.filter(func(scenario):
			return scenario.get("story", null) != null and scenario["story"]["chapterId"] == chapter["id"])
		if beats.is_empty():
			continue
		var found: int = GameSession.catalog.found_clues(state, chapter["id"]).size()
		var closed: bool = state["story"]["deductions"].get(chapter["finaleDeductionId"], {}).get("solved", false)
		var header := Kit.hbox(10)
		var title_column := Kit.vbox(2)
		title_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title_column.add_child(Kit.kicker("Case file"))
		title_column.add_child(Kit.heading(chapter["title"], 24))
		header.add_child(title_column)
		header.add_child(Kit.label(Kit.t("Case closed") if closed else Kit.tf("%d / %d clues", [found, beats.size()]), 15, P.MUTED, false))
		column.add_child(header)
		column.add_child(Kit.label(chapter["synopsis"], 15, P.MUTED))
		var grid := GridContainer.new()
		grid.columns = 2
		grid.add_theme_constant_override("h_separation", 12)
		grid.add_theme_constant_override("v_separation", 12)
		for scenario in beats:
			var story: Dictionary = scenario["story"]
			var ticket_id: String = scenario["ticket"]["id"]
			var resolved := GameSession.ticket_status(ticket_id) == "RESOLVED"
			var clue_found: bool = GameSession.catalog.is_clue_found(state, scenario)
			var card := Kit.panel(P.WARNING_SOFT if clue_found else P.SUBTLE, Color("#e6d27a") if clue_found else P.BORDER, 8, 14)
			card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var body := Kit.vbox(4)
			body.add_child(Kit.kicker(ticket_id))
			if clue_found:
				body.add_child(Kit.heading(story["clue"]["title"], 16))
				body.add_child(Kit.label(story["clue"]["text"], 14))
				var connected: bool = state["story"]["deductions"].get(story["deduction"]["id"], {}).get("solved", false) if story.has("deduction") else true
				body.add_child(Kit.kicker("Connected" if connected else "Not yet connected", P.SUCCESS if connected else P.MUTED))
			elif resolved:
				body.add_child(Kit.heading("Record not found yet", 16, P.MUTED))
				body.add_child(Kit.label(story.get("discovery", {}).get("hint", ""), 14, P.MUTED))
			elif GameState.has_found(state, story.get("discovery", {}).get("documentId", "")):
				body.add_child(Kit.heading("Record found early", 16, P.MUTED))
				body.add_child(Kit.label(Kit.tf("Flag the defect in %s to connect it.", ticket_id), 14, P.MUTED))
			else:
				body.add_child(Kit.heading("Unknown clue", 16, P.MUTED))
				body.add_child(Kit.label(Kit.tf("Test %s and keep an eye on the Console.", ticket_id), 14, P.MUTED))
			var leads := GameState.leads_for(state, ticket_id)
			if not leads.is_empty() and not clue_found:
				var lead_row := HFlowContainer.new()
				lead_row.add_theme_constant_override("h_separation", 6)
				for term in leads:
					lead_row.add_child(Kit.button("🔎 %s" % term, DesktopSession.search_intranet.bind(term)))
				body.add_child(lead_row)
			card.add_child(body)
			grid.add_child(card)
		column.add_child(grid)
		if closed:
			var last: Dictionary = chapter["epilogue"][-1]
			column.add_child(Kit.label("%s: %s" % [last["from"], Kit.t(last["text"])], 15, P.WARNING))
	return column


## Pick the clues that prove a conclusion, then send it to the lead.
func _clue_board(deduction: Dictionary) -> Control:
	var board := Kit.panel(P.ACCENT_SOFT, P.ACCENT, 10, 16)
	board.name = "ClueBoard"
	var body := Kit.vbox(10)
	board.add_child(body)
	body.add_child(Kit.kicker("Connect the clues"))
	body.add_child(Kit.heading(Kit.t(deduction["prompt"]), 18))
	body.add_child(Kit.label("Pick the clues that prove it:", 14, P.MUTED))
	var selected := {}
	var picked := { "option": "" }
	var send := Kit.primary(Kit.tf("Send to %s", deduction["askedBy"]["from"]), func(): pass)
	var refresh_send := func():
		send.disabled = picked["option"] == "" or selected.is_empty()
	var clue_grid := GridContainer.new()
	clue_grid.columns = 2
	clue_grid.add_theme_constant_override("h_separation", 8)
	clue_grid.add_theme_constant_override("v_separation", 8)
	for clue in GameSession.catalog.found_clues(GameSession.state, _chapter_of(deduction)):
		var card := Kit.button("📌 %s" % Kit.t(clue["title"]), func(): pass, "ChoiceButton")
		card.name = "Clue%s" % clue["id"]
		card.toggle_mode = true
		card.alignment = HORIZONTAL_ALIGNMENT_LEFT
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var id: String = clue["id"]
		card.toggled.connect(func(on):
			if on:
				selected[id] = true
			else:
				selected.erase(id)
			refresh_send.call())
		clue_grid.add_child(card)
	body.add_child(clue_grid)
	body.add_child(Kit.label("Conclusion:", 14, P.MUTED))
	var group := ButtonGroup.new()
	for option in deduction["options"]:
		var choice := Kit.button(option["text"], func(): pass, "ChoiceButton")
		choice.toggle_mode = true
		choice.button_group = group
		choice.alignment = HORIZONTAL_ALIGNMENT_LEFT
		choice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		choice.custom_minimum_size = Vector2(560, 0)
		var option_id: String = option["id"]
		choice.pressed.connect(func():
			picked["option"] = option_id
			refresh_send.call())
		body.add_child(choice)
	var attempts: Array = GameSession.state["story"]["deductions"].get(deduction["id"], {}).get("boardAttempts", [])
	if not attempts.is_empty():
		var last: Dictionary = attempts[-1]
		var response := ""
		for option in deduction["options"]:
			if option["id"] == last["option"]:
				response = option["response"] if (last["correct"] or not option["correct"]) else deduction.get("boardHint", "")
		body.add_child(Kit.label(Kit.t(response), 14, P.WARNING))
	send.pressed.connect(func():
		GameSession.answer_board(deduction, picked["option"], selected.keys())
		var solved: bool = GameSession.state["story"]["deductions"].get(deduction["id"], {}).get("solved", false)
		Sfx.play("success" if solved else "fail")
		if solved:
			DesktopSession.open_app("messenger"))
	send.disabled = true
	body.add_child(send)
	return board


func _chapter_of(deduction: Dictionary) -> String:
	for scenario in GameSession.catalog.scenarios:
		var story: Variant = scenario.get("story", null)
		if story != null and story.get("deduction", {}).get("id", "") == deduction["id"]:
			return story["chapterId"]
	return ""
