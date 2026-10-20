## The Northstar directory (people.northstar.local, data/people.json): our own team and
## the client contacts on the player's projects. An organization, team, person, or line
## shows from the Ticket it is `since`, once the team has assigned that Ticket, so the
## directory grows with the story and never runs ahead of it. It holds what a directory
## would: titles, teams, managers, addresses, and what each person looks after.
extends RefCounted

const DEFAULT_PATH := "res://data/people.json"
## The player's own entry; its name is the profile's.
const YOU := "you"

var orgs: Array = []
var people: Array = []


static func load_from(path: String = DEFAULT_PATH) -> RefCounted:
	var directory: RefCounted = load("res://scripts/domain/directory.gd").new()
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) == TYPE_DICTIONARY:
		directory.orgs = parsed.get("orgs", [])
		directory.people = parsed.get("people", [])
	return directory


## The directory id of a chat name ("Mina Seo" → "mina-seo").
static func id_of(name: String) -> String:
	return name.strip_edges().to_lower().replace(" ", "-")


## Whether an item shows, given the Tickets the team has assigned so far.
static func shows(item: Dictionary, arrived: Array) -> bool:
	var since := str(item.get("since", ""))
	return since == "" or arrived.has(since)


func get_person(id: String) -> Variant:
	for person in people:
		if person["id"] == id:
			return person
	return null


## A person the player can look up now, or null.
func find(id: String, arrived: Array) -> Variant:
	var person: Variant = get_person(id)
	return person if person != null and shows(person, arrived) else null


## The organizations as they show now: { name, kind, notes, teams: [{ name, notes, people }] }.
func visible_orgs(arrived: Array) -> Array:
	var shown: Array = []
	for org in orgs:
		if not shows(org, arrived):
			continue
		var teams: Array = []
		for team in org.get("teams", []):
			if not shows(team, arrived):
				continue
			var members: Array = team["people"].filter(func(id): return find(id, arrived) != null)
			if members.is_empty():
				continue
			teams.append({ "name": team["name"], "notes": _texts(team.get("notes", []), arrived), "people": members })
		shown.append({ "id": org["id"], "name": org["name"], "kind": org["kind"], "notes": _texts(org.get("notes", []), arrived), "teams": teams })
	return shown


## Where a person sits: the first organization and team that list them.
func placement(id: String, arrived: Array) -> Dictionary:
	for org in visible_orgs(arrived):
		for team in org["teams"]:
			if team["people"].has(id):
				return { "org": org["name"], "team": team["name"] }
	return {}


## Who reports to a person, among the people who show now.
func direct_reports(id: String, arrived: Array) -> Array:
	return people.filter(func(person): return str(person.get("reportsTo", "")) == id and shows(person, arrived)) \
		.map(func(person): return person["id"])


## What the directory says about a person now.
func facts(id: String, arrived: Array) -> Array:
	var person: Variant = get_person(id)
	return _texts(person.get("facts", []), arrived) if person != null else []


static func _texts(lines: Array, arrived: Array) -> Array:
	return lines.filter(func(line): return shows(line, arrived)).map(func(line): return line["text"])
