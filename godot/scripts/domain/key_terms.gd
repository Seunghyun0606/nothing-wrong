## Finds the terms a player should not miss in story text, and marks them bold in BBCode:
## the names and codes in data/key_terms.json, record IDs (E-18419, HRDG-01), build and
## promo codes (RC3, SAVE20), constants (DATA_CORRECTION), order numbers, dates, and times.
extends RefCounted

const TERMS_PATH := "res://data/key_terms.json"

const PATTERNS := [
	"[A-Z][A-Z0-9]*(?:-[A-Z0-9]+)+",
	"[a-z]+-[0-9]+",
	"[A-Z][A-Z0-9]*(?:_[A-Z0-9]+)+",
	"[A-Z]{2,}[0-9]+[A-Z0-9]*",
	"#[0-9]+",
	"\\$[0-9]+(?:,[0-9]{3})*(?:\\.[0-9]{2})?",
	"[0-9]{4}-[0-9]{2}-[0-9]{2}",
	"[0-9]{1,2}:[0-9]{2}",
	"[0-9]{1,2} (?:January|February|March|April|May|June|July|August|September|October|November|December)(?: [0-9]{4})?",
	"(?:[0-9]{4}년 )?[0-9]{1,2}월 [0-9]{1,2}일",
]

static var _regex: RegEx


## The text as BBCode, with its key terms in [b] and any "[" escaped.
static func mark(text: String) -> String:
	var out := ""
	var at := 0
	for found in _pattern().search_all(text):
		out += _escape(text.substr(at, found.get_start() - at))
		out += "[b]%s[/b]" % _escape(found.get_string())
		at = found.get_end()
	return out + _escape(text.substr(at))


## The key terms in a text, in order (for tests and tooling).
static func find(text: String) -> Array:
	return _pattern().search_all(text).map(func(found): return found.get_string())


static func _escape(text: String) -> String:
	return text.replace("[", "[lb]")


static func _pattern() -> RegEx:
	if _regex != null:
		return _regex
	var terms: Array = []
	var file := FileAccess.open(TERMS_PATH, FileAccess.READ)
	if file != null:
		var parsed: Variant = JSON.parse_string(file.get_as_text())
		if typeof(parsed) == TYPE_DICTIONARY:
			terms = parsed.get("terms", []).duplicate()
	# Longer names first, so "Horizon Opportunity Program" wins over "Opportunity Program".
	terms.sort_custom(func(a, b): return a.length() > b.length())
	var choices: Array = terms.map(func(term): return _literal(term)) + PATTERNS
	_regex = RegEx.create_from_string("(?<![\\w/.#$-])(?:%s)(?![\\w/-])" % "|".join(choices))
	return _regex


static func _literal(term: String) -> String:
	var out := ""
	for character in term:
		out += "\\" + character if "\\^$.|?*+()[]{}/".contains(character) else character
	return out
