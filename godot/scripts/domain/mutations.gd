## Resolves Scenario Mutations for a product target. Port of resolveMutation.ts.
extends RefCounted

const Conditions := preload("res://scripts/domain/conditions.gd")


static func is_active(mutation: Dictionary, context: Dictionary) -> bool:
	return Conditions.all_match(mutation.get("conditions", []), context)


static func find_active(target: String, context: Dictionary, mutations: Array) -> Variant:
	for mutation in mutations:
		if str(mutation.get("target", "")) == target and is_active(mutation, context):
			return mutation
	return null


static func resolve(target: String, base_value: Variant, context: Dictionary, mutations: Array) -> Variant:
	var mutation: Variant = find_active(target, context, mutations)
	if mutation == null:
		return base_value
	var payload: Dictionary = mutation.get("payload", {})
	if not payload.has("value"):
		return base_value
	return payload["value"]
