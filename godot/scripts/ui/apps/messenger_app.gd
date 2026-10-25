## Team chat: story messages, links, ticket cards, reports, clues, and deduction replies.
## Each chapter talks in its own channel, and private moments come as direct messages;
## the list on the left grows as the story opens new conversations.
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
const MessengerLog := preload("res://scripts/domain/messenger_log.gd")
const Directory := preload("res://scripts/domain/directory.gd")

const LIST_WIDTH := 240
## Narrower than this, the conversation list folds into a picker above the chat.
const COMPACT_WIDTH := 640

var _scroll: ScrollContainer
var _chats_box: VBoxContainer
var _list: VBoxContainer
var _sidebar: Control
var _picker: OptionButton
var _picker_ids: Array = []
var _composer: VBoxContainer
var _channel_name: Label
var _channel_members: Label
## Kept across renders so a half-written report survives new messages.
var _report_form: VBoxContainer
var _signature := ""
## One chat log per conversation: { box, ids, day }. New messages are appended; a log is
## only rebuilt when its history changes (a new language, a new game).
var _chats := {}
var _shown := ""
var _typing: Label
## Keep the newest message in view until the player scrolls back.
var _follow := true
## The Tickets the chat has reached; senders they introduced link to the directory.
var _arrived: Array = []


func _ready() -> void:
	name = "MessengerApp"
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 0)

	var layout := Kit.hbox(0)
	layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(layout)
	_sidebar = Kit.panel(Color("#eef1f5"), Color.TRANSPARENT, 0, 0)
	_sidebar.custom_minimum_size = Vector2(LIST_WIDTH, 0)
	_list = Kit.vbox(2)
	_list.name = "Conversations"
	_sidebar.add_child(Kit.scroll(Kit.margin(_list, 8, 12, 8, 12)))
	layout.add_child(_sidebar)
	var column := Kit.vbox(0)
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 0)
	layout.add_child(column)

	var channel := Kit.panel(P.SUBTLE, Color.TRANSPARENT, 0, 12)
	var header := Kit.hbox(10)
	var channel_text := Kit.vbox(2)
	channel_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_channel_name = Kit.heading("", 16)
	_channel_name.name = "ChannelName"
	_channel_name.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	channel_text.add_child(_channel_name)
	_channel_members = Kit.label("", 13, P.MUTED)
	_channel_members.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	channel_text.add_child(_channel_members)
	header.add_child(channel_text)
	_picker = OptionButton.new()
	_picker.name = "ConversationPicker"
	_picker.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	_picker.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_picker.visible = false
	_picker.item_selected.connect(func(index): DesktopSession.show_chat(_picker_ids[index]))
	header.add_child(_picker)
	channel.add_child(header)
	column.add_child(channel)
	resized.connect(_fit)

	_chats_box = Kit.vbox(0)
	_chats_box.name = "TeamChat"
	_scroll = Kit.scroll(Kit.margin(_chats_box, 14, 14, 14, 14))
	_scroll.get_v_scroll_bar().changed.connect(func():
		if _follow:
			_scroll.scroll_vertical = int(_scroll.get_v_scroll_bar().max_value))
	_scroll.scroll_started.connect(func(): _follow = false)
	column.add_child(_scroll)

	var composer_panel := Kit.panel(P.SUBTLE, Color.TRANSPARENT, 0, 12)
	_composer = Kit.vbox(6)
	composer_panel.add_child(_composer)
	column.add_child(composer_panel)

	GameSession.changed.connect(_render)
	DesktopSession.changed.connect(_render)
	Settings.language_changed.connect(func():
		_signature = ""
		for conversation in _chats:
			_chats[conversation]["ids"] = ["<rebuild>"]
		_render())
	visibility_changed.connect(func():
		if is_visible_in_tree():
			_follow = true
			_scroll_to_end())
	_render()


func _render() -> void:
	var log := DesktopSession.messenger_log()
	var active := GameSession.active_ticket_id()
	var current := DesktopSession.current_chat(log)
	var discovery_id: String = log["pendingDiscovery"]["documentId"] if log["pendingDiscovery"] != null else ""
	var signature := "%d|%d|%s|%s|%d|%s|%s|%s|%s|%s" % [log["delivered"], log["entries"].size(), str(log["pendingDeduction"] != null), discovery_id,
		GameState.search_misses(GameSession.state, discovery_id), active, str(DesktopSession.report_requested), current, str(log["unreadIn"]),
		str(DesktopSession.gate.get("step", ""))]
	if signature == _signature:
		return
	_signature = signature
	_arrived = log["arrived"]
	_render_list(log, current)
	_render_channel(log, current)
	_render_chats(log, current)
	_render_composer(log, current, active)
	if _follow:
		_scroll_to_end.call_deferred()


func _fit() -> void:
	# Before the first layout the width is still 0; keep the list until it is known.
	var compact := size.x > 0 and size.x < COMPACT_WIDTH
	_sidebar.visible = not compact
	_picker.visible = compact and _picker.item_count > 1


## Every conversation the story has opened, newest first; channels, then direct messages.
## A narrow window lists them in the picker instead.
func _render_list(log: Dictionary, current: String) -> void:
	_picker.clear()
	_picker_ids = []
	for conversation in log["conversations"]:
		var unread := int(log["unreadIn"].get(conversation, 0))
		_picker.add_item(MessengerLog.conversation_name(conversation) + ("  (%d)" % unread if unread > 0 else ""))
		_picker_ids.append(conversation)
		if conversation == current:
			_picker.select(_picker.item_count - 1)
	_fit()
	Kit.clear(_list)
	for direct in [false, true]:
		var conversations: Array = log["conversations"].filter(func(each): return MessengerLog.is_direct(each) == direct)
		if conversations.is_empty():
			continue
		var kicker := Kit.kicker("Direct messages" if direct else "Channels", P.MUTED)
		_list.add_child(Kit.margin(kicker, 6, 8 if direct else 0, 0, 4))
		conversations.reverse()
		for conversation in conversations:
			_list.add_child(_conversation_button(conversation, conversation == current, int(log["unreadIn"].get(conversation, 0))))


func _conversation_button(conversation: String, selected: bool, unread: int) -> Control:
	var row := Kit.panel(P.ACCENT_SOFT if selected else Color.TRANSPARENT, Color.TRANSPARENT, 6, 0)
	var line := Kit.hbox(6)
	var title := MessengerLog.conversation_name(conversation)
	var button := Kit.button(title, DesktopSession.show_chat.bind(conversation), "FlatLink")
	button.name = "Chat%d" % _list.get_child_count()
	button.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.clip_text = true
	button.tooltip_text = title
	button.add_theme_color_override("font_color", P.ACCENT if selected else P.TEXT)
	if selected or unread > 0:
		button.add_theme_font_override("font", Kit.bold_font())
	if MessengerLog.is_direct(conversation):
		line.add_child(Kit.avatar(Kit.initials(title), 22))
	line.add_child(button)
	if unread > 0:
		var badge := Kit.panel(P.DANGER, Color.TRANSPARENT, 9, 0)
		badge.name = "Unread"
		var count := Kit.label(str(unread), 11, Color.WHITE, false)
		count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		count.custom_minimum_size = Vector2(20, 0)
		badge.add_child(count)
		badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		line.add_child(badge)
	row.add_child(Kit.margin(line, 6, 2, 6, 2))
	return row


## Each conversation keeps its own log; only the one on screen is shown.
func _render_chats(log: Dictionary, current: String) -> void:
	var entries: Array = log["entries"]
	var delivered: int = log["delivered"]
	var by_conversation := {}
	for index in delivered:
		var conversation: String = entries[index]["in"]
		if not by_conversation.has(conversation):
			by_conversation[conversation] = []
		by_conversation[conversation].append(entries[index])
	if _typing != null:
		_typing.get_parent().remove_child(_typing)
		_typing.queue_free()
		_typing = null
	for conversation in _chats.keys():
		if not by_conversation.has(conversation):
			_chats_box.remove_child(_chats[conversation]["box"])
			_chats[conversation]["box"].queue_free()
			_chats.erase(conversation)
	for conversation in by_conversation:
		var chat: Dictionary = _chat(conversation)
		var shown: Array = by_conversation[conversation]
		var ids: Array = shown.map(func(entry): return entry["id"])
		if chat["ids"].size() > ids.size() or ids.slice(0, chat["ids"].size()) != chat["ids"]:
			Kit.clear(chat["box"])
			chat["ids"] = []
			chat["day"] = -1
		for index in range(chat["ids"].size(), shown.size()):
			var entry: Dictionary = shown[index]
			# A divider whenever the story moves to another day.
			var today: int = int(entry.get("time", 0)) / 1440
			if today != chat["day"]:
				chat["day"] = today
				var divider := Kit.label("— %s —" % Kit.t(StoryClock.day_name(int(entry.get("time", 0)))), 12, P.MUTED, false)
				divider.name = "Day%d" % today
				divider.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				divider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				chat["box"].add_child(divider)
			chat["box"].add_child(_entry(entry))
			if conversation == current:
				_follow = true
			chat["ids"].append(entry["id"])
	for conversation in _chats:
		_chats[conversation]["box"].visible = conversation == current
	if current != _shown:
		_shown = current
		_follow = true
	var empty := _chats_box.get_node_or_null("NoMessages")
	if by_conversation.is_empty() and empty == null:
		empty = Kit.label("No messages yet.", 14, P.MUTED)
		empty.name = "NoMessages"
		_chats_box.add_child(empty)
	elif not by_conversation.is_empty() and empty != null:
		_chats_box.remove_child(empty)
		empty.queue_free()
	# A Ticket that waits for the player is not being typed yet.
	if delivered < entries.size() and DesktopSession.gate.is_empty() and entries[delivered]["kind"] == "message" and entries[delivered]["in"] == current and _chats.has(current):
		_typing = Kit.label(Kit.tf("%s is typing…", entries[delivered]["from"]), 13, P.MUTED)
		_chats[current]["box"].add_child(_typing)


func _chat(conversation: String) -> Dictionary:
	if not _chats.has(conversation):
		var box := Kit.vbox(14)
		box.name = "Chat_%d" % _chats.size()
		_chats_box.add_child(box)
		_chats[conversation] = { "box": box, "ids": [], "day": -1 }
	return _chats[conversation]


## The composer answers in the conversation where the team is waiting; elsewhere it
## points there.
func _render_composer(log: Dictionary, current: String, active: String) -> void:
	var entries: Array = log["entries"]
	var delivered: int = log["delivered"]
	if _report_form != null and _report_form.get_parent() == _composer:
		_composer.remove_child(_report_form)
	Kit.clear(_composer)
	var pending: Variant = log["pendingDeduction"]
	var discovery: Variant = log["pendingDiscovery"]
	var discovery_id: String = discovery["documentId"] if discovery != null else ""
	var waiting_in: String = log["pendingIn"]
	if waiting_in == "" and active != "":
		waiting_in = MessengerLog.conversation_of(GameSession.catalog, GameSession.scenario(active))
	if waiting_in != "" and waiting_in != current and (discovery != null or pending != null or active != ""):
		var row := Kit.hbox(8)
		row.add_child(Kit.label(Kit.tf("The team is waiting for you in %s.", MessengerLog.conversation_name(waiting_in)), 13, P.WARNING))
		var go := Kit.button(Kit.tf("Go to %s", MessengerLog.conversation_name(waiting_in)), DesktopSession.show_chat.bind(waiting_in))
		go.name = "GoToChat"
		go.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		row.add_child(go)
		_composer.add_child(row)
	elif discovery != null and delivered >= entries.size():
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
		_composer.add_child(Kit.label(_waiting_line(pending), 13, P.WARNING))
		var board := Kit.primary(Kit.t("Open Case File and connect the clues"), DesktopSession.show_case_file)
		board.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		_composer.add_child(board)
	elif pending != null and delivered >= entries.size():
		var reply := Kit.vbox(6)
		reply.name = "Reply"
		reply.add_child(Kit.label(_waiting_line(pending), 13, P.WARNING))
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
		var typing := delivered < entries.size() and DesktopSession.gate.is_empty()
		_composer.add_child(Kit.label("The team is typing…" if typing else "No reply needed right now.", 13, P.MUTED))
	if _report_form != null and _report_form.get_parent() != _composer and (active == "" or _report_form.ticket_id != active):
		_drop_report_form()


## A channel's members are whoever has spoken in it so far; a direct message is one person.
func _render_channel(log: Dictionary, current: String) -> void:
	if current == "":
		_channel_name.text = MessengerLog.conversation_of(GameSession.catalog, GameSession.catalog.scenarios[0])
		_channel_members.text = ""
		return
	_channel_name.text = MessengerLog.conversation_name(current)
	var members: Array = []
	var role := ""
	for index in int(log["delivered"]):
		var entry: Dictionary = log["entries"][index]
		if entry["in"] == current and entry["kind"] == "message":
			if not members.has(entry["from"]):
				members.append(entry["from"])
			role = entry["role"]
	if MessengerLog.is_direct(current):
		_channel_members.text = Kit.tf("Direct message · %s", Kit.t(role))
		return
	members.append(Kit.t("you"))
	_channel_members.text = ", ".join(members)


## The kept report form is not in the tree while another conversation is on screen.
func _exit_tree() -> void:
	if _report_form != null and _report_form.get_parent() == null:
		_report_form.free()


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


## A sender's name; someone in the directory opens their page there.
func _author(name: String) -> Control:
	var id := Directory.id_of(name)
	if GameSession.directory.find(id, _arrived) == null:
		var plain := Kit.heading(name, 14)
		plain.autowrap_mode = TextServer.AUTOWRAP_OFF
		plain.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		return plain
	var link := Kit.button(name, DesktopSession.show_person.bind(id), "FlatLink")
	link.name = "Author"
	link.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	link.tooltip_text = Kit.t("Open in Directory")
	link.add_theme_font_override("font", Kit.bold_font())
	link.add_theme_font_size_override("font_size", 14)
	link.add_theme_color_override("font_color", P.TEXT)
	link.add_theme_color_override("font_hover_color", P.ACCENT)
	link.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	return link


func _entry(entry: Dictionary) -> Control:
	match entry["kind"]:
		"message":
			var row := Kit.hbox(10)
			row.add_child(Kit.avatar(Kit.initials(entry["from"]), 34))
			var column := Kit.vbox(3)
			column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var author := Kit.hbox(6)
			author.add_child(_author(entry["from"]))
			author.add_child(Kit.label("· %s" % Kit.t(entry["role"]), 13, P.MUTED, false))
			author.add_child(_time(entry))
			column.add_child(author)
			var args: Array = entry.get("args", [])
			var said := Kit.rich(Kit.tf(entry["text"], args) if not args.is_empty() else Kit.t(entry["text"]), 15)
			said.name = "Said"
			column.add_child(said)
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
			body.add_child(Kit.rich(Kit.t(entry["text"]), 14, P.TEXT))
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
			var args: Array = entry.get("args", [])
			var said: String = DeductionForm.filled_text(entry["sentence"], entry["filled"]) if entry.has("sentence") \
				else (Kit.tf(entry["text"], args) if not args.is_empty() else Kit.t(entry["text"]))
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


## A wrong conclusion can be answered again but costs story time (MessengerLog.PENALTY);
## the final decision has no wrong answer.
static func _waiting_line(pending: Dictionary) -> String:
	if pending.get("mode", "") == "choice":
		return Kit.tf("%s is waiting for your decision.", pending["askedBy"]["from"])
	return Kit.tf("%s is waiting for your answer. You can answer again, but a wrong guess costs %d minutes.", [pending["askedBy"]["from"], MessengerLog.PENALTY])
