## Picks the Scenario guide step for the current situation. Port of resolveGuideStep.ts.
extends RefCounted

const Conditions := preload("res://scripts/domain/conditions.gd")

const SEVERITY_GUIDE := {
	"LOW": "Cosmetic or presentation issue. The customer can still finish the task correctly.",
	"MEDIUM": "Wrong data or money shown, or a rule applied incorrectly. A workaround exists.",
	"HIGH": "A core flow is blocked or sends the customer somewhere harmful, such as an unintended payment.",
	"CRITICAL": "Data loss, a security exposure, or the product is unusable for everyone.",
}


## Returns the first step whose conditions all hold; the fallback step is listed last.
static func resolve_step(steps: Array, context: Dictionary) -> Variant:
	for step in steps:
		if Conditions.all_match(step.get("conditions", []), context):
			return step
	return null
