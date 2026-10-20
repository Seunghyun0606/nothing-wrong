## Derives the team chat from Game State. Port of messengerLog.ts.
## Entry kinds: message, ticket, report, found, clue, player, system, ending.
## Reports are the player's messages to the Ticket's sender; a miss gets a reply with a
## hint, and enough misses bring the team's help (story.assist).
## After a debrief the chat pauses until the player finds the record it points to,
## then pauses again on the deduction.
## Every entry is "in" a conversation: a channel ("# name") or a direct message
## ("@Name"). A Ticket's chat happens in its chapter's channel unless its story, a
## message, or its deduction names another one. Help is private: a hint the player asks
## for, and the team's nudges after missed reports, come as direct messages.
extends RefCounted

const StoryClock := preload("res://scripts/domain/story_clock.gd")

## Minutes a wrong report or a wrong conclusion costs on the story's clock.
const PENALTY := 20
const PARTIAL_REPLY := "Good, that's one. This Ticket has more; keep going."
const DEFAULT_CHANNEL := "# northstar-qa"
const HINT_QUESTION := "Do you have a minute? I'm stuck on %s. Any pointers?"


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


## The conversation a Ticket's chat happens in.
static func conversation_of(catalog: RefCounted, scenario: Dictionary) -> String:
	var story: Variant = scenario.get("story", null)
	if story == null:
		return DEFAULT_CHANNEL
	if story.has("channel"):
		return story["channel"]
	var chapter: Variant = catalog.get_chapter(story.get("chapterId", ""))
	return str(chapter.get("channel", DEFAULT_CHANNEL)) if chapter != null else DEFAULT_CHANNEL


static func is_direct(conversation: String) -> bool:
	return conversation.begins_with("@")


## How a conversation is named in the chat list: the channel, or the person.
static func conversation_name(conversation: String) -> String:
	return conversation.substr(1) if is_direct(conversation) else conversation


static func _build(catalog: RefCounted, state: Dictionary) -> Dictionary:
	var entries: Array = []
	for scenario in catalog.scenarios:
		var ticket: Dictionary = scenario["ticket"]
		var ticket_id: String = ticket["id"]
		if not catalog.is_ticket_unlocked(state, ticket_id):
			break
		var story: Variant = scenario.get("story", null)
		var scenario_id: String = scenario["id"]
		var conversation := conversation_of(catalog, scenario)
		if story != null:
			for index in story["briefing"].size():
				var line := _message("%s:briefing:%d" % [scenario_id, index], story["briefing"][index], conversation)
				line["ticketId"] = ticket_id
				entries.append(line)
		entries.append({ "id": "%s:ticket" % scenario_id, "kind": "ticket", "ticketId": ticket_id, "title": ticket["title"], "in": conversation })
		_append_reports(entries, scenario, state, conversation)

		if state["tickets"].get(ticket_id, {}).get("status", "") != "RESOLVED":
			break
		if story == null:
			continue

		for index in story["debrief"].size():
			entries.append(_message("%s:debrief:%d" % [scenario_id, index], story["debrief"][index], conversation))
		var chapter_of_story: Variant = catalog.get_chapter(story["chapterId"])
		var quiet: bool = chapter_of_story != null and chapter_of_story.get("quiet", false)
		var discovery: Variant = story.get("discovery", null)
		if discovery != null:
			if not state["story"].get("foundDocuments", []).has(discovery["documentId"]):
				return { "entries": entries, "pendingDeduction": null, "pendingDiscovery": discovery, "pendingIn": entries[-1]["in"] }
			if not quiet:
				entries.append({ "id": "%s:found" % scenario_id, "kind": "found", "documentId": discovery["documentId"], "in": conversation })
		if not quiet:
			entries.append({ "id": "%s:clue" % scenario_id, "kind": "clue", "title": story["clue"]["title"], "text": story["clue"]["text"], "in": conversation })

		var deduction: Variant = story.get("deduction", null)
		if deduction == null:
			continue
		var asked_by: Dictionary = deduction["askedBy"]
		# A conclusion can be asked for in private, away from the people it is about.
		var asked_in: String = deduction.get("channel", conversation)
		entries.append(_message("%s:deduction" % scenario_id, {
			"from": asked_by["from"], "role": asked_by["role"], "text": deduction["prompt"],
		}, asked_in))
		var progress: Dictionary = state["story"]["deductions"].get(deduction["id"], { "attempts": [], "solved": false })
		var answered := 0
		for attempt in progress["attempts"]:
			if typeof(attempt) != TYPE_DICTIONARY:
				continue
			entries.append({ "id": "%s:answer:%d" % [scenario_id, answered], "kind": "player", "text": "",
				"sentence": deduction["sentence"], "filled": attempt["filled"], "in": asked_in })
			var reply := { "from": asked_by["from"], "role": asked_by["role"] }
			if attempt["correct"]:
				reply["text"] = deduction["success"]
			else:
				reply["text"] = "%d of %d parts hold up. Look at your clues again."
				reply["args"] = [int(attempt["right"]), int(attempt["total"])]
			var answer_reply := _message("%s:answerReply:%d" % [scenario_id, answered], reply, asked_in)
			answer_reply["penalty"] = not attempt["correct"]
			entries.append(answer_reply)
			answered += 1
		if not progress["solved"]:
			return { "entries": entries, "pendingDeduction": deduction, "pendingDiscovery": null, "pendingIn": asked_in }

		var chapter: Variant = catalog.get_chapter(story["chapterId"])
		if chapter != null and chapter["finaleDeductionId"] == deduction["id"]:
			var ending := ending_for(chapter, progress)
			var lines: Array = ending.get("epilogue", chapter["epilogue"])
			for index in lines.size():
				var line := _message("%s:epilogue:%d" % [chapter["id"], index], lines[index], conversation)
				line["epilogueOf"] = chapter["id"]
				entries.append(line)
			entries.append({ "id": "%s:complete" % chapter["id"], "kind": "system", "text": "%s complete." % chapter["title"], "chapterTitle": chapter["title"], "in": conversation })
			if chapter.has("finalCard"):
				entries.append({ "id": "%s:ending" % chapter["id"], "kind": "ending", "lines": chapter["finalCard"],
					"ending": ending.get("id", "default"), "title": ending.get("title", chapter.get("defaultEnding", "")), "in": conversation })

	return { "entries": entries, "pendingDeduction": null, "pendingDiscovery": null, "pendingIn": "" }


## The ending a chapter's final choice leads to: the first of `chapter.endings` whose
## `requires` all match the answer, or {} for the chapter's default epilogue.
static func ending_for(chapter: Dictionary, progress: Dictionary) -> Dictionary:
	var attempts: Array = progress.get("attempts", [])
	if attempts.is_empty() or typeof(attempts[-1]) != TYPE_DICTIONARY:
		return {}
	var filled: Dictionary = attempts[-1].get("filled", {})
	for ending in chapter.get("endings", []):
		var requires: Dictionary = ending.get("requires", {})
		if requires.keys().all(func(key): return str(filled.get(key, "")) == str(requires[key])):
			return ending
	return {}


static func _append_reports(entries: Array, scenario: Dictionary, state: Dictionary, conversation: String) -> void:
	var ticket: Dictionary = scenario["ticket"]
	var story: Variant = scenario.get("story", null)
	var assist: Array = story.get("assist", []) if story != null else []
	# The hint comes where it was asked: after that many reports.
	var hint_after := int(state["story"].get("hintsAsked", {}).get(ticket["id"], -1))
	var sent := 0
	var misses := 0
	for index in state["reportHistory"].size():
		var report: Dictionary = state["reportHistory"][index]
		if report["ticketId"] != ticket["id"]:
			continue
		if sent == hint_after:
			_append_hint(entries, scenario)
		sent += 1
		var review: Dictionary = state["reviewHistory"][index]
		var report_message := report_entry(report)
		report_message["in"] = conversation
		entries.append(report_message)
		if review["valid"]:
			if review.get("partial", false):
				entries.append(_message("%s:partial:%s" % [scenario["id"], report["id"]], {
					"from": ticket["sender"]["name"], "role": ticket["sender"]["role"], "text": PARTIAL_REPLY,
				}, conversation))
			continue
		misses += 1
		var feedback: Array = review.get("feedback", [])
		var text: String = review.get("hint", "")
		if text == "" and not feedback.is_empty():
			text = feedback[-1]
		var reply := _message("%s:reply:%s" % [scenario["id"], report["id"]], {
			"from": ticket["sender"]["name"], "role": ticket["sender"]["role"], "text": text,
		}, conversation)
		reply["penalty"] = true
		entries.append(reply)
		# Missed reports bring the team in: first a nudge, then the answer.
		for help in assist:
			if int(help["after"]) == misses:
				entries.append(_message("%s:assist:%d" % [scenario["id"], misses], help, "@%s" % help["from"]))
	if sent == hint_after:
		_append_hint(entries, scenario)


## The player asks the Ticket's sender for a hint in private; the sender answers there.
static func _append_hint(entries: Array, scenario: Dictionary) -> void:
	var ticket: Dictionary = scenario["ticket"]
	var sender: Dictionary = ticket["sender"]
	var direct := "@%s" % sender["name"]
	entries.append({ "id": "%s:hintAsked" % scenario["id"], "kind": "player", "text": HINT_QUESTION, "args": [ticket["id"]], "in": direct })
	var hints: Array = ticket.get("hints", [])
	for index in hints.size():
		entries.append(_message("%s:hint:%d" % [scenario["id"], index], {
			"from": sender["name"], "role": sender["role"], "text": hints[index]["text"],
		}, direct))


## The next Ticket's chat waits for the player when its first message is next: it
## arrives as a notification, and the chat goes on once the player opens it. `since` is
## the story time of the last message before it; `day` is true when the Ticket starts on
## another day (or is the first one), so the player clocks out and signs in again first.
static func next_gate(entries: Array, delivered: int) -> Dictionary:
	if delivered >= entries.size() or not str(entries[delivered]["id"]).ends_with(":briefing:0"):
		return {}
	var first: Dictionary = entries[delivered]
	var at := int(first.get("time", 0))
	var since := int(entries[delivered - 1].get("time", 0)) if delivered > 0 else -1
	return {
		"id": first["id"], "in": first["in"], "from": first["from"], "text": first["text"], "args": first.get("args", []),
		"time": at, "since": since, "day": delivered == 0 or since / 1440 != at / 1440,
	}


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
		"outcome": report.get("outcome", "BUG"),
	}


## A message is in the given conversation unless it names its own `channel`.
static func _message(id: String, message: Dictionary, conversation: String) -> Dictionary:
	return {
		"id": id,
		"kind": "message",
		"in": message.get("channel", conversation),
		"from": message["from"],
		"role": message["role"],
		"text": message["text"],
		"args": message.get("args", []),
		"links": message.get("links", []),
	}
