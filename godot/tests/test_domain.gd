extends "res://tests/test_case.gd"

const Catalog := preload("res://scripts/domain/catalog.gd")
const Conditions := preload("res://scripts/domain/conditions.gd")
const Mutations := preload("res://scripts/domain/mutations.gd")
const GameState := preload("res://scripts/domain/game_state.gd")
const MessengerLog := preload("res://scripts/domain/messenger_log.gd")
const Addresses := preload("res://scripts/domain/addresses.gd")
const Rules := preload("res://scripts/domain/shoply_rules.gd")
const Intranet := preload("res://scripts/domain/intranet.gd")
const Draft := preload("res://scripts/domain/report_draft.gd")


func _catalog() -> RefCounted:
	return Catalog.load_from()


func _context(path: String, quantity: int, account := "BASIC", coupon := "", captured: Array = []) -> Dictionary:
	return {
		"test": { "account": account, "viewport": "DESKTOP", "locale": "en-US", "currentPath": path },
		"product": { "cart": { "quantity": quantity }, "coupon": coupon },
		"workspace": { "onShoply": path.begins_with("/shoply"), "capturedPaths": captured, "evidenceCount": captured.size(), "flagCount": captured.size() },
	}


func test_catalog_loads_four_tickets_in_order() -> void:
	check_eq(_catalog().ticket_ids(), ["T01", "T02", "T03", "T04", "T05"], "ticket ids")


func test_conditions_support_every_operator() -> void:
	var context := _context("/shoply/cart", 3, "GOLD", "SAVE20", ["/shoply/checkout"])
	check(Conditions.matches({ "field": "product.cart.quantity", "operator": "GTE", "value": 3.0 }, context), "GTE with float")
	check(Conditions.matches({ "field": "test.account", "operator": "IN", "value": ["GOLD"] }, context), "IN")
	check(Conditions.matches({ "field": "workspace.capturedPaths", "operator": "INCLUDES", "value": "/shoply/checkout" }, context), "INCLUDES")
	check(Conditions.matches({ "field": "test.currentPath", "operator": "STARTS_WITH", "value": "/shoply/" }, context), "STARTS_WITH")
	check(not Conditions.matches({ "field": "product.missing", "operator": "NEQ", "value": 1 }, context), "missing never matches")


func test_t02_mutation_only_changes_the_quantity_two_cart() -> void:
	var mutations: Array = _catalog().get_scenario("T02")["mutations"]
	check_eq(Mutations.resolve("cart.subtotal", 60.0, _context("/shoply/cart", 2), mutations), 50.0, "qty 2 cart")
	check_eq(Mutations.resolve("cart.subtotal", 30.0, _context("/shoply/cart", 1), mutations), 30.0, "qty 1 cart")
	check_eq(Mutations.resolve("cart.subtotal", 60.0, _context("/shoply/checkout", 2), mutations), 60.0, "checkout")


func test_t04_mutation_requires_gold_save20_and_three_items() -> void:
	var mutations: Array = _catalog().get_scenario("T04")["mutations"]
	check_eq(Mutations.resolve("cart.discountRate", 0.2, _context("/shoply/cart", 3, "GOLD", "SAVE20"), mutations), 0.1, "positive")
	check_eq(Mutations.resolve("cart.discountRate", 0.2, _context("/shoply/cart", 2, "GOLD", "SAVE20"), mutations), 0.2, "qty 2")
	check_eq(Mutations.resolve("cart.discountRate", 0.0, _context("/shoply/cart", 3, "BASIC", "SAVE20"), mutations), 0.0, "basic")


func test_game_state_start_review_and_unlock() -> void:
	var catalog := _catalog()
	var state := GameState.create_initial(catalog.ticket_ids())
	check(not catalog.is_ticket_unlocked(state, "T02"), "T02 locked")
	state = GameState.start_ticket(state, "T01", 1)
	check_eq(state["tickets"]["T01"]["status"], "TESTING", "testing")
	var report := { "id": "R1", "ticketId": "T01", "kind": "BUG" }
	var review := { "valid": true }
	state = GameState.apply_review(state, report, review, {}, 2)
	check_eq(state["tickets"]["T01"]["status"], "RESOLVED", "resolved")
	check(not state["profile"].has("xp") and not state["profile"].has("reputation"), "no points to keep")
	check(catalog.is_ticket_unlocked(state, "T02"), "T02 unlocked")
	check_eq(catalog.find_next_open_ticket(state)["id"], "T02", "next ticket")


func test_invalid_review_keeps_testing_and_no_issue_uses_its_status_path() -> void:
	var state := GameState.start_ticket(GameState.create_initial(["T01"]), "T01", 1)
	state = GameState.apply_review(state, { "id": "R1", "ticketId": "T01", "kind": "NO_ISSUE" }, { "valid": false }, {}, 2)
	check_eq(state["tickets"]["T01"]["status"], "TESTING", "back to testing")
	check_eq(state["currentTicketId"], "T01", "current ticket kept")


func test_deduction_keeps_every_attempt() -> void:
	var deduction: Dictionary = _catalog().get_scenario("T01")["story"]["deduction"]
	var right: Dictionary = deduction["options"].filter(func(option): return option["correct"])[0]
	var wrong: Dictionary = deduction["options"].filter(func(option): return not option["correct"])[0]
	var state := GameState.create_initial(["T01"])
	var missed := GameState.answer_deduction(state, deduction, wrong["id"])
	check(not missed["story"]["deductions"][deduction["id"]]["solved"], "a wrong guess keeps it open")
	var retried := GameState.answer_deduction(missed, deduction, right["id"])
	check(retried["story"]["deductions"][deduction["id"]]["solved"], "solved")
	check_eq(retried["story"]["deductions"][deduction["id"]]["attempts"].size(), 2, "attempts")


func test_messenger_log_pauses_on_the_deduction() -> void:
	var catalog := _catalog()
	var state := GameState.create_initial(catalog.ticket_ids())
	var log := MessengerLog.build(catalog, state)
	check_eq(log["entries"][-1]["kind"], "ticket", "ends with ticket card")
	check(log["pendingDeduction"] == null, "nothing pending")

	state["tickets"]["T01"]["status"] = "RESOLVED"
	log = MessengerLog.build(catalog, state)
	check(log["pendingDeduction"] == null, "no deduction before the record is found")
	check_eq(log["pendingDiscovery"]["documentId"], "DOC-CHECKOUT-HISTORY", "debrief points to a record")
	check(not catalog.is_clue_found(state, catalog.get_scenario("T01")), "clue hidden until found")
	state = GameState.find_document(state, "DOC-CHECKOUT-HISTORY")
	log = MessengerLog.build(catalog, state)
	check(log["entries"].any(func(entry): return entry["kind"] == "found"), "found entry")
	check(catalog.is_clue_found(state, catalog.get_scenario("T01")), "clue revealed")
	check_eq(log["pendingDeduction"]["id"], "DED-T01", "pending deduction")
	var deduction: Dictionary = log["pendingDeduction"]
	var right: Dictionary = deduction["options"].filter(func(option): return option["correct"])[0]
	state = GameState.answer_deduction(state, deduction, right["id"])
	log = MessengerLog.build(catalog, state)
	check_eq(log["entries"][-1]["ticketId"], "T02", "next briefing card")


func test_missed_flags_bring_a_nudge_then_the_answer() -> void:
	var catalog := _catalog()
	var state := GameState.start_ticket(GameState.create_initial(catalog.ticket_ids()), "T01", 1)
	check_eq(_assists(MessengerLog.build(catalog, state)).size(), 0, "no help before a miss")
	var reported := MessengerLog.build(catalog, GameState.apply_review(state, { "id": "R0", "ticketId": "T01", "kind": "BUG" }, { "valid": false, "hint": "Look again." }, {}, 2))
	var tail: Array = reported["entries"].slice(-3)
	check_eq(tail[0]["kind"], "report", "the report is the player's message")
	check_eq([tail[1]["from"], tail[1]["text"]], ["Maya Kim", "Look again."], "the sender replies with the hint")
	var miss := { "valid": false, "hint": "Look again." }
	state = GameState.apply_review(state, { "id": "R1", "ticketId": "T01", "kind": "BUG" }, miss, {}, 2)
	check_eq(GameState.misses(state, "T01"), 1, "one miss")
	var help := _assists(MessengerLog.build(catalog, state))
	check_eq(help.size(), 1, "a nudge after the first miss")
	check(str(help[0]["text"]).begins_with("Tip:"), "the nudge does not give the answer away")
	state = GameState.apply_review(state, { "id": "R2", "ticketId": "T01", "kind": "BUG" }, miss, {}, 3)
	help = _assists(MessengerLog.build(catalog, state))
	check_eq(help.size(), 2, "the answer after the second miss")
	check("REQ-T01-02" in str(help[1]["text"]), "the answer names the rule")
	state = GameState.apply_review(state, { "id": "R3", "ticketId": "T01", "kind": "BUG" }, { "valid": true }, {}, 4)
	var log := MessengerLog.build(catalog, state)
	check_eq(_assists(log).size(), 2, "help stays in the chat after the Ticket is resolved")
	var ids: Array = log["entries"].map(func(entry): return entry["id"])
	check(ids.find("SCENARIO-T01:assist:2") < ids.find("SCENARIO-T01:debrief:0"), "help comes before the debrief")


func _assists(log: Dictionary) -> Array:
	return log["entries"].filter(func(entry): return ":assist:" in str(entry["id"]))


func test_intranet_search_is_lenient_and_gated_by_progress() -> void:
	var intranet: RefCounted = Intranet.load_from()
	var state := GameState.create_initial(_catalog().ticket_ids())
	var ids := func(query: String) -> Array:
		return intranet.search(query, state).map(func(document): return document["id"])
	check(not ids.call("checkout").has("DOC-CHECKOUT-HISTORY"), "story records wait for their Ticket")
	check(ids.call("lunch").has("DOC-LUNCH"), "flavour records are always searchable")
	state["tickets"]["T01"]["status"] = "RESOLVED"
	check_eq(ids.call("checkout")[0], "DOC-CHECKOUT-HISTORY", "exact keyword")
	check(ids.call("who changed CHECKOUT?").has("DOC-CHECKOUT-HISTORY"), "keyword inside a sentence")
	check(ids.call("chekout").has("DOC-CHECKOUT-HISTORY"), "one typo")
	check(ids.call("결제").has("DOC-CHECKOUT-HISTORY"), "Korean keyword")
	check(ids.call("banana").is_empty(), "no results")


func test_clue_board_needs_the_right_conclusion_and_clues() -> void:
	var deduction: Dictionary = _catalog().get_scenario("T04")["story"]["deduction"]
	var right: String = deduction["options"].filter(func(option): return option["correct"])[0]["id"]
	var wrong: String = deduction["options"].filter(func(option): return not option["correct"])[0]["id"]
	check(not GameState.board_answer_correct(deduction, wrong, ["CLUE-0214", "CLUE-MERGE-RULE"]), "wrong conclusion")
	check(not GameState.board_answer_correct(deduction, right, ["CLUE-0214"]), "missing the mechanism")
	check(GameState.board_answer_correct(deduction, right, ["CLUE-0214", "CLUE-MERGE-RULE", "CLUE-TWO-FOR-50"]), "extra clues are fine")
	var state := GameState.create_initial(["T04"])
	state = GameState.answer_board(state, deduction, right, ["CLUE-0214"])
	check(not state["story"]["deductions"][deduction["id"]]["solved"], "not solved without the right clues")
	state = GameState.answer_board(state, deduction, right, ["CLUE-0214", "CLUE-MERGE-RULE"])
	check(state["story"]["deductions"][deduction["id"]]["solved"], "solved")


func test_report_steps_are_drafted_from_the_capture() -> void:
	var actions := [
		{ "id": "A1", "type": "OPEN_PRODUCT", "target": "/shoply/product/everyday-pack" },
		{ "id": "A2", "type": "CHANGE_VIEWPORT", "target": "MOBILE" },
		{ "id": "A3", "type": "ADD_TO_CART", "target": "everyday-pack" },
		{ "id": "A4", "type": "ADD_TO_CART", "target": "everyday-pack" },
		{ "id": "A5", "type": "OPEN_CHECKOUT", "target": "/shoply/checkout" },
		{ "id": "A6", "type": "CAPTURE_EVIDENCE", "target": "/shoply/checkout", "payload": { "evidenceId": "E1" } },
		{ "id": "A7", "type": "OPEN_ORDERS", "target": "/shoply/orders" },
	]
	var steps := Draft.steps_until(actions, "E1")
	check_eq(steps.map(func(step): return step["action"]), ["OPEN_PRODUCT", "ADD_TO_CART", "OPEN_CHECKOUT"], "steps up to the capture")
	check_eq(steps.map(func(step): return step["order"]), [0, 1, 2], "ordered")
	var scenario: Dictionary = _catalog().get_scenario("T01")
	var report := Draft.bug_report(scenario, actions, scenario["ticket"]["requirements"][1],
		{ "evidenceId": "E1", "target": "checkout.confirmButton", "label": "Confirm order button", "value": "Secondary action style" }, "LOW")
	check_eq(report["evidenceIds"], ["E1"], "the chosen capture is the Evidence")
	check_eq(report["actual"], "Confirm order button: Secondary action style", "actual from the observation")


func test_addresses_parse_and_format() -> void:
	check_eq(Addresses.parse("shoply.local"), { "kind": "shoply", "path": "/shoply" }, "host only")
	check_eq(Addresses.parse(" HTTPS://www.Shoply.local/cart/ "), { "kind": "shoply", "path": "/shoply/cart" }, "protocol")
	check_eq(Addresses.parse("docs.nothingwrong.local/Shoply-Pricing-Rules")["slug"], "shoply-pricing-rules", "docs")
	check_eq(Addresses.parse("shoply.com")["kind"], "unreachable", "unknown host")
	check_eq(Addresses.format({ "kind": "shoply", "path": "/shoply/checkout" }), "https://shoply.local/checkout", "format")
	check_eq(Addresses.slug("Checkout interaction specification"), "checkout-interaction-specification", "slug")


func test_shoply_rules_price_coupons_and_money() -> void:
	var items := [{ "product": { "price": 30 }, "quantity": 3 }]
	var gold := Rules.order_summary(items, "SAVE20", "GOLD")
	check_eq(gold["discount"], 18.0, "gold discount")
	check_eq(gold["total"], 72.0, "gold total")
	check(not Rules.order_summary(items, "SAVE20", "BASIC")["valid"], "basic rejected")
	check_eq(Rules.shipping(30.0), 5.0, "shipping")
	check_eq(Rules.money(1234.5), "$1,234.50", "money")
	check_eq(Rules.money(9.0), "$9.00", "money small")


func test_console_leads_unlock_records_before_the_ticket_is_resolved() -> void:
	var catalog := _catalog()
	var intranet: RefCounted = Intranet.load_from()
	var state := GameState.create_initial(catalog.ticket_ids())
	check(not intranet.search("release-bot", state).any(func(document): return document["id"] == "DOC-CHECKOUT-HISTORY"), "story record hidden at first")
	state = GameState.note_leads(state, ["release-bot", "02:14"], "T01")
	state = GameState.note_leads(state, ["release-bot"], "T01")
	check_eq(GameState.lead_terms(state), ["release-bot", "02:14"], "leads are unique")
	check_eq(GameState.leads_for(state, "T02"), [], "leads belong to their Ticket")
	var found: Array = intranet.search("release-bot", state).map(func(document): return document["id"])
	check(found.has("DOC-CHECKOUT-HISTORY"), "lead unlocks the record")
	check(not catalog.is_clue_found(GameState.find_document(state, "DOC-CHECKOUT-HISTORY"), catalog.get_scenario("T01")), "the clue still waits for the flag")


func test_flag_fills_in_severity_from_the_ticket() -> void:
	var scenario: Dictionary = _catalog().get_scenario("T03")
	check_eq(Draft.severity_for(scenario, scenario["ticket"]["requirements"][0]), "HIGH", "defect severity")
	check_eq(Draft.severity_for(scenario, scenario["ticket"]["requirements"][1]), "MEDIUM", "default severity")
