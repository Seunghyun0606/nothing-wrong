## Derives the team chat from Game State. Port of messengerLog.ts.
## Entry kinds: message, ticket, report, found, clue, player, system.
## Reports are the player's messages to the Ticket's sender; a miss gets a reply with a
## hint, and enough misses bring the team's help (story.assist).
## After a debrief the chat pauses until the player finds the record it points to,
## then pauses again on the deduction.
extends RefCounted


static func build(catalog: RefCounted, state: Dictionary) -> Dictionary:
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
		var attempts: Array = progress["attempts"]
		var board: Array = progress.get("boardAttempts", [])
		for index in board.size():
			var attempt: Dictionary = board[index]
			for option in deduction["options"]:
				if option["id"] == attempt["option"]:
					var clue_titles: Array = attempt["clues"].map(func(id):
						var clue: Variant = catalog.find_clue(id)
						return clue["title"] if clue != null else id)
					entries.append({ "id": "%s:board:%d" % [scenario_id, index], "kind": "player", "text": option["text"], "clues": clue_titles })
					var response: String = option["response"] if attempt["correct"] or not option["correct"] else deduction.get("boardHint", option["response"])
					entries.append(_message("%s:boardResponse:%d" % [scenario_id, index], {
						"from": asked_by["from"], "role": asked_by["role"], "text": response,
					}))
		if not board.is_empty():
			attempts = []
		for index in attempts.size():
			for option in deduction["options"]:
				if option["id"] == attempts[index]:
					entries.append({ "id": "%s:reply:%d" % [scenario_id, index], "kind": "player", "text": option["text"] })
					entries.append(_message("%s:response:%d" % [scenario_id, index], {
						"from": asked_by["from"], "role": asked_by["role"], "text": option["response"],
					}))
		if not progress["solved"]:
			return { "entries": entries, "pendingDeduction": deduction, "pendingDiscovery": null }

		var chapter: Variant = catalog.get_chapter(story["chapterId"])
		if chapter != null and chapter["finaleDeductionId"] == deduction["id"]:
			for index in chapter["epilogue"].size():
				entries.append(_message("%s:epilogue:%d" % [chapter["id"], index], chapter["epilogue"][index]))
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
			continue
		misses += 1
		var feedback: Array = review.get("feedback", [])
		var text: String = review.get("hint", "")
		if text == "" and not feedback.is_empty():
			text = feedback[-1]
		entries.append(_message("%s:reply:%s" % [scenario["id"], report["id"]], {
			"from": ticket["sender"]["name"], "role": ticket["sender"]["role"], "text": text,
		}))
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
		"links": message.get("links", []),
	}
