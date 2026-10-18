## Renders the main screens to PNG for visual review:
##   godot --path godot --script res://tests/screenshot_tour.gd -- <output-dir>
## Uses a throwaway session; the player's save is not touched.
extends SceneTree

const GameState := preload("res://scripts/domain/game_state.gd")

var out_dir := "user://screenshots"
var language := "en"
var main: Control


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if not args.is_empty():
		out_dir = args[0]
	if args.size() > 1:
		language = args[1]
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


func _tour() -> void:
	root.size = Vector2i(1440, 900)
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
	root.get_node("DesktopSession").show_ticket("T01")
	await process_frame
	await _shot("g4-tracker")
	await _press("Start test")
	await _shot("g4b-tracker-testing")
	DesktopSession.open_url("https://shoply.local")
	await _shot("g4a-storefront")
	await _press("shoply.local/product/everyday-pack")
	DesktopSession.open_url("https://docs.nothingwrong.local/checkout-interaction-specification")
	await _shot("g4c-spec-side-by-side")
	await _press("Add to bag")
	await _press("View bag")
	await _shot("g5-cart")
	await _press("Continue to checkout")
	await _shot("g6-checkout")
	(main.find_child("ConsoleButton", true, false) as Button).pressed.emit()
	await _shot("g6b-console")
	await _press("🚩 Flag")
	await _press("Confirm order button: Secondary action style")
	await _press("T01-02")
	await _shot("g8-flag")
	await _press("Send flag")
	await _shot("g9-flag-accepted")
	DesktopSession.open_app("notes")
	await _shot("g7-notes")
	await _press("The team replied · Open Messenger")
	DesktopSession.open_app("messenger")
	await _shot("g10-chat-debrief")
	await _press("🔎 release-bot")
	await _shot("g11-search")
	DesktopSession.navigate({ "kind": "record", "id": "DOC-CHECKOUT-HISTORY" })
	await _shot("g12-record")
	DesktopSession.open_app("messenger")
	await _shot("g13-deduction")
	quit()
