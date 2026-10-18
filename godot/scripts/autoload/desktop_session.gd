## Workstation session: windows, browser tabs and their history, app selections,
## notifications, and paced Messenger delivery. Port of DesktopProvider.tsx and
## useMessenger.ts. Window layout and browser tabs are not saved.
extends Node

signal changed
signal toasts_changed
## Asks a window to occupy a fraction of the desktop (position and size in 0..1).
signal layout_requested(app: String, fraction: Rect2)
## A reference document was pinned to a Ticket's QA Notes.
signal reference_pinned(ticket_id: String, attachment_id: String)

const Addresses := preload("res://scripts/domain/addresses.gd")
const MessengerLog := preload("res://scripts/domain/messenger_log.gd")

const APPS := ["messenger", "browser", "notes"]
const APP_TITLES := { "messenger": "Messenger", "browser": "Browser", "notes": "QA Notes" }
const MESSAGE_DELAY := 0.9
const FIRST_MESSAGE_DELAY := 1.8
const TOAST_SECONDS := 7.0
const MAX_TABS := 6

var windows := {}
var focused_app := ""
## Each Browser tab keeps its own history. Links from other apps open in a new tab.
var tabs: Array = [{ "id": 0, "history": [Addresses.new_tab()], "index": 0 }]
var active_tab := 0
var reload_key := 0
var viewport := "DESKTOP"
## QA Notes shows a Ticket page or the Case File.
var notes_view := "ticket"
var notes_ticket_id := ""
## Messenger opens its report form on the next render.
var report_requested := false
var toasts: Array = []
## Messages are delivered only while the desktop is on screen.
var delivery_enabled := false
## Tests deliver queued messages immediately.
var instant_messages := false

var _toast_counter := 0
var _tab_counter := 0
var _z := 0
var _delivery_timer: Timer
var _scheduled_for := -1


func _ready() -> void:
	for app in APPS:
		windows[app] = { "open": false, "minimized": false, "maximized": false, "z": 0 }
	_delivery_timer = Timer.new()
	_delivery_timer.one_shot = true
	_delivery_timer.timeout.connect(_deliver_next)
	add_child(_delivery_timer)
	GameSession.changed.connect(_schedule_delivery)


func reset_layout() -> void:
	for app in APPS:
		windows[app] = { "open": false, "minimized": false, "maximized": false, "z": 0 }
	focused_app = ""
	tabs = [_tab_state(Addresses.new_tab())]
	active_tab = 0
	notes_view = "ticket"
	notes_ticket_id = ""
	report_requested = false
	toasts = []
	changed.emit()
	toasts_changed.emit()


# --- Windows ---------------------------------------------------------------

func open_app(app: String) -> void:
	_z += 1
	windows[app]["open"] = true
	windows[app]["minimized"] = false
	windows[app]["z"] = _z
	focused_app = app
	var before := toasts.size()
	toasts = toasts.filter(func(toast): return toast.get("app", "") != app)
	if toasts.size() != before:
		toasts_changed.emit()
	if app == "messenger":
		_mark_read()
	changed.emit()


func close_app(app: String) -> void:
	windows[app] = { "open": false, "minimized": false, "maximized": false, "z": 0 }
	if focused_app == app:
		focused_app = ""
	changed.emit()


func minimize_app(app: String) -> void:
	windows[app]["minimized"] = true
	if focused_app == app:
		focused_app = ""
	changed.emit()


func toggle_maximize(app: String) -> void:
	windows[app]["maximized"] = not windows[app]["maximized"]
	changed.emit()


func is_visible_app(app: String) -> bool:
	return windows[app]["open"] and not windows[app]["minimized"]


# --- Browser ---------------------------------------------------------------

func _tab_state(first: Dictionary) -> Dictionary:
	_tab_counter += 1
	return { "id": _tab_counter, "history": [first], "index": 0 }


func _tab() -> Dictionary:
	return tabs[active_tab]


func location() -> Dictionary:
	return _tab()["history"][_tab()["index"]]


## Changes whenever the Browser shows a different page: another tab or another step in
## a tab's history.
func location_key() -> String:
	return "%d#%d" % [_tab()["id"], _tab()["index"]]


func tab_location(index: int) -> Dictionary:
	return tabs[index]["history"][tabs[index]["index"]]


## Every address visited in any tab, oldest first.
func visited() -> Array:
	var all: Array = []
	for tab in tabs:
		all.append_array(tab["history"])
	return all


func can_go_back() -> bool:
	return _tab()["index"] > 0


func can_go_forward() -> bool:
	return _tab()["index"] < _tab()["history"].size() - 1


func open_tab(first: Dictionary = Addresses.new_tab()) -> void:
	tabs.append(_tab_state(first))
	if tabs.size() > MAX_TABS:
		tabs.remove_at(0)
	active_tab = tabs.size() - 1
	_record_visit(first)
	changed.emit()


func switch_tab(index: int) -> void:
	if index == active_tab or index < 0 or index >= tabs.size():
		return
	active_tab = index
	_record_visit(location())
	changed.emit()


func close_tab(index: int) -> void:
	if tabs.size() == 1:
		tabs = [_tab_state(Addresses.new_tab())]
		active_tab = 0
		changed.emit()
		return
	tabs.remove_at(index)
	if active_tab >= index and active_tab > 0:
		active_tab -= 1
	_record_visit(location())
	changed.emit()


## Opens a page from another app: in the current tab when it is blank, otherwise in a
## new tab, so the page the player was testing stays open.
func open_in_browser(target: Dictionary) -> void:
	open_app("browser")
	if location()["kind"] == "newtab":
		navigate(target)
	else:
		open_tab(target)


## Opens a link. Intranet documents attached to a Ticket are pinned into that
## Ticket's QA Notes and placed beside the Browser, so the player can read the spec
## while testing. Other addresses open in the Browser.
func open_url(address: String) -> void:
	var target := Addresses.parse(address)
	if target["kind"] == "docs":
		var owner := _document_owner(target["slug"])
		if not owner.is_empty():
			pin_reference(owner["ticketId"], owner["attachment"])
			return
	open_in_browser(target)


## Opens the Browser on intranet search results for a lead.
func search_intranet(term: String) -> void:
	open_in_browser(Addresses.search(term))


func _document_owner(slug: String) -> Dictionary:
	for scenario in GameSession.catalog.scenarios:
		for attachment in scenario["ticket"].get("attachments", []):
			if Addresses.slug(attachment["name"]) == slug:
				return { "ticketId": scenario["ticket"]["id"], "attachment": attachment }
	return {}


func pin_reference(ticket_id: String, attachment: Dictionary) -> void:
	WorkspaceSession.pin_reference(ticket_id, attachment["id"])
	notes_ticket_id = ticket_id
	if windows["browser"]["open"]:
		arrange_side_by_side("browser", "notes")
	else:
		snap_app("notes", Rect2(0.58, 0, 0.42, 1))
	push_toast(str(TranslationServer.translate("Reference saved")),
		str(TranslationServer.translate("%s is pinned in QA Notes.")) % TranslationServer.translate(attachment["name"]), "notes")
	reference_pinned.emit(ticket_id, attachment["id"])


## Opens an app filling the given fraction of the desktop.
func snap_app(app: String, fraction: Rect2) -> void:
	windows[app]["maximized"] = false
	open_app(app)
	layout_requested.emit(app, fraction)


## Browser on the left, the reference app on the right.
func arrange_side_by_side(left_app: String = "browser", right_app: String = "notes") -> void:
	snap_app(left_app, Rect2(0, 0, 0.6, 1))
	snap_app(right_app, Rect2(0.6, 0, 0.4, 1))


func navigate(next: Dictionary) -> void:
	var tab := _tab()
	tab["history"] = tab["history"].slice(0, tab["index"] + 1)
	tab["history"].append(next)
	tab["index"] = tab["history"].size() - 1
	_record_visit(next)
	changed.emit()


func go_back() -> void:
	if can_go_back():
		_tab()["index"] -= 1
		_record_visit(location())
		changed.emit()


func go_forward() -> void:
	if can_go_forward():
		_tab()["index"] += 1
		_record_visit(location())
		changed.emit()


func reload() -> void:
	reload_key += 1
	var active := GameSession.active_ticket_id()
	if active != "" and Addresses.is_workspace(location()):
		WorkspaceSession.record_interaction(active, "RELOAD_PAGE", location()["path"])
	changed.emit()


func set_viewport(next: String) -> void:
	viewport = next
	var active := GameSession.active_ticket_id()
	if active != "":
		WorkspaceSession.record_interaction(active, "CHANGE_VIEWPORT", next)
	changed.emit()


static func action_for_path(path: String) -> String:
	if path.contains("/payment"):
		return "OPEN_PAYMENT"
	if path.contains("/orders/"):
		return "OPEN_ORDER"
	if path.ends_with("/orders"):
		return "OPEN_ORDERS"
	if path.contains("/checkout"):
		return "OPEN_CHECKOUT"
	if path.contains("/cart"):
		return "OPEN_CART"
	if path.contains("/product/") or path == "/shoply":
		return "OPEN_PRODUCT"
	return "NAVIGATE"


func _record_visit(next: Dictionary) -> void:
	var active := GameSession.active_ticket_id()
	if active != "" and Addresses.is_workspace(next):
		WorkspaceSession.record_interaction(active, action_for_path(next["path"]), next["path"])


## The Test Context the Browser currently shows, used by Mutations, Evidence, and guides.
func qa_context() -> Dictionary:
	var active := GameSession.active_ticket_id()
	var current := location()
	var on_shoply: bool = Addresses.is_workspace(current)
	var evidence: Array = WorkspaceSession.evidence_for(active) if active != "" else []
	var locale := "en-US"
	if active != "":
		locale = GameSession.scenario(active)["ticket"]["startingContext"]["locale"]
	var current_path: String = current["path"] if on_shoply else Addresses.format(current)
	return {
		"test": {
			"account": ShoplyStore.account,
			"viewport": viewport,
			"locale": locale,
			"currentPath": current_path if current_path != "" else "about:blank",
		},
		"product": { "cart": { "quantity": ShoplyStore.item_count() }, "coupon": ShoplyStore.coupon },
		"workspace": {
			"onShoply": on_shoply,
			"browserOpen": windows["browser"]["open"],
			"evidenceCount": evidence.size(),
			"capturedPaths": evidence.map(func(item): return item["context"]["currentPath"]),
			"visitedPaths": (WorkspaceSession.interactions_for(active) if active != "" else []).map(func(action): return action.get("target", "")),
			"reportCount": GameSession.state["tickets"][active]["reportIds"].size() if active != "" else 0,
		},
	}


# --- App selections ----------------------------------------------------------

func show_ticket(ticket_id: String) -> void:
	notes_ticket_id = ticket_id
	notes_view = "ticket"
	open_app("notes")


func show_case_file() -> void:
	notes_view = "casefile"
	open_app("notes")


func show_notes(ticket_id: String = "") -> void:
	if ticket_id != "":
		notes_ticket_id = ticket_id
	notes_view = "ticket"
	open_app("notes")


## Opens Messenger with the report form for the Ticket under test.
func open_report() -> void:
	report_requested = true
	open_app("messenger")


# --- Notifications -------------------------------------------------------------

func push_toast(title: String, text: String, app: String = "") -> void:
	_toast_counter += 1
	var id := _toast_counter
	toasts.append({ "id": id, "title": title, "text": text, "app": app })
	if toasts.size() > 3:
		toasts = toasts.slice(toasts.size() - 3)
	toasts_changed.emit()
	get_tree().create_timer(TOAST_SECONDS).timeout.connect(dismiss_toast.bind(id))


func dismiss_toast(id: int) -> void:
	var before := toasts.size()
	toasts = toasts.filter(func(toast): return toast["id"] != id)
	if toasts.size() != before:
		toasts_changed.emit()


# --- Messenger -------------------------------------------------------------

## How far the chat has been delivered and read is kept as the last entry's id, so
## messages added to the story later never replay the conversation; the counts are the
## fallback for older saves.
func messenger_log() -> Dictionary:
	var log := MessengerLog.build(GameSession.catalog, GameSession.state)
	var entries: Array = log["entries"]
	var story: Dictionary = GameSession.state["story"]
	var delivered := _position_after(entries, str(story.get("deliveredId", "")), int(story["deliveredCount"]))
	var read := mini(_position_after(entries, str(story.get("readId", "")), int(story["readCount"])), delivered)
	log["delivered"] = delivered
	log["unread"] = maxi(0, delivered - read)
	return log


static func _position_after(entries: Array, id: String, fallback: int) -> int:
	if id != "":
		for index in entries.size():
			if entries[index]["id"] == id:
				return index + 1
	return mini(fallback, entries.size())


func set_delivery_enabled(enabled: bool) -> void:
	delivery_enabled = enabled
	_schedule_delivery()


func _schedule_delivery() -> void:
	if not delivery_enabled:
		_delivery_timer.stop()
		_scheduled_for = -1
		return
	var log := messenger_log()
	var delivered: int = log["delivered"]
	var entries: Array = log["entries"]
	if delivered >= entries.size():
		_mark_read()
		return
	if instant_messages:
		GameSession.mark_messages_delivered(entries.size(), entries[-1]["id"])
		return
	if _scheduled_for == delivered and not _delivery_timer.is_stopped():
		return
	_scheduled_for = delivered
	var next: Dictionary = entries[delivered]
	var delay := MESSAGE_DELAY
	if next["kind"] == "player":
		delay = 0.05
	elif delivered == 0:
		delay = FIRST_MESSAGE_DELAY
	_delivery_timer.start(delay)


func _deliver_next() -> void:
	_scheduled_for = -1
	var log := messenger_log()
	var delivered: int = log["delivered"]
	if delivered >= log["entries"].size():
		return
	var entry: Dictionary = log["entries"][delivered]
	GameSession.mark_messages_delivered(delivered + 1, entry["id"])
	if entry["kind"] == "message":
		Sfx.play("message")
	if entry["kind"] == "message" and not is_visible_app("messenger"):
		push_toast(entry["from"], entry["text"], "messenger")
	_mark_read()


func _mark_read() -> void:
	if is_visible_app("messenger"):
		var log := messenger_log()
		var delivered: int = log["delivered"]
		if delivered > 0:
			GameSession.mark_messages_read(delivered, log["entries"][delivered - 1]["id"])
