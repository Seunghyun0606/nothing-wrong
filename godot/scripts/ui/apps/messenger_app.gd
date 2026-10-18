## Team chat: story messages, links, ticket cards, reports, clues, and deduction replies.
## While a Ticket is under test, the composer is the report form for its sender.
extends VBoxContainer

const Kit := preload("res://scripts/ui/kit.gd")
const P := preload("res://scripts/ui/palette.gd")
const GameState := preload("res://scripts/domain/game_state.gd")
const Addresses := preload("res://scripts/domain/addresses.gd")
const Observations := preload("res://scripts/domain/observations.gd")
const ReportComposer := preload("res://scripts/ui/apps/report_composer.gd")
const DeductionForm := preload("res://scripts/ui/apps/deduction_form.gd")
const StoryClock := preload("res://scripts/domain/story_clock.gd")

var _scroll: ScrollContainer
var _log_box: VBoxContainer
var _composer: VBoxContainer
var _channel_name: Label
var _channel_members: Label
## Kept across renders so a half-written report survives new messages.
var _report_form: VBoxContainer
var _signature := ""
## Ids of the entries already in the chat. New messages are appended; the chat is only
## rebuilt when its history changes (a new language, a new game).
var _rendered_ids: Array = []
var _last_day := -1
var _typing: Label
## Keep the newest message in view until the player scrolls back.
var _follow := true


func _ready() -> void:
	name = "MessengerApp"
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 0)

	var channel := Kit.panel(P.SUBTLE, Color.TRANSPARENT, 0, 12)
	var channel_text := Kit.vbox(2)
	_channel_name = Kit.heading("", 16)
	_channel_name.name = "ChannelName"
	_channel_name.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	channel_text.add_child(_channel_name)
	_channel_members = Kit.label("", 13, P.MUTED)
	_channel_members.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	channel_text.add_child(_channel_members)
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
	DesktopSession.changed.connect(_render)
	Settings.language_changed.connect(func():
		_signature = ""
		_rendered_ids = ["<rebuild>"]
		_render())
	visibility_changed.connect(func():
		if is_visible_in_tree():
			_follow = true
			_scroll_to_end())
	_render()


func _render() -> void:
	var log := DesktopSession.messenger_log()
	var active := GameSession.active_ticket_id()
	var discovery_id: String = log["pendingDiscovery"]["documentId"] if log["pendingDiscovery"] != null else ""
	var signature := "%d|%d|%s|%s|%d|%s|%s" % [log["delivered"], log["entries"].size(), str(log["pendingDeduction"] != null), discovery_id,
		GameState.search_misses(GameSession.state, discovery_id), active, str(DesktopSession.report_requested)]
	if signature == _signature:
		return
	_signature = signature
	_follow = true
	_render_channel()
	var entries: Array = log["entries"]
	var delivered: int = log["delivered"]
	var ids: Array = entries.slice(0, delivered).map(func(entry): return entry["id"])
	if _rendered_ids.is_empty() or _rendered_ids.size() > ids.size() or ids.slice(0, _rendered_ids.size()) != _rendered_ids:
		Kit.clear(_log_box)
		_rendered_ids = []
		_last_day = -1
		_typing = null
	if _typing != null:
		_log_box.remove_child(_typing)
		_typing.queue_free()
		_typing = null
	if delivered == 0 and entries.is_empty() and _log_box.get_child_count() == 0:
		_log_box.add_child(Kit.label("No messages yet.", 14, P.MUTED))
	for index in range(_rendered_ids.size(), delivered):
		var entry: Dictionary = entries[index]
		# A divider whenever the story moves to another day.
		var today: int = int(entry.get("time", 0)) / 1440
		if today != _last_day:
			_last_day = today
			var divider := Kit.label("— %s —" % Kit.t(StoryClock.day_name(int(entry.get("time", 0)))), 12, P.MUTED, false)
			divider.name = "Day%d" % today
			divider.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			divider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_log_box.add_child(divider)
		_log_box.add_child(_entry(entry))
		_rendered_ids.append(entry["id"])
	if delivered < entries.size() and entries[delivered]["kind"] == "message":
		_typing = Kit.label(Kit.tf("%s is typing…", entries[delivered]["from"]), 13, P.MUTED)
		_log_box.add_child(_typing)

	if _report_form != null and _report_form.get_parent() == _composer:
		_composer.remove_child(_report_form)
	Kit.clear(_composer)
	var pending: Variant = log["pendingDeduction"]
	var discovery: Variant = log["pendingDiscovery"]
	if discovery != null and delivered >= entries.size():
		_composer.add_child(Kit.label("The team is waiting for what you find on the intranet.", 13, P.WARNING))
		var search := Kit.button(Kit.t("Open intranet search"), DesktopSession.open_url.bind("https://search.northstar.local"))
		search.name = "OpenSearch"
		search.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		_composer.add_child(search)
		# Search terms are the player's to find; after a few misses the team suggests one.
		var missed := GameState.search_misses(GameSession.state, discovery_id)
		var terms: Array = discovery.get("searchTerms", [])
		if missed >= 2 and not terms.is_empty():
			var row := Kit.hbox(6)
			row.name = "SearchHelp"
			row.add_child(Kit.label("Stuck? Try searching:", 13, P.MUTED, false))
			for term in terms.slice(0, 1 if missed < 4 else terms.size()):
				row.add_child(Kit.button("🔎 %s" % term, DesktopSession.search_intranet.bind(term)))
			_composer.add_child(row)
	elif pending != null and delivered >= entries.size() and GameState.on_board(pending):
		_composer.add_child(Kit.label(Kit.tf("%s is waiting for your answer. A wrong guess costs nothing.", pending["askedBy"]["from"]), 13, P.WARNING))
		var board := Kit.primary(Kit.t("Open Case File and connect the clues"), DesktopSession.show_case_file)
		board.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		_composer.add_child(board)
	elif pending != null and delivered >= entries.size():
		var reply := Kit.vbox(6)
		reply.name = "Reply"
		reply.add_child(Kit.label(Kit.tf("%s is waiting for your answer. A wrong guess costs nothing.", pending["askedBy"]["from"]), 13, P.WARNING))
		var form: VBoxContainer = DeductionForm.new()
		form.setup(pending)
		reply.add_child(form)
		_composer.add_child(reply)
	elif active != "":
		if _report_form == null or _report_form.ticket_id != active:
			_drop_report_form()
			_report_form = ReportComposer.new()
			_report_form.setup(GameSession.scenario(active))
		if DesktopSession.report_requested:
			DesktopSession.report_requested = false
			_report_form.expanded = true
		_composer.add_child(_report_form)
		_report_form.refresh()
	else:
		_composer.add_child(Kit.label("The team is typing…" if delivered < entries.size() else "No reply needed right now.", 13, P.MUTED))
	if _report_form != null and _report_form.get_parent() != _composer:
		_drop_report_form()
	_scroll_to_end.call_deferred()


## Each chapter has its own channel; its members are whoever speaks in it.
func _render_channel() -> void:
	var focus := GameSession.focus_ticket_id()
	var scenario: Variant = GameSession.scenario(focus) if focus != "" else GameSession.catalog.scenarios[-1]
	var chapter_id: String = scenario.get("story", {}).get("chapterId", "")
	var chapter: Variant = GameSession.catalog.get_chapter(chapter_id)
	_channel_name.text = str(chapter.get("channel", "# northstar-qa")) if chapter != null else "# northstar-qa"
	var members: Array = []
	for each in GameSession.catalog.scenarios:
		if each.get("story", {}).get("chapterId", "") != chapter_id:
			continue
		for message in each["story"]["briefing"] + each["story"]["debrief"]:
			if not members.has(message["from"]):
				members.append(message["from"])
	members.append(Kit.t("you"))
	_channel_members.text = ", ".join(members)


func _drop_report_form() -> void:
	if _report_form != null:
		_report_form.queue_free()
		_report_form = null


func _scroll_to_end() -> void:
	# Wait for wrapped messages to lay out before jumping to the newest one.
	for i in 2:
		await get_tree().process_frame
	if is_inside_tree():
		_scroll.scroll_vertical = int(_scroll.get_v_scroll_bar().max_value)


## When a message was sent, on the story's clock.
static func _time(entry: Dictionary, color: Color = P.MUTED) -> Label:
	var stamp := Kit.label(StoryClock.hhmm(int(entry.get("time", 0))), 12, color, false)
	stamp.name = "SentAt"
	stamp.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	return stamp


static func _you(entry: Dictionary) -> Control:
	var row := Kit.hbox(6)
	row.add_child(Kit.heading("You", 13, Color.WHITE))
	row.add_child(_time(entry, Color(1, 1, 1, 0.75)))
	return row


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
			author.add_child(_time(entry))
			column.add_child(author)
			var args: Array = entry.get("args", [])
			column.add_child(Kit.label(Kit.tf(entry["text"], args) if not args.is_empty() else entry["text"], 15))
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
			var open := Kit.button(Kit.tf("Open %s in QA Notes", entry["ticketId"]), DesktopSession.show_ticket.bind(entry["ticketId"]))
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
		"report":
			var card := Kit.panel(P.ACCENT, Color.TRANSPARENT, 10, 12)
			card.name = "Report"
			var body := Kit.vbox(2)
			body.add_child(_you(entry))
			if entry["noIssue"]:
				body.add_child(Kit.label(Kit.tf("%s: I checked every requirement and nothing breaks a rule. NO ISSUE FOUND.", entry["ticketId"]), 15, Color.WHITE))
			else:
				var noted := Observations.describe({ "label": entry["label"], "value": entry["value"] })
				body.add_child(Kit.label(Kit.tf("On %s, I noticed %s.", [entry["screen"], noted]), 15, Color.WHITE))
				body.add_child(Kit.label(Kit.tf("That breaks %s: %s", [entry["requirementId"], Kit.t(entry["requirement"])]), 14, Color(1, 1, 1, 0.85)))
				if str(entry.get("outcome", "BUG")) != "BUG":
					body.add_child(Kit.label(Kit.t(ReportComposer.OUTCOME_LABELS.get(entry["outcome"], entry["outcome"])), 13, Color(1, 1, 1, 0.85)))
			card.add_child(body)
			return Kit.margin(card, 80, 0, 0, 0)
		"player":
			var card := Kit.panel(P.ACCENT, Color.TRANSPARENT, 10, 12)
			var body := Kit.vbox(2)
			body.add_child(_you(entry))
			var said: String = DeductionForm.filled_text(entry["sentence"], entry["filled"]) if entry.has("sentence") else entry["text"]
			body.add_child(Kit.label(said, 15, Color.WHITE))
			if not entry.get("clues", []).is_empty():
				var clue_names: Array = entry["clues"].map(func(title): return Kit.t(title))
				body.add_child(Kit.label(Kit.tf("Clues: %s", ", ".join(clue_names)), 13, Color(1, 1, 1, 0.85)))
			card.add_child(body)
			return Kit.margin(card, 80, 0, 0, 0)
		"ending":
			# The release screen every ending closes on (canon: NW-FINAL).
			var card := Kit.panel(Color("#0f1720"), Color.TRANSPARENT, 10, 22)
			card.name = "EndingCard"
			var body := Kit.vbox(6)
			if str(entry.get("title", "")) != "":
				var title := Kit.kicker(Kit.t(entry["title"]), Color("#f7c948"))
				title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				body.add_child(title)
			for index in entry["lines"].size():
				var last: bool = index == entry["lines"].size() - 1
				var text := Kit.heading(entry["lines"][index], 30 if last else 15, Color.WHITE if last else Color("#cbd2d9"))
				text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				text.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
				body.add_child(text)
			card.add_child(body)
			return card
		_:
			var system := Kit.panel(P.SUCCESS_SOFT, P.SUCCESS, 14, 8)
			var text := Kit.heading(Kit.tf("%s complete.", Kit.t(entry["chapterTitle"])) if entry.has("chapterTitle") else entry["text"], 14, P.SUCCESS)
			text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			system.add_child(text)
			return system
