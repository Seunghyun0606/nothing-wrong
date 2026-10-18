## Shared helpers for tests that drive the real workstation scene.
extends "res://tests/test_case.gd"

const GameState := preload("res://scripts/domain/game_state.gd")

var main: Control


func _start() -> Control:
	Settings.persist = false
	Settings.set_language("en")
	GameSession.persist = false
	WorkspaceSession.persist = false
	GameSession.state = GameState.create_initial(GameSession.catalog.ticket_ids())
	GameSession.changed.emit()
	WorkspaceSession.reset()
	DesktopSession.reset_layout()
	DesktopSession.instant_messages = true
	tree.root.size = Vector2i(1440, 900)
	main = load("res://scenes/main.tscn").instantiate()
	tree.root.add_child(main)
	main.show_desktop()
	return main.current


func _finish() -> void:
	main.free()


func _visible(node: Node) -> bool:
	return not (node is CanvasItem) or (node as CanvasItem).is_visible_in_tree()


func find_button(root: Node, text: String, exact: bool = true) -> Button:
	for child in root.get_children():
		if child is Button and _visible(child) and (child.text == text if exact else child.text.contains(text)):
			return child
		var nested := find_button(child, text, exact)
		if nested:
			return nested
	return null


func find_named(root: Node, node_name: String) -> Node:
	return root.find_child(node_name, true, false)


func press(root: Node, text: String, exact: bool = true) -> bool:
	var button := find_button(root, text, exact)
	if button == null:
		failures.append("button not found: %s" % text)
		return false
	if button.disabled:
		failures.append("button disabled: %s" % text)
		return false
	button.pressed.emit()
	return true


## Notes one part of the Browser page, as clicking its highlight in Note mode does.
func _note(desktop: Control, target: String) -> void:
	DesktopSession.open_app("browser")
	check(press(desktop, "📌 Note"), "note mode")
	var marker: Node = find_named(desktop, "Mark%s" % target.replace(".", "_"))
	check(marker != null, "highlight for %s" % target)
	if marker:
		marker.pressed.emit()


## Reports a note and the requirement it breaks to the Ticket's sender in Messenger.
func _report(desktop: Control, note: String, requirement: String) -> void:
	DesktopSession.open_report()
	var form: Node = find_named(desktop, "ReportComposer")
	check(form != null, "report form open")
	if form == null:
		return
	check(press(form, note, false), "note %s" % note)
	check(press(form, requirement, false), "requirement %s" % requirement)
	check(press(form, "Send report"), "send report")


func _no_issue(desktop: Control) -> void:
	DesktopSession.open_report()
	var form: Node = find_named(desktop, "ReportComposer")
	check(form != null, "report form open")
	if form == null:
		return
	check(press(form, "Nothing is wrong"), "nothing is wrong")
	check(press(form, "Send NO ISSUE FOUND"), "send no issue")


## Fills in the open deduction (in Messenger or on the Case File board) and sends it.
func _deduce(desktop: Control, answers: Dictionary, clues: Array = []) -> void:
	var form: Node = find_named(desktop, "DeductionForm")
	check(form != null, "deduction form open")
	if form == null:
		return
	for id in clues:
		var card := form.find_child("Clue%s" % id, true, false) as Button
		check(card != null, "clue %s on the board" % id)
		if card:
			card.button_pressed = true
	for key in answers:
		form.fill(key, answers[key])
	check(press(form, "Send to", false), "send deduction")


func _accept(desktop: Control, ticket_id: String) -> void:
	DesktopSession.open_app("messenger")
	check(press(desktop, "Open %s in QA Notes" % ticket_id), "ticket card %s" % ticket_id)
	check(press(desktop, "Start test"), "start %s" % ticket_id)


## Turns a toggle button on the way a click does (emitting `toggled`).
func toggle_on(root: Node, text: String) -> bool:
	var button := find_button(root, text, false)
	if button == null:
		failures.append("toggle not found: %s" % text)
		return false
	button.button_pressed = true
	return true


## Searches the intranet and opens the record, as the player would.
func _find_record(desktop: Control, query: String, document_id: String) -> void:
	DesktopSession.open_url("https://search.nothingwrong.local/?q=%s" % query.uri_encode())
	var result: Node = find_named(desktop, "Result%s" % document_id)
	check(result != null, "search for %s finds %s" % [query, document_id])
	if result:
		for child in result.get_children():
			if child is Button:
				child.pressed.emit()
				break
	check(GameSession.state["story"]["foundDocuments"].has(document_id), "%s found" % document_id)


func _address(desktop: Control, text: String) -> void:
	DesktopSession.open_app("browser")
	(find_named(desktop, "Address") as LineEdit).text_submitted.emit(text)
