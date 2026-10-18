## The QA workstation desktop: icons, app windows, taskbar, notifications, and guide.
extends Control

signal signed_out

const Kit := preload("res://scripts/ui/kit.gd")
const P := preload("res://scripts/ui/palette.gd")
const OsWindow := preload("res://scripts/ui/os_window.gd")
const Guide := preload("res://scripts/domain/guide.gd")
const GameState := preload("res://scripts/domain/game_state.gd")
const MessengerApp := preload("res://scripts/ui/apps/messenger_app.gd")
const TrackerApp := preload("res://scripts/ui/apps/tracker_app.gd")
const BrowserApp := preload("res://scripts/ui/apps/browser_app.gd")
const NotesApp := preload("res://scripts/ui/apps/notes_app.gd")

const ICONS := { "messenger": "💬", "tracker": "📋", "browser": "🌐", "notes": "📝" }
const TASKBAR_HEIGHT := 52.0

var windows_layer: Control
var windows := {}
var _icon_badge: Label
var _taskbar_buttons := {}
var _toast_box: VBoxContainer
var _guide_box: PanelContainer
## Steps the player folded, and folded-by-default hints the player opened.
var _collapsed := {}
var _expanded := {}
var _sound_button: Button
var _clock: Label
var _start_menu: PopupMenu


func _ready() -> void:
	var desk := ColorRect.new()
	desk.color = P.DESK
	desk.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(desk)
	var wordmark := Kit.heading("NOTHING WRONG", 88, Color(1, 1, 1, 0.45))
	wordmark.autowrap_mode = TextServer.AUTOWRAP_OFF
	wordmark.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	wordmark.position = Vector2(-760, -200)
	wordmark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(wordmark)

	var icons := Kit.vbox(10)
	icons.name = "DesktopIcons"
	icons.position = Vector2(16, 16)
	add_child(icons)
	for app in DesktopSession.APPS:
		var icon := Button.new()
		icon.name = "Icon%s" % app.capitalize()
		icon.tooltip_text = DesktopSession.APP_TITLES[app]
		icon.custom_minimum_size = Vector2(100, 88)
		icon.theme_type_variation = "FlatLink"
		icon.add_theme_stylebox_override("hover", Kit.style(Color(1, 1, 1, 0.45), Color(0.043, 0.341, 0.69, 0.35), 6))
		icon.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		icon.pressed.connect(DesktopSession.open_app.bind(app))
		var face := Kit.vbox(2)
		face.set_anchors_preset(Control.PRESET_FULL_RECT)
		face.alignment = BoxContainer.ALIGNMENT_CENTER
		face.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var glyph := Kit.label(ICONS[app], 34, P.TEXT, false)
		glyph.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var caption := Kit.label(DesktopSession.APP_TITLES[app], 14, P.TEXT, false)
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		for part in [glyph, caption]:
			part.mouse_filter = Control.MOUSE_FILTER_IGNORE
			face.add_child(part)
		icon.add_child(face)
		icons.add_child(icon)
		if app == "messenger":
			_icon_badge = _badge()
			_icon_badge.position = Vector2(64, 2)
			icon.add_child(_icon_badge)

	windows_layer = Control.new()
	windows_layer.name = "Windows"
	windows_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	windows_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	windows_layer.offset_bottom = -TASKBAR_HEIGHT
	add_child(windows_layer)
	_add_window("messenger", Rect2(132, 28, 460, 620), MessengerApp.new())
	_add_window("tracker", Rect2(220, 16, 1000, 700), TrackerApp.new())
	_add_window("browser", Rect2(160, 10, 1140, 740), BrowserApp.new())
	_add_window("notes", Rect2(760, 60, 540, 640), NotesApp.new())

	_guide_box = PanelContainer.new()
	_guide_box.name = "GuideNote"
	add_child(_guide_box)

	_toast_box = Kit.vbox(8)
	_toast_box.name = "Toasts"
	_toast_box.custom_minimum_size = Vector2(360, 0)
	add_child(_toast_box)

	_build_taskbar()

	DesktopSession.changed.connect(_sync)
	DesktopSession.toasts_changed.connect(_render_toasts)
	GameSession.changed.connect(_sync)
	ShoplyStore.changed.connect(_render_guide)
	WorkspaceSession.changed.connect(_render_guide)
	resized.connect(_layout_overlays)
	DesktopSession.set_delivery_enabled(true)
	Sfx.start_ambience()
	_sync()
	_render_toasts()
	_layout_overlays.call_deferred()


## Clicking anywhere inside a window brings it to the front.
func _input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed):
		return
	for index in range(windows_layer.get_child_count() - 1, -1, -1):
		var window := windows_layer.get_child(index) as Control
		if window.visible and window.get_global_rect().has_point(event.global_position):
			if DesktopSession.focused_app != window.app:
				DesktopSession.open_app(window.app)
			return


func _exit_tree() -> void:
	DesktopSession.set_delivery_enabled(false)
	Sfx.stop_ambience()


func _badge() -> Label:
	var badge := Kit.label("", 12, P.STICKY_TEXT, false)
	badge.add_theme_stylebox_override("normal", Kit.style(Color("#f2c94c"), Color.TRANSPARENT, 9, 6, 1))
	badge.add_theme_font_override("font", Kit.bold_font())
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return badge


func _add_window(app: String, rect: Rect2, content: Control) -> void:
	var window: Control = OsWindow.new()
	windows_layer.add_child(window)
	window.setup(app, ICONS[app], rect, content)
	windows[app] = window


func _build_taskbar() -> void:
	var bar := PanelContainer.new()
	bar.name = "Taskbar"
	bar.add_theme_stylebox_override("panel", Kit.style(Color(0.953, 0.961, 0.973, 0.97), P.BORDER_STRONG, 0, 10, 6))
	bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bar.offset_top = -TASKBAR_HEIGHT
	add_child(bar)
	var row := Kit.hbox(6)
	bar.add_child(row)

	var start := Kit.primary("NW", _open_start_menu)
	start.custom_minimum_size = Vector2(46, 38)
	row.add_child(start)
	_start_menu = PopupMenu.new()
	for index in DesktopSession.APPS.size():
		var app: String = DesktopSession.APPS[index]
		_start_menu.add_item("%s  %s" % [ICONS[app], Kit.t(DesktopSession.APP_TITLES[app])], index)
	_start_menu.add_separator()
	_start_menu.add_item("⏻  %s" % Kit.t("Sign out"), 99)
	_start_menu.id_pressed.connect(func(id):
		if id == 99:
			signed_out.emit()
		else:
			DesktopSession.open_app(DesktopSession.APPS[id]))
	add_child(_start_menu)

	for app in DesktopSession.APPS:
		var button := Kit.button("%s  %s" % [ICONS[app], Kit.t(DesktopSession.APP_TITLES[app])], _toggle_app.bind(app), "ChoiceButton")
		button.name = "Task%s" % app.capitalize()
		button.toggle_mode = false
		button.custom_minimum_size = Vector2(0, 38)
		row.add_child(button)
		_taskbar_buttons[app] = button

	row.add_child(Kit.spacer())
	row.add_child(Kit.label("Shoply RC3 · Staging", 13, P.MUTED, false))
	_sound_button = Kit.button("", _toggle_sound, "FlatLink")
	_sound_button.name = "SoundToggle"
	_sound_button.tooltip_text = "Sound"
	_sound_button.add_theme_color_override("font_color", P.TEXT)
	_sound_button.text = "🔊" if Settings.sound else "🔇"
	row.add_child(_sound_button)
	_clock = Kit.label("", 14, P.TEXT, false)
	row.add_child(_clock)
	var timer := Timer.new()
	timer.wait_time = 15.0
	timer.autostart = true
	timer.timeout.connect(_tick)
	add_child(timer)
	_tick()


func _toggle_sound() -> void:
	Settings.set_sound(not Settings.sound)
	_sound_button.text = "🔊" if Settings.sound else "🔇"
	if Settings.sound:
		Sfx.start_ambience()


func _open_start_menu() -> void:
	_start_menu.reset_size()
	var at := Vector2i(int(global_position.x) + 10, int(global_position.y + size.y - TASKBAR_HEIGHT) - _start_menu.size.y - 6)
	_start_menu.popup(Rect2i(at, _start_menu.size))


func _tick() -> void:
	var now := Time.get_time_dict_from_system()
	var hour: int = now["hour"]
	_clock.text = Kit.clock_text(hour, now["minute"])


func _toggle_app(app: String) -> void:
	if DesktopSession.is_visible_app(app) and DesktopSession.focused_app == app:
		DesktopSession.minimize_app(app)
	else:
		DesktopSession.open_app(app)


func _sync() -> void:
	if not is_inside_tree():
		return
	var order: Array = DesktopSession.APPS.duplicate()
	order.sort_custom(func(a, b): return DesktopSession.windows[a]["z"] < DesktopSession.windows[b]["z"])
	for app in order:
		windows_layer.move_child(windows[app], -1)
	var unread: int = DesktopSession.messenger_log()["unread"]
	_icon_badge.text = str(unread)
	_icon_badge.visible = unread > 0
	for app in DesktopSession.APPS:
		var button: Button = _taskbar_buttons[app]
		var label: String = "%s  %s" % [ICONS[app], Kit.t(DesktopSession.APP_TITLES[app])]
		if app == "messenger" and unread > 0:
			label += "  (%d)" % unread
		button.text = label
		button.set_pressed_no_signal(false)
		button.add_theme_stylebox_override("normal", Kit.style(P.ACCENT_SOFT if DesktopSession.is_visible_app(app) else P.SURFACE, P.ACCENT if DesktopSession.focused_app == app else P.BORDER, 6, 12, 7))
	var active := GameSession.active_ticket_id()
	windows["tracker"].set_subtitle(Kit.tf("%s in testing", active) if active != "" else "")
	_render_guide()


func _layout_overlays() -> void:
	_toast_box.position = Vector2(size.x - 376, size.y - TASKBAR_HEIGHT - 16 - _toast_box.size.y)
	_guide_box.position = Vector2(16, size.y - TASKBAR_HEIGHT - 16 - _guide_box.size.y)


func _render_toasts() -> void:
	Kit.clear(_toast_box)
	for toast in DesktopSession.toasts:
		var card := Kit.panel(P.SURFACE, P.BORDER_STRONG, 8, 12)
		var row := Kit.hbox(8)
		card.add_child(row)
		var text_column := Kit.vbox(2)
		text_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var title := Kit.heading(toast["title"], 15)
		text_column.add_child(title)
		var body := Kit.label(toast["text"], 14, P.MUTED)
		body.max_lines_visible = 2
		text_column.add_child(body)
		row.add_child(text_column)
		var id: int = toast["id"]
		var app: String = toast.get("app", "")
		var open := Kit.link("Open", func():
			if app != "":
				DesktopSession.open_app(app)
			DesktopSession.dismiss_toast(id))
		row.add_child(open)
		row.add_child(Kit.link("×", func(): DesktopSession.dismiss_toast(id)))
		_toast_box.add_child(card)
	_toast_box.reset_size()
	_layout_overlays.call_deferred()


## Picks the sticky-note step: workstation steps first, then the Scenario guide.
## From T03 on, Scenario hints start folded until the player asks for them.
func guide_step() -> Dictionary:
	var focus := GameSession.focus_ticket_id()
	var scenario: Variant = GameSession.scenario(focus)
	var guide: Variant = scenario.get("guide", null) if scenario != null else null
	var log := DesktopSession.messenger_log()
	var caught_up: bool = log["delivered"] >= log["entries"].size()
	var pending: Variant = log["pendingDeduction"]
	var discovery: Variant = log["pendingDiscovery"]
	var label: String = guide["label"] if guide != null else "Guide"
	var folded: bool = guide != null and guide.get("hintMode", "always") == "on_request"
	var status := GameSession.ticket_status(focus) if focus != "" else ""

	if pending != null and caught_up and pending.get("mode", "") == "board":
		return { "note": "Case notes", "label": "Case File", "title": "Connect the clues.",
			"instruction": "Open the Case File in QA Tracker, pick the clues that prove it, and choose a conclusion.",
			"action": "Open Case File", "run": _open_case_file, "folded": false }
	if pending != null and caught_up:
		return { "note": "Case notes", "label": "Team chat", "title": "The team is waiting for your answer.",
			"instruction": "Open Messenger, read the debrief, and reply with your conclusion.",
			"action": "Open Messenger", "run": func(): DesktopSession.open_app("messenger"), "folded": false }
	if discovery != null and caught_up:
		var owner: Variant = _discovery_owner(discovery["documentId"])
		var owner_folded: bool = owner != null and owner.get("guide", {}).get("hintMode", "always") == "on_request"
		var leads: Array = GameState.leads_for(GameSession.state, owner["ticket"]["id"]) if owner != null else []
		if not leads.is_empty():
			return { "note": "Case notes", "label": "Find the record", "title": "The team needs a record from the intranet.",
				"instruction": Kit.tf("The console gave you a lead: %s. Search the intranet for it.", leads[0]),
				"action": "Search for the lead", "run": DesktopSession.search_intranet.bind(leads[0]), "folded": owner_folded }
		return { "note": "Case notes", "label": "Find the record", "title": "The team needs a record from the intranet.",
			"instruction": discovery["hint"], "action": "Open intranet search",
			"run": func(): DesktopSession.open_url("https://search.nothingwrong.local"), "folded": owner_folded }
	if guide == null:
		return {}
	if log["unread"] > 0:
		return { "note": label, "label": "New message", "title": "You have a new message.",
			"instruction": "Open Messenger to read your briefing.",
			"action": "Open Messenger", "run": func(): DesktopSession.open_app("messenger"), "folded": false }
	if status == "NEW" or status == "ACCEPTED":
		return { "note": label, "label": "Accept the Ticket", "title": Kit.tf("%s is waiting in QA Tracker.", focus),
			"instruction": "Open QA Tracker, read the requirements, and select Start test.",
			"action": "Open QA Tracker", "run": func(): DesktopSession.show_ticket(focus), "folded": folded }
	if status == "TESTING" and guide.has("workspace"):
		var step: Variant = Guide.resolve_step(guide["workspace"], DesktopSession.qa_context())
		if step != null:
			return { "note": label, "label": step["label"], "title": step["title"], "instruction": step["instruction"], "folded": folded }
	return {}


func _discovery_owner(document_id: String) -> Variant:
	for scenario in GameSession.catalog.scenarios:
		if scenario.get("story", {}).get("discovery", {}).get("documentId", "") == document_id:
			return scenario
	return null


func _open_case_file() -> void:
	DesktopSession.tracker_view = "casefile"
	DesktopSession.open_app("tracker")


func _step_key(step: Dictionary) -> String:
	return "%s|%s|%s" % [step["note"], step["label"], step["title"]]


func _render_guide() -> void:
	if not is_inside_tree():
		return
	Kit.clear(_guide_box)
	var step := guide_step()
	_guide_box.visible = not step.is_empty()
	if step.is_empty():
		return
	_guide_box.add_theme_stylebox_override("panel", Kit.style(P.STICKY, Color("#e6d27a"), 4, 14, 12))
	var key := _step_key(step)
	var collapsed: bool = _collapsed.has(key) or (step.get("folded", false) and not _expanded.has(key))
	if collapsed:
		_guide_box.custom_minimum_size = Vector2.ZERO
		var tab_text: String = Kit.t("Need a hint?") if step.get("folded", false) else Kit.t(step["note"])
		_guide_box.add_child(Kit.link("📌 %s" % tab_text, func():
			_collapsed.erase(key)
			_expanded[key] = true
			_render_guide()))
	else:
		_guide_box.custom_minimum_size = Vector2(340, 0)
		var column := Kit.vbox(6)
		_guide_box.add_child(column)
		var header := Kit.hbox(6)
		var tag := Kit.kicker("📌 %s · %s" % [Kit.t(step["note"]), Kit.t(step["label"])], P.STICKY_TEXT)
		tag.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		header.add_child(tag)
		header.add_child(Kit.link("–", func():
			_expanded.erase(key)
			_collapsed[key] = true
			_render_guide()))
		column.add_child(header)
		for line in [Kit.heading(step["title"], 16, P.STICKY_TEXT), Kit.label(step["instruction"], 14, P.STICKY_TEXT)]:
			# A known wrap width keeps the note from measuring itself one word per line.
			line.custom_minimum_size = Vector2(312, 0)
			column.add_child(line)
		if step.has("action"):
			column.add_child(Kit.link("%s →" % Kit.t(step["action"]), step["run"]))
	_guide_box.size = Vector2.ZERO
	_guide_box.reset_size()
	_layout_overlays.call_deferred()
