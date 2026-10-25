## The ONE HORIZON QA portal (res://data/horizon.json): read-only UAT snapshots of
## Horizon Group systems that Tickets inspect. Every system is a "view" of records, either
## a plain table or a Source/Target migration compare, drawn by one generic screen
## (record_view.gd). A view opens once the Ticket that uses it is unlocked.
extends RefCounted

const DEFAULT_PATH := "res://data/horizon.json"

var portal: Dictionary = {}
var views: Array = []


static func load_from(path: String = DEFAULT_PATH) -> RefCounted:
	var data: RefCounted = load("res://scripts/domain/horizon_data.gd").new()
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) == TYPE_DICTIONARY:
		data.portal = parsed.get("portal", {})
		data.views = parsed.get("views", [])
	return data


func get_view(id: String) -> Variant:
	for view in views:
		if view["id"] == id:
			return view
	return null


func is_open(view: Dictionary, catalog: RefCounted, state: Dictionary) -> bool:
	return catalog.is_ticket_unlocked(state, str(view.get("ticket", "")))


func open_views(catalog: RefCounted, state: Dictionary) -> Array:
	return views.filter(func(view): return is_open(view, catalog, state))


## The evidence target of one cell: "view.key.side.column" on a compare, "view.key.column"
## on a table.
static func cell_target(view: Dictionary, key: String, side: String, column: String) -> String:
	return "%s.%s.%s.%s" % [view["id"], key, side, column] if side != "" else "%s.%s.%s" % [view["id"], key, column]


## The photo a row shows on one side and device, or {} for a row without one. `photo` names
## the source image (`asset`) and how this screen draws it: `crop` ([x, y, w, h] as
## fractions of the image) and `rotate` (degrees clockwise). `source`, `target`, and
## `byViewport` override those on one side of a compare or on one device, so every defect
## is drawn from the same picture. `notes` is the column a Note on the photo records.
static func photo_on(row: Dictionary, side: String, viewport: String) -> Dictionary:
	var photo: Dictionary = row.get("photo", {})
	if photo.is_empty():
		return {}
	var shown := photo.duplicate()
	for part in ["source", "target", "byViewport"]:
		shown.erase(part)
	if side != "":
		shown.merge(photo.get(side, {}), true)
	shown.merge(photo.get("byViewport", {}).get(viewport, {}), true)
	return shown


static func has_photos(view: Dictionary) -> bool:
	return view["rows"].any(func(row): return row.has("photo"))


## A table row as the current device shows it: `byViewport` overrides some values on
## some devices (a gallery that breaks only on tablets).
static func values_on(row: Dictionary, viewport: String) -> Dictionary:
	var values: Dictionary = row.get("values", {})
	var overrides: Dictionary = row.get("byViewport", {}).get(viewport, {})
	if overrides.is_empty():
		return values
	var merged := values.duplicate()
	merged.merge(overrides, true)
	return merged


## Rows whose filter column matches `value` ("" keeps every row).
static func filtered_rows(view: Dictionary, value: String) -> Array:
	var column: String = view.get("filter", "")
	if column == "" or value == "":
		return view["rows"]
	return view["rows"].filter(func(row): return str(_values(view, row).get(column, "")) == value)


static func filter_values(view: Dictionary) -> Array:
	var column: String = view.get("filter", "")
	var seen: Array = []
	for row in view["rows"]:
		var value := str(_values(view, row).get(column, ""))
		if value != "" and not seen.has(value):
			seen.append(value)
	seen.sort()
	return seen


## The values a row is filtered by: the Source side of a compare, or the row itself.
static func _values(view: Dictionary, row: Dictionary) -> Dictionary:
	if view.get("mode", "table") == "compare":
		var source: Variant = row.get("source", null)
		return source if source != null else row.get("target", {})
	return row.get("values", {})
