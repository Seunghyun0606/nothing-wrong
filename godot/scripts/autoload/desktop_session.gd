## Workstation session: windows, browser tabs and their history, app selections,
## notifications, and paced Messenger delivery. Port of DesktopProvider.tsx and
## useMessenger.ts. Window layout and browser tabs are not saved.
## Each Ticket's chat waits for the player (MessengerLog.next_gate): time passes on the
## clock, its first message arrives as a notification, and the chat goes on when the
## player opens it. A Ticket on another day first ends the day: the player clocks out
## and signs in again the next morning.
extends Node

signal changed
signal toasts_changed
## Asks a window to occupy a fraction of the desktop (position and size in 0..1).
signal layout_requested(app: String, fraction: Rect2)
## A reference document was pinned to a Ticket's QA Notes.
signal reference_pinned(ticket_id: String, attachment_id: String)
## The waiting Ticket's step changed, or the clock moved while time passes.
signal gate_changed

const Addresses := preload("res://scripts/domain/addresses.gd")
const MessengerLog := preload("res://scripts/domain/messenger_log.gd")
const StoryClock := preload("res://scripts/domain/story_clock.gd")

const APPS := ["messenger", "browser", "notes"]
const APP_TITLES := { "messenger": "Messenger", "browser": "Browser", "notes": "QA Notes" }
const MESSAGE_DELAY := 0.9
const FIRST_MESSAGE_DELAY := 1.8
const TOAST_SECONDS := 7.0
const MAX_TABS := 6
## Back/Forward keeps this many pages per tab, so a long session does not grow without end.
const MAX_HISTORY := 50
## Seconds before a waiting Ticket's notification, or the end of the day, shows up.
const NOTIFY_DELAY := 2.5
## Seconds the clock takes to run forward to the next Ticket.
const WAIT_SECONDS := 2.4
## Gaps shorter than this many minutes pass without showing the clock run.
const SHORT_GAP := 15
## The player signs in this many minutes before the day's first message.
const LOGIN_LEAD := 20
## A working day ends at 18:00 at the earliest: the afternoon passes before clocking out.
const END_OF_DAY := 18 * 60

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
## The conversation the player picked in Messenger. Empty follows the newest message.
var chat_pinned := ""
var toasts: Array = []
## Messages are delivered only while the desktop is on screen.
var delivery_enabled := false
## Tests deliver queued messages immediately.
var instant_messages := false
## The Ticket whose chat waits for the player: MessengerLog.next_gate plus its "step":
## "clock_out" (the day is over; "left" is when), "wait" (time passes to its first
## message), or "notify" (its notification is up), and "running" while the clock runs
## from "run_from" to "run_to". Empty when nothing waits.
var gate := {}
## The story time the taskbar shows while the player waits; -1 follows the chat.
var clock_override := -1

var _toast_counter := 0
var _tab_counter := 0
var _z := 0
var _delivery_timer: Timer
var _scheduled_for := -1
var _gate_timer: Timer
var _clock_tween: Tween
## Waiting Tickets the player opened, and the day starts they signed in for.
var _opened := {}
var _signed_in_for := {}
## The Ticket the last recorded visit belongs to.
var _visit_ticket := ""


func _ready() -> void:
	for app in APPS:
		windows[app] = { "open": false, "minimized": false, "maximized": false, "z": 0 }
	_delivery_timer = Timer.new()
	_delivery_timer.one_shot = true
	_delivery_timer.timeout.connect(_deliver_next)
	add_child(_delivery_timer)
	_gate_timer = Timer.new()
	_gate_timer.one_shot = true
	_gate_timer.timeout.connect(_advance_gate)
	add_child(_gate_timer)
	GameSession.changed.connect(_schedule_delivery)
	GameSession.changed.connect(_note_started_ticket)


func reset_layout() -> void:
	for app in APPS:
		windows[app] = { "open": false, "minimized": false, "maximized": false, "z": 0 }
	focused_app = ""
	tabs = [_tab_state(Addresses.new_tab())]
	active_tab = 0
	notes_view = "ticket"
	notes_ticket_id = ""
	report_requested = false
	chat_pinned = ""
	toasts = []
	# A new game or a new day: every Ticket ahead waits for the player again.
	_opened = {}
	_signed_in_for = {}
	_release_gate()
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
		# Opening Messenger while a Ticket's notification is up opens it too.
		if gate.get("step", "") == "notify":
			open_gate()
			return
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


## Opens a person's page in the directory.
func show_person(id: String) -> void:
	open_in_browser(Addresses.people(id))


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


## Browser on the left three quarters, the reference app on the right, both full height.
func arrange_side_by_side(left_app: String = "browser", right_app: String = "notes") -> void:
	snap_app(left_app, Rect2(0, 0, 0.75, 1))
	snap_app(right_app, Rect2(0.75, 0, 0.25, 1))


## The testing layout (the taskbar's Arrange): Browser and QA Notes side by side.
## Messenger steps aside; its messages still come up as notifications.
func arrange_for_testing() -> void:
	if is_visible_app("messenger"):
		minimize_app("messenger")
	arrange_side_by_side("browser", "notes")


func navigate(next: Dictionary) -> void:
	var tab := _tab()
	tab["history"] = tab["history"].slice(0, tab["index"] + 1)
	tab["history"].append(next)
	if tab["history"].size() > MAX_HISTORY:
		tab["history"] = tab["history"].slice(tab["history"].size() - MAX_HISTORY)
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


## A Ticket started while the Browser already shows its starting screen counts that
## screen as visited. Any other page left open from earlier work does not.
func _note_started_ticket() -> void:
	var active := GameSession.active_ticket_id()
	if active == _visit_ticket:
		return
	_visit_ticket = active
	if active == "" or tabs.is_empty():
		return
	var start: String = GameSession.scenario(active)["ticket"]["startingContext"]["currentPath"]
	if location().get("path", "") == start:
		_record_visit(location())


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


## Opens Messenger with the report form for the Ticket under test, in its conversation.
func open_report() -> void:
	report_requested = true
	var active := GameSession.active_ticket_id()
	if active != "":
		_pin_chat(MessengerLog.conversation_of(GameSession.catalog, GameSession.scenario(active)), messenger_log())
	open_app("messenger")


## Opens Messenger on a conversation.
func show_chat(conversation: String) -> void:
	_pin_chat(conversation, messenger_log())
	open_app("messenger")


## Picking the conversation with the newest message goes back to following the chat.
func _pin_chat(conversation: String, log: Dictionary) -> void:
	chat_pinned = "" if conversation == latest_chat(log) else conversation


## The conversation Messenger shows.
func current_chat(log: Dictionary) -> String:
	if chat_pinned != "" and log["conversations"].has(chat_pinned):
		return chat_pinned
	return latest_chat(log)


static func latest_chat(log: Dictionary) -> String:
	var delivered: int = log["delivered"]
	return str(log["entries"][delivered - 1]["in"]) if delivered > 0 else ""


# --- Notifications -------------------------------------------------------------

## `extra` may hold "sticky" (stays until it is acted on), "gate" (the waiting Ticket's
## notification), or "kind" ("clock_out").
func push_toast(title: String, text: String, app: String = "", chat: String = "", extra: Dictionary = {}) -> void:
	_toast_counter += 1
	var id := _toast_counter
	var toast := { "id": id, "title": title, "text": text, "app": app, "chat": chat }
	toast.merge(extra)
	toasts.append(toast)
	var sticky: Array = toasts.filter(func(each): return each.get("sticky", false))
	var passing: Array = toasts.filter(func(each): return not each.get("sticky", false))
	toasts = sticky + passing.slice(maxi(0, passing.size() - (3 - sticky.size())))
	toasts_changed.emit()
	if not toast.get("sticky", false):
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
## "conversations" lists the ones with a delivered entry, in the order they started;
## "unreadIn" counts what the player has not seen in each; "arrived" lists the Tickets
## the team has started talking about in the chat so far.
func messenger_log() -> Dictionary:
	var log := MessengerLog.build(GameSession.catalog, GameSession.state)
	var entries: Array = log["entries"]
	var story: Dictionary = GameSession.state["story"]
	var delivered := _position_after(entries, str(story.get("deliveredId", "")), int(story["deliveredCount"]))
	var legacy_read := mini(_position_after(entries, str(story.get("readId", "")), int(story["readCount"])), delivered)
	var read_in: Dictionary = story.get("readIn", {})
	var read_until := {}
	for conversation in read_in:
		# A read marker the story no longer has counts as read up to now.
		read_until[conversation] = _position_after(entries, str(read_in[conversation]), delivered)
	var conversations: Array = []
	var unread_in := {}
	var unread := 0
	var arrived: Array = []
	for index in delivered:
		var entry: Dictionary = entries[index]
		var conversation: String = entry["in"]
		# A Ticket arrives with its first message.
		if entry.has("ticketId") and not arrived.has(entry["ticketId"]):
			arrived.append(entry["ticketId"])
		if not conversations.has(conversation):
			conversations.append(conversation)
			unread_in[conversation] = 0
		if index >= int(read_until.get(conversation, legacy_read)) and not entry["kind"] in ["player", "report"]:
			unread_in[conversation] += 1
			unread += 1
	log["delivered"] = delivered
	log["arrived"] = arrived
	log["conversations"] = conversations
	log["unreadIn"] = unread_in
	log["unread"] = unread
	return log


static func _position_after(entries: Array, id: String, fallback: int) -> int:
	if id != "":
		for index in entries.size():
			if entries[index]["id"] == id:
				return index + 1
	return mini(fallback, entries.size())


## Whether the team has assigned a Ticket in the chat yet.
func has_arrived(ticket_id: String) -> bool:
	return messenger_log()["arrived"].has(ticket_id)


## The story time now: the clock while the player waits, else the newest message's.
func story_now(log: Dictionary) -> int:
	if clock_override >= 0:
		return clock_override
	var delivered: int = log["delivered"]
	return int(log["entries"][delivered - 1].get("time", 0)) if delivered > 0 else -1


## The time the lock screen shows: the next morning when a new day waits, else now.
func login_time() -> int:
	var log := messenger_log()
	var waiting := MessengerLog.next_gate(log["entries"], log["delivered"])
	if not waiting.is_empty() and waiting["day"]:
		return int(waiting["time"]) - LOGIN_LEAD
	return story_now(log)


func set_delivery_enabled(enabled: bool) -> void:
	delivery_enabled = enabled
	if not enabled:
		_release_gate()
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
	var waiting := MessengerLog.next_gate(entries, delivered)
	if not waiting.is_empty() and not _opened.has(waiting["id"]):
		_hold(waiting)
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
	clock_override = -1
	GameSession.mark_messages_delivered(delivered + 1, entry["id"])
	if entry["kind"] == "message":
		Sfx.play("message")
	if entry["kind"] == "message" and (not is_visible_app("messenger") or current_chat(messenger_log()) != entry["in"]):
		var from: String = entry["from"]
		if not MessengerLog.is_direct(entry["in"]):
			from = "%s · %s" % [from, entry["in"]]
		push_toast(from, entry["text"], "messenger", entry["in"])
	_mark_read()


## Only the conversation on screen is read.
func _mark_read() -> void:
	if is_visible_app("messenger"):
		var log := messenger_log()
		var conversation := current_chat(log)
		var entries: Array = log["entries"]
		for index in range(int(log["delivered"]) - 1, -1, -1):
			if entries[index]["in"] == conversation:
				GameSession.mark_chat_read(conversation, entries[index]["id"])
				return


# --- Waiting Tickets -----------------------------------------------------------

## Holds the chat before a Ticket's first message. A new day waits for the player to
## clock out; otherwise the clock runs forward and the notification comes up.
func _hold(waiting: Dictionary) -> void:
	if gate.get("id", "") == waiting["id"]:
		return
	_delivery_timer.stop()
	_scheduled_for = -1
	gate = waiting.duplicate()
	var since := int(waiting["since"])
	if waiting["day"] and since >= 0 and not _signed_in_for.has(waiting["id"]):
		gate["step"] = "clock_out"
		gate["left"] = maxi(since, since / 1440 * 1440 + END_OF_DAY)
		_run(since, int(gate["left"]), _advance_gate)
	else:
		if waiting["day"]:
			gate["since"] = int(waiting["time"]) - LOGIN_LEAD
		gate["step"] = "wait"
		_run(int(gate["since"]), int(gate["time"]), _notify)
	gate_changed.emit()
	changed.emit()


## Runs the taskbar clock forward, then goes on. A short gap just pauses.
func _run(from: int, to: int, then: Callable) -> void:
	clock_override = from
	gate["run_from"] = from
	gate["run_to"] = to
	if to - from < SHORT_GAP:
		_gate_timer.start(NOTIFY_DELAY)
		return
	gate["running"] = true
	if _clock_tween != null:
		_clock_tween.kill()
	_clock_tween = create_tween()
	_clock_tween.tween_interval(0.6)
	_clock_tween.tween_method(_run_clock, from, to, WAIT_SECONDS)
	_clock_tween.tween_callback(func():
		gate["running"] = false
		gate_changed.emit())
	_clock_tween.tween_interval(0.8)
	_clock_tween.tween_callback(then)


func _run_clock(minutes: int) -> void:
	if minutes != clock_override:
		clock_override = minutes
		gate_changed.emit()


func _advance_gate() -> void:
	match gate.get("step", ""):
		"clock_out":
			clock_override = int(gate["left"])
			gate_changed.emit()
			if not toasts.any(func(toast): return toast.get("kind", "") == "clock_out"):
				Sfx.play("message")
				push_toast(str(TranslationServer.translate("Today's work is done")),
					str(TranslationServer.translate("The next Ticket comes in on %s at %s. Clock out when you're ready.")) % [
						TranslationServer.translate(StoryClock.day_name(int(gate["time"]))), StoryClock.hhmm(int(gate["time"]))],
					"", "", { "sticky": true, "kind": "clock_out" })
		"wait":
			_notify()


## Lets the waiting time pass at once (tests, or a player who clicks through).
func skip_wait() -> void:
	if _clock_tween != null:
		_clock_tween.kill()
	gate["running"] = false
	_gate_timer.stop()
	if gate.get("step", "") == "wait":
		_notify()
	elif gate.get("step", "") == "clock_out":
		clock_override = int(gate["left"])
		_advance_gate()


## The waiting Ticket's first message comes up as a notification.
func _notify() -> void:
	if gate.get("step", "") != "wait":
		return
	if _clock_tween != null:
		_clock_tween.kill()
	_gate_timer.stop()
	clock_override = int(gate["time"])
	gate["step"] = "notify"
	gate["running"] = false
	Sfx.play("message")
	var from: String = gate["from"]
	if not MessengerLog.is_direct(gate["in"]):
		from = "%s · %s" % [from, gate["in"]]
	push_toast(from, gate["text"], "messenger", gate["in"], { "sticky": true, "gate": gate["id"] })
	gate_changed.emit()
	changed.emit()


## Opens the waiting Ticket's notification: Messenger follows the chat from its first
## message.
func open_gate() -> void:
	if gate.get("step", "") != "notify":
		return
	_opened[gate["id"]] = true
	var at := int(gate["time"])
	_release_gate()
	clock_override = at
	chat_pinned = ""
	open_app("messenger")
	_scheduled_for = int(messenger_log()["delivered"])
	_delivery_timer.start(0.4)


## Ends the day: what the day screen shows, from the last message to the next sign-in.
func clock_out() -> Dictionary:
	var day := { "left": int(gate.get("left", gate.get("since", 0))), "next": int(gate.get("time", 0)) - LOGIN_LEAD }
	_release_gate()
	return day


## Signing in on the lock screen starts the day that waits, if any.
func sign_in() -> void:
	var log := messenger_log()
	var waiting := MessengerLog.next_gate(log["entries"], log["delivered"])
	if not waiting.is_empty() and waiting["day"]:
		_signed_in_for[waiting["id"]] = true
	_release_gate()


func _release_gate() -> void:
	_gate_timer.stop()
	if _clock_tween != null:
		_clock_tween.kill()
		_clock_tween = null
	var had := not gate.is_empty()
	gate = {}
	clock_override = -1
	var before := toasts.size()
	toasts = toasts.filter(func(toast): return not toast.has("gate") and toast.get("kind", "") != "clock_out")
	if toasts.size() != before:
		toasts_changed.emit()
	if had:
		gate_changed.emit()
