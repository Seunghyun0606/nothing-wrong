## Lists what an Evidence capture recorded. Port of observations.ts.
extends RefCounted


static func observations_of(evidence: Dictionary) -> Array:
	var snapshot: Dictionary = evidence.get("snapshot", {})
	var result: Array = []
	var seen := {}
	for control in snapshot.get("controls", []):
		if typeof(control) != TYPE_DICTIONARY:
			continue
		var target := str(control.get("target", ""))
		if target == "" or seen.has(target):
			continue
		seen[target] = true
		var label := str(control.get("label", ""))
		result.append({
			"target": target,
			"label": label if label != "" else target,
			"value": str(control.get("value", control.get("text", ""))),
		})
	for target in snapshot.get("visibleTargets", []):
		if typeof(target) == TYPE_STRING and target != "" and not seen.has(target):
			seen[target] = true
			result.append({ "target": target, "label": target, "value": "" })
	return result


static func describe(observation: Dictionary) -> String:
	var value := str(observation.get("value", ""))
	return "%s: %s" % [observation["label"], value] if value != "" else str(observation["label"])
