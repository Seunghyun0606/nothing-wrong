## Intranet records and the search engine that finds them (res://data/intranet.json).
## Story records become searchable once their Ticket is resolved, or earlier once the
## player has seen one of their leads in the Browser console. Finding one reveals that
## Ticket's clue. Matching is lenient: substrings, either language, and one typo.
extends RefCounted

const DEFAULT_PATH := "res://data/intranet.json"

var documents: Array = []


static func load_from(path: String = DEFAULT_PATH) -> RefCounted:
	var intranet: RefCounted = load("res://scripts/domain/intranet.gd").new()
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) == TYPE_DICTIONARY:
		intranet.documents = parsed.get("documents", [])
	return intranet


func get_document(id: String) -> Variant:
	for document in documents:
		if document["id"] == id:
			return document
	return null


static func is_available(document: Dictionary, state: Dictionary) -> bool:
	var after: String = document.get("availableAfter", "")
	if after == "" or state["tickets"].get(after, {}).get("status", "") == "RESOLVED":
		return true
	for lead in state.get("story", {}).get("leads", []):
		if document.get("unlockedByLeads", []).has(lead["term"]):
			return true
	return false


static func normalize(text: String) -> String:
	var lowered := text.strip_edges().to_lower()
	lowered = RegEx.create_from_string("[\"'“”‘’?!,:;()\\[\\]]").sub(lowered, " ", true)
	return RegEx.create_from_string("\\s+").sub(lowered, " ", true).strip_edges()


static func distance(a: String, b: String) -> int:
	var previous: Array = range(b.length() + 1)
	for i in a.length():
		var current: Array = [i + 1]
		for j in b.length():
			var cost := 0 if a[i] == b[j] else 1
			current.append(mini(mini(current[j] + 1, previous[j + 1] + 1), previous[j] + cost))
		previous = current
	return previous[b.length()]


## Korean words are short, so two syllables are enough to count as a partial match.
static func _min_length(text: String) -> int:
	for index in text.length():
		if text.unicode_at(index) > 127:
			return 2
	return 3


## 0 when unrelated; higher is a better match.
static func score(query: String, keyword: String) -> int:
	var q := normalize(query)
	var k := normalize(keyword)
	if q.length() < 2 or k == "":
		return 0
	if q == k:
		return 3
	if (k.length() >= _min_length(k) and q.contains(k)) or (q.length() >= _min_length(q) and k.contains(q)):
		return 2
	if q.length() >= 5 and k.length() >= 5 and distance(q, k) <= 1:
		return 1
	return 0


func search(query: String, state: Dictionary) -> Array:
	var ranked: Array = []
	for document in documents:
		if not is_available(document, state):
			continue
		var best := 0
		for keyword in document.get("keywords", []) + document.get("keywordsKo", []):
			best = maxi(best, score(query, keyword))
		if best == 0:
			best = 1 if score(query, document["title"]) >= 2 else 0
		if best > 0:
			ranked.append({ "document": document, "score": best })
	ranked.sort_custom(func(a, b): return a["score"] > b["score"])
	return ranked.map(func(entry): return entry["document"])
