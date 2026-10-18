## A conclusion with blanks to fill in, sent to the person who asked. On the Case File
## board the clues found so far are listed above it to reason from. Messenger and the
## Case File both use it.
extends VBoxContainer

const Kit := preload("res://scripts/ui/kit.gd")
const P := preload("res://scripts/ui/palette.gd")

const BLANK := "\\{(\\w+)\\}"

var deduction: Dictionary
var board := false

var _filled := {}
var _send: Button


func setup(source: Dictionary) -> void:
	deduction = source
	board = source.get("mode", "") in ["board", "choice"]


func _ready() -> void:
	name = "DeductionForm"
	add_theme_constant_override("separation", 10)
	var asked_by: String = deduction["askedBy"]["from"]
	if board:
		add_child(Kit.label("Your clues:", 14, P.MUTED))
		for clue in GameSession.catalog.found_clues(GameSession.state, chapter_of(deduction)):
			var card := Kit.panel(P.WARNING_SOFT, Color("#e6d27a"), 6, 10)
			card.name = "Clue%s" % clue["id"]
			var body := Kit.vbox(2)
			body.add_child(Kit.heading("📌 %s" % Kit.t(clue["title"]), 14))
			body.add_child(Kit.rich(Kit.t(clue["text"]), 13, P.TEXT))
			card.add_child(body)
			add_child(card)
	add_child(Kit.label(Kit.tf("Fill in the blanks and send it to %s.", asked_by), 14, P.MUTED))
	add_child(_sentence())
	_send = Kit.primary(Kit.tf("Send to %s", asked_by), _submit)
	_send.name = "SendDeduction"
	_send.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	add_child(_send)
	_refresh()


## The translated sentence, split around its {blanks}; each blank is a drop-down. Words
## are separate labels so the sentence wraps like text.
func _sentence() -> Control:
	var flow := HFlowContainer.new()
	flow.name = "Sentence"
	flow.add_theme_constant_override("h_separation", 6)
	flow.add_theme_constant_override("v_separation", 6)
	var template := Kit.t(deduction["sentence"])
	var cursor := 0
	for found in RegEx.create_from_string(BLANK).search_all(template):
		_add_words(flow, template.substr(cursor, found.get_start() - cursor))
		var key := found.get_string(1)
		# Sorted, so the answer is not always listed first.
		var options: Array = deduction["blanks"][key]["options"].duplicate()
		options.sort()
		var pick := OptionButton.new()
		pick.name = "Blank_%s" % key
		pick.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		pick.add_item("…  %s  …" % Kit.t("Pick"))
		for option in options:
			if _allowed(option):
				pick.add_item(Kit.t(option))
			else:
				# Some answers need groundwork first (the Final's inspections).
				pick.add_item("%s %s" % [Kit.t(option), Kit.t("(inspect first)" if _can_still_inspect(option) else "(not inspected)")])
				pick.set_item_disabled(pick.item_count - 1, true)
		pick.item_selected.connect(func(index):
			if index == 0:
				_filled.erase(key)
			else:
				_filled[key] = options[index - 1]
			_refresh())
		flow.add_child(pick)
		cursor = found.get_end()
	_add_words(flow, template.substr(cursor))
	return flow


static func _add_words(flow: Control, text: String) -> void:
	for word in text.split(" ", false):
		var label := Kit.label(word, 15, P.TEXT, false)
		label.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
		flow.add_child(label)


func _allowed(option: String) -> bool:
	var needs: Dictionary = deduction.get("optionRequires", {}).get(option, {})
	if needs.is_empty():
		return true
	var done: Array = GameSession.state["story"].get("inspected", {}).get(needs["view"], [])
	return needs["keys"].all(func(key): return done.has(key))


## Whether the inspections an option needs can still be made within the view's budget.
func _can_still_inspect(option: String) -> bool:
	var needs: Dictionary = deduction.get("optionRequires", {}).get(option, {})
	var view: Variant = GameSession.horizon.get_view(needs.get("view", ""))
	var budget := int(view.get("inspect", {}).get("budget", 0)) if view != null else 0
	var done: Array = GameSession.state["story"].get("inspected", {}).get(needs.get("view", ""), [])
	var missing: Array = needs.get("keys", []).filter(func(key): return not done.has(key))
	return done.size() + missing.size() <= budget


## Chooses an option for a blank, as picking it from the drop-down does.
func fill(key: String, option: String) -> void:
	var pick := find_child("Blank_%s" % key, true, false) as OptionButton
	for index in pick.item_count:
		if pick.get_item_text(index) == Kit.t(option) and not pick.is_item_disabled(index):
			pick.select(index)
			pick.item_selected.emit(index)
			return


func _refresh() -> void:
	var complete: bool = _filled.size() == deduction["blanks"].size()
	_send.disabled = not complete


func _submit() -> void:
	GameSession.answer_deduction(deduction, _filled.duplicate())
	var solved: bool = GameSession.state["story"]["deductions"].get(deduction["id"], {}).get("solved", false)
	Sfx.play("success" if solved else "fail")
	if solved and board:
		DesktopSession.open_app("messenger")


## The sentence with the player's words in its blanks, in the current language.
static func filled_text(sentence: String, filled: Dictionary) -> String:
	var text := Kit.t(sentence)
	for key in filled:
		text = text.replace("{%s}" % key, Kit.t(str(filled[key])))
	return text


static func chapter_of(source: Dictionary) -> String:
	for scenario in GameSession.catalog.scenarios:
		var story: Variant = scenario.get("story", null)
		if story != null and story.get("deduction", {}).get("id", "") == source["id"]:
			return story["chapterId"]
	return ""
