## In-game browser: tabs, address bar, QA bar (viewport, account, Console, Note), and pages for
## shoply.local, docs.northstar.local, intranet search, new tab, and unreachable hosts.
## The Console logs what Shoply's code did on screen; a defect leaves a trace there whose
## terms become leads for the story. Note highlights what can be recorded on the page;
## clicking one saves it to QA Notes, ready to report in Messenger.
extends VBoxContainer

const Kit := preload("res://scripts/ui/kit.gd")
const P := preload("res://scripts/ui/palette.gd")
const Addresses := preload("res://scripts/domain/addresses.gd")
const Mutations := preload("res://scripts/domain/mutations.gd")
const Intranet := preload("res://scripts/domain/intranet.gd")
const GameState := preload("res://scripts/domain/game_state.gd")
const ShoplyView := preload("res://scripts/ui/shoply/shoply_view.gd")
const RecordView := preload("res://scripts/ui/horizon/record_view.gd")
const Observations := preload("res://scripts/domain/observations.gd")

const VIEWPORT_WIDTHS := { "DESKTOP": 0.0, "TABLET": 768.0, "MOBILE": 390.0 }
## Everyday log lines, so a defect's trace has to be read rather than spotted.
const CONSOLE_NOISE := {
	"/shoply": ["info: hero banner bucket=control", "warn: font-display swap for Fraunces"],
	"/shoply/product": ["warn: image srcset fallback for everyday-pack.jpg", "info: reviews widget lazy-loaded"],
	"/shoply/cart": ["warn: cart.v1 API is deprecated (sunset 2027)", "info: recommendations skipped (no history)"],
	"/shoply/checkout": ["warn: autofill disabled for postal code field", "info: payment iframe ready"],
	"/shoply/orders": ["info: order cache refreshed (3 orders)", "warn: tracking service slow (812 ms)"],
	"/shoply/payment": ["warn: 3-D Secure running in sandbox mode", "info: card form mounted"],
}

var view: RefCounted = ShoplyView.new()
var records: RefCounted = RecordView.new()
var _tab_row: HBoxContainer
var _tab_signature := ""
var _address: LineEdit
var _back: Button
var _forward: Button
var _ticket_label: Label
var _viewport_buttons := {}
var _account_box: HBoxContainer
var _note: Button
var _console_button: Button
var _console: PanelContainer
var _console_open := false
var _note_bar: PanelContainer
var _traces: Array = []
var _stage: ScrollContainer
## While noting, every recordable part of the page gets a highlight to click.
var _noting := false
var _markers: Control
var _marked: Array = []
var _page: VBoxContainer
var _signature := ""
var _location_key := ""


func _ready() -> void:
	name = "BrowserApp"
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 0)
	view.navigate = func(path: String): DesktopSession.navigate(Addresses.shoply(path))
	view.record = _record
	view.mutate = _mutate
	view.rerender = _render
	records.rerender = func():
		_signature = ""
		_render()

	var tab_panel := PanelContainer.new()
	tab_panel.add_theme_stylebox_override("panel", Kit.style(Color("#e4e8ee"), Color.TRANSPARENT, 0, 6, 4))
	_tab_row = Kit.hbox(4)
	_tab_row.name = "BrowserTabs"
	tab_panel.add_child(_tab_row)
	add_child(tab_panel)

	var toolbar_panel := Kit.panel(P.SUBTLE, Color.TRANSPARENT, 0, 8)
	var toolbar := Kit.hbox(6)
	toolbar_panel.add_child(toolbar)
	_back = Kit.button("←", DesktopSession.go_back)
	_back.tooltip_text = "Go back"
	_forward = Kit.button("→", DesktopSession.go_forward)
	_forward.tooltip_text = "Go forward"
	var reload := Kit.button("↻", DesktopSession.reload)
	reload.tooltip_text = "Reload page"
	toolbar.add_child(_back)
	toolbar.add_child(_forward)
	toolbar.add_child(reload)
	_address = LineEdit.new()
	_address.name = "Address"
	_address.placeholder_text = "Type an address"
	_address.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_address.select_all_on_focus = true
	_address.text_submitted.connect(func(text): DesktopSession.navigate(Addresses.parse(text)))
	toolbar.add_child(_address)
	add_child(toolbar_panel)

	var qa_panel := Kit.panel(P.ACCENT_SOFT, Color.TRANSPARENT, 0, 6)
	var qa := Kit.hbox(8)
	qa.name = "QaTools"
	qa_panel.add_child(qa)
	_ticket_label = Kit.kicker("")
	qa.add_child(_ticket_label)
	qa.add_child(Kit.spacer())
	for mode in ["DESKTOP", "TABLET", "MOBILE"]:
		var button := Kit.button(mode.capitalize(), DesktopSession.set_viewport.bind(mode), "ChoiceButton")
		_viewport_buttons[mode] = button
		qa.add_child(button)
	_account_box = Kit.hbox(4)
	_account_box.name = "ShoplyAccount"
	for tier in ["BASIC", "GOLD"]:
		_account_box.add_child(Kit.button(tier.capitalize(), _change_account.bind(tier), "ChoiceButton"))
	qa.add_child(_account_box)
	_console_button = Kit.button("Console", toggle_console)
	_console_button.name = "ConsoleButton"
	_console_button.tooltip_text = "Show what the page logged"
	qa.add_child(_console_button)
	_note = Kit.primary("📌 Note", toggle_noting)
	_note.name = "Note"
	qa.add_child(_note)
	add_child(qa_panel)
	# Console and the noting bar dock under the QA bar, next to their buttons and clear of
	# the desktop sticky note.
	_console = Kit.panel(Color("#1f2933"), Color.TRANSPARENT, 0, 10)
	_console.name = "Console"
	_console.visible = false
	add_child(_console)
	_note_bar = Kit.panel(P.WARNING_SOFT, Color("#e6d27a"), 0, 8)
	_note_bar.name = "NoteBar"
	_note_bar.visible = false
	var note_row := Kit.hbox(10)
	var note_text := Kit.label("Click the part of the page that looks wrong. It goes into QA Notes.", 14, P.STICKY_TEXT)
	note_row.add_child(note_text)
	note_row.add_child(Kit.button("Cancel", stop_noting))
	_note_bar.add_child(note_row)
	add_child(_note_bar)

	_page = Kit.vbox(0)
	_stage = Kit.scroll(_page)
	_stage.add_theme_stylebox_override("panel", Kit.style(Color("#e9edf2"), Color.TRANSPARENT, 0))
	_stage.set_anchors_preset(Control.PRESET_FULL_RECT)
	var holder := Control.new()
	holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	holder.add_child(_stage)
	_markers = Control.new()
	_markers.name = "NoteMarkers"
	_markers.set_anchors_preset(Control.PRESET_FULL_RECT)
	_markers.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_markers.clip_contents = true
	holder.add_child(_markers)
	add_child(holder)

	for source in [DesktopSession.changed, ShoplyStore.changed, GameSession.changed]:
		source.connect(_render)
	Settings.language_changed.connect(func():
		_signature = ""
		_render())
	_render()


func _active() -> String:
	return GameSession.active_ticket_id()


func _record(type: String, target: String, payload: Dictionary) -> void:
	if _active() != "":
		WorkspaceSession.record_interaction(_active(), type, target, payload)


func _mutate(target: String, base: Variant) -> Variant:
	var scenario: Variant = GameSession.scenario(_active())
	var mutations: Array = scenario["mutations"] if scenario != null else []
	var context := DesktopSession.qa_context()
	var value: Variant = Mutations.resolve(target, base, context, mutations)
	var mutation: Variant = Mutations.find_active(target, context, mutations)
	if mutation != null and mutation.has("trace") and str(value) != str(base):
		if not _traces.has(mutation["trace"]):
			_traces.append(mutation["trace"])
	return value


func _change_account(tier: String) -> void:
	if tier == ShoplyStore.account:
		return
	var scenario: Variant = GameSession.scenario(_active())
	var reset: bool = scenario != null and scenario.get("accountSwitchPolicy", {}).get("resetProductState", false)
	ShoplyStore.switch_account(tier, reset)
	_record("CHANGE_ACCOUNT", tier, {})


func _render() -> void:
	var location := DesktopSession.location()
	_render_tabs()
	var location_key := "%s|%s" % [DesktopSession.location_key(), Addresses.format(location)]
	if location_key != _location_key:
		_location_key = location_key
		_address.text = Addresses.format(location).uri_decode()
		view.product_added = false
		view.confirmed_order = null
		view.coupon_draft = ""
		_stage.scroll_vertical = 0
		stop_noting()
		if location["kind"] == "record":
			_on_record_opened(location["id"])
		elif location["kind"] == "search" and str(location.get("query", "")) != "":
			_check_search(location["query"])
	_back.disabled = not DesktopSession.can_go_back()
	_forward.disabled = not DesktopSession.can_go_forward()
	var active := _active()
	_ticket_label.text = Kit.tf("QA · %s", active) if active != "" else Kit.t("QA · no active Ticket")
	for mode in _viewport_buttons:
		var pressed: bool = DesktopSession.viewport == mode
		_viewport_buttons[mode].add_theme_stylebox_override("normal", Kit.style(P.ACCENT if pressed else P.SURFACE, P.ACCENT if pressed else P.BORDER, 6, 12, 7))
		_viewport_buttons[mode].add_theme_color_override("font_color", Color.WHITE if pressed else P.TEXT)
	_account_box.visible = GameSession.state["unlockedTools"].has("ACCOUNT_SWITCHER")
	for button in _account_box.get_children():
		var pressed: bool = button.text.to_upper() == ShoplyStore.account
		button.add_theme_stylebox_override("normal", Kit.style(Color("#f2c94c") if pressed else P.SURFACE, P.BORDER, 6, 12, 7))
	_note.disabled = active == "" or not Addresses.is_workspace(location) or GameSession.ticket_status(active) != "TESTING"
	_note.tooltip_text = "Something on this page looks wrong? Note it." if not _note.disabled else "Start a Ticket in QA Notes and open Shoply to take notes"
	if _note.disabled and _noting:
		stop_noting()

	var signature := "%s|%s|%d|%s|%s|%s|%s" % [location_key, DesktopSession.viewport, DesktopSession.reload_key,
		JSON.stringify([ShoplyStore.cart, ShoplyStore.coupon, ShoplyStore.account, ShoplyStore.orders]), active,
		str(view.product_added), str(view.confirmed_order != null)]
	if signature == _signature:
		return
	_signature = signature
	_build_page(location)


func _build_page(location: Dictionary) -> void:
	Kit.clear(_page)
	_traces = []
	_fill_page(location)
	_render_console()
	if _noting:
		_refresh_markers.call_deferred()


func _fill_page(location: Dictionary) -> void:
	match location["kind"]:
		"shoply":
			var width: float = VIEWPORT_WIDTHS[DesktopSession.viewport]
			var row := Kit.hbox(0)
			row.size_flags_vertical = Control.SIZE_EXPAND_FILL
			var surface := Kit.panel(P.SHOP_BG, P.SHOP_LINE, 0, 0)
			surface.name = "ProductViewport"
			# Shoply is an English-language client site in every game language.
			surface.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
			surface.size_flags_vertical = Control.SIZE_EXPAND_FILL
			var content := Kit.vbox(0)
			surface.add_child(content)
			if width > 0.0:
				surface.custom_minimum_size = Vector2(width, 0)
				row.add_child(Kit.spacer())
				row.add_child(surface)
				row.add_child(Kit.spacer())
			else:
				surface.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				row.add_child(surface)
			view.narrow = width > 0.0 and width < 760.0
			view.build(content, location["path"])
			_page.add_child(row)
		"horizon":
			records.build(_page, location["path"])
		"docs":
			_page.add_child(_docs(location["slug"]))
		"search":
			_page.add_child(_search_page(location.get("query", "")))
		"record":
			_page.add_child(_record_page(location["id"]))
		"unreachable":
			var column := Kit.vbox(10)
			var host: String = Addresses.display(location["address"]).split("/")[0]
			column.add_child(Kit.heading("This site can't be reached", 26))
			column.add_child(Kit.label(Kit.tf("Check if there is a typo in %s.", host), 16))
			column.add_child(Kit.label("DNS_PROBE_FINISHED_NXDOMAIN", 13, P.MUTED))
			_page.add_child(Kit.margin(column, 48, 48, 48, 48))
		_:
			_page.add_child(_new_tab())


func _docs(slug: String) -> Control:
	var column := Kit.vbox(12)
	column.add_child(Kit.kicker("Northstar · Intranet", P.MUTED))
	var docs: Array = []
	for id in GameSession.catalog.ticket_ids():
		if GameSession.catalog.is_ticket_unlocked(GameSession.state, id):
			docs.append_array(GameSession.catalog.get_ticket(id).get("attachments", []))
	for doc in docs:
		if Addresses.slug(doc["name"]) == slug:
			column.add_child(Kit.heading(doc["name"], 28))
			column.add_child(Kit.label(doc.get("reference", ""), 14, P.MUTED))
			for line in doc.get("content", ["No content published yet."]):
				column.add_child(Kit.label("•  %s" % Kit.t(line), 17))
			return Kit.margin(column, 56, 44, 56, 44)
	column.add_child(Kit.heading("Document not found" if slug != "" else "Documents", 28))
	for doc in docs:
		column.add_child(Kit.link(doc["name"], DesktopSession.open_url.bind(Addresses.doc_url(doc["name"]))))
	return Kit.margin(column, 56, 44, 56, 44)


func _search_box(initial: String) -> Control:
	var row := Kit.hbox(8)
	var input := LineEdit.new()
	input.name = "IntranetSearch"
	input.placeholder_text = "Search the intranet"
	input.text = initial
	input.custom_minimum_size = Vector2(0, 40)
	input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input.text_submitted.connect(func(text): DesktopSession.navigate(Addresses.search(text)))
	row.add_child(input)
	row.add_child(Kit.primary("Search", func(): DesktopSession.navigate(Addresses.search(input.text))))
	return row


func _search_page(query: String) -> Control:
	var column := Kit.vbox(14)
	column.add_child(Kit.kicker("NS Search · Intranet"))
	column.add_child(Kit.heading("Search the intranet", 28))
	column.add_child(_search_box(query))
	var help := Kit.label("Search for names, times, file names, or codes you have seen in Messenger, QA Notes, or the shop.", 15, P.MUTED)
	if query == "":
		column.add_child(help)
		return Kit.margin(column, 56, 44, 56, 44)
	var results: Array = GameSession.intranet.search(query, GameSession.state)
	if results.is_empty():
		column.add_child(Kit.heading("No results found.", 22))
		column.add_child(help)
		return Kit.margin(column, 56, 44, 56, 44)
	column.add_child(Kit.label(Kit.tf("%d results", results.size()), 14, P.MUTED))
	for document in results:
		var item := Kit.vbox(2)
		item.name = "Result%s" % document["id"]
		var found := GameState.has_found(GameSession.state, document["id"])
		item.add_child(Kit.link(("✓ " if found else "") + Kit.t(document["title"]),
			DesktopSession.navigate.bind({ "kind": "record", "id": document["id"] })))
		item.add_child(Kit.label(Kit.t(document["source"]), 13, P.SUCCESS))
		item.add_child(Kit.label(Kit.t(document["lines"][0]), 14, P.MUTED))
		column.add_child(item)
	return Kit.margin(column, 56, 44, 56, 44)


func _record_page(id: String) -> Control:
	var column := Kit.vbox(12)
	column.add_child(Kit.kicker("NS Search · Intranet", P.MUTED))
	var document: Variant = GameSession.intranet.get_document(id)
	if document == null or not Intranet.is_available(document, GameSession.state):
		column.add_child(Kit.heading("Document not found", 28))
		column.add_child(Kit.link("← Search", DesktopSession.navigate.bind(Addresses.search(""))))
		return Kit.margin(column, 56, 44, 56, 44)
	column.add_child(Kit.label(Kit.t(document["source"]), 14, P.SUCCESS))
	column.add_child(Kit.heading(Kit.t(document["title"]), 28))
	for line in document["lines"]:
		column.add_child(Kit.label("•  %s" % Kit.t(line), 17))
	column.add_child(Kit.link("← Search", DesktopSession.navigate.bind(Addresses.search(""))))
	return Kit.margin(column, 56, 44, 56, 44)


## Opening a story record reveals its clue and moves the story on.
func _on_record_opened(id: String) -> void:
	var first_time := GameSession.open_document(id)
	if not first_time:
		return
	for scenario in GameSession.catalog.scenarios:
		var story: Variant = scenario.get("story", null)
		if story != null and story.get("discovery", {}).get("documentId", "") == id:
			Sfx.play("discover")
			if GameSession.ticket_status(scenario["ticket"]["id"]) == "RESOLVED":
				DesktopSession.push_toast(Kit.t("Record found"), Kit.tf("New clue in the Case File: %s", Kit.t(story["clue"]["title"])), "messenger")
			else:
				DesktopSession.push_toast(Kit.t("Record found"), Kit.tf("Saved to the Case File. Report the defect in %s to connect it.", scenario["ticket"]["id"]), "notes")
			return
	Sfx.play("click")


func _new_tab() -> Control:
	var column := Kit.vbox(10)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(Kit.kicker("NS Browser"))
	column.add_child(Kit.heading("Where to?", 34))
	column.add_child(Kit.label("Type an address in the bar above. Work sites end in .local.", 16, P.MUTED))
	column.add_child(Kit.kicker("NS Search · Intranet"))
	column.add_child(_search_box(""))
	var seen := {}
	var recent: Array = []
	for location in DesktopSession.visited():
		var address := Addresses.format(location)
		if address != "" and not seen.has(address):
			seen[address] = true
			recent.append(address)
	if not recent.is_empty():
		column.add_child(Kit.kicker("Recently visited", P.MUTED))
		for address in recent.slice(maxi(0, recent.size() - 5)):
			column.add_child(Kit.link(Addresses.display(address), DesktopSession.open_url.bind(address)))
	return Kit.margin(column, 56, 56, 56, 56)


## A search that misses the record the team is waiting for counts toward their help.
func _check_search(query: String) -> void:
	var pending: Variant = DesktopSession.messenger_log()["pendingDiscovery"]
	if pending == null:
		return
	var found: Array = GameSession.intranet.search(query, GameSession.state).map(func(document): return document["id"])
	if not found.has(pending["documentId"]):
		GameSession.note_search_miss(pending["documentId"])


# --- Tabs ----------------------------------------------------------------------

func _render_tabs() -> void:
	var titles: Array = []
	for index in DesktopSession.tabs.size():
		titles.append(tab_title(DesktopSession.tab_location(index)))
	var signature := "%s|%d|%s" % [str(titles), DesktopSession.active_tab, Settings.language]
	if signature == _tab_signature:
		return
	_tab_signature = signature
	Kit.clear(_tab_row)
	for index in titles.size():
		var active: bool = index == DesktopSession.active_tab
		var tab := PanelContainer.new()
		tab.add_theme_stylebox_override("panel", Kit.style(P.SURFACE if active else Color.TRANSPARENT, P.BORDER if active else Color.TRANSPARENT, 6, 6, 0))
		tab.name = "Tab%d" % index
		var row := Kit.hbox(2)
		tab.add_child(row)
		var title := Kit.button(titles[index], DesktopSession.switch_tab.bind(index), "FlatLink")
		title.name = "TabTitle"
		title.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		title.add_theme_color_override("font_color", P.TEXT if active else P.MUTED)
		title.tooltip_text = Addresses.display(Addresses.format(DesktopSession.tab_location(index)))
		row.add_child(title)
		var close := Kit.button("×", DesktopSession.close_tab.bind(index), "FlatLink")
		close.name = "TabClose"
		close.tooltip_text = "Close tab"
		close.add_theme_color_override("font_color", P.MUTED)
		row.add_child(close)
		_tab_row.add_child(tab)
	var add := Kit.button("+", DesktopSession.open_tab, "FlatLink")
	add.name = "NewTab"
	add.tooltip_text = "New tab"
	_tab_row.add_child(add)


## A short title for a tab, like a page title.
static func tab_title(location: Dictionary) -> String:
	var title: String
	match location.get("kind", "newtab"):
		"shoply":
			var path := str(location["path"]).trim_prefix("/shoply")
			title = "Shoply %s" % (path if path != "" else "/")
		"horizon":
			var view_path := str(location["path"]).trim_prefix("/horizon")
			title = "ONE HORIZON %s" % (view_path if view_path != "" else "/")
		"docs":
			title = Kit.t("Intranet docs")
		"search":
			var query: String = location.get("query", "")
			title = Kit.tf("Search: %s", query) if query != "" else Kit.t("NS Search")
		"record":
			var document: Variant = GameSession.intranet.get_document(location["id"])
			title = Kit.t(document["title"]) if document != null else Kit.t("NS Search")
		"unreachable":
			title = Addresses.display(location["address"]).split("/")[0]
		_:
			title = Kit.t("New tab")
	return title if title.length() <= 22 else title.substr(0, 21) + "…"


# --- Console -------------------------------------------------------------------

func toggle_console() -> void:
	_console_open = not _console_open
	_render_console(false)


func _console_lines(location: Dictionary) -> Array:
	if location["kind"] == "horizon":
		var horizon_lines: Array = [{ "level": "info", "text": "GET %s 200" % location["path"] }]
		for text in records.console_lines(location["path"]):
			horizon_lines.append(_log_line(text))
		return horizon_lines
	if location["kind"] != "shoply":
		return []
	var lines: Array = [
		{ "level": "info", "text": "GET %s 200" % location["path"] },
		{ "level": "info", "text": "analytics: page_view queued" },
	]
	var noise: Array = []
	var best := ""
	for prefix in CONSOLE_NOISE:
		if str(location["path"]).begins_with(prefix) and prefix.length() > best.length():
			best = prefix
	if best != "":
		noise = CONSOLE_NOISE[best]
	for text in noise.slice(0, 1):
		lines.append(_log_line(text))
	for trace in _traces:
		lines.append({ "level": "warn", "text": "warn: %s" % trace["text"] })
	for text in noise.slice(1):
		lines.append(_log_line(text))
	lines.append({ "level": "info", "text": "render %s" % (view.heading if view.heading != "" else "page") })
	return lines


static func _log_line(text: String) -> Dictionary:
	return { "level": "warn" if text.begins_with("warn") else "info", "text": text }


## While a page is being built, leads are noted after the build so state does not
## change in the middle of a render.
func _render_console(defer: bool = true) -> void:
	var warnings := _traces.size()
	_console_button.text = Kit.t("Console")
	_console.visible = _console_open
	Kit.clear(_console)
	if not _console_open:
		return
	var body := Kit.vbox(4)
	_console.add_child(body)
	var lines := _console_lines(DesktopSession.location())
	if lines.is_empty():
		body.add_child(Kit.label("Console is empty on this page.", 13, Color("#9aa5b1"), false))
	for line in lines:
		var warn: bool = line["level"] == "warn"
		var text := Kit.label("%s  %s" % ["⚠" if warn else "›", line["text"]], 13, Color("#f7c948") if warn else Color("#cbd2d9"), false)
		text.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		body.add_child(text)
	if warnings > 0 and defer:
		_note_leads.call_deferred(_traces.duplicate())
	elif warnings > 0:
		_note_leads(_traces.duplicate())


## Terms in a trace the player has seen are remembered quietly: they open their records
## early and let the team suggest a search when the player is stuck. Reading and typing
## them is the player's job.
func _note_leads(traces: Array) -> void:
	var terms: Array = []
	for trace in traces:
		terms.append_array(trace["terms"])
	GameSession.note_leads(terms, _active())


# --- Note ----------------------------------------------------------------------

func toggle_noting() -> void:
	if _noting:
		stop_noting()
		return
	if _note.disabled:
		return
	_noting = true
	_note_bar.visible = true
	_note.text = Kit.t("📌 Noting…")
	_refresh_markers()


func stop_noting() -> void:
	if _markers == null:
		return
	_noting = false
	_note_bar.visible = false
	_note.text = Kit.t("📌 Note")
	_marked = []
	Kit.clear(_markers)


func _unhandled_input(event: InputEvent) -> void:
	if _noting and event.is_action_pressed("ui_cancel"):
		stop_noting()
		get_viewport().set_input_as_handled()


## One highlight per recordable part of the page. Parents come first, so a smaller part
## inside a card sits on top of the card's highlight.
func _refresh_markers() -> void:
	_marked = []
	Kit.clear(_markers)
	if not _noting:
		return
	var nodes: Array = []
	_collect_nodes(_page, nodes)
	var normal := Kit.style(Color(0.043, 0.341, 0.69, 0.06), P.ACCENT, 4, 0, 0, 2)
	var hover := Kit.style(Color(0.949, 0.788, 0.298, 0.35), Color("#d4a106"), 4, 0, 0, 3)
	for node in nodes:
		var marker := Button.new()
		marker.name = "Mark%s" % str(node.get_meta("evidence_target")).replace(".", "_")
		marker.flat = false
		marker.focus_mode = Control.FOCUS_NONE
		marker.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		for state in ["normal", "focus", "disabled"]:
			marker.add_theme_stylebox_override(state, normal)
		for state in ["hover", "pressed", "hover_pressed"]:
			marker.add_theme_stylebox_override(state, hover)
		marker.tooltip_text = Observations.describe(_observation_of(node))
		marker.pressed.connect(note.bind(node))
		_markers.add_child(marker)
		_marked.append([node, marker])
	_place_markers()


func _collect_nodes(node: Node, nodes: Array) -> void:
	if node.has_meta("evidence_target") and node is Control and (node as Control).is_visible_in_tree():
		nodes.append(node)
	for child in node.get_children():
		_collect_nodes(child, nodes)


func _process(_delta: float) -> void:
	if _noting:
		_place_markers()


func _place_markers() -> void:
	for pair in _marked:
		var node: Control = pair[0]
		var marker: Button = pair[1]
		if not is_instance_valid(node) or not node.is_inside_tree():
			continue
		var rect := node.get_global_rect().grow(4)
		marker.position = rect.position - _markers.get_global_rect().position
		marker.size = rect.size


static func _observation_of(node: Node) -> Dictionary:
	var value: String = node.get_meta("evidence_value", "")
	if value == "" and (node is Label or node is Button):
		value = node.text
	var label: String = node.get_meta("evidence_label", "")
	return { "target": node.get_meta("evidence_target"), "label": label if label != "" else node.get_meta("evidence_target"), "value": value }


## Records one part of the page in QA Notes, with the screen it was on.
func note(node: Node) -> Dictionary:
	var focus := _observation_of(node)
	stop_noting()
	var item := capture(focus)
	if item.is_empty():
		return {}
	DesktopSession.push_toast(Kit.t("Noted in QA Notes"), Observations.describe(focus), "notes")
	return item


## Notes the part of the page with this evidence target (used by tests and tours).
func note_target(target: String) -> Dictionary:
	var nodes: Array = []
	_collect_nodes(_page, nodes)
	for node in nodes:
		if node.get_meta("evidence_target") == target:
			return note(node)
	return {}


## Saves the visible Shoply screen, its values, and its console to QA Notes. `focus` is
## the part the player clicked.
func capture(focus: Dictionary = {}) -> Dictionary:
	var active := _active()
	var location := DesktopSession.location()
	if active == "" or not Addresses.is_workspace(location):
		return {}
	var controls: Array = []
	_collect(_page, controls)
	var context := DesktopSession.qa_context()
	var heading: String = records.heading if location["kind"] == "horizon" else view.heading
	if heading == "":
		heading = "Shoply page"
	var item := {
		"id": WorkspaceSession.new_id("EVIDENCE"),
		"ticketId": active,
		"type": "SCREENSHOT",
		"preview": "Shoply · %s · %s" % [heading, DesktopSession.viewport],
		"capturedAt": int(Time.get_unix_time_from_system() * 1000),
		"context": context["test"],
		"snapshot": {
			"product": location["kind"],
			"heading": heading,
			"visibleTargets": controls.map(func(control): return control["target"]),
			"controls": controls,
			"productState": context["product"],
			"console": _console_lines(location).filter(func(line): return line["level"] == "warn").map(func(line): return line["text"]),
		},
	}
	if not focus.is_empty():
		item["focus"] = focus
	WorkspaceSession.add_evidence(item)
	WorkspaceSession.record_interaction(active, "CAPTURE_EVIDENCE", location["path"], { "evidenceId": item["id"] })
	Sfx.play("capture")
	if not _traces.is_empty():
		_note_leads(_traces.duplicate())
	return item


func _collect(node: Node, controls: Array) -> void:
	if node.has_meta("evidence_target"):
		var value: String = node.get_meta("evidence_value", "")
		if value == "" and (node is Label or node is Button):
			value = node.text
		controls.append({ "target": node.get_meta("evidence_target"), "label": node.get_meta("evidence_label", ""), "value": value })
	for child in node.get_children():
		_collect(child, controls)
