## Korean catalog coverage, reference pinning, and window behaviour.
extends "res://tests/ui_test_base.gd"

const Kit := preload("res://scripts/ui/kit.gd")
const RecordView := preload("res://scripts/ui/horizon/record_view.gd")
const HorizonData := preload("res://scripts/domain/horizon_data.gd")


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
	# A full row of tabs with long titles still fits.
	for view in ["photo-thumbnails", "foundation-gallery", "opportunity-program", "archive-attachments", "release-validation", "identity-matching"]:
		DesktopSession.open_tab(Addresses.parse("https://qa.onehorizon.local/%s" % view))
	check_eq(DesktopSession.tabs.size(), DesktopSession.MAX_TABS, "every tab is open")
	_check_on_screen(desktop, "browser")
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


## Starting a Ticket on its own starting screen counts as a visit; a page left open from
## the previous Ticket does not (T05 would otherwise pass NO ISSUE FOUND on T04's page).
func test_a_ticket_start_counts_only_its_own_screen() -> void:
	_start()
	for id in ["T01", "T02", "T03", "T04"]:
		GameSession.state["tickets"][id]["status"] = "RESOLVED"
	var start: String = GameSession.scenario("T05")["ticket"]["startingContext"]["currentPath"]
	DesktopSession.open_url("https://shoply.local/cart")
	check(DesktopSession.location()["path"] != start, "T04's page is still open")
	GameSession.start_ticket("T05")
	check(WorkspaceSession.interactions_for("T05").is_empty(), "the old page is not a T05 visit")
	GameSession.state["tickets"]["T05"]["status"] = "NEW"
	GameSession.state["currentTicketId"] = null
	GameSession.changed.emit()
	DesktopSession.open_url(Addresses.path_url(start))
	GameSession.start_ticket("T05")
	check(WorkspaceSession.interactions_for("T05").any(func(action): return action.get("target", "") == start), "its own screen is")
	_finish()


## The title, lock screen, and desktop draw their pictures (DEC-017), and the window has
## the game's icon.
func test_screens_show_their_art() -> void:
	for art in ["title", "lock", "wallpaper"]:
		var backdrop := Kit.backdrop(art, Color.BLACK)
		check(backdrop is TextureRect and (backdrop as TextureRect).texture != null, "%s picture" % art)
		backdrop.free()
	check(Kit.backdrop("missing", Color.BLACK) is ColorRect, "a missing picture falls back to a colour")
	check(ResourceLoader.exists(str(ProjectSettings.get_setting("application/config/icon"))), "the icon exists")
	var desktop := _start()
	check(desktop.find_child("Backdrop", false, false) is TextureRect, "the desktop has its wallpaper")
	_finish()


## A tab keeps its last MAX_HISTORY pages (CX-08b found history growing without end).
func test_browser_history_is_capped() -> void:
	_start()
	for index in DesktopSession.MAX_HISTORY + 30:
		DesktopSession.navigate(Addresses.shoply("/shoply/product/%d" % index))
	check_eq(DesktopSession._tab()["history"].size(), DesktopSession.MAX_HISTORY, "history stays capped")
	check_eq(DesktopSession.location()["path"], "/shoply/product/%d" % (DesktopSession.MAX_HISTORY + 29), "on the newest page")
	DesktopSession.go_back()
	check_eq(DesktopSession.location()["path"], "/shoply/product/%d" % (DesktopSession.MAX_HISTORY + 28), "Back still works")
	_finish()


## The directory shows first-week badge photos with their year (DEC-018), the story says
## so before a photo tags Grace, and Shoply's products have photos.
func test_directory_badge_photos_and_product_photos() -> void:
	for person in GameSession.directory.people:
		if person.has("photo"):
			check(Kit.picture("people/%s" % person["photo"]["asset"]) != null, "%s has a badge photo" % person["id"])
			check(str(person["photo"]["taken"]).is_valid_int(), "%s's photo has a year" % person["id"])
	for product in ShoplyStore.products:
		check(Kit.picture("products/%s" % product["id"]) != null, "%s has a photo" % product["id"])
	var said := func(ticket: String, words: String) -> bool:
		var story: Dictionary = GameSession.scenario(ticket)["story"]
		return (story["briefing"] + story["debrief"]).any(func(message): return message["text"].contains(words))
	check(said.call("T13", "badge photos from everyone's first week"), "T13 says what the directory photos are")
	check(said.call("T24", "badge photo from 2008"), "T24 says Grace's photo is old")
	var desktop := _start()
	DesktopSession.open_app("messenger")
	DesktopSession.navigate(Addresses.people("mina-seo"))
	var page: Node = find_named(desktop, "PersonPage")
	check(page != null and find_named(page, "BadgePhoto") != null, "Mina's page shows her badge photo")
	var texts: Array = page.find_children("*", "Label", true, false).map(func(label): return label.text) if page else []
	check(texts.has("Badge photo · 2016"), "with the year it was taken")
	_finish()


## Every photo a record view names is there, and each defect is drawn from the one source
## image: the thumbnail cut (T14), the tablet layout (T32), and the rotated preview (T38).
func test_record_views_draw_their_photos() -> void:
	var assets: Array = []
	var rows := {}
	for view in GameSession.horizon.views:
		if view.has("photo"):
			assets.append(view["photo"]["asset"])
		for row in view["rows"]:
			if row.has("photo"):
				assets.append(row["photo"]["asset"])
				rows["%s/%s" % [view["id"], row["key"]]] = row
				check(row["photo"].get("notes", "") in view["columns"].map(func(column): return column["id"]),
					"a Note on %s records one of its columns" % row["key"])
	for asset in ["IMG001", "IMG002", "IMG003", "IMG004", "IMG005", "IMG006", "IMG007"]:
		check(assets.has(asset), "%s is shown" % asset)
	for asset in assets:
		check(RecordView.photo_texture({ "asset": asset }) != null, "%s is in assets/photos" % asset)
	var drawn := func(key: String, side: String, viewport: String) -> Texture2D:
		return RecordView.photo_texture(HorizonData.photo_on(rows[key], side, viewport))
	var original: Texture2D = drawn.call("photo-thumbnails/IMG001", "source", "DESKTOP")
	var thumbnail: Texture2D = drawn.call("photo-thumbnails/IMG001", "target", "DESKTOP")
	check(thumbnail.get_width() < original.get_width() and thumbnail.get_height() == original.get_height(), "the thumbnail cuts the right edge")
	var gala: Texture2D = drawn.call("foundation-gallery/IMG003", "", "DESKTOP")
	var gala_tablet: Texture2D = drawn.call("foundation-gallery/IMG003", "", "TABLET")
	check(gala_tablet.get_width() * 2 < gala.get_width(), "the tablet hides most of the gala photo")
	var preview: Texture2D = drawn.call("archive-attachments/ATT-1012-02", "", "DESKTOP")
	var upright := RecordView.photo_texture({ "asset": "IMG007" })
	check_eq(Vector2i(preview.get_width(), preview.get_height()), Vector2i(upright.get_height(), upright.get_width()), "the preview is turned")


## A Korean conclusion reads as a sentence whichever option fills a blank: no 을(를)-style
## fallback, and no particle that depends on the word before it right after a blank.
func test_korean_conclusions_read_with_every_option() -> void:
	var ko: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(Settings.KO_PATH))
	var after_blank := RegEx.create_from_string("\\{\\w+\\}(을|를|이|가|은|는|과|와|으로|로|였|라는|\\()")
	var fallback := RegEx.create_from_string("\\((을|를|이|가|은|는|과|와|으)\\)")
	var checked := 0
	for scenario in GameSession.catalog.scenarios:
		var story: Variant = scenario.get("story", null)
		if story == null or not story.has("deduction"):
			continue
		var sentence: String = ko.get(story["deduction"]["sentence"], "")
		check(sentence != "", "%s has Korean" % story["deduction"]["id"])
		var found := after_blank.search(sentence)
		check(found == null, "%s: %s" % [story["deduction"]["id"], found.get_string() if found else ""])
		for blank in story["deduction"]["blanks"].values():
			for option in blank["options"]:
				check(fallback.search(str(ko.get(option, option))) == null, "%s option %s" % [story["deduction"]["id"], option])
		checked += 1
	check_eq(checked, 19, "every conclusion")


## Each key term reads the same in every Korean line: no English left in, no second wording.
func test_key_terms_have_one_korean_wording() -> void:
	var ko: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(Settings.KO_PATH))
	var others := {
		"티켓": ["Ticket"],
		"보고": ["리포트"],
		"QA 노트": ["QA노트", "QA 트래커", "QA Tracker"],
		"사건 파일": ["케이스 파일", "사건파일", "Case File"],
		"조직도": ["디렉터리", "디렉토리"],
		"추리": ["추론"],
		# The 📌 Note action is 메모; 기록 is kept for the records the story turns up.
		"📌 메모": ["📌 기록"],
		"메모하": ["기록하고 보고", "기록한 뒤 보고"],
	}
	for source in ko:
		for canonical in others:
			for other in others[canonical]:
				check(not str(ko[source]).contains(other), "%s says %s, not %s: %s" % [source.left(50), other, canonical, ko[source]])
