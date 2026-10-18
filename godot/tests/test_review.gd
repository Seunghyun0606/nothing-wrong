extends "res://tests/test_case.gd"

const Catalog := preload("res://scripts/domain/catalog.gd")
const Review := preload("res://scripts/domain/review.gd")


func _evidence(ticket_id: String, path: String, controls: Array, product: Dictionary, account := "BASIC", id := "E1") -> Dictionary:
	return {
		"id": id,
		"ticketId": ticket_id,
		"type": "SCREENSHOT",
		"preview": "capture",
		"capturedAt": 1,
		"context": { "account": account, "viewport": "DESKTOP", "locale": "en-US", "currentPath": path },
		"snapshot": { "controls": controls, "productState": product },
	}


func _report(ticket_id: String, requirement: String, evidence: Dictionary, target: String, actions: Array, severity: String) -> Dictionary:
	var steps: Array = []
	for index in actions.size():
		var step: Dictionary = actions[index].duplicate()
		step["id"] = "S%d" % index
		step["order"] = index
		steps.append(step)
	return {
		"id": "R-%s" % ticket_id,
		"ticketId": ticket_id,
		"kind": "BUG",
		"title": "report",
		"reproductionSteps": steps,
		"requirementId": requirement,
		"observation": { "evidenceId": evidence["id"], "target": target, "label": target, "value": "" },
		"expected": "expected",
		"actual": "actual",
		"severity": severity,
		"evidenceIds": [evidence["id"]],
		"submittedAt": 2,
	}


func test_reply_hints_say_where_to_look_without_the_answer() -> void:
	var t01: Dictionary = Catalog.load_from().get_scenario("T01")
	var bag := _evidence("T01", "/shoply/cart", [
		{ "target": "cart.subtotal", "label": "Subtotal", "value": "$30.00" },
	], { "cart": { "quantity": 1 }, "coupon": "" })
	check(Review.reply_hint(_report("T01", "REQ-T01-01", bag, "cart.subtotal", [], "LOW"), t01, bag).begins_with("I checked that screen"), "wrong screen")
	var checkout := _evidence("T01", "/shoply/checkout", [
		{ "target": "cart.total", "label": "Total", "value": "$35.00" },
		{ "target": "checkout.confirmButton", "label": "Confirm order button", "value": "Secondary action style" },
	], { "cart": { "quantity": 1 }, "coupon": "" })
	check(Review.reply_hint(_report("T01", "REQ-T01-02", checkout, "cart.total", [], "LOW"), t01, checkout).begins_with("You're on the right screen"), "wrong value")
	check(Review.reply_hint(_report("T01", "REQ-T01-01", checkout, "checkout.confirmButton", [], "LOW"), t01, checkout).begins_with("That value is wrong"), "wrong rule")
	var t02: Dictionary = Catalog.load_from().get_scenario("T02")
	var one := _evidence("T02", "/shoply/cart", [
		{ "target": "cart.subtotal", "label": "Subtotal", "value": "$30.00" },
	], { "cart": { "quantity": 1 }, "coupon": "" })
	check(Review.reply_hint(_report("T02", "REQ-T02-01", one, "cart.subtotal", [], "MEDIUM"), t02, one).begins_with("That part can go wrong"), "wrong state")
	var t05: Dictionary = Catalog.load_from().get_scenario("T05")
	check("NO ISSUE FOUND" in Review.reply_hint(_report("T05", "REQ-T05-01", one, "cart.subtotal", [], "MEDIUM"), t05, one), "clean build")


func test_flag_steps_score_but_do_not_block() -> void:
	var scenario: Dictionary = Catalog.load_from().get_scenario("T01")
	var evidence := _evidence("T01", "/shoply/checkout", [
		{ "target": "checkout.confirmButton", "label": "Confirm order button", "value": "Secondary action style" },
	], { "cart": { "quantity": 1 }, "coupon": "" })
	var result := Review.review_report(_report("T01", "REQ-T01-02", evidence, "checkout.confirmButton", [{ "action": "OPEN_CHECKOUT" }], "LOW"), scenario, [evidence])
	check(result["valid"], "valid without every step")
	check_eq(result["scores"]["reproduction"], 0, "missing steps cost points")


func test_t01_valid_report_scores_100() -> void:
	var scenario: Dictionary = Catalog.load_from().get_scenario("T01")
	var evidence := _evidence("T01", "/shoply/checkout", [
		{ "target": "cart.total", "label": "Total", "value": "$35.00" },
		{ "target": "checkout.confirmButton", "label": "Confirm order button", "value": "Secondary action style" },
	], { "cart": { "quantity": 1 }, "coupon": "" })
	var report := _report("T01", "REQ-T01-02", evidence, "checkout.confirmButton", [{ "action": "ADD_TO_CART" }, { "action": "OPEN_CHECKOUT" }], "LOW")
	var result := Review.review_report(report, scenario, [evidence])
	check(result["valid"], "valid")
	check_eq(result["totalScore"], 100, "total")
	check_eq(result["matchedBugId"], "BUG-T01-001", "matched bug")

	report["observation"]["target"] = "cart.total"
	var wrong := Review.review_report(report, scenario, [evidence])
	check(not wrong["valid"], "a correct figure is not a defect")


func test_t02_requires_quantity_two_and_names_missing_steps() -> void:
	var scenario: Dictionary = Catalog.load_from().get_scenario("T02")
	var evidence := _evidence("T02", "/shoply/cart", [
		{ "target": "cart.lineTotal", "label": "Line total", "value": "$60.00" },
		{ "target": "cart.subtotal", "label": "Subtotal", "value": "$50.00" },
	], { "cart": { "quantity": 2 }, "coupon": "" })
	var report := _report("T02", "REQ-T02-01", evidence, "cart.subtotal", [{ "action": "ADD_TO_CART" }, { "action": "OPEN_CART" }], "MEDIUM")
	check(Review.review_report(report, scenario, [evidence])["valid"], "valid at quantity two")

	var quantity_one := evidence.duplicate(true)
	quantity_one["snapshot"]["productState"]["cart"]["quantity"] = 1
	check(not Review.review_report(report, scenario, [quantity_one])["valid"], "invalid at quantity one")

	report["reproductionSteps"] = [{ "id": "S0", "order": 0, "action": "ADD_TO_CART" }]
	var missing := Review.review_report(report, scenario, [evidence])
	check_eq(missing["feedback"][1], "Your steps skip: open the bag.", "missing step feedback")


func test_t04_requires_gold_save20_quantity_three() -> void:
	var scenario: Dictionary = Catalog.load_from().get_scenario("T04")
	var evidence := _evidence("T04", "/shoply/cart", [
		{ "target": "cart.discount", "label": "Discount", "value": "−$9.00" },
	], { "cart": { "quantity": 3 }, "coupon": "SAVE20" }, "GOLD")
	var actions := [
		{ "action": "CHANGE_ACCOUNT", "target": "GOLD" },
		{ "action": "APPLY_COUPON", "payload": { "code": "SAVE20" } },
		{ "action": "OPEN_CART", "target": "/shoply/cart" },
	]
	var report := _report("T04", "REQ-T04-02", evidence, "cart.discount", actions, "MEDIUM")
	check_eq(Review.review_report(report, scenario, [evidence])["totalScore"], 100, "full score")
	var basic := evidence.duplicate(true)
	basic["context"]["account"] = "BASIC"
	check(not Review.review_report(report, scenario, [basic])["valid"], "basic is invalid")


func test_no_issue_found_misses_a_real_defect_but_passes_a_clean_ticket() -> void:
	var scenario: Dictionary = Catalog.load_from().get_scenario("T01")
	var evidence := _evidence("T01", "/shoply/checkout", [], {})
	var report := { "id": "R", "ticketId": "T01", "kind": "NO_ISSUE", "reproductionSteps": [{ "id": "S0", "order": 0, "action": "OPEN_CHECKOUT" }], "evidenceIds": ["E1"] }
	check(not Review.review_report(report, scenario, [evidence])["valid"], "missed bug")
	var clean := scenario.duplicate(true)
	clean["expectedBugs"] = []
	var result := Review.review_report(report, clean, [evidence])
	check(result["valid"], "clean ticket accepted")
	check_eq(result["totalScore"], 100, "clean total")
