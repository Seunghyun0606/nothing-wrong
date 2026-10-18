## QA Notes: the QA workbook. A page per Ticket (request, requirements, the spec, what you
## noted in the Browser, console leads, and your own notes) and the Case File, where the
## clues are connected. Reports go to the team in Messenger.
extends HBoxContainer

const Kit := preload("res://scripts/ui/kit.gd")
const P := preload("res://scripts/ui/palette.gd")
const GameState := preload("res://scripts/domain/game_state.gd")
const Addresses := preload("res://scripts/domain/addresses.gd")
const Observations := preload("res://scripts/domain/observations.gd")
const DeductionForm := preload("res://scripts/ui/apps/deduction_form.gd")

var _files: VBoxContainer
var _files_scroll: ScrollContainer
var _document: VBoxContainer
var _scroll: ScrollContainer
var _references: VBoxContainer
var _note_editor: TextEdit
var _signature := ""


func _ready() -> void:
	name = "NotesApp"
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 0)
	var files_panel := Kit.panel(P.SUBTLE, Color.TRANSPARENT, 0, 8)
	files_panel.custom_minimum_size = Vector2(150, 0)
	_files = Kit.vbox(4)
	_files.name = "TicketFiles"
	# The list grows with every chapter; it scrolls, and keeps the open Ticket in view.
	_files_scroll = Kit.scroll(_files)
	files_panel.add_child(_files_scroll)
	add_child(files_panel)
	_document = Kit.vbox(18)
	_scroll = Kit.scroll(Kit.margin(_document, 18, 16, 18, 16))
	add_child(_scroll)
	for source in [GameSession.changed, WorkspaceSession.changed, DesktopSession.changed, Settings.language_changed]:
		source.connect(_render)
	DesktopSession.reference_pinned.connect(func(_ticket, _attachment): _show_references.call_deferred())
	_render()


func _show_references() -> void:
	await get_tree().process_frame
	if is_instance_valid(_references):
		_scroll.ensure_control_visible(_references)


func _ticket_id() -> String:
	if DesktopSession.notes_ticket_id != "":
		return DesktopSession.notes_ticket_id
	var focus := GameSession.focus_ticket_id()
	return focus if focus != "" else "T01"


func _render() -> void:
	var state: Dictionary = GameSession.state
	var ticket_id := _ticket_id()
	var statuses := []
	for id in GameSession.catalog.ticket_ids():
		statuses.append(GameSession.ticket_status(id))
	var log := DesktopSession.messenger_log()
	var signature := "|".join([DesktopSession.notes_view, ticket_id, ",".join(statuses), Settings.language,
		str(WorkspaceSession.evidence_for(ticket_id).size()), str(WorkspaceSession.references_for(ticket_id)),
		str(state["story"].get("leads", [])), str(state["story"].get("foundDocuments", [])),
		str(state["story"]["deductions"]), str(log["delivered"] >= log["entries"].size())])
	if signature == _signature:
		return
	_signature = signature
	_render_files(ticket_id)
	Kit.clear(_document)
	if DesktopSession.notes_view == "casefile":
		_document.add_child(_case_file())
		return
	if not GameSession.catalog.is_ticket_unlocked(state, ticket_id):
		_document.add_child(Kit.label("Resolve the previous Ticket to unlock this one.", 15, P.MUTED))
		return
	_ticket_page(GameSession.scenario(ticket_id))


func _render_files(ticket_id: String) -> void:
	Kit.clear(_files)
	_files.add_child(Kit.kicker("Tickets"))
	for id in GameSession.catalog.ticket_ids():
		if not GameSession.catalog.is_ticket_unlocked(GameSession.state, id):
			continue
		var file := Kit.button("📝 %s\n%s" % [id, Kit.status_label(GameSession.ticket_status(id))], DesktopSession.show_ticket.bind(id), "ChoiceButton")
		file.name = "File%s" % id
		file.alignment = HORIZONTAL_ALIGNMENT_LEFT
		_highlight(file, DesktopSession.notes_view == "ticket" and id == ticket_id)
		_files.add_child(file)
		if DesktopSession.notes_view == "ticket" and id == ticket_id:
			_reveal_file.call_deferred(file)
	_files.add_child(Kit.kicker("Story"))
	var case_file := Kit.button("🗂 %s" % Kit.t("Case File"), DesktopSession.show_case_file, "ChoiceButton")
	case_file.name = "CaseFileTab"
	case_file.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_highlight(case_file, DesktopSession.notes_view == "casefile")
	_files.add_child(case_file)


func _reveal_file(file: Control) -> void:
	if is_instance_valid(file) and file.is_inside_tree():
		_files_scroll.ensure_control_visible(file)


static func _highlight(button: Button, on: bool) -> void:
	if not on:
		return
	button.add_theme_stylebox_override("normal", Kit.style(P.ACCENT, P.ACCENT, 6, 12, 9))
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", P.ACCENT)


# --- Ticket page -----------------------------------------------------------------

func _ticket_page(scenario: Dictionary) -> void:
	var ticket: Dictionary = scenario["ticket"]
	var ticket_id: String = ticket["id"]
	var status := GameSession.ticket_status(ticket_id)

	var sheet := Kit.panel(P.SUBTLE, P.BORDER_STRONG, 6, 14)
	sheet.name = "TicketDetail"
	var sheet_body := Kit.vbox(6)
	sheet.add_child(sheet_body)
	var meta := Kit.hbox(8)
	meta.add_child(Kit.kicker(ticket_id))
	meta.add_child(Kit.kicker(ticket["priority"], P.WARNING))
	meta.add_child(Kit.kicker(Kit.status_label(status), P.MUTED))
	sheet_body.add_child(meta)
	sheet_body.add_child(Kit.heading(ticket["title"], 20))
	sheet_body.add_child(Kit.label(Kit.tf("From %s · %s", [ticket["sender"]["name"], Kit.t(ticket["sender"]["role"])]), 14, P.MUTED))
	var start_url := Addresses.path_url(ticket["startingContext"]["currentPath"])
	if status == "NEW" or status == "ACCEPTED":
		var start := Kit.primary("Start test", GameSession.start_ticket.bind(ticket_id))
		start.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		sheet_body.add_child(start)
	elif status == "TESTING":
		var callout := Kit.panel(P.ACCENT_SOFT, Color.TRANSPARENT, 6, 12)
		var callout_body := Kit.vbox(6)
		callout_body.add_child(Kit.label(Kit.tf("Testing. Open Shoply, press 📌 Note on anything that looks wrong, then report it to %s in Messenger.", ticket["sender"]["name"]), 14))
		callout_body.add_child(Kit.link(Addresses.display(start_url), DesktopSession.open_url.bind(start_url)))
		var report := Kit.button(Kit.tf("📝 Report to %s", ticket["sender"]["name"]), DesktopSession.open_report)
		report.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		callout_body.add_child(report)
		callout.add_child(callout_body)
		sheet_body.add_child(callout)
	elif status == "RESOLVED":
		var done := Kit.hbox(10)
		done.add_child(Kit.label("Resolved. The team took it from here.", 14, P.SUCCESS, false))
		done.add_child(Kit.link("Open Case File", DesktopSession.show_case_file))
		sheet_body.add_child(done)
	_document.add_child(sheet)

	var brief := Kit.vbox(8)
	brief.add_child(Kit.kicker("Request"))
	brief.add_child(Kit.label(ticket["request"], 15))
	brief.add_child(Kit.kicker("Acceptance requirements"))
	for requirement in ticket["requirements"]:
		var row := Kit.hbox(10)
		var code := Kit.label(requirement["id"], 13, P.MUTED, false)
		code.custom_minimum_size = Vector2(96, 0)
		row.add_child(code)
		row.add_child(Kit.label(requirement["description"], 15))
		brief.add_child(row)
	brief.add_child(Kit.kicker("Test scope"))
	brief.add_child(Kit.label(" · ".join(ticket["scope"].map(func(item): return Kit.t(item))), 14))
	var context: Dictionary = ticket["startingContext"]
	brief.add_child(Kit.label(Kit.tf("Account %s · Viewport %s · Locale %s", [context["account"], context["viewport"], context["locale"]]), 13, P.MUTED))
	for attachment in ticket.get("attachments", []):
		brief.add_child(Kit.link("📎 %s" % Kit.t(attachment["name"]), DesktopSession.open_url.bind(Addresses.doc_url(attachment["name"]))))
	var hints: Array = ticket.get("hints", [])
	if not hints.is_empty():
		var hint_text := Kit.label("\n".join(hints.map(func(hint): return "• %s" % Kit.t(hint["text"]))), 14)
		hint_text.visible = false
		brief.add_child(Kit.link("Need a hint?", func(): hint_text.visible = not hint_text.visible))
		brief.add_child(hint_text)
	_document.add_child(brief)

	var pinned := WorkspaceSession.references_for(ticket_id)
	_references = Kit.vbox(10)
	_references.name = "References"
	_document.add_child(_references)
	if not pinned.is_empty():
		_references.add_child(Kit.kicker("Reference documents"))
	for attachment in ticket.get("attachments", []):
		if pinned.has(attachment["id"]):
			_references.add_child(_reference_card(ticket_id, attachment))

	var noted: Array = WorkspaceSession.evidence_for(ticket_id).filter(func(item): return item.has("focus"))
	var noted_section := Kit.vbox(8)
	noted_section.name = "Noted"
	noted_section.add_child(Kit.kicker(Kit.tf("What I noted · %d", noted.size())))
	if noted.is_empty():
		noted_section.add_child(Kit.label("Nothing noted yet. In the Browser, press 📌 Note and click what looks wrong.", 14, P.MUTED))
	for index in range(noted.size() - 1, -1, -1):
		noted_section.add_child(note_card(noted[index]))
	_document.add_child(noted_section)

	var notes_section := Kit.vbox(6)
	notes_section.add_child(Kit.kicker("My notes"))
	_note_editor = TextEdit.new()
	_note_editor.name = "MyNotes"
	_note_editor.custom_minimum_size = Vector2(0, 110)
	_note_editor.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_note_editor.placeholder_text = "Observations, hypotheses, reproduction details…"
	_note_editor.text = WorkspaceSession.notes.get(ticket_id, "")
	_note_editor.text_changed.connect(func(): WorkspaceSession.set_note(ticket_id, _note_editor.text))
	notes_section.add_child(_note_editor)
	notes_section.add_child(Kit.label("Saved automatically.", 13, P.MUTED))
	_document.add_child(notes_section)


func _reference_card(ticket_id: String, attachment: Dictionary) -> Control:
	var card := Kit.panel(P.WARNING_SOFT, Color("#e6d27a"), 8, 14)
	card.name = "Reference%s" % attachment["id"]
	var body := Kit.vbox(6)
	card.add_child(body)
	body.add_child(Kit.heading("📎 %s" % Kit.t(attachment["name"]), 16))
	if attachment.has("reference"):
		body.add_child(Kit.label(attachment["reference"], 13, P.MUTED))
	for line in attachment.get("content", []):
		body.add_child(Kit.label("•  %s" % Kit.t(line), 15))
	var actions := Kit.hbox(12)
	actions.add_child(Kit.link("Place beside Browser", DesktopSession.arrange_side_by_side.bind("browser", "notes")))
	var url := Addresses.doc_url(attachment["name"])
	actions.add_child(Kit.link("Open in Browser", DesktopSession.open_in_browser.bind(Addresses.parse(url))))
	actions.add_child(Kit.link("Unpin", WorkspaceSession.unpin_reference.bind(ticket_id, attachment["id"])))
	body.add_child(actions)
	return card


## One thing the player clicked in the Browser, with where and when it was seen.
static func note_card(item: Dictionary) -> Control:
	var card := Kit.panel(P.SURFACE, P.BORDER_STRONG, 8, 12)
	var body := Kit.vbox(4)
	card.add_child(body)
	var row := Kit.hbox(8)
	var pin := Kit.label("📌", 16, P.TEXT, false)
	row.add_child(pin)
	var value := Kit.heading(Observations.describe(item["focus"]), 15)
	value.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(value)
	body.add_child(row)
	var context: Dictionary = item["context"]
	var where := Kit.label("%s · %s · %s · %s" % [item["snapshot"].get("heading", ""), Addresses.display(Addresses.path_url(context["currentPath"])),
		context["account"], Kit.time_text(float(item["capturedAt"]))], 13, P.MUTED)
	where.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	body.add_child(where)
	for line in item["snapshot"].get("console", []):
		var logged := Kit.label("⚠ %s" % line, 13, P.WARNING)
		logged.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		body.add_child(logged)
	return card


# --- Case File -------------------------------------------------------------------

func _case_file() -> Control:
	var column := Kit.vbox(16)
	column.name = "CaseFile"
	var state: Dictionary = GameSession.state
	var log := DesktopSession.messenger_log()
	var pending: Variant = log["pendingDeduction"]
	if pending != null and pending.get("mode", "") == "board" and log["delivered"] >= log["entries"].size():
		column.add_child(_clue_board(pending))
	# The newest chapter first: that is where the open questions are.
	var chapters: Array = GameSession.catalog.chapters.duplicate()
	chapters.reverse()
	for chapter in chapters:
		if not GameSession.catalog.is_case_file_open(state, chapter):
			continue
		var beats: Array = GameSession.catalog.scenarios.filter(func(scenario):
			return scenario.get("story", null) != null and scenario["story"]["chapterId"] == chapter["id"])
		# A chapter the story has not reached stays hidden: its title would give it away.
		if beats.is_empty() or not GameSession.catalog.is_ticket_unlocked(state, beats[0]["ticket"]["id"]):
			continue
		var found: int = GameSession.catalog.found_clues(state, chapter["id"]).size()
		var closed: bool = state["story"]["deductions"].get(chapter["finaleDeductionId"], {}).get("solved", false)
		var header := Kit.hbox(10)
		var title_column := Kit.vbox(2)
		title_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title_column.add_child(Kit.kicker("Case file"))
		title_column.add_child(Kit.heading(chapter["title"], 22))
		header.add_child(title_column)
		header.add_child(Kit.label(Kit.t("Case closed") if closed else Kit.tf("%d / %d clues", [found, beats.size()]), 15, P.MUTED, false))
		column.add_child(header)
		column.add_child(Kit.label(chapter["synopsis"], 15, P.MUTED))
		for scenario in beats:
			column.add_child(_clue_card(scenario))
		if closed:
			var last: Dictionary = chapter["epilogue"][-1]
			column.add_child(Kit.label("%s: %s" % [last["from"], Kit.t(last["text"])], 15, P.WARNING))
	return column


func _clue_card(scenario: Dictionary) -> Control:
	var state: Dictionary = GameSession.state
	var story: Dictionary = scenario["story"]
	var ticket_id: String = scenario["ticket"]["id"]
	var resolved := GameSession.ticket_status(ticket_id) == "RESOLVED"
	var clue_found: bool = GameSession.catalog.is_clue_found(state, scenario)
	var card := Kit.panel(P.WARNING_SOFT if clue_found else P.SUBTLE, Color("#e6d27a") if clue_found else P.BORDER, 8, 14)
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
		body.add_child(Kit.label(Kit.tf("Report the defect in %s to connect it.", ticket_id), 14, P.MUTED))
	else:
		body.add_child(Kit.heading("Unknown clue", 16, P.MUTED))
		body.add_child(Kit.label(Kit.tf("Test %s and read the Console carefully.", ticket_id), 14, P.MUTED))
	card.add_child(body)
	return card


## Pick the clues that prove a conclusion, fill in its blanks, and send it to the lead.
func _clue_board(deduction: Dictionary) -> Control:
	var board := Kit.panel(P.ACCENT_SOFT, P.ACCENT, 10, 16)
	board.name = "ClueBoard"
	var body := Kit.vbox(10)
	board.add_child(body)
	body.add_child(Kit.kicker("Connect the clues"))
	body.add_child(Kit.heading(Kit.t(deduction["prompt"]), 18))
	var attempts: Array = GameSession.state["story"]["deductions"].get(deduction["id"], {}).get("attempts", [])
	if not attempts.is_empty() and typeof(attempts[-1]) == TYPE_DICTIONARY:
		var last: Dictionary = attempts[-1]
		body.add_child(Kit.label(Kit.tf("%d of %d parts hold up. Look at your clues again.", [int(last["right"]), int(last["total"])]), 14, P.WARNING))
	var form: VBoxContainer = DeductionForm.new()
	form.setup(deduction)
	body.add_child(form)
	return board
