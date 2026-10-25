## Renders the main screens to PNG for visual review:
##   godot --path godot --script res://tests/screenshot_tour.gd -- <output-dir> [en|ko] [WIDTHxHEIGHT]
## Uses a throwaway session; the player's save is not touched.
extends SceneTree

const GameState := preload("res://scripts/domain/game_state.gd")

var out_dir := "user://screenshots"
var language := "en"
var screen := Vector2i(1440, 900)
var main: Control


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		out_dir = args[0]
	if args.size() > 1:
		language = args[1]
	if args.size() > 2 and args[2].contains("x"):
		screen = Vector2i(int(args[2].get_slice("x", 0)), int(args[2].get_slice("x", 1)))
	DirAccess.make_dir_recursive_absolute(out_dir)
	_tour.call_deferred()


func _shot(name: String) -> void:
	for i in 4:
		await process_frame
	var image := root.get_texture().get_image()
	image.save_png("%s/%s.png" % [out_dir, name])
	print("saved %s" % name)


func _button(node: Node, text: String) -> Button:
	for child in node.get_children():
		if child is Button and child.is_visible_in_tree() 				and (child.text.contains(text) or child.text.contains(str(TranslationServer.translate(text)))):
			return child
		var nested := _button(child, text)
		if nested:
			return nested
	return null


func _press(text: String) -> void:
	var button := _button(main, text)
	if button:
		button.pressed.emit()
	else:
		print("missing button: %s" % text)
	await process_frame


func _mark(target: String) -> void:
	var marker := main.find_child("Mark%s" % target, true, false) as Button
	if marker:
		marker.pressed.emit()
	else:
		print("missing marker: %s" % target)
	await process_frame


func _tour() -> void:
	root.size = screen
	DisplayServer.window_set_size(screen)
	# Autoload names are not compile-time identifiers inside a SceneTree script.
	var GameSession: Node = root.get_node("GameSession")
	var WorkspaceSession: Node = root.get_node("WorkspaceSession")
	var DesktopSession: Node = root.get_node("DesktopSession")
	var Settings: Node = root.get_node("Settings")
	Settings.persist = false
	Settings.set_language(language)
	GameSession.persist = false
	WorkspaceSession.persist = false
	GameSession.state = GameState.create_initial(GameSession.catalog.ticket_ids())
	WorkspaceSession.reset()
	DesktopSession.instant_messages = true
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await _shot("g0-title")
	main.show_lock()
	await _shot("g1-lock")
	main.show_desktop()
	await _shot("g2-desktop")
	DesktopSession.open_app("messenger")
	await _shot("g3-messenger")
	DesktopSession.show_ticket("T01")
	await process_frame
	await _shot("g4-notes-ticket")
	await _press("Start test")
	await _shot("g4b-notes-testing")
	DesktopSession.open_url("https://shoply.local")
	await _shot("g4a-storefront")
	await _press("shoply.local/product/everyday-pack")
	DesktopSession.open_url("https://docs.northstar.local/checkout-interaction-specification")
	await _shot("g4c-spec-side-by-side")
	await _press("Add to bag")
	await _press("View bag")
	await _shot("g5-cart")
	# A miss in the bag: noted, reported, and Mina replies.
	await _press("📌 Note")
	await _shot("g5a-noting")
	await _mark("cart_subtotal")
	DesktopSession.open_report()
	await process_frame
	await _press("Subtotal")
	await _press("T01-02")
	await _shot("g5b-report-form")
	await _press("Send report")
	await _shot("g5c-reply")
	DesktopSession.open_app("browser")
	await _press("Continue to checkout")
	await _shot("g6-checkout")
	(main.find_child("ConsoleButton", true, false) as Button).pressed.emit()
	await _shot("g6b-console")
	await _press("📌 Note")
	await _shot("g6c-noting")
	await _mark("checkout_confirmButton")
	DesktopSession.show_notes("T01")
	await _shot("g7-notes")
	DesktopSession.open_report()
	await process_frame
	await _press("Confirm order button")
	await _press("T01-02")
	await _press("Send report")
	await _shot("g10-chat-debrief")
	DesktopSession.search_intranet("release-bot")
	await process_frame
	await _shot("g11-search")
	DesktopSession.navigate({ "kind": "record", "id": "DOC-CHECKOUT-HISTORY" })
	await _shot("g12-record")
	DesktopSession.open_app("messenger")
	await _shot("g13-deduction")
	var form := main.find_child("DeductionForm", true, false)
	if form:
		form.fill("changed", "did change")
		form.fill("when", "18:40")
		form.fill("who", "release-bot")
		await _shot("g13b-deduction-filled")
		await _press("Mina Seo")
		await _shot("g13c-deduction-reply")

	# The photo views, with every Ticket open.
	for id in GameSession.state["tickets"]:
		GameSession.state["tickets"][id]["status"] = "RESOLVED"
	if not DesktopSession.windows["browser"].get("maximized", false):
		DesktopSession.toggle_maximize("browser")
	for view in ["photo-thumbnails", "cms-albums", "foundation-gallery", "opportunity-program", "archive-attachments"]:
		DesktopSession.open_url("https://qa.onehorizon.local/%s" % view)
		await _shot("p-%s" % view)
	DesktopSession.open_url("https://qa.onehorizon.local/photo-thumbnails")
	await process_frame
	var thumbnail := main.find_child("Photo_IMG001_Target", true, false) as Control
	if thumbnail:
		var click := InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = true
		thumbnail.gui_input.emit(click)
		await _shot("p-photo-thumbnails-zoom")
	DesktopSession.open_url("https://qa.onehorizon.local/foundation-gallery")
	DesktopSession.set_viewport("TABLET")
	await _shot("p-foundation-gallery-tablet")
	DesktopSession.set_viewport("DESKTOP")
	quit()
