## Pure Game State transitions. Port of gameState.ts, ticketStateMachine.ts,
## applyReview.ts, and answerDeduction.ts. Every function returns a new state.
extends RefCounted

const SAVE_VERSION := 1

const ALLOWED_TRANSITIONS := {
	"NEW": ["ACCEPTED"],
	"ACCEPTED": ["TESTING"],
	"TESTING": ["REPORTED", "NO_ISSUE"],
	"REPORTED": ["REVIEWED"],
	"NO_ISSUE": ["REVIEWED"],
	"REVIEWED": ["TESTING", "RESOLVED"],
	"RESOLVED": [],
}


static func create_initial(ticket_ids: Array) -> Dictionary:
	var tickets := {}
	for id in ticket_ids:
		tickets[id] = new_ticket_state()
	return {
		"profile": { "name": "J. PARK", "career": "JUNIOR_QA" },
		"tickets": tickets,
		"currentTicketId": null,
		"unlockedTools": [],
		"reportHistory": [],
		"reviewHistory": [],
		"story": { "deductions": {}, "deliveredCount": 0, "readCount": 0, "foundDocuments": [], "leads": [] },
	}


static func new_ticket_state() -> Dictionary:
	return { "status": "NEW", "reportIds": [] }


static func can_transition(from: String, to: String) -> bool:
	return ALLOWED_TRANSITIONS.get(from, []).has(to)


static func transition(from: String, to: String) -> String:
	assert(can_transition(from, to), "Invalid Ticket status transition: %s -> %s" % [from, to])
	return to


## Adds Tickets that appeared in the catalog and restores tools earned by resolved Tickets.
static func reconcile(state: Dictionary, catalog: RefCounted) -> Dictionary:
	var next := state.duplicate(true)
	for id in catalog.ticket_ids():
		if not next["tickets"].has(id):
			next["tickets"][id] = new_ticket_state()
	for scenario in catalog.scenarios:
		var id: String = scenario["ticket"]["id"]
		if next["tickets"][id]["status"] == "RESOLVED":
			for tool in scenario.get("progression", {}).get("unlockedTools", []):
				if not next["unlockedTools"].has(tool):
					next["unlockedTools"].append(tool)
	if not next.has("story"):
		next["story"] = { "deductions": {}, "deliveredCount": 0, "readCount": 0 }
	if not next["story"].has("foundDocuments"):
		next["story"]["foundDocuments"] = []
	for key in ["deliveredCount", "readCount"]:
		next["story"][key] = int(next["story"].get(key, 0))
	return next


static func start_ticket(state: Dictionary, ticket_id: String, now_ms: int) -> Dictionary:
	var next := state.duplicate(true)
	var ticket: Dictionary = next["tickets"][ticket_id]
	next["currentTicketId"] = ticket_id
	if ticket["status"] == "TESTING":
		return next
	var accepted := transition(ticket["status"], "ACCEPTED")
	ticket["status"] = transition(accepted, "TESTING")
	if not ticket.has("acceptedAt"):
		ticket["acceptedAt"] = now_ms
	return next


static func apply_review(
	state: Dictionary,
	report: Dictionary,
	review: Dictionary,
	reward: Dictionary,
	reviewed_at: int,
) -> Dictionary:
	var ticket_id: String = report["ticketId"]
	var ticket: Dictionary = state["tickets"][ticket_id]
	if ticket["reportIds"].has(report["id"]):
		return state
	assert(ticket["status"] == "TESTING", "Ticket %s is not ready for Report submission" % ticket_id)

	var next := state.duplicate(true)
	var next_ticket: Dictionary = next["tickets"][ticket_id]
	var reported := transition("TESTING", "NO_ISSUE" if report.get("kind", "BUG") == "NO_ISSUE" else "REPORTED")
	var reviewed := transition(reported, "REVIEWED")
	var valid: bool = review["valid"]
	# A Ticket with several defects stays open until each one has been reported.
	var resolved: bool = valid and not review.get("partial", false)
	next_ticket["status"] = transition(reviewed, "RESOLVED" if resolved else "TESTING")
	next_ticket["reportIds"].append(report["id"])
	next_ticket["reviewedAt"] = reviewed_at
	if valid and review.has("matchedBugId"):
		var found: Array = next_ticket.get("foundBugIds", [])
		if not found.has(review["matchedBugId"]):
			found.append(review["matchedBugId"])
		next_ticket["foundBugIds"] = found
	if resolved:
		next_ticket["resolvedAt"] = reviewed_at
		for tool in reward.get("unlockedTools", []):
			if not next["unlockedTools"].has(tool):
				next["unlockedTools"].append(tool)

	next["currentTicketId"] = null if resolved else ticket_id
	next["reportHistory"].append(report)
	next["reviewHistory"].append(review)
	return next


## Board deductions (chapter finales) and choices (the final decision) are answered on
## the Case File rather than in the chat.
static func on_board(deduction: Dictionary) -> bool:
	return deduction.get("mode", "") in ["board", "choice"]


## Checks a filled-in conclusion: how many of its blanks are right. A choice has no wrong
## answer: every complete answer closes it, and the chapter's ending follows from it.
static func check_deduction(deduction: Dictionary, filled: Dictionary) -> Dictionary:
	var blanks: Dictionary = deduction.get("blanks", {})
	if deduction.get("mode", "") == "choice":
		var complete := blanks.keys().all(func(key): return filled.has(key))
		return { "right": blanks.size() if complete else 0, "total": blanks.size(), "correct": complete }
	var right := 0
	for key in blanks:
		if str(filled.get(key, "")) == str(blanks[key]["answer"]):
			right += 1
	return { "right": right, "total": blanks.size(), "correct": right == blanks.size() }


static func answer_deduction(state: Dictionary, deduction: Dictionary, filled: Dictionary) -> Dictionary:
	var progress: Dictionary = state["story"]["deductions"].get(deduction["id"], { "attempts": [], "solved": false })
	if progress["solved"]:
		return state
	var check := check_deduction(deduction, filled)
	var next := state.duplicate(true)
	var attempts: Array = progress["attempts"].duplicate(true)
	attempts.append({ "filled": filled.duplicate(), "right": check["right"], "total": check["total"], "correct": check["correct"] })
	next["story"]["deductions"][deduction["id"]] = { "attempts": attempts, "solved": check["correct"] }
	return next


## Spends one inspection of a view's budget on a row (the Final's coverage budget).
## Rows already inspected, and inspections past the budget, change nothing.
static func inspect(state: Dictionary, view_id: String, key: String, budget: int) -> Dictionary:
	var done := inspected(state, view_id)
	if done.has(key) or done.size() >= budget:
		return state
	var next := state.duplicate(true)
	var all: Dictionary = next["story"].get("inspected", {})
	all[view_id] = done + [key]
	next["story"]["inspected"] = all
	return next


static func inspected(state: Dictionary, view_id: String) -> Array:
	return state["story"].get("inspected", {}).get(view_id, [])


## Counts a search that did not turn up the record the team is waiting for.
static func note_search_miss(state: Dictionary, document_id: String) -> Dictionary:
	var next := state.duplicate(true)
	var misses: Dictionary = next["story"].get("searchMisses", {})
	misses[document_id] = int(misses.get(document_id, 0)) + 1
	next["story"]["searchMisses"] = misses
	return next


static func search_misses(state: Dictionary, document_id: String) -> int:
	return int(state["story"].get("searchMisses", {}).get(document_id, 0))


static func find_document(state: Dictionary, document_id: String) -> Dictionary:
	if state["story"].get("foundDocuments", []).has(document_id):
		return state
	var next := state.duplicate(true)
	if not next["story"].has("foundDocuments"):
		next["story"]["foundDocuments"] = []
	next["story"]["foundDocuments"].append(document_id)
	return next


## Story terms the player has seen in the Browser console, in the order they were seen.
static func note_leads(state: Dictionary, terms: Array, ticket_id: String) -> Dictionary:
	var known := lead_terms(state)
	var fresh: Array = terms.filter(func(term): return not known.has(term))
	if fresh.is_empty():
		return state
	var next := state.duplicate(true)
	if not next["story"].has("leads"):
		next["story"]["leads"] = []
	for term in fresh:
		next["story"]["leads"].append({ "term": term, "ticketId": ticket_id })
	return next


static func lead_terms(state: Dictionary) -> Array:
	return state.get("story", {}).get("leads", []).map(func(lead): return lead["term"])


static func leads_for(state: Dictionary, ticket_id: String) -> Array:
	return state.get("story", {}).get("leads", []).filter(func(lead): return lead["ticketId"] == ticket_id) \
		.map(func(lead): return lead["term"])


static func has_found(state: Dictionary, document_id: String) -> bool:
	return state["story"].get("foundDocuments", []).has(document_id)


## How many submissions on a Ticket the review turned down.
static func misses(state: Dictionary, ticket_id: String) -> int:
	var count := 0
	for index in state["reportHistory"].size():
		if state["reportHistory"][index]["ticketId"] == ticket_id and not state["reviewHistory"][index]["valid"]:
			count += 1
	return count



## The review for the most recent report on a Ticket, or null.
static func latest_review(state: Dictionary, ticket_id: String) -> Variant:
	var report_ids: Array = state["tickets"].get(ticket_id, {}).get("reportIds", [])
	if report_ids.is_empty():
		return null
	var last_id: String = report_ids[-1]
	for index in state["reportHistory"].size():
		if state["reportHistory"][index]["id"] == last_id:
			return { "result": state["reviewHistory"][index], "index": index }
	return null
