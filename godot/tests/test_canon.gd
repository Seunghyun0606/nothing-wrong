## Keeps the story on the master synopsis (docs/NOTHING_WRONG_ALL_IN_ONE.md): what the
## player learns widens in a fixed order (October 17 → Horizon Ridge → Daniel's death →
## the Foundation → who controls it), and some things are never stated as fact. The rules
## live in data/canon.json.
extends "res://tests/test_case.gd"

const Catalog := preload("res://scripts/domain/catalog.gd")


func _json(path: String) -> Variant:
	return JSON.parse_string(FileAccess.get_file_as_string(path))


static func _strings(value: Variant, out: Array) -> void:
	match typeof(value):
		TYPE_STRING:
			out.append(value)
		TYPE_ARRAY:
			for item in value:
				_strings(item, out)
		TYPE_DICTIONARY:
			for key in value:
				_strings(value[key], out)


## Every text the player can see in each chapter, in English and Korean.
func _texts_by_chapter() -> Dictionary:
	var catalog := Catalog.load_from()
	var ko: Dictionary = _json("res://i18n/ko.json")
	var horizon: Dictionary = _json("res://data/horizon.json")
	var intranet: Dictionary = _json("res://data/intranet.json")
	var chapter_of_ticket := {}
	var texts := {}
	var add := func(chapter: String, value: Variant) -> void:
		var found: Array = []
		_strings(value, found)
		if not texts.has(chapter):
			texts[chapter] = []
		for text in found:
			texts[chapter].append(text)
			if ko.has(text):
				texts[chapter].append(ko[text])
	for scenario in catalog.scenarios:
		var chapter: String = scenario["story"]["chapterId"]
		chapter_of_ticket[scenario["ticket"]["id"]] = chapter
		add.call(chapter, scenario["ticket"])
		add.call(chapter, scenario["story"])
		add.call(chapter, scenario["expectedBugs"])
		add.call(chapter, scenario["mutations"])
	for chapter in catalog.chapters:
		add.call(chapter["id"], [chapter["title"], chapter["synopsis"], chapter["epilogue"], chapter.get("lateEpilogue", [])])
	for view in horizon["views"]:
		add.call(chapter_of_ticket.get(view["ticket"], "CH1"), view)
	for document in intranet["documents"]:
		add.call(chapter_of_ticket.get(document.get("availableAfter", ""), "CH1"), document)
	return texts


static func _mentions(text: String, term: String) -> bool:
	if term.unicode_at(0) > 127:
		return text.contains(term)
	return RegEx.create_from_string("(?i)\\b%s\\b" % term).search(text) != null


func test_no_chapter_reveals_what_the_story_has_not_reached() -> void:
	var canon: Dictionary = _json("res://data/canon.json")
	var order: Array = canon["order"]
	var texts := _texts_by_chapter()
	for chapter in texts:
		check(order.has(chapter), "%s is placed in the canon order" % chapter)
		for reveal in canon["reveals"]:
			if order.find(reveal["from"]) <= order.find(chapter):
				continue
			for term in reveal["terms"]:
				for text in texts[chapter]:
					if _mentions(text, term):
						failures.append("%s reveals %s too early (\"%s\" in: %s)" % [chapter, reveal["id"], term, text.left(90)])


func test_the_story_never_states_what_canon_leaves_open() -> void:
	var canon: Dictionary = _json("res://data/canon.json")
	var texts := _texts_by_chapter()
	for chapter in texts:
		for term in canon["never"]:
			for text in texts[chapter]:
				if _mentions(text, term):
					failures.append("%s states \"%s\" (in: %s)" % [chapter, term, text.left(90)])
