## Draws the ONE HORIZON QA portal: the list of open views, and any view as a table of
## records or a Source/Target compare. Every cell is evidence (see Kit.evidence), so Note,
## reports, and Review work on these screens exactly as they do on Shoply.
extends RefCounted

const Kit := preload("res://scripts/ui/kit.gd")
const P := preload("res://scripts/ui/palette.gd")
const Addresses := preload("res://scripts/domain/addresses.gd")
const HorizonData := preload("res://scripts/domain/horizon_data.gd")
const GameState := preload("res://scripts/domain/game_state.gd")

const MISSING := "(not in target)"
const SOURCE_BG := Color("#f4f6f9")
const TARGET_BG := Color("#eef4fb")
const PHOTO_PATH := "res://assets/photos/%s.jpg"
const THUMB_HEIGHT := 72.0
const ZOOM_WIDTH := 640.0

## Photos as drawn (cropped, rotated), by their drawing.
static var _photos := {}

var rerender: Callable
## The screen's title, for Evidence and notes.
var heading := ""
## The filter chosen on each view.
var _filters := {}
## The photo shown large above the records: its view, row ("" for the view's own photo),
## side, and caption. It is drawn again on every render, so it follows the device.
var _zoom := {}


func build(page: VBoxContainer, path: String) -> void:
	heading = ""
	var data: RefCounted = GameSession.horizon
	var root := Kit.vbox(14)
	root.name = "RecordView"
	# Horizon's systems are an in-world client portal, in English in every game language.
	root.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	page.add_child(Kit.margin(root, 32, 28, 32, 32))
	root.add_child(Kit.kicker(str(data.portal.get("title", "ONE HORIZON · QA portal")), P.MUTED))
	var id := path.trim_prefix("/horizon").trim_prefix("/")
	if id == "":
		_index(root, data)
		return
	var view: Variant = data.get_view(id)
	if view == null or not data.is_open(view, GameSession.catalog, GameSession.state):
		heading = "View not available"
		root.add_child(Kit.heading(heading, 26))
		root.add_child(Kit.label("This view is not part of your assigned test scope.", 15, P.MUTED))
		return
	heading = view["title"]
	root.add_child(Kit.label(view.get("system", ""), 14, P.ACCENT, false))
	root.add_child(Kit.heading(heading, 26))
	if view.has("note"):
		root.add_child(Kit.label(view["note"], 14, P.MUTED))
	if view.has("photo"):
		root.add_child(_photo(view, view["photo"], view["photo"]["asset"], 160.0, "", ""))
	if view.get("filter", "") != "":
		root.add_child(_filter_row(view))
	if _zoom.get("view", "") == view["id"] and not _zoom_shown(view).is_empty():
		root.add_child(_zoomed(view))
	root.add_child(_grid(view))


func console_lines(path: String) -> Array:
	var view: Variant = GameSession.horizon.get_view(path.trim_prefix("/horizon").trim_prefix("/"))
	return view.get("console", []) if view != null else []


func _index(root: VBoxContainer, data: RefCounted) -> void:
	heading = "QA portal"
	root.add_child(Kit.heading(heading, 26))
	root.add_child(Kit.label(str(data.portal.get("note", "")), 14, P.MUTED))
	var open: Array = data.open_views(GameSession.catalog, GameSession.state)
	if open.is_empty():
		root.add_child(Kit.label("No views are assigned to you yet.", 15, P.MUTED))
	for view in open:
		var row := Kit.hbox(10)
		row.add_child(Kit.link(view["title"], DesktopSession.navigate.bind(Addresses.horizon("/horizon/%s" % view["id"]))))
		row.add_child(Kit.label(view.get("system", ""), 13, P.MUTED, false))
		root.add_child(row)


func _filter_row(view: Dictionary) -> Control:
	var row := Kit.hbox(8)
	var column: String = view["filter"]
	var label := column
	for item in view["columns"]:
		if item["id"] == column:
			label = item["label"]
	row.add_child(Kit.label("%s:" % label, 14, P.MUTED, false))
	var pick := OptionButton.new()
	pick.name = "RecordFilter"
	pick.add_item("All")
	var values := HorizonData.filter_values(view)
	for value in values:
		pick.add_item(value)
	var current: String = _filters.get(view["id"], "")
	pick.select(values.find(current) + 1 if current != "" else 0)
	pick.item_selected.connect(func(index):
		_filters[view["id"]] = "" if index == 0 else values[index - 1]
		rerender.call())
	row.add_child(pick)
	return row


func _grid(view: Dictionary) -> Control:
	var compare: bool = view.get("mode", "table") == "compare"
	var columns: Array = view["columns"]
	# A compare shows each record on two lines, Source above Target, so wide records still
	# fit the Browser.
	# A view with an inspection budget hides some columns until the row is inspected.
	var inspect: Dictionary = view.get("inspect", {})
	var photos := HorizonData.has_photos(view)
	var grid := GridContainer.new()
	grid.name = "Records"
	grid.columns = columns.size() + (2 if compare else 1) + (1 if not inspect.is_empty() else 0) + (1 if photos else 0)
	grid.add_theme_constant_override("h_separation", 2)
	grid.add_theme_constant_override("v_separation", 2)
	grid.add_child(_cell(view.get("keyLabel", "Record"), P.SUBTLE, true))
	if compare:
		grid.add_child(_cell("Side", P.SUBTLE, true))
	if photos:
		grid.add_child(_cell("Image", P.SUBTLE, true))
	for column in columns:
		grid.add_child(_cell(column["label"], P.SUBTLE, true))
	if not inspect.is_empty():
		grid.add_child(_cell(Kit.t("Inspect"), P.SUBTLE, true))
	for row in HorizonData.filtered_rows(view, _filters.get(view["id"], "")):
		var key: String = row["key"]
		if compare:
			grid.add_child(_cell(key, P.SURFACE, true))
			grid.add_child(_cell("Source", SOURCE_BG, false))
			if photos:
				grid.add_child(_photo_cell(view, row, "source", row.get("source", null), SOURCE_BG))
			_values(grid, view, key, "source", row.get("source", null), columns, SOURCE_BG)
			grid.add_child(_cell("", TARGET_BG, false))
			grid.add_child(_cell("Target", TARGET_BG, false))
			if photos:
				grid.add_child(_photo_cell(view, row, "target", row.get("target", null), TARGET_BG))
			_values(grid, view, key, "target", row.get("target", null), columns, TARGET_BG)
		else:
			grid.add_child(_cell(key, P.SURFACE, true))
			var values := HorizonData.values_on(row, DesktopSession.viewport)
			if photos:
				grid.add_child(_photo_cell(view, row, "", values, P.SURFACE))
			if not inspect.is_empty() and not GameState.inspected(GameSession.state, view["id"]).has(key):
				values = values.duplicate()
				for hidden in inspect.get("hides", []):
					values[hidden] = Kit.t("Not inspected")
			_values(grid, view, key, "", values, columns, P.SURFACE)
			if not inspect.is_empty():
				grid.add_child(_inspect_cell(view, key, inspect))
	return grid


func _values(grid: GridContainer, view: Dictionary, key: String, side: String, values: Variant, columns: Array, background: Color) -> void:
	for column in columns:
		var text: String = MISSING if values == null else str(values.get(column["id"], ""))
		var cell := _cell("—" if values == null else text, background, false)
		var value_label: Label = cell.get_child(0)
		# Long descriptions (a photo's visible details) wrap in a wide column.
		if column.get("wide", false):
			value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			value_label.custom_minimum_size = Vector2(260, 0)
		var name := "%s · %s · %s" % [key, side.capitalize(), column["label"]] if side != "" else "%s · %s" % [key, column["label"]]
		Kit.evidence(value_label, HorizonData.cell_target(view, key, side, column["id"]), name, text)
		grid.add_child(cell)


## A row's photo as this side and device draw it. A Note on it records the column the
## photo is described in, so noting the picture and noting its description are the same.
func _photo_cell(view: Dictionary, row: Dictionary, side: String, values: Variant, background: Color) -> Control:
	var cell := Kit.panel(background, Color.TRANSPARENT, 0, 4)
	var shown := HorizonData.photo_on(row, side, DesktopSession.viewport)
	if shown.is_empty() or values == null:
		cell.add_child(Kit.label("—", 13, P.MUTED, false))
		return cell
	var caption := "%s · %s" % [row["key"], side.capitalize()] if side != "" else str(row["key"])
	var photo := _photo(view, shown, caption, THUMB_HEIGHT, row["key"], side)
	if shown.has("notes") and photo is TextureRect:
		var column: String = shown["notes"]
		var label := column
		for item in view["columns"]:
			if item["id"] == column:
				label = item["label"]
		Kit.evidence(photo, HorizonData.cell_target(view, row["key"], side, column), "%s · %s" % [caption, label], str(values.get(column, "")))
	cell.add_child(photo)
	return cell


## A photo at the given height; clicking it shows it large above the records. When the
## image is missing, the alt text and metadata in the row still carry the record.
func _photo(view: Dictionary, shown: Dictionary, caption: String, height: float, row_key: String, side: String) -> Control:
	var texture := photo_texture(shown)
	if texture == null:
		var missing := Kit.label("Image unavailable", 12, P.MUTED, false)
		missing.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		return missing
	var picture := TextureRect.new()
	picture.name = "Photo_%s" % caption.replace(" · ", "_")
	picture.texture = texture
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	picture.custom_minimum_size = Vector2(height * texture.get_width() / texture.get_height(), height)
	picture.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	picture.mouse_filter = Control.MOUSE_FILTER_STOP
	picture.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	picture.tooltip_text = "Click to enlarge"
	picture.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			zoom(view["id"], row_key, side, caption))
	return picture


## Shows a photo large above the records; the same photo again closes it.
func zoom(view_id: String, row_key: String, side: String, caption: String) -> void:
	var same: bool = _zoom.get("view", "") == view_id and _zoom.get("caption", "") == caption
	_zoom = {} if same else { "view": view_id, "row": row_key, "side": side, "caption": caption }
	rerender.call()


## The zoomed photo as the current device draws it.
func _zoom_shown(view: Dictionary) -> Dictionary:
	if _zoom["row"] == "":
		return view.get("photo", {})
	for row in view["rows"]:
		if row["key"] == _zoom["row"]:
			return HorizonData.photo_on(row, _zoom["side"], DesktopSession.viewport)
	return {}


func _zoomed(view: Dictionary) -> Control:
	var panel := Kit.panel(P.SURFACE, P.BORDER, 6, 12)
	panel.name = "PhotoZoom"
	panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var column := Kit.vbox(8)
	var bar := Kit.hbox(10)
	bar.add_child(Kit.heading(_zoom["caption"], 14))
	bar.add_child(Kit.button("Close", func():
		_zoom = {}
		rerender.call()))
	column.add_child(bar)
	var texture := photo_texture(_zoom_shown(view))
	var picture := TextureRect.new()
	picture.texture = texture
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	var width := minf(ZOOM_WIDTH, texture.get_width())
	picture.custom_minimum_size = Vector2(width, width * texture.get_height() / texture.get_width())
	column.add_child(picture)
	panel.add_child(column)
	return panel


## The source image with this screen's crop and rotation applied, or null when the image
## is not there.
static func photo_texture(shown: Dictionary) -> Texture2D:
	var key := JSON.stringify(shown)
	if _photos.has(key):
		return _photos[key]
	var path := PHOTO_PATH % shown.get("asset", "")
	if not ResourceLoader.exists(path):
		return null
	var image: Image = (load(path) as Texture2D).get_image()
	if image.is_compressed():
		image.decompress()
	if shown.has("crop"):
		var crop: Array = shown["crop"]
		var size := Vector2(image.get_size())
		image = image.get_region(Rect2i(Vector2i(Vector2(crop[0], crop[1]) * size), Vector2i(Vector2(crop[2], crop[3]) * size)))
	if int(shown.get("rotate", 0)) == 90:
		image.rotate_90(CLOCKWISE)
	_photos[key] = ImageTexture.create_from_image(image)
	return _photos[key]


func _inspect_cell(view: Dictionary, key: String, inspect: Dictionary) -> Control:
	var done := GameState.inspected(GameSession.state, view["id"])
	var budget := int(inspect.get("budget", 0))
	if done.has(key):
		return _cell(Kit.t("Inspected"), P.SUCCESS_SOFT, false)
	if done.size() >= budget:
		return _cell(Kit.t("No budget left"), P.SURFACE, false)
	var cell := Kit.panel(P.SURFACE, Color.TRANSPARENT, 0, 4)
	var button := Kit.button(Kit.tf("Inspect (%d left)", budget - done.size()), func():
		GameSession.inspect(view["id"], key, budget)
		rerender.call())
	button.name = "Inspect%s" % key
	button.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	cell.add_child(button)
	return cell


static func _cell(text: String, background: Color, strong: bool) -> PanelContainer:
	var cell := Kit.panel(background, Color.TRANSPARENT, 0, 8)
	cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var label := Kit.heading(text, 13) if strong else Kit.label(text, 13, P.TEXT, false)
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	cell.add_child(label)
	return cell
