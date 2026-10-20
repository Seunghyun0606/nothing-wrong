## A movable, resizable app window. Drag anywhere on the title bar; drag a window
## to the left or right screen edge to fill that half, or to the top edge to maximize.
## Resize from any edge or corner.
extends Control

const Kit := preload("res://scripts/ui/kit.gd")
const P := preload("res://scripts/ui/palette.gd")

const MIN_SIZE := Vector2(320, 260)
const HANDLE := 6.0
const SNAP_MARGIN := 6.0
const TITLE_HEIGHT := 40.0

var app := ""
var icon := ""
var default_rect := Rect2()
var body: MarginContainer
## The window rectangle when not maximized, in the parent's coordinates.
var rect := Rect2()

var _background: Panel
var _title_bar: PanelContainer
var _subtitle: Label
var _dragging := false
var _drag_offset := Vector2.ZERO
var _resize_edges := Vector2i.ZERO   # x: -1 left, 1 right; y: -1 top, 1 bottom
var _resize_start_rect := Rect2()
var _resize_start_mouse := Vector2.ZERO


func setup(app_id: String, glyph: String, initial: Rect2, content: Control) -> void:
	app = app_id
	icon = glyph
	default_rect = initial
	rect = initial
	name = "%sWindow" % app_id.capitalize()
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP

	_background = Panel.new()
	_background.set_anchors_preset(Control.PRESET_FULL_RECT)
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_background)

	var column := Kit.vbox(0)
	column.set_anchors_preset(Control.PRESET_FULL_RECT)
	column.offset_left = 1
	column.offset_top = 1
	column.offset_right = -1
	column.offset_bottom = -1
	add_child(column)

	_title_bar = PanelContainer.new()
	_title_bar.custom_minimum_size = Vector2(0, TITLE_HEIGHT)
	_title_bar.mouse_filter = Control.MOUSE_FILTER_STOP
	_title_bar.mouse_default_cursor_shape = Control.CURSOR_MOVE
	_title_bar.gui_input.connect(_on_title_input)
	column.add_child(_title_bar)
	var bar := Kit.hbox(8)
	_title_bar.add_child(Kit.margin(bar, 12, 2, 4, 2))
	bar.add_child(Kit.label(icon, 15, P.TEXT, false))
	var title := Kit.label(DesktopSession.APP_TITLES[app], 15, P.TEXT, false)
	title.add_theme_font_override("font", Kit.bold_font())
	bar.add_child(title)
	_subtitle = Kit.label("", 13, P.ACCENT, false)
	bar.add_child(_subtitle)
	bar.add_child(Kit.spacer())
	for control in [["–", "Minimize", func(): DesktopSession.minimize_app(app)],
			["□", "Maximize", func(): DesktopSession.toggle_maximize(app)],
			["×", "Close", func(): DesktopSession.close_app(app)]]:
		var button := Kit.button(control[0], control[2], "FlatLink")
		button.tooltip_text = control[1]
		button.custom_minimum_size = Vector2(34, 30)
		button.add_theme_color_override("font_color", P.TEXT)
		bar.add_child(button)
	# Everything on the bar except its buttons lets the press reach the bar, so the
	# whole bar drags the window.
	_ignore_mouse_except_buttons(_title_bar)

	body = MarginContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(body)
	body.add_child(content)

	_add_handles()
	DesktopSession.changed.connect(refresh)
	DesktopSession.layout_requested.connect(_on_layout_requested)
	refresh()


func _ignore_mouse_except_buttons(node: Node) -> void:
	for child in node.get_children():
		if child is Control and not (child is BaseButton):
			(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
		_ignore_mouse_except_buttons(child)


func _add_handles() -> void:
	var specs := [
		[Vector2i(-1, 0), Control.CURSOR_HSIZE], [Vector2i(1, 0), Control.CURSOR_HSIZE],
		[Vector2i(0, -1), Control.CURSOR_VSIZE], [Vector2i(0, 1), Control.CURSOR_VSIZE],
		[Vector2i(-1, -1), Control.CURSOR_FDIAGSIZE], [Vector2i(1, 1), Control.CURSOR_FDIAGSIZE],
		[Vector2i(1, -1), Control.CURSOR_BDIAGSIZE], [Vector2i(-1, 1), Control.CURSOR_BDIAGSIZE],
	]
	for spec in specs:
		var edges: Vector2i = spec[0]
		var handle := Control.new()
		handle.name = "Resize%d%d" % [edges.x + 1, edges.y + 1]
		handle.mouse_default_cursor_shape = spec[1]
		handle.mouse_filter = Control.MOUSE_FILTER_STOP
		handle.anchor_left = 1.0 if edges.x == 1 else 0.0
		handle.anchor_right = 0.0 if edges.x == -1 else 1.0
		handle.anchor_top = 1.0 if edges.y == 1 else 0.0
		handle.anchor_bottom = 0.0 if edges.y == -1 else 1.0
		handle.offset_left = -HANDLE if edges.x == 1 else (0.0 if edges.x == -1 else HANDLE * 2)
		handle.offset_right = HANDLE if edges.x == -1 else (0.0 if edges.x == 1 else -HANDLE * 2)
		handle.offset_top = -HANDLE if edges.y == 1 else (0.0 if edges.y == -1 else HANDLE * 2)
		handle.offset_bottom = HANDLE if edges.y == -1 else (0.0 if edges.y == 1 else -HANDLE * 2)
		handle.gui_input.connect(_on_handle_input.bind(edges))
		add_child(handle)


func set_subtitle(text: String) -> void:
	_subtitle.text = text


func _parent_rect() -> Rect2:
	var parent := get_parent() as Control
	return Rect2(Vector2.ZERO, parent.size) if parent and parent.size.x > 0.0 else Rect2(Vector2.ZERO, Vector2(1440, 848))


func refresh() -> void:
	var state: Dictionary = DesktopSession.windows[app]
	visible = state["open"] and not state["minimized"]
	var focused: bool = DesktopSession.focused_app == app
	_title_bar.add_theme_stylebox_override("panel", Kit.style(P.ACCENT_SOFT if focused else P.SUBTLE, Color.TRANSPARENT, 7, 0, 0))
	_background.add_theme_stylebox_override("panel", Kit.style(P.SURFACE, P.ACCENT if focused else P.BORDER_STRONG, 8, 0, 0))
	if state["maximized"]:
		position = Vector2.ZERO
		size = _parent_rect().size
	else:
		_apply(rect)


func _apply(next: Rect2) -> void:
	var bounds := _parent_rect()
	var width := clampf(next.size.x, MIN_SIZE.x, bounds.size.x)
	var height := clampf(next.size.y, MIN_SIZE.y, bounds.size.y)
	var x := clampf(next.position.x, -width + 160.0, bounds.size.x - 160.0)
	var y := clampf(next.position.y, 0.0, maxf(0.0, bounds.size.y - TITLE_HEIGHT))
	rect = Rect2(x, y, width, height)
	position = rect.position
	size = rect.size


func _on_layout_requested(target: String, fraction: Rect2) -> void:
	if target != app:
		return
	var bounds := _parent_rect().size
	_apply(Rect2(fraction.position * bounds, fraction.size * bounds))
	refresh()


func get_parent_control_mouse() -> Vector2:
	var parent := get_parent() as Control
	return parent.get_local_mouse_position() if parent else get_global_mouse_position()


func _on_title_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.double_click:
			DesktopSession.toggle_maximize(app)
			return
		if event.pressed:
			if DesktopSession.focused_app != app:
				DesktopSession.open_app(app)
			if DesktopSession.windows[app]["maximized"]:
				# Dragging a maximized window restores it under the pointer.
				rect.position = get_parent_control_mouse() - Vector2(rect.size.x / 2.0, 16)
				DesktopSession.toggle_maximize(app)
			_dragging = true
			_drag_offset = get_parent_control_mouse() - rect.position
		elif _dragging:
			_dragging = false
			_snap_to_edge()
	elif event is InputEventMouseMotion and _dragging:
		_apply(Rect2(get_parent_control_mouse() - _drag_offset, rect.size))


func _snap_to_edge() -> void:
	var mouse := get_parent_control_mouse()
	var bounds := _parent_rect().size
	if mouse.x <= SNAP_MARGIN:
		DesktopSession.snap_app(app, Rect2(0, 0, 0.5, 1))
	elif mouse.x >= bounds.x - SNAP_MARGIN:
		DesktopSession.snap_app(app, Rect2(0.5, 0, 0.5, 1))
	elif mouse.y <= SNAP_MARGIN:
		DesktopSession.toggle_maximize(app)


func _on_handle_input(event: InputEvent, edges: Vector2i) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if DesktopSession.focused_app != app:
				DesktopSession.open_app(app)
			if DesktopSession.windows[app]["maximized"]:
				return
			_resize_edges = edges
			_resize_start_rect = rect
			_resize_start_mouse = get_parent_control_mouse()
		else:
			_resize_edges = Vector2i.ZERO
	elif event is InputEventMouseMotion and _resize_edges != Vector2i.ZERO:
		resize_by(_resize_edges, get_parent_control_mouse() - _resize_start_mouse, _resize_start_rect)


## Resizes from the given edges by a pointer delta. Also used by tests.
func resize_by(edges: Vector2i, delta: Vector2, start: Rect2 = Rect2()) -> void:
	if start.size == Vector2.ZERO:
		start = rect
	var next := start
	if edges.x == 1:
		next.size.x = maxf(MIN_SIZE.x, start.size.x + delta.x)
	elif edges.x == -1:
		var width := maxf(MIN_SIZE.x, start.size.x - delta.x)
		next.position.x = start.end.x - width
		next.size.x = width
	if edges.y == 1:
		next.size.y = maxf(MIN_SIZE.y, start.size.y + delta.y)
	elif edges.y == -1:
		var height := maxf(MIN_SIZE.y, start.size.y - delta.y)
		next.position.y = start.end.y - height
		next.size.y = height
	_apply(next)
