## Turns a report in Messenger into a full Report: the title, reproduction steps,
## attached Evidence, and severity are filled in, so the player only says what they noted
## and which rule it breaks.
extends RefCounted

const Observations := preload("res://scripts/domain/observations.gd")

## Actions that do not change what the customer sees are left out of the steps.
const IGNORED_ACTIONS := ["CAPTURE_EVIDENCE", "CHANGE_VIEWPORT", "RELOAD_PAGE"]



## The actions recorded before the given capture, in order, without repeated or
## cosmetic actions. Every action is kept when the capture is unknown.
static func steps_until(interactions: Array, evidence_id: String) -> Array:
	var cut := interactions.size()
	for index in interactions.size():
		var action: Dictionary = interactions[index]
		if action["type"] == "CAPTURE_EVIDENCE" and action.get("payload", {}).get("evidenceId", "") == evidence_id:
			cut = index
			break
	var steps: Array = []
	var last_key := ""
	for action in interactions.slice(0, cut):
		if IGNORED_ACTIONS.has(action["type"]):
			continue
		var key := "%s|%s|%s" % [action["type"], action.get("target", ""), JSON.stringify(action.get("payload", {}))]
		if key == last_key:
			continue
		last_key = key
		var step := { "id": "STEP-%s" % action["id"], "order": steps.size(), "action": action["type"] }
		if action.has("target"):
			step["target"] = action["target"]
		if action.has("payload"):
			step["payload"] = action["payload"]
		steps.append(step)
	return steps


## The severity a defect against this requirement carries. Severity is not part of the
## puzzle, so the report takes it from the Ticket instead of asking.
static func severity_for(scenario: Dictionary, requirement: Dictionary) -> String:
	for bug in scenario["expectedBugs"]:
		if bug.get("requirementId", "") == requirement["id"]:
			return bug["severity"]
	return "MEDIUM"


static func bug_report(scenario: Dictionary, interactions: Array, requirement: Dictionary,
		observation: Dictionary, severity: String = "", screen: String = "", outcome: String = "BUG") -> Dictionary:
	return {
		"screen": screen,
		"outcome": outcome,
		"ticketId": scenario["ticket"]["id"],
		"kind": "BUG",
		"title": "%s: %s" % [scenario["ticket"]["title"], Observations.describe(observation)],
		"reproductionSteps": steps_until(interactions, observation["evidenceId"]),
		"requirementId": requirement["id"],
		"observation": observation,
		"expected": requirement["description"],
		"actual": Observations.describe(observation),
		"severity": severity if severity != "" else severity_for(scenario, requirement),
		"evidenceIds": [observation["evidenceId"]],
	}


static func no_issue_report(scenario: Dictionary, interactions: Array, evidence: Array) -> Dictionary:
	return {
		"ticketId": scenario["ticket"]["id"],
		"kind": "NO_ISSUE",
		"title": "%s: NO ISSUE FOUND" % scenario["ticket"]["id"],
		"reproductionSteps": steps_until(interactions, ""),
		"expected": "Every requirement in scope is met",
		"actual": "No defect observed",
		"evidenceIds": evidence.map(func(item): return item["id"]),
	}
