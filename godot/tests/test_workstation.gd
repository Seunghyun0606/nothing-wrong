## Korean catalog coverage, reference pinning, and window behaviour.
extends "res://tests/ui_test_base.gd"

const Kit := preload("res://scripts/ui/kit.gd")


func _content_strings() -> Array:
	var strings: Array = []
	var add := func(value):
		if typeof(value) == TYPE_STRING and value != "" and not strings.has(value):
			strings.append(value)
	for scenario in GameSession.catalog.scenarios:
		var ticket: Dictionary = scenario["ticket"]
		for value in [ticket["title"], ticket["sender"]["role"], ticket["request"]] + ticket["scope"]:
			add.call(value)
		for requirement in ticket["requirements"]:
			add.call(requirement["description"])
		for attachment in ticket.get("attachments", []):
			add.call(attachment["name"])
			for line in attachment.get("content", []):
				add.call(line)
		for hint in ticket.get("hints", []):
			add.call(hint["text"])
		for bug in scenario["expectedBugs"]:
			for matcher in bug.get("reproductionActions", []):
				add.call(matcher["label"])
		var story: Variant = scenario.get("story", null)
		if story != null:
			for message in story["briefing"] + story["debrief"]:
				add.call(message["role"])
				add.call(message["text"])
			add.call(story["clue"]["title"])
			add.call(story["clue"]["text"])
			add.call(story.get("discovery", {}).get("hint"))
			for help in story.get("assist", []):
				add.call(help["text"])
			if story.has("deduction"):
				add.call(story["deduction"]["prompt"])
				add.call(story["deduction"].get("boardHint"))
				add.call(story["deduction"]["sentence"])
				add.call(story["deduction"]["success"])
				for key in story["deduction"]["blanks"]:
					for option in story["deduction"]["blanks"][key]["options"]:
						# Names, times, and code identifiers stay as they are.
						if not RegEx.create_from_string("[0-9/:.*-]").search(option):
							add.call(option)
	for document in GameSession.intranet.documents:
		add.call(document["title"])
		add.call(document["source"])
		for line in document["lines"]:
			add.call(line)
	for person in GameSession.directory.people:
		for key in ["title", "manager", "location"]:
			add.call(person.get(key))
		for fact in person["facts"]:
			add.call(fact["text"])
	for org in GameSession.directory.orgs:
		add.call(org["kind"])
		for note in org.get("notes", []):
			add.call(note["text"])
		for team in org["teams"]:
			add.call(team["name"])
			for note in team.get("notes", []):
				add.call(note["text"])
	for chapter in GameSession.catalog.chapters:
		add.call(chapter["title"])
		add.call(chapter["synopsis"])
		add.call(chapter.get("deadline", {}).get("label"))
		add.call(chapter.get("defaultEnding"))
		for ending in chapter.get("endings", []):
			add.call(ending["title"])
			for message in ending["epilogue"]:
				add.call(message["text"])
		add.call(chapter["synopsis"])
		for message in chapter["epilogue"]:
			add.call(message["text"])
	return strings


func test_every_story_and_ticket_string_has_korean() -> void:
	var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://i18n/ko.json"))
	var missing := _content_strings().filter(func(text): return not catalog.has(text))
	check(missing.is_empty(), "missing Korean for: %s" % str(missing.slice(0, 5)))


func test_korean_language_translates_ui_and_templates() -> void:
	Settings.persist = false
	Settings.set_language("ko")
	check_eq(Kit.t("Start test"), "테스트 시작", "plain string")
	check_eq(Kit.tf("Open %s in QA Notes", "T01"), "QA 노트에서 T01 열기", "template")
	check_eq(Kit.status_label("TESTING"), "테스트 중", "status")
	Settings.set_language("en")
	check_eq(Kit.t("Start test"), "Start test", "back to English")


func test_spec_links_pin_into_qa_notes_beside_the_browser() -> void:
	var desktop := _start()
	var placed := {}
	DesktopSession.layout_requested.connect(func(app, fraction): placed[app] = fraction)
	DesktopSession.open_url("https://shoply.local/product/everyday-pack")
	DesktopSession.open_url("https://docs.northstar.local/checkout-interaction-specification")
	check(WorkspaceSession.references_for("T01").has("ATT-T01-01"), "spec pinned to T01")
	check_eq(DesktopSession.location()["kind"], "shoply", "browser keeps the shop open")
	check(DesktopSession.is_visible_app("notes"), "notes opened")
	check_eq(placed.get("browser"), Rect2(0, 0, 0.75, 1), "browser on the left")
	check_eq(placed.get("notes"), Rect2(0.75, 0, 0.25, 1), "notes on the right")
	var references: Node = find_named(desktop, "References")
	check(references != null and references.find_child("ReferenceATT-T01-01", true, false) != null, "reference card shown")
	check(find_button(desktop, "Place beside Browser") != null, "re-arrange action")
	_finish()


func test_windows_resize_and_whole_title_bar_drags() -> void:
	var desktop := _start()
	DesktopSession.open_app("notes")
	var window: Control = desktop.windows["notes"]
	var before: Vector2 = window.size
	window.resize_by(Vector2i(1, 1), Vector2(120, 80))
	check_eq(window.size, before + Vector2(120, 80), "grows from the corner")
	window.resize_by(Vector2i(-1, 0), Vector2(5000, 0))
	check_eq(window.size.x, window.MIN_SIZE.x, "never narrower than the minimum")
	var blockers: Array = []
	var collect := func(node: Node, walk: Callable) -> void:
		for child in node.get_children():
			if child is Control and not (child is BaseButton) and (child as Control).mouse_filter != Control.MOUSE_FILTER_IGNORE:
				blockers.append(child.name)
			walk.call(child, walk)
	collect.call(window._title_bar, collect)
	check(blockers.is_empty(), "nothing on the title bar blocks dragging: %s" % str(blockers))
	_finish()


func test_delivered_chat_survives_story_changes() -> void:
	var before := [{ "id": "a" }, { "id": "b" }, { "id": "c" }]
	check_eq(DesktopSession._position_after(before, "b", 0), 2, "delivered up to b")
	var after := [{ "id": "a" }, { "id": "new" }, { "id": "b" }, { "id": "c" }]
	check_eq(DesktopSession._position_after(after, "b", 2), 3, "a message added earlier does not replay b")
	check_eq(DesktopSession._position_after(after, "gone", 2), 2, "older saves fall back to the count")


## Every open window, and everything in it, stays on the desktop at a small screen and
## after the game window shrinks.
func test_windows_fit_small_screens() -> void:
	var desktop := _start()
	tree.root.size = Vector2i(1280, 720)
	GameSession.start_ticket("T01")
	for app in ["messenger", "browser", "notes"]:
		DesktopSession.open_app(app)
		_check_on_screen(desktop, app)
	DesktopSession.open_url("https://shoply.local/product/everyday-pack")
	DesktopSession.arrange_for_testing()
	_check_on_screen(desktop, "browser")
	_check_on_screen(desktop, "notes")
	DesktopSession.open_url("https://docs.northstar.local/checkout-interaction-specification")
	_check_on_screen(desktop, "notes")
	DesktopSession.show_case_file()
	DesktopSession.arrange_side_by_side("browser", "notes")
	_check_on_screen(desktop, "notes")
	DesktopSession.open_app("messenger")
	tree.root.size = Vector2i(1024, 640)
	for app in ["messenger", "browser", "notes"]:
		_check_on_screen(desktop, app)
	tree.root.size = Vector2i(1440, 900)
	_finish()


func _check_on_screen(desktop: Control, app: String) -> void:
	var window: Control = desktop.windows[app]
	if not window.visible:
		return
	var layer := (window.get_parent() as Control).get_global_rect()
	var area := window.get_global_rect()
	check(layer.grow(0.5).encloses(area), "%s at %s fits the desktop %s" % [app, area, layer])
	var column: Control = window.get_children().filter(func(child): return child is VBoxContainer)[0]
	check(column.get_combined_minimum_size().x <= window.size.x + 0.5,
		"%s content needs %.0f px but the window is %.0f" % [app, column.get_combined_minimum_size().x, window.size.x])
