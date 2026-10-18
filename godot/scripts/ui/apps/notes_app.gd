## QA Notes: a Ticket sheet with links, leads from the console, personal notes,
## Evidence, and the activity log.
extends HBoxContainer

const Kit := preload("res://scripts/ui/kit.gd")
const P := preload("res://scripts/ui/palette.gd")
const GameState := preload("res://scripts/domain/game_state.gd")
const Addresses := preload("res://scripts/domain/addresses.gd")
const Observations := preload("res://scripts/domain/observations.gd")

var _files: VBoxContainer
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
	files_panel.custom_minimum_size = Vector2(130, 0)
	_files = Kit.vbox(4)
	files_panel.add_child(_files)
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
	var ticket_id := _ticket_id()
	var evidence := WorkspaceSession.evidence_for(ticket_id)
	var actions := WorkspaceSession.interactions_for(ticket_id)
	var pinned := WorkspaceSession.references_for(ticket_id)
	var leads := GameState.leads_for(GameSession.state, ticket_id)
	var signature := "%s|%s|%d|%d|%s|%s|%s|%s" % [ticket_id, GameSession.ticket_status(ticket_id), evidence.size(), actions.size(), str(pinned), Settings.language,
		str(leads), str(GameSession.state["story"].get("foundDocuments", []))]
	if signature == _signature:
		return
	_signature = signature

	Kit.clear(_files)
	for id in GameSession.catalog.ticket_ids():
		if not GameSession.catalog.is_ticket_unlocked(GameSession.state, id):
			continue
		var file := Kit.button("📝 %s.txt" % id, DesktopSession.show_notes.bind(id), "ChoiceButton")
		file.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if id == ticket_id:
			file.add_theme_stylebox_override("normal", Kit.style(P.ACCENT, P.ACCENT, 6, 12, 9))
			file.add_theme_color_override("font_color", Color.WHITE)
		_files.add_child(file)

	Kit.clear(_document)
	var ticket: Dictionary = GameSession.catalog.get_ticket(ticket_id)
	var sheet := Kit.panel(P.SUBTLE, P.BORDER_STRONG, 6, 14)
	var sheet_body := Kit.vbox(6)
	sheet.add_child(sheet_body)
	sheet_body.add_child(Kit.kicker("%s · %s" % [ticket_id, Kit.status_label(GameSession.ticket_status(ticket_id))]))
	sheet_body.add_child(Kit.heading(ticket["title"], 18))
	var start_url := Addresses.shoply_url(ticket["startingContext"]["currentPath"])
	var start_row := Kit.hbox(4)
	start_row.add_child(Kit.label("Start here:", 14, P.MUTED, false))
	start_row.add_child(Kit.link(Addresses.display(start_url), DesktopSession.open_url.bind(start_url)))
	sheet_body.add_child(start_row)
	for attachment in ticket.get("attachments", []):
		var doc_row := Kit.hbox(4)
		doc_row.add_child(Kit.label("Doc:", 14, P.MUTED, false))
		doc_row.add_child(Kit.link(attachment["name"], DesktopSession.open_url.bind(Addresses.doc_url(attachment["name"]))))
		sheet_body.add_child(doc_row)
	for requirement in ticket["requirements"]:
		sheet_body.add_child(Kit.label("• %s  %s" % [requirement["id"], Kit.t(requirement["description"])], 14))
	_document.add_child(sheet)

	_references = Kit.vbox(10)
	_references.name = "References"
	_document.add_child(_references)
	if not pinned.is_empty():
		_references.add_child(Kit.kicker("Reference documents"))
	for attachment in ticket.get("attachments", []):
		if pinned.has(attachment["id"]):
			_references.add_child(_reference_card(ticket_id, attachment))

	if not leads.is_empty():
		var lead_panel := Kit.panel(P.WARNING_SOFT, Color("#e6d27a"), 6, 12)
		lead_panel.name = "Leads"
		var lead_body := Kit.vbox(6)
		lead_panel.add_child(lead_body)
		lead_body.add_child(Kit.kicker("Leads from the console"))
		lead_body.add_child(Kit.label("Names and codes Shoply logged while the defect was on screen. Search the intranet for them.", 13, P.MUTED))
		var chips := HFlowContainer.new()
		chips.add_theme_constant_override("h_separation", 6)
		chips.add_theme_constant_override("v_separation", 6)
		for term in leads:
			chips.add_child(Kit.button("🔎 %s" % term, DesktopSession.search_intranet.bind(term)))
		lead_body.add_child(chips)
		_document.add_child(lead_panel)

	var notes_section := Kit.vbox(6)
	notes_section.add_child(Kit.kicker("My notes"))
	_note_editor = TextEdit.new()
	_note_editor.name = "MyNotes"
	_note_editor.custom_minimum_size = Vector2(0, 120)
	_note_editor.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_note_editor.placeholder_text = "Observations, hypotheses, reproduction details…"
	_note_editor.text = WorkspaceSession.notes.get(ticket_id, "")
	_note_editor.text_changed.connect(func(): WorkspaceSession.set_note(ticket_id, _note_editor.text))
	notes_section.add_child(_note_editor)
	notes_section.add_child(Kit.label("Saved automatically · Notes are never scored.", 13, P.MUTED))
	_document.add_child(notes_section)

	var evidence_section := Kit.vbox(8)
	evidence_section.name = "Evidence"
	evidence_section.add_child(Kit.kicker(Kit.tf("Evidence · %d", evidence.size())))
	if evidence.is_empty():
		evidence_section.add_child(Kit.label("Nothing flagged yet. Press 🚩 Flag in the Browser while the problem is on screen.", 14, P.MUTED))
	for index in range(evidence.size() - 1, -1, -1):
		evidence_section.add_child(evidence_card(evidence[index]))
	_document.add_child(evidence_section)

	var activity := Kit.vbox(3)
	activity.add_child(Kit.kicker(Kit.tf("Activity log · %d", actions.size())))
	for action in actions.slice(maxi(0, actions.size() - 30)):
		var line := "%s  %s%s" % [Kit.time_text(float(action["timestamp"])), str(action["type"]).replace("_", " ").to_lower(),
			" · %s" % action["target"] if action.has("target") else ""]
		activity.add_child(Kit.label(line, 13, P.MUTED))
	_document.add_child(activity)


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
	actions.add_child(Kit.link("Open in Browser", func():
		DesktopSession.open_app("browser")
		DesktopSession.navigate(Addresses.parse(url))))
	actions.add_child(Kit.link("Unpin", WorkspaceSession.unpin_reference.bind(ticket_id, attachment["id"])))
	body.add_child(actions)
	return card


static func evidence_card(item: Dictionary) -> Control:
	var card := Kit.panel(P.SURFACE, P.BORDER_STRONG, 8, 0)
	var column := Kit.vbox(0)
	card.add_child(column)
	var thumb := Kit.panel(P.SHOP_BG, Color.TRANSPARENT, 8, 14)
	var thumb_row := Kit.hbox(10)
	var swatch := ColorRect.new()
	swatch.color = P.SHOP_CORAL
	swatch.custom_minimum_size = Vector2(52, 52)
	thumb_row.add_child(swatch)
	var heading: String = str(item["snapshot"].get("heading", "Shoply page"))
	var thumb_text := Kit.vbox(0)
	thumb_text.add_child(Kit.label("SHOPLY", 11, P.SHOP_MUTED, false))
	var thumb_title := Kit.heading(heading, 18, P.SHOP_INK)
	thumb_title.autowrap_mode = TextServer.AUTOWRAP_OFF
	thumb_text.add_child(thumb_title)
	thumb_row.add_child(thumb_text)
	thumb.add_child(thumb_row)
	column.add_child(thumb)
	var info := Kit.vbox(4)
	var context: Dictionary = item["context"]
	info.add_child(Kit.label("%s · %s · %s" % [context["account"], context["viewport"], Kit.time_text(float(item["capturedAt"]))], 13, P.MUTED))
	info.add_child(Kit.label(Addresses.display(Addresses.shoply_url(context["currentPath"])), 13, P.ACCENT))
	var values := Kit.vbox(2)
	values.name = "CapturedValues"
	for observation in Observations.observations_of(item):
		values.add_child(Kit.label(Observations.describe(observation), 14))
	info.add_child(values)
	for line in item["snapshot"].get("console", []):
		var logged := Kit.label("⚠ %s" % line, 13, P.WARNING)
		logged.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		info.add_child(logged)
	column.add_child(Kit.margin(info, 12, 10, 12, 12))
	return card
