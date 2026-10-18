## Team chat: story messages, links, ticket cards, clues, and deduction replies.
extends VBoxContainer

const Kit := preload("res://scripts/ui/kit.gd")
const P := preload("res://scripts/ui/palette.gd")
const GameState := preload("res://scripts/domain/game_state.gd")
const Addresses := preload("res://scripts/domain/addresses.gd")

var _scroll: ScrollContainer
var _log_box: VBoxContainer
var _composer: VBoxContainer
var _signature := ""
## Keep the newest message in view until the player scrolls back.
var _follow := true


func _ready() -> void:
	name = "MessengerApp"
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 0)

	var channel := Kit.panel(P.SUBTLE, Color.TRANSPARENT, 0, 12)
	var channel_text := Kit.vbox(2)
	channel_text.add_child(Kit.heading("# shoply-autumn-release", 16))
	channel_text.add_child(Kit.label("Maya Kim, Daniel Reyes, Priya Nair, Sam Ortiz, you", 13, P.MUTED))
	channel.add_child(channel_text)
	add_child(channel)

	_log_box = Kit.vbox(14)
	_log_box.name = "TeamChat"
	_scroll = Kit.scroll(Kit.margin(_log_box, 14, 14, 14, 14))
	_scroll.get_v_scroll_bar().changed.connect(func():
		if _follow:
			_scroll.scroll_vertical = int(_scroll.get_v_scroll_bar().max_value))
	_scroll.scroll_started.connect(func(): _follow = false)
	add_child(_scroll)

	var composer_panel := Kit.panel(P.SUBTLE, Color.TRANSPARENT, 0, 12)
	_composer = Kit.vbox(6)
	composer_panel.add_child(_composer)
	add_child(composer_panel)

	GameSession.changed.connect(_render)
	Settings.language_changed.connect(func():
		_signature = ""
		_render())
	visibility_changed.connect(func():
		if is_visible_in_tree():
			_follow = true
			_scroll_to_end())
	_render()


func _render() -> void:
	var log := DesktopSession.messenger_log()
	var signature := "%d|%d|%s|%s|%d" % [log["delivered"], log["entries"].size(), str(log["pendingDeduction"] != null), str(log["pendingDiscovery"] != null),
		GameState.lead_terms(GameSession.state).size()]
	if signature == _signature:
		return
	_signature = signature
	_follow = true
	Kit.clear(_log_box)
	var entries: Array = log["entries"]
	var delivered: int = log["delivered"]
	if delivered == 0 and entries.is_empty():
		_log_box.add_child(Kit.label("No messages yet.", 14, P.MUTED))
	for index in delivered:
		_log_box.add_child(_entry(entries[index]))
	if delivered < entries.size() and entries[delivered]["kind"] == "message":
		_log_box.add_child(Kit.label(Kit.tf("%s is typing…", entries[delivered]["from"]), 13, P.MUTED))

	Kit.clear(_composer)
	var pending: Variant = log["pendingDeduction"]
	var discovery: Variant = log["pendingDiscovery"]
	if discovery != null and delivered >= entries.size():
		_composer.add_child(Kit.label("The team is waiting for what you find on the intranet.", 13, P.WARNING))
		var row := Kit.hbox(6)
		row.name = "LeadSearch"
		for term in GameState.lead_terms(GameSession.state).slice(-3):
			row.add_child(Kit.button("🔎 %s" % term, DesktopSession.search_intranet.bind(term)))
		var search := Kit.button(Kit.t("Open intranet search"), DesktopSession.open_url.bind("https://search.nothingwrong.local"))
		row.add_child(search)
		_composer.add_child(row)
	elif pending != null and delivered >= entries.size() and pending.get("mode", "") == "board":
		_composer.add_child(Kit.label(Kit.tf("%s is waiting for your answer. A wrong guess costs nothing.", pending["askedBy"]["from"]), 13, P.WARNING))
		var board := Kit.primary(Kit.t("Open Case File and connect the clues"), func():
			DesktopSession.tracker_view = "casefile"
			DesktopSession.open_app("tracker"))
		board.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		_composer.add_child(board)
	elif pending != null and delivered >= entries.size():
		var reply := Kit.vbox(6)
		reply.name = "Reply"
		reply.add_child(Kit.label(Kit.tf("%s is waiting for your answer. A wrong guess costs nothing.", pending["askedBy"]["from"]), 13, P.WARNING))
		var attempts: Array = GameSession.state["story"]["deductions"].get(pending["id"], {}).get("attempts", [])
		for option in pending["options"]:
			if attempts.has(option["id"]):
				continue
			var button := Kit.button(option["text"], GameSession.answer_deduction.bind(pending, option["id"]), "ChoiceButton")
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			# A known wrap width keeps the reply from measuring one word per line.
			button.custom_minimum_size = Vector2(400, 0)
			reply.add_child(button)
		_composer.add_child(reply)
	else:
		_composer.add_child(Kit.label("The team is typing…" if delivered < entries.size() else "No reply needed right now.", 13, P.MUTED))
	_scroll_to_end.call_deferred()


func _scroll_to_end() -> void:
	# Wait for wrapped messages to lay out before jumping to the newest one.
	for i in 2:
		await get_tree().process_frame
	if is_inside_tree():
		_scroll.scroll_vertical = int(_scroll.get_v_scroll_bar().max_value)


func _entry(entry: Dictionary) -> Control:
	match entry["kind"]:
		"message":
			var row := Kit.hbox(10)
			row.add_child(Kit.avatar(Kit.initials(entry["from"]), 34))
			var column := Kit.vbox(3)
			column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var author := Kit.hbox(6)
			var from := Kit.heading(entry["from"], 14)
			from.autowrap_mode = TextServer.AUTOWRAP_OFF
			from.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			author.add_child(from)
			author.add_child(Kit.label("· %s" % Kit.t(entry["role"]), 13, P.MUTED, false))
			column.add_child(author)
			column.add_child(Kit.label(entry["text"], 15))
			for link in entry.get("links", []):
				var url: String = link["url"]
				var button := Kit.button("🔗 %s" % Kit.t(link["label"]), DesktopSession.open_url.bind(url))
				button.tooltip_text = Addresses.display(url)
				button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
				column.add_child(button)
			row.add_child(column)
			return row
		"ticket":
			var card := Kit.panel(P.ACCENT_SOFT, P.BORDER_STRONG, 8, 12)
			var body := Kit.vbox(6)
			body.add_child(Kit.kicker(Kit.tf("Ticket assigned · %s", entry["ticketId"])))
			body.add_child(Kit.heading(entry["title"], 15))
			var open := Kit.button(Kit.tf("Open %s in QA Tracker", entry["ticketId"]), DesktopSession.show_ticket.bind(entry["ticketId"], "detail"))
			open.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			body.add_child(open)
			card.add_child(body)
			return Kit.margin(card, 44, 0, 0, 0)
		"found":
			var document: Variant = GameSession.intranet.get_document(entry["documentId"])
			var card := Kit.panel(P.SUCCESS_SOFT, P.SUCCESS, 8, 12)
			var body := Kit.vbox(4)
			body.add_child(Kit.kicker("You found a record", P.SUCCESS))
			body.add_child(Kit.heading(Kit.t(document["title"]) if document != null else entry["documentId"], 15))
			card.add_child(body)
			return Kit.margin(card, 80, 0, 0, 0)
		"clue":
			var card := Kit.panel(P.WARNING_SOFT, Color("#e6d27a"), 8, 12)
			var body := Kit.vbox(4)
			body.add_child(Kit.kicker("New clue · Case File", P.WARNING))
			body.add_child(Kit.heading(entry["title"], 15))
			body.add_child(Kit.label(entry["text"], 14, P.TEXT))
			card.add_child(body)
			return Kit.margin(card, 44, 0, 0, 0)
		"player":
			var card := Kit.panel(P.ACCENT, Color.TRANSPARENT, 10, 12)
			var body := Kit.vbox(2)
			body.add_child(Kit.heading("You", 13, Color.WHITE))
			body.add_child(Kit.label(entry["text"], 15, Color.WHITE))
			if entry.has("clues"):
				var clue_names: Array = entry["clues"].map(func(title): return Kit.t(title))
				body.add_child(Kit.label(Kit.tf("Clues: %s", ", ".join(clue_names)), 13, Color(1, 1, 1, 0.85)))
			card.add_child(body)
			return Kit.margin(card, 80, 0, 0, 0)
		_:
			var system := Kit.panel(P.SUCCESS_SOFT, P.SUCCESS, 14, 8)
			var text := Kit.heading(Kit.tf("%s complete.", Kit.t(entry["chapterTitle"])) if entry.has("chapterTitle") else entry["text"], 14, P.SUCCESS)
			text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			system.add_child(text)
			return system
