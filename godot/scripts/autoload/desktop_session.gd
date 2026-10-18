## Workstation session: windows, browser history, app selections, notifications,
## and paced Messenger delivery. Port of DesktopProvider.tsx and useMessenger.ts.
## Window layout and browser history are not saved.
extends Node

signal changed
signal toasts_changed
## Asks a window to occupy a fraction of the desktop (position and size in 0..1).
signal layout_requested(app: String, fraction: Rect2)
## A reference document was pinned to a Ticket's QA Notes.
signal reference_pinned(ticket_id: String, attachment_id: String)

const Addresses := preload("res://scripts/domain/addresses.gd")
const MessengerLog := preload("res://scripts/domain/messenger_log.gd")

const APPS := ["messenger", "tracker", "browser", "notes"]
const APP_TITLES := { "messenger": "Messenger", "tracker": "QA Tracker", "browser": "Browser", "notes": "QA Notes" }
const MESSAGE_DELAY := 0.9
const FIRST_MESSAGE_DELAY := 1.8
const TOAST_SECONDS := 7.0

var windows := {}
var focused_app := ""
var history: Array = [Addresses.new_tab()]
var history_index := 0
var reload_key := 0
var viewport := "DESKTOP"
var tracker_ticket_id := ""
var tracker_view := "detail"
var notes_ticket_id := ""
var toasts: Array = []
## Messages are delivered only while the desktop is on screen.
var delivery_enabled := false
## Tests deliver queued messages immediately.
var instant_messages := false

var _toast_counter := 0
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
	history = [Addresses.new_tab()]
	history_index = 0
	tracker_ticket_id = ""
	tracker_view = "detail"
	notes_ticket_id = ""
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

func location() -> Dictionary:
	return history[history_index]


func can_go_back() -> bool:
	return history_index > 0


func can_go_forward() -> bool:
	return history_index < history.size() - 1


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
	open_app("browser")
	navigate(target)


## Opens the Browser on intranet search results for a lead.
func search_intranet(term: String) -> void:
	open_app("browser")
	navigate(Addresses.search(term))


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
	history = history.slice(0, history_index + 1)
	history.append(next)
	history_index = history.size() - 1
	_record_visit(next)
	changed.emit()


func go_back() -> void:
	if can_go_back():
		history_index -= 1
		_record_visit(location())
		changed.emit()


func go_forward() -> void:
	if can_go_forward():
		history_index += 1
		_record_visit(location())
		changed.emit()


func reload() -> void:
	reload_key += 1
	var active := GameSession.active_ticket_id()
	if active != "" and location()["kind"] == "shoply":
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
	if active != "" and next["kind"] == "shoply":
		WorkspaceSession.record_interaction(active, action_for_path(next["path"]), next["path"])


## The Test Context the Browser currently shows, used by Mutations, Evidence, and guides.
func qa_context() -> Dictionary:
	var active := GameSession.active_ticket_id()
	var current := location()
	var on_shoply: bool = current["kind"] == "shoply"
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
			"flagCount": GameSession.state["tickets"][active]["reportIds"].size() if active != "" else 0,
		},
	}


# --- App selections ----------------------------------------------------------

func show_ticket(ticket_id: String, view: String = "detail") -> void:
	tracker_ticket_id = ticket_id
	tracker_view = view
	open_app("tracker")


func set_tracker_view(view: String) -> void:
	tracker_view = view
	changed.emit()


func show_notes(ticket_id: String = "") -> void:
	if ticket_id != "":
		notes_ticket_id = ticket_id
	open_app("notes")


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

func messenger_log() -> Dictionary:
	var log := MessengerLog.build(GameSession.catalog, GameSession.state)
	var total: int = log["entries"].size()
	var delivered := mini(int(GameSession.state["story"]["deliveredCount"]), total)
	var read := mini(int(GameSession.state["story"]["readCount"]), delivered)
	log["delivered"] = delivered
	log["unread"] = maxi(0, delivered - read)
	return log


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
		GameSession.mark_messages_delivered(entries.size())
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
	GameSession.mark_messages_delivered(delivered + 1)
	if entry["kind"] == "message":
		Sfx.play("message")
	if entry["kind"] == "message" and not is_visible_app("messenger"):
		push_toast(entry["from"], entry["text"], "messenger")
	_mark_read()


func _mark_read() -> void:
	if is_visible_app("messenger"):
		var log := messenger_log()
		GameSession.mark_messages_read(log["delivered"])
