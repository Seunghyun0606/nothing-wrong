## The QA workstation desktop: icons, app windows, taskbar, and notifications.
## The team's messages are the guide; there is no separate tutorial.
## Between Tickets the clock runs forward on screen ("2 hours later"); at the end of a
## day a card offers to clock out.
extends Control

signal signed_out
## The player clocked out: { left, next } story times for the day screen.
signal clocked_out(day: Dictionary)

const Kit := preload("res://scripts/ui/kit.gd")
const P := preload("res://scripts/ui/palette.gd")
const OsWindow := preload("res://scripts/ui/os_window.gd")
const MessengerApp := preload("res://scripts/ui/apps/messenger_app.gd")
const StoryClock := preload("res://scripts/domain/story_clock.gd")
const BrowserApp := preload("res://scripts/ui/apps/browser_app.gd")
const NotesApp := preload("res://scripts/ui/apps/notes_app.gd")

const ICONS := { "messenger": "💬", "browser": "🌐", "notes": "📝" }
const TASKBAR_HEIGHT := 52.0

var windows_layer: Control
var windows := {}
var _icon_badge: Label
var _taskbar_buttons := {}
var _toast_box: VBoxContainer
## Notification cards by id, so a new one can slide in without rebuilding the rest.
var _toast_cards := {}
var _toast_tween: Tween
var _sound_button: Button
var _clock: Label
var _deadline: Label
var _start_menu: PopupMenu
## "2 hours later": shown while the clock runs forward to the next Ticket.
var _wait_caption: PanelContainer
var _wait_label: Label


func _ready() -> void:
	# Northstar's wallpaper: its faint star is the only mark on the desk.
	var desk := Kit.backdrop("wallpaper", P.DESK)
	desk.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(desk)

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
	_add_window("messenger", Rect2(132, 28, 780, 680), MessengerApp.new())
	_add_window("browser", Rect2(160, 10, 1140, 740), BrowserApp.new())
	_add_window("notes", Rect2(300, 24, 860, 690), NotesApp.new())

	_toast_box = Kit.vbox(8)
	_toast_box.name = "Toasts"
	_toast_box.custom_minimum_size = Vector2(360, 0)
	# Wrapped text can leave the stack taller than its cards; keep them at the bottom.
	_toast_box.alignment = BoxContainer.ALIGNMENT_END
	add_child(_toast_box)

	_wait_caption = Kit.panel(Color(0.06, 0.09, 0.13, 0.82), Color.TRANSPARENT, 22, 0)
	_wait_caption.name = "TimePasses"
	_wait_caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_wait_label = Kit.heading("", 22, Color.WHITE)
	_wait_label.name = "TimePassesText"
	_wait_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	_wait_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_wait_caption.add_child(Kit.margin(_wait_label, 28, 14, 28, 14))
	_wait_caption.visible = false
	add_child(_wait_caption)

	_build_taskbar()

	DesktopSession.changed.connect(_sync)
	DesktopSession.gate_changed.connect(_on_gate_changed)
	DesktopSession.toasts_changed.connect(_render_toasts)
	GameSession.changed.connect(_sync)
	resized.connect(_layout_overlays)
	DesktopSession.set_delivery_enabled(true)
	Sfx.start_ambience()
	_sync()
	_render_toasts()
	_on_gate_changed()
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

	var start := Kit.primary("NS", _open_start_menu)
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
			# At the end of the day, signing out is clocking out.
			if DesktopSession.gate.get("step", "") == "clock_out":
				_clock_out()
			else:
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
	var arrange := Kit.button("▦  %s" % Kit.t("Arrange"), DesktopSession.arrange_for_testing, "ChoiceButton")
	arrange.name = "ArrangeWindows"
	arrange.tooltip_text = "Browser on the left, QA Notes on the right"
	arrange.custom_minimum_size = Vector2(0, 38)
	row.add_child(arrange)

	row.add_child(Kit.spacer())
	_deadline = Kit.label("", 13, P.MUTED, false)
	_deadline.name = "Deadline"
	row.add_child(_deadline)
	_sound_button = Kit.button("", _toggle_sound, "FlatLink")
	_sound_button.name = "SoundToggle"
	_sound_button.tooltip_text = "Sound"
	_sound_button.add_theme_color_override("font_color", P.TEXT)
	_sound_button.text = "🔊" if Settings.sound else "🔇"
	row.add_child(_sound_button)
	_clock = Kit.label("", 14, P.TEXT, false)
	_clock.name = "Clock"
	_clock.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	row.add_child(_clock)


func _toggle_sound() -> void:
	Settings.set_sound(not Settings.sound)
	_sound_button.text = "🔊" if Settings.sound else "🔇"
	if Settings.sound:
		Sfx.start_ambience()


func _open_start_menu() -> void:
	_start_menu.reset_size()
	var at := Vector2i(int(global_position.x) + 10, int(global_position.y + size.y - TASKBAR_HEIGHT) - _start_menu.size.y - 6)
	_start_menu.popup(Rect2i(at, _start_menu.size))


## The story's clock: each Ticket happens at a set time ("Thu 15:30"), and each chapter
## counts down to its deadline (`chapter.deadline`). The countdown sets the mood only.
func _tick() -> void:
	# The clock moves on with the chat, and runs forward while the next Ticket waits.
	var log := DesktopSession.messenger_log()
	var now := DesktopSession.story_now(log)
	if now < 0:
		_clock.text = ""
		_deadline.text = ""
		return
	_clock.text = "%s %s" % [Kit.t(StoryClock.day_of(now)), StoryClock.hhmm(now)]
	# The deadline is the chapter of the newest Ticket the team has assigned.
	var arrived: Array = log["arrived"]
	var scenario: Variant = GameSession.scenario(arrived[-1]) if not arrived.is_empty() else null
	var story: Dictionary = scenario.get("story", {}) if scenario != null else {}
	var chapter: Variant = GameSession.catalog.get_chapter(str(story.get("chapterId", "")))
	var deadline: Dictionary = chapter.get("deadline", {}) if chapter != null else {}
	var at := StoryClock.parse(str(deadline.get("at", "")))
	# A closed chapter has no deadline left.
	if at < 0 or GameSession.state["story"]["deductions"].get(chapter["finaleDeductionId"], {}).get("solved", false):
		_deadline.text = ""
		return
	var when := "%s %s" % [Kit.t(StoryClock.day_of(at)), StoryClock.hhmm(at)]
	# Deadlines are absolute; once the chat runs past one, the chapter ends late.
	if now >= at:
		_deadline.text = Kit.tf("%s · %s · past due", [Kit.t(deadline["label"]), when])
		_deadline.add_theme_color_override("font_color", P.DANGER)
		return
	var hours := StoryClock.hours_until(now, at)
	_deadline.text = Kit.tf("%s · %s · %dh left", [Kit.t(deadline["label"]), when, hours])
	_deadline.add_theme_color_override("font_color", P.DANGER if hours <= 3 else (P.WARNING if hours <= 24 else P.MUTED))


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
	if DesktopSession.gate.get("step", "") == "notify":
		unread += 1
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
	windows["notes"].set_subtitle(Kit.tf("%s in testing", active) if active != "" else "")
	_tick()


## While time passes, the caption says how much; the clock in the taskbar runs with it.
func _on_gate_changed() -> void:
	var gate: Dictionary = DesktopSession.gate
	var minutes := int(gate.get("run_to", 0)) - int(gate.get("run_from", 0))
	var waiting: bool = gate.get("running", false)
	if waiting:
		var hours := int(round(minutes / 60.0))
		_wait_label.text = Kit.tf("%d minutes later", minutes) if minutes < 60 else (Kit.t("1 hour later") if hours == 1 else Kit.tf("%d hours later", hours))
	var changed := waiting != _wait_caption.visible
	if changed:
		_wait_caption.visible = true
		_wait_caption.modulate.a = 0.0 if waiting else 1.0
		var fade := create_tween()
		fade.tween_property(_wait_caption, "modulate:a", 1.0 if waiting else 0.0, 0.35)
		if not waiting:
			fade.tween_callback(func(): _wait_caption.visible = false)
		_layout_overlays()
	# While the clock runs, only the clock moves.
	if waiting and not changed and DesktopSession.clock_override >= 0:
		var now: int = DesktopSession.clock_override
		_clock.text = "%s %s" % [Kit.t(StoryClock.day_of(now)), StoryClock.hhmm(now)]
		return
	_sync()


func _clock_out() -> void:
	clocked_out.emit(DesktopSession.clock_out())


func _layout_overlays() -> void:
	_wait_caption.reset_size()
	_wait_caption.position = Vector2((size.x - _wait_caption.size.x) / 2.0, (size.y - TASKBAR_HEIGHT) * 0.38)
	if _toast_tween != null and _toast_tween.is_running():
		return
	_toast_box.reset_size()
	_toast_box.position = _toast_target()


## Notifications sit in the bottom-right corner, just above the taskbar.
func _toast_target() -> Vector2:
	return Vector2(size.x - 376, size.y - TASKBAR_HEIGHT - 16 - _toast_box.size.y)


func _render_toasts() -> void:
	var ids: Array = DesktopSession.toasts.map(func(toast): return toast["id"])
	for id in _toast_cards.keys():
		if not ids.has(id):
			var gone: Control = _toast_cards[id]
			_toast_cards.erase(id)
			_toast_box.remove_child(gone)
			gone.queue_free()
	var fresh: Array = []
	for toast in DesktopSession.toasts:
		if not _toast_cards.has(toast["id"]):
			var card := _toast_card(toast)
			_toast_box.add_child(card)
			_toast_cards[toast["id"]] = card
			fresh.append(card)
	_toast_box.reset_size()
	if fresh.is_empty():
		_layout_overlays.call_deferred()
	else:
		_slide_in.call_deferred(fresh)


func _toast_card(toast: Dictionary) -> Control:
	var card := Kit.panel(P.SURFACE, P.BORDER_STRONG, 8, 12)
	card.name = "Toast%d" % toast["id"]
	var row := Kit.hbox(8)
	card.add_child(row)
	var text_column := Kit.vbox(2)
	text_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_column.add_child(Kit.heading(toast["title"], 15))
	var body := Kit.label(toast["text"], 14, P.MUTED)
	body.max_lines_visible = 2
	text_column.add_child(body)
	row.add_child(text_column)
	var id: int = toast["id"]
	var app: String = toast.get("app", "")
	var chat: String = toast.get("chat", "")
	# The end of the day: the card is the way out.
	if toast.get("kind", "") == "clock_out":
		var leave := Kit.primary("Clock out", _clock_out)
		leave.name = "ClockOut"
		leave.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(leave)
		return card
	var open := Kit.link("Open", func():
		if toast.has("gate"):
			DesktopSession.open_gate()
		elif chat != "":
			DesktopSession.show_chat(chat)
		elif app != "":
			DesktopSession.open_app(app)
		DesktopSession.dismiss_toast(id))
	open.name = "OpenToast"
	row.add_child(open)
	# A waiting Ticket's notification stays until it is opened.
	if not toast.get("sticky", false):
		row.add_child(Kit.link("×", func(): DesktopSession.dismiss_toast(id)))
	return card


## New notifications rise from behind the taskbar and fade in, pushing older ones up.
func _slide_in(fresh: Array) -> void:
	_toast_box.reset_size()
	var target := _toast_target()
	var rise := 0.0
	for card in fresh:
		if is_instance_valid(card):
			rise += maxf(card.size.y, card.get_combined_minimum_size().y) + 8.0
			card.modulate.a = 0.0
	if _toast_tween != null:
		_toast_tween.kill()
	_toast_box.position = target + Vector2(0, rise)
	_toast_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_toast_tween.tween_property(_toast_box, "position", target, 0.35)
	for card in fresh:
		if is_instance_valid(card):
			_toast_tween.tween_property(card, "modulate:a", 1.0, 0.3)
	_toast_tween.chain().tween_callback(_layout_overlays)
