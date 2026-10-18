## In-game browser addresses. Port of browserAddress.ts.
## Locations: { kind: newtab } | { kind: shoply, path } | { kind: horizon, path }
## | { kind: docs, slug } | { kind: search, query } | { kind: record, id }
## | { kind: unreachable, address }. Shoply and the ONE HORIZON QA portal are the sites
## under test ("workspace" sites): they can be noted, logged, and reported.
extends RefCounted

const SHOPLY_HOST := "shoply.local"
const HORIZON_HOST := "qa.onehorizon.local"
const DOCS_HOST := "docs.northstar.local"
const SEARCH_HOST := "search.northstar.local"


static func new_tab() -> Dictionary:
	return { "kind": "newtab" }


static func shoply(path: String) -> Dictionary:
	return { "kind": "shoply", "path": path }


static func horizon(path: String) -> Dictionary:
	return { "kind": "horizon", "path": path }


static func is_workspace(location: Dictionary) -> bool:
	return location.get("kind", "") in ["shoply", "horizon"]


## The address of a site-under-test path ("/shoply/cart", "/horizon/shoply-orders").
static func path_url(path: String) -> String:
	return format(horizon(path)) if path.begins_with("/horizon") else shoply_url(path)


static func parse(input: String) -> Dictionary:
	var trimmed := input.strip_edges()
	if trimmed == "" or trimmed.to_lower().begins_with("about:"):
		return new_tab()
	var without_protocol := RegEx.create_from_string("^[a-zA-Z]+://").sub(trimmed, "")
	var query_start := without_protocol.find("?")
	if query_start >= 0 and not without_protocol.left(query_start).contains("/"):
		without_protocol = "%s/%s" % [without_protocol.left(query_start), without_protocol.substr(query_start)]
	var parts := without_protocol.split("/")
	var host := parts[0].to_lower()
	if host.begins_with("www."):
		host = host.substr(4)
	host = RegEx.create_from_string(":\\d+$").sub(host, "")
	var rest := "/".join(parts.slice(1))
	if host == SEARCH_HOST:
		var record := RegEx.create_from_string("^record/([^?#/]+)").search(rest)
		if record:
			return { "kind": "record", "id": record.get_string(1).to_upper() }
		var query := RegEx.create_from_string("[?&]q=([^&#]*)").search(rest)
		return search(query.get_string(1).uri_decode().replace("+", " ") if query else "")
	rest = RegEx.create_from_string("[?#].*$").sub(rest, "")
	while rest.ends_with("/"):
		rest = rest.left(rest.length() - 1)

	if host == SHOPLY_HOST:
		return shoply("/shoply/%s" % rest if rest != "" else "/shoply")
	if host == HORIZON_HOST:
		return horizon("/horizon/%s" % rest if rest != "" else "/horizon")
	if host == DOCS_HOST:
		return { "kind": "docs", "slug": rest.split("/")[0].to_lower() if rest != "" else "" }
	return { "kind": "unreachable", "address": trimmed }


static func format(location: Dictionary) -> String:
	match location.get("kind", "newtab"):
		"shoply":
			var path: String = str(location["path"]).trim_prefix("/shoply")
			return "https://%s%s" % [SHOPLY_HOST, path if path != "" else "/"]
		"horizon":
			var path: String = str(location["path"]).trim_prefix("/horizon")
			return "https://%s%s" % [HORIZON_HOST, path if path != "" else "/"]
		"docs":
			return "https://%s/%s" % [DOCS_HOST, location["slug"]]
		"search":
			var query: String = location.get("query", "")
			return "https://%s/%s" % [SEARCH_HOST, ("?q=%s" % query.uri_encode()) if query != "" else ""]
		"record":
			return "https://%s/record/%s" % [SEARCH_HOST, str(location["id"]).to_lower()]
		"unreachable":
			return str(location["address"])
	return ""


static func search(query: String) -> Dictionary:
	return { "kind": "search", "query": query.strip_edges() }


static func slug(name: String) -> String:
	var lowered := RegEx.create_from_string("[^a-z0-9]+").sub(name.to_lower(), "-", true)
	return lowered.trim_prefix("-").trim_suffix("-")


static func doc_url(name: String) -> String:
	return "https://%s/%s" % [DOCS_HOST, slug(name)]


static func shoply_url(path: String) -> String:
	return format(shoply(path))


static func display(url: String) -> String:
	return RegEx.create_from_string("^[a-zA-Z]+://").sub(url, "")


static func same(a: Dictionary, b: Dictionary) -> bool:
	return format(a) == format(b) and a.get("kind") == b.get("kind")
