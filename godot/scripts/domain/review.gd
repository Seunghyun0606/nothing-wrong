## Deterministic Report review. Port of reviewBugReport.ts.
extends RefCounted

const Conditions := preload("res://scripts/domain/conditions.gd")
const Observations := preload("res://scripts/domain/observations.gd")

const NOISE_PENALTY := 5
## Flags are cheap to retry, so a wrong one costs little.
const FALSE_REPORT_REPUTATION := -1
const CORRECT_NO_ISSUE_REPUTATION := 2


static func normalize(value: String) -> String:
	var collapsed := RegEx.create_from_string("\\s+").sub(value.strip_edges(), " ", true)
	return collapsed.to_lower()


static func evidence_targets(evidence: Dictionary) -> Array:
	return Observations.observations_of(evidence).map(func(observation): return observation["target"])


static func evidence_shows_bug(evidence: Dictionary, bug: Dictionary) -> bool:
	var targets := evidence_targets(evidence)
	for target in bug["validEvidenceTargets"]:
		if targets.has(target):
			return true
	return false


static func conditions_match_evidence(evidence: Dictionary, bug: Dictionary) -> bool:
	var snapshot: Dictionary = evidence.get("snapshot", {})
	var product: Variant = snapshot.get("productState", snapshot)
	if typeof(product) != TYPE_DICTIONARY:
		product = snapshot
	return Conditions.all_match(bug.get("reproductionConditions", []), {
		"test": evidence.get("context", {}),
		"product": product,
	})


static func step_matches(step: Dictionary, matcher: Dictionary) -> bool:
	if step.get("action", "") != matcher["type"]:
		return false
	if matcher.has("target") and step.get("target", null) != matcher["target"]:
		return false
	var payload: Dictionary = step.get("payload", {})
	for key in matcher.get("payload", {}):
		if not Conditions.same_value(payload.get(key, null), matcher["payload"][key]):
			return false
	return true


static func has_ordered_steps(report: Dictionary) -> bool:
	var steps: Array = report.get("reproductionSteps", [])
	for index in steps.size():
		if int(steps[index].get("order", -1)) != index:
			return false
	return true


static func _sum(scores: Dictionary) -> int:
	return int(scores["detection"] + scores["reproduction"] + scores["evidence"] + scores["severity"])


static func _invalid(feedback: Array) -> Dictionary:
	return {
		"valid": false,
		"scores": { "detection": 0, "reproduction": 0, "evidence": 0, "severity": 0 },
		"totalScore": 0,
		"xp": 0,
		"reputationDelta": FALSE_REPORT_REPUTATION,
		"feedback": feedback,
	}


static func evaluate_bug(
	report: Dictionary,
	scenario: Dictionary,
	bug: Dictionary,
	ticket_evidence: Array,
	attached: Array,
) -> Dictionary:
	var scoring: Dictionary = scenario["scoring"]
	var requirement_matches: bool
	if bug.has("requirementId"):
		requirement_matches = report.get("requirementId", "") == bug["requirementId"]
	else:
		requirement_matches = normalize(str(report.get("expected", ""))) == normalize(bug["expected"])

	var observation: Variant = report.get("observation", null)
	var observation_evidence: Variant = null
	if observation != null:
		for item in ticket_evidence:
			if item["id"] == observation["evidenceId"]:
				observation_evidence = item
	var observation_target_valid: bool = observation != null and observation_evidence != null \
		and bug["validEvidenceTargets"].has(observation["target"]) \
		and evidence_targets(observation_evidence).has(observation["target"])
	var observation_in_failing_state: bool = observation_evidence != null \
		and conditions_match_evidence(observation_evidence, bug)
	var observation_matches: bool
	if observation != null:
		observation_matches = observation_target_valid and observation_in_failing_state
	else:
		observation_matches = normalize(str(report.get("actual", ""))) == normalize(bug["actual"])
	var detection_matches := requirement_matches and observation_matches

	var steps: Array = report.get("reproductionSteps", [])
	var required_actions: Array = bug.get("reproductionActions", [])
	var missing_actions: Array = required_actions.filter(func(matcher):
		for step in steps:
			if step_matches(step, matcher):
				return false
		return true)
	var failing_state_evidence: Array = attached.filter(func(item):
		return evidence_shows_bug(item, bug) and conditions_match_evidence(item, bug))
	var reached_failing_state: bool = bug.get("reproductionConditions", []).is_empty() \
		or attached.any(func(item): return conditions_match_evidence(item, bug))
	var reproduction_matches: bool = steps.size() > 0 and has_ordered_steps(report) \
		and missing_actions.is_empty() and reached_failing_state
	var evidence_matches := not failing_state_evidence.is_empty()
	var noisy_evidence: bool = attached.size() >= 3 \
		and attached.size() - failing_state_evidence.size() > failing_state_evidence.size()
	var severity_matches: bool = report.get("severity", "") == bug["severity"]

	var scores := {
		"detection": int(scoring["detection"]) if detection_matches else 0,
		"reproduction": int(scoring["reproduction"]) if reproduction_matches else 0,
		"evidence": max(0, int(scoring["evidence"]) - (NOISE_PENALTY if noisy_evidence else 0)) if evidence_matches else 0,
		"severity": int(scoring["severity"]) if severity_matches else 0,
	}
	var valid := detection_matches and reproduction_matches and evidence_matches

	var detection_feedback: String
	if detection_matches:
		detection_feedback = "You matched the right requirement to an observation that breaks it."
	elif not requirement_matches and observation_matches:
		detection_feedback = "Your observation shows a real defect, but the selected requirement is not the one it breaks. Which rule does that value contradict?"
	elif requirement_matches and observation_target_valid and not observation_in_failing_state:
		detection_feedback = "The selected observation was captured before the failure appeared, so it still meets the requirement. Reproduce the failure, then capture again."
	elif requirement_matches:
		detection_feedback = "The selected observation does not show the problem. Pick the captured value that contradicts the requirement."
	else:
		detection_feedback = "Neither the requirement nor the observation identifies a defect yet. Re-read the requirements and compare them with what you captured."

	var reproduction_feedback: String
	if reproduction_matches:
		reproduction_feedback = "Another tester could repeat this path."
	elif not missing_actions.is_empty():
		reproduction_feedback = "Your steps skip: %s." % "; ".join(missing_actions.map(func(matcher): return matcher["label"]))
	elif not reached_failing_state:
		reproduction_feedback = "None of the attached Evidence was captured in the failing state."
	else:
		reproduction_feedback = "Add an ordered reproduction path that reaches the failing state."

	var evidence_feedback: String
	if evidence_matches:
		evidence_feedback = "Attached Evidence shows the defect, but several attachments do not. Leave those out next time." if noisy_evidence else "Attached Evidence shows the defect in the failing state."
	else:
		evidence_feedback = "Attach Evidence captured while the defect was on screen."

	var result := {
		"valid": valid,
		"scores": scores,
		"totalScore": _sum(scores),
		"xp": int(scenario.get("progression", {}).get("xp", 0)) if valid else 0,
		"reputationDelta": int(scenario.get("progression", {}).get("reputationDelta", 0)) if valid else FALSE_REPORT_REPUTATION,
		"feedback": [
			detection_feedback,
			reproduction_feedback,
			evidence_feedback,
			"Severity matches the impact of this issue." if severity_matches else "Reconsider the severity using the severity guide.",
		],
	}
	if detection_matches:
		result["matchedBugId"] = bug["id"]
	return result


static func review_no_issue(report: Dictionary, scenario: Dictionary, attached: Array) -> Dictionary:
	if not scenario["expectedBugs"].is_empty():
		return _invalid([
			"A documented defect exists within this Ticket scope, so NO ISSUE FOUND misses it.",
			"Compare every requirement with what Shoply actually shows, including different quantities, accounts, and actions.",
		])
	var scoring: Dictionary = scenario["scoring"]
	# Either a capture or a recorded visit to Shoply shows what was checked.
	var covered: bool = not attached.is_empty() or not report.get("reproductionSteps", []).is_empty()
	var scores := {
		"detection": int(scoring["detection"]),
		"reproduction": int(scoring["reproduction"]) if not report.get("reproductionSteps", []).is_empty() else 0,
		"evidence": int(scoring["evidence"]) if covered else 0,
		"severity": int(scoring["severity"]),
	}
	return {
		"valid": covered,
		"scores": scores,
		"totalScore": _sum(scores),
		"xp": int(scenario.get("progression", {}).get("xp", 0)) if covered else 0,
		"reputationDelta": int(scenario.get("progression", {}).get("reputationDelta", CORRECT_NO_ISSUE_REPUTATION)) if covered else 0,
		"feedback": ["Correct call. Every requirement in scope holds, and your Evidence shows what you checked."] if covered else ["Check Shoply against the requirements before closing a Ticket as NO ISSUE FOUND."],
	}


static func review_report(report: Dictionary, scenario: Dictionary, available_evidence: Array) -> Dictionary:
	var ticket_evidence: Array = available_evidence.filter(func(item): return item["ticketId"] == report["ticketId"])
	var claimed: Array = report.get("evidenceIds", [])
	var attached: Array = ticket_evidence.filter(func(item): return claimed.has(item["id"]))

	if report.get("kind", "BUG") == "NO_ISSUE":
		return review_no_issue(report, scenario, attached)
	if scenario["expectedBugs"].is_empty():
		return _invalid([
			"Every requirement in this Ticket scope holds. This Report is a false positive.",
			"When the product matches the requirements, close the Ticket as NO ISSUE FOUND.",
		])

	var best: Dictionary = {}
	for bug in scenario["expectedBugs"]:
		var result := evaluate_bug(report, scenario, bug, ticket_evidence, attached)
		if best.is_empty() or result["totalScore"] > best["totalScore"]:
			best = result
	return best
