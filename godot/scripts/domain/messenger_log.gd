## Derives the team chat from Game State. Port of messengerLog.ts.
## Entry kinds: message, ticket, report, found, clue, player, system.
## Reports are the player's messages to the Ticket's sender; a miss gets a reply with a
## hint, and enough misses bring the team's help (story.assist).
## After a debrief the chat pauses until the player finds the record it points to,
## then pauses again on the deduction.
extends RefCounted

const StoryClock := preload("res://scripts/domain/story_clock.gd")

## Minutes a wrong report or a wrong conclusion costs on the story's clock.
const PENALTY := 20
const PARTIAL_REPLY := "Good, that's one. This Ticket has more; keep going."


## The chat, with a story time on every entry ("time", minutes; see story_clock.gd).
static func build(catalog: RefCounted, state: Dictionary) -> Dictionary:
	var log := _build(catalog, state)
	_stamp(catalog, log["entries"])
	return log


## Each Ticket's briefing starts at its story time; after that the chat moves on two
## minutes per message and one per reply from the player. A miss (a wrong report or a
## wrong conclusion) costs PENALTY minutes. A chapter whose finale is answered after its
## deadline closes with its `lateEpilogue` instead.
static func _stamp(catalog: RefCounted, entries: Array) -> void:
	var starts := {}
	for scenario in catalog.scenarios:
		var time := StoryClock.parse(str(scenario.get("story", {}).get("time", "")))
		if time >= 0:
			starts["%s:briefing:0" % scenario["id"]] = time
	var clock := 0
	for entry in entries:
		if starts.has(entry["id"]):
			clock = maxi(clock, starts[entry["id"]])
		elif entry.get("penalty", false):
			clock += PENALTY
		else:
			clock += 1 if entry["kind"] in ["player", "report"] else 2
		entry["time"] = clock
	for chapter in catalog.chapters:
		var deadline := StoryClock.parse(str(chapter.get("deadline", {}).get("at", "")))
		var late: Array = chapter.get("lateEpilogue", [])
		if deadline < 0 or late.is_empty():
			continue
		var lines: Array = entries.filter(func(entry): return entry.get("epilogueOf", "") == chapter["id"])
		if lines.is_empty() or int(lines[0]["time"]) <= deadline:
			continue
		for index in mini(lines.size(), late.size()):
			lines[index]["from"] = late[index]["from"]
			lines[index]["role"] = late[index]["role"]
			lines[index]["text"] = late[index]["text"]
			lines[index]["late"] = true


static func _build(catalog: RefCounted, state: Dictionary) -> Dictionary:
	var entries: Array = []
	for scenario in catalog.scenarios:
		var ticket: Dictionary = scenario["ticket"]
		var ticket_id: String = ticket["id"]
		if not catalog.is_ticket_unlocked(state, ticket_id):
			break
		var story: Variant = scenario.get("story", null)
		var scenario_id: String = scenario["id"]
		if story != null:
			for index in story["briefing"].size():
				entries.append(_message("%s:briefing:%d" % [scenario_id, index], story["briefing"][index]))
		entries.append({ "id": "%s:ticket" % scenario_id, "kind": "ticket", "ticketId": ticket_id, "title": ticket["title"] })
		_append_reports(entries, scenario, state)

		if state["tickets"].get(ticket_id, {}).get("status", "") != "RESOLVED":
			break
		if story == null:
			continue

		for index in story["debrief"].size():
			entries.append(_message("%s:debrief:%d" % [scenario_id, index], story["debrief"][index]))
		var discovery: Variant = story.get("discovery", null)
		if discovery != null:
			if not state["story"].get("foundDocuments", []).has(discovery["documentId"]):
				return { "entries": entries, "pendingDeduction": null, "pendingDiscovery": discovery }
			entries.append({ "id": "%s:found" % scenario_id, "kind": "found", "documentId": discovery["documentId"] })
		entries.append({ "id": "%s:clue" % scenario_id, "kind": "clue", "title": story["clue"]["title"], "text": story["clue"]["text"] })

		var deduction: Variant = story.get("deduction", null)
		if deduction == null:
			continue
		var asked_by: Dictionary = deduction["askedBy"]
		entries.append(_message("%s:deduction" % scenario_id, {
			"from": asked_by["from"], "role": asked_by["role"], "text": deduction["prompt"],
		}))
		var progress: Dictionary = state["story"]["deductions"].get(deduction["id"], { "attempts": [], "solved": false })
		var answered := 0
		for attempt in progress["attempts"]:
			if typeof(attempt) != TYPE_DICTIONARY:
				continue
			entries.append({ "id": "%s:answer:%d" % [scenario_id, answered], "kind": "player", "text": "",
				"sentence": deduction["sentence"], "filled": attempt["filled"] })
			var reply := { "from": asked_by["from"], "role": asked_by["role"] }
			if attempt["correct"]:
				reply["text"] = deduction["success"]
			else:
				reply["text"] = "%d of %d parts hold up. Look at your clues again."
				reply["args"] = [int(attempt["right"]), int(attempt["total"])]
			var answer_reply := _message("%s:answerReply:%d" % [scenario_id, answered], reply)
			answer_reply["penalty"] = not attempt["correct"]
			entries.append(answer_reply)
			answered += 1
		if not progress["solved"]:
			return { "entries": entries, "pendingDeduction": deduction, "pendingDiscovery": null }

		var chapter: Variant = catalog.get_chapter(story["chapterId"])
		if chapter != null and chapter["finaleDeductionId"] == deduction["id"]:
			for index in chapter["epilogue"].size():
				var line := _message("%s:epilogue:%d" % [chapter["id"], index], chapter["epilogue"][index])
				line["epilogueOf"] = chapter["id"]
				entries.append(line)
			entries.append({ "id": "%s:complete" % chapter["id"], "kind": "system", "text": "%s complete." % chapter["title"], "chapterTitle": chapter["title"] })

	return { "entries": entries, "pendingDeduction": null, "pendingDiscovery": null }


static func _append_reports(entries: Array, scenario: Dictionary, state: Dictionary) -> void:
	var ticket: Dictionary = scenario["ticket"]
	var story: Variant = scenario.get("story", null)
	var assist: Array = story.get("assist", []) if story != null else []
	var misses := 0
	for index in state["reportHistory"].size():
		var report: Dictionary = state["reportHistory"][index]
		if report["ticketId"] != ticket["id"]:
			continue
		var review: Dictionary = state["reviewHistory"][index]
		entries.append(report_entry(report))
		if review["valid"]:
			if review.get("partial", false):
				entries.append(_message("%s:partial:%s" % [scenario["id"], report["id"]], {
					"from": ticket["sender"]["name"], "role": ticket["sender"]["role"], "text": PARTIAL_REPLY,
				}))
			continue
		misses += 1
		var feedback: Array = review.get("feedback", [])
		var text: String = review.get("hint", "")
		if text == "" and not feedback.is_empty():
			text = feedback[-1]
		var reply := _message("%s:reply:%s" % [scenario["id"], report["id"]], {
			"from": ticket["sender"]["name"], "role": ticket["sender"]["role"], "text": text,
		})
		reply["penalty"] = true
		entries.append(reply)
		# Missed reports bring the team in: first a nudge, then the answer.
		for help in assist:
			if int(help["after"]) == misses:
				entries.append(_message("%s:assist:%d" % [scenario["id"], misses], help))


static func report_entry(report: Dictionary) -> Dictionary:
	var observation: Dictionary = report.get("observation", {})
	return {
		"id": "report:%s" % report["id"],
		"kind": "report",
		"ticketId": report["ticketId"],
		"noIssue": report.get("kind", "BUG") == "NO_ISSUE",
		"screen": report.get("screen", ""),
		"label": observation.get("label", ""),
		"value": observation.get("value", ""),
		"requirementId": report.get("requirementId", ""),
		"requirement": report.get("expected", ""),
	}


static func _message(id: String, message: Dictionary) -> Dictionary:
	return {
		"id": id,
		"kind": "message",
		"from": message["from"],
		"role": message["role"],
		"text": message["text"],
		"args": message.get("args", []),
		"links": message.get("links", []),
	}
