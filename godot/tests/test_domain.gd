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
const StoryClock := preload("res://scripts/domain/story_clock.gd")
const HorizonData := preload("res://scripts/domain/horizon_data.gd")
const KeyTerms := preload("res://scripts/domain/key_terms.gd")
const Directory := preload("res://scripts/domain/directory.gd")


func _catalog() -> RefCounted:
	return Catalog.load_from()


func _context(path: String, quantity: int, account := "BASIC", coupon := "", captured: Array = []) -> Dictionary:
	return {
		"test": { "account": account, "viewport": "DESKTOP", "locale": "en-US", "currentPath": path },
		"product": { "cart": { "quantity": quantity }, "coupon": coupon },
		"workspace": { "onShoply": path.begins_with("/shoply"), "capturedPaths": captured, "evidenceCount": captured.size(), "flagCount": captured.size() },
	}


func test_catalog_loads_the_chapters_in_order() -> void:
	check_eq(_catalog().ticket_ids().slice(0, 13), ["T01", "T02", "T03", "T04", "T05", "T06", "T07", "T08", "T09", "T10", "T11", "T12", "T13"], "ticket ids")
	check_eq(_catalog().chapters.map(func(chapter): return chapter["id"]).slice(0, 5), ["CH1", "CH2", "CH3", "CH4", "CH5"], "chapters")


func test_each_chapter_talks_in_its_own_conversation() -> void:
	var catalog := _catalog()
	var channels: Array = catalog.chapters.map(func(chapter): return MessengerLog.conversation_of(catalog, { "story": { "chapterId": chapter["id"] } }))
	check_eq(channels.slice(0, 5), ["# shoply-autumn-release", "# shoply-autumn-release", "# shoply-weekend-support", "# shoply-rc5-rollback", "# one-horizon-migration"], "prologue and Chapter 5 channels")
	check_eq(channels[-1], "# one-horizon-release", "the Final has its own channel")
	check(MessengerLog.is_direct("@Mina Seo") and not MessengerLog.is_direct("# oh-source-data"), "direct messages start with @")
	check_eq(MessengerLog.conversation_name("@Alex Han"), "Alex Han", "a direct message is named after the person")
	var state := _chapter_one_done(0)
	var log := MessengerLog.build(catalog, state)
	check(log["entries"].all(func(entry): return entry["in"] == "# shoply-autumn-release"), "Chapter 1 is all in its channel")
	# Working conclusions are the team's; only what someone keeps from the channel is private.
	var private: Array = catalog.scenarios.filter(func(scenario): return scenario["story"].get("deduction", {}).get("channel", "") == "@Mina Seo")
	check_eq(private.map(func(scenario): return scenario["ticket"]["id"]), ["T24", "T29", "T36", "T39", "T41", "T42"], "private from Grace's photo on")
	var first_private: Dictionary = catalog.get_scenario("T24")["story"]["debrief"][0]
	check(first_private["channel"] == "@Mina Seo" and str(first_private["text"]).begins_with("Not in the channel"), "the first private word says why")


func test_key_terms_are_marked_bold() -> void:
	check_eq(KeyTerms.find("E-18419, Daniel Park, left on 16 October 2021, yet PayFlow paid him."), ["E-18419", "Daniel Park", "16 October 2021"], "an ID, a name, and a date")
	check_eq(KeyTerms.find("2021년 10월 17일, 38명이 HRDG-01로 이동했다."), ["2021년 10월 17일", "HRDG-01"], "Korean dates and IDs")
	check_eq(KeyTerms.find("COMMUNITY_PARTNER_OVERRIDE and the COMMUNITY tier"), ["COMMUNITY_PARTNER_OVERRIDE", "COMMUNITY"], "a constant is one term")
	check_eq(KeyTerms.find("from \"release/*\" to \"release/*, exp/*, promo/*\" at 02:14"), ["release/*", "release/*", "exp/*", "promo/*", "02:14"], "branch patterns and times")
	check_eq(KeyTerms.find("Check the read-only cross-system view"), [], "ordinary words stay plain")
	check_eq(KeyTerms.find("shows $24 instead of $24.00, and $1,240.00 on 2021-10-17"), ["$24", "$24.00", "$1,240.00", "2021-10-17"], "money keeps its cents; ISO dates count")
	check_eq(KeyTerms.mark("RC3 [draft]"), "[b]RC3[/b] [lb]draft]", "BBCode in the text is escaped")


func test_horizon_views_are_generic_records() -> void:
	var data: RefCounted = HorizonData.load_from()
	var orders: Dictionary = data.get_view("shoply-orders")
	check_eq(HorizonData.filtered_rows(orders, "2021-10-17").size(), 4, "filter by date")
	check_eq(HorizonData.cell_target(orders, "SO-1017-01", "target", "status"), "shoply-orders.SO-1017-01.target.status", "compare cells")
	var payments: Dictionary = data.get_view("payflow-after-exit")
	check_eq(HorizonData.cell_target(payments, "PF-2111-25", "", "type"), "payflow-after-exit.PF-2111-25.type", "table cells")
	var state := GameState.create_initial(_catalog().ticket_ids())
	check(not data.is_open(orders, _catalog(), state), "views open with their Ticket")
	check_eq(StoryClock.parse("W3 Mon 09:30"), 2 * StoryClock.WEEK + 570, "weeks after release week")


## Chapter 1 played to its finale, with `misses` wrong reports on T04.
func _chapter_one_done(misses: int) -> Dictionary:
	var catalog := _catalog()
	var state := GameState.create_initial(catalog.ticket_ids())
	for id in ["T01", "T02", "T03", "T04"]:
		state = GameState.start_ticket(state, id, 1)
		if id == "T04":
			for index in misses:
				state = GameState.apply_review(state, { "id": "M%d" % index, "ticketId": id, "kind": "BUG" }, { "valid": false, "hint": "Look again." }, {}, 2)
		state = GameState.apply_review(state, { "id": "R-%s" % id, "ticketId": id, "kind": "BUG" }, { "valid": true }, {}, 3)
		var story: Dictionary = catalog.get_scenario(id)["story"]
		state = GameState.find_document(state, story["discovery"]["documentId"])
		state = GameState.answer_deduction(state, story["deduction"], _answers(story["deduction"]))
	if misses > 0:
		state = GameState.find_document(state, "DOC-PRICING-RULES")
	return state


func test_a_late_finale_changes_how_the_chapter_ends() -> void:
	var on_time := MessengerLog.build(_catalog(), _chapter_one_done(0))
	var lines: Array = on_time["entries"].filter(func(entry): return entry.get("epilogueOf", "") == "CH1")
	check_eq(lines.size(), 3, "the epilogue is there")
	check(not lines[1].get("late", false), "answered before code freeze")
	var late_log := MessengerLog.build(_catalog(), _chapter_one_done(8))
	lines = late_log["entries"].filter(func(entry): return entry.get("epilogueOf", "") == "CH1")
	check(lines[1].get("late", false), "eight misses push the finale past 18:00")
	check(str(lines[1]["text"]).contains("missed code freeze"), "Mina says what it cost")


func test_inspections_spend_a_budget() -> void:
	var state := GameState.create_initial(_catalog().ticket_ids())
	for key in ["Identity", "Identity", "Payroll", "Travel", "Organization"]:
		state = GameState.inspect(state, "release-validation", key, 3)
	check_eq(GameState.inspected(state, "release-validation"), ["Identity", "Payroll", "Travel"], "three inspections, no repeats")


func test_the_final_choice_decides_the_ending() -> void:
	var catalog := _catalog()
	var final_chapter: Dictionary = catalog.get_chapter("FINAL")
	var deduction: Dictionary = catalog.get_scenario("T42")["story"]["deduction"]
	var ending := func(filled: Dictionary) -> String:
		var state := GameState.answer_deduction(GameState.create_initial(catalog.ticket_ids()), deduction, filled)
		return str(MessengerLog.ending_for(final_chapter, state["story"]["deductions"][deduction["id"]]).get("id", "default"))
	var formal: String = deduction["blanks"]["route"]["options"][0]
	var chain: String = deduction["blanks"]["evidence"]["options"][0]
	check_eq(ending.call({ "decision": "HOLD", "route": formal, "evidence": chain }), "escalate", "hold, the formal channel, and the full chain")
	check_eq(ending.call({ "decision": "HOLD", "route": formal, "evidence": "my own suspicions" }), "default", "too little evidence: working as intended")
	check_eq(ending.call({ "decision": "SHIP", "route": "nobody", "evidence": chain }), "default", "ship: working as intended")
	check_eq(ending.call({ "decision": "HOLD", "route": "a journalist, off the record", "evidence": chain }), "removed", "a leak takes you off the project")
	check(GameState.check_deduction(deduction, { "decision": "SHIP", "route": "nobody", "evidence": "the photos" })["correct"], "a choice has no wrong answer")


func test_a_ticket_with_two_defects_needs_both_reported() -> void:
	var state := GameState.start_ticket(GameState.create_initial(_catalog().ticket_ids()), "T11", 1)
	state = GameState.apply_review(state, { "id": "R1", "ticketId": "T11", "kind": "BUG" }, { "valid": true, "matchedBugId": "BUG-T11-001", "partial": true }, {}, 2)
	check_eq(state["tickets"]["T11"]["status"], "TESTING", "one of two keeps the Ticket open")
	check_eq(state["tickets"]["T11"]["foundBugIds"], ["BUG-T11-001"], "the first defect is remembered")
	state = GameState.apply_review(state, { "id": "R2", "ticketId": "T11", "kind": "BUG" }, { "valid": true, "matchedBugId": "BUG-T11-002" }, {}, 3)
	check_eq(state["tickets"]["T11"]["status"], "RESOLVED", "both resolve it")


func test_chapter_three_defects_need_a_gold_account() -> void:
	var t08: Array = _catalog().get_scenario("T08")["mutations"]
	check_eq(Mutations.resolve("orders.discountKept", 1.0, _context("/shoply/orders/order-1043", 0, "GOLD"), t08), 0.0, "Gold orders lose their discount")
	check_eq(Mutations.resolve("orders.discountKept", 1.0, _context("/shoply/orders/order-1043", 0), t08), 1.0, "Basic orders keep it")
	var t09: Array = _catalog().get_scenario("T09")["mutations"]
	check_eq(Mutations.resolve("cart.discountRate", 0.1, _context("/shoply/cart", 1, "GOLD", "SAVE10"), t09), 0.0, "Gold loses SAVE10")
	check_eq(Mutations.resolve("cart.discountRate", 0.1, _context("/shoply/cart", 1, "BASIC", "SAVE10"), t09), 0.1, "Basic keeps SAVE10")


func test_story_clock_and_chat_times() -> void:
	check_eq(StoryClock.parse("Tue 09:10"), 1440 + 550, "parse")
	check_eq([StoryClock.day_of(1440 + 550), StoryClock.hhmm(1440 + 550)], ["Tue", "09:10"], "format")
	check_eq(StoryClock.hours_until(StoryClock.parse("Fri 07:40"), StoryClock.parse("Fri 10:00")), 3, "hours left")
	check_eq(StoryClock.hours_until(StoryClock.parse("Sun 15:10"), StoryClock.parse("Mon 09:00")), 18, "a deadline next week")
	check_eq(StoryClock.parse("next Mon 07:40") - StoryClock.parse("Mon 07:40"), StoryClock.WEEK, "the week after")
	check_eq(StoryClock.day_of(StoryClock.parse("next Mon 07:40")), "Mon", "still a Monday")
	var log := MessengerLog.build(_catalog(), GameState.create_initial(_catalog().ticket_ids()))
	check_eq(log["entries"][0]["time"], StoryClock.parse("Tue 09:10"), "the briefing starts at the Ticket's time")
	check_eq(log["entries"][1]["time"], StoryClock.parse("Tue 09:12"), "two minutes per message")


## The right word for every blank of a deduction.
static func _answers(deduction: Dictionary) -> Dictionary:
	var filled := {}
	for key in deduction["blanks"]:
		filled[key] = deduction["blanks"][key]["answer"]
	return filled


func test_chapter_two_defects_depend_on_the_device() -> void:
	var t06: Array = _catalog().get_scenario("T06")["mutations"]
	var mobile := _context("/shoply/cart", 2)
	mobile["test"]["viewport"] = "MOBILE"
	check_eq(Mutations.resolve("cart.shipping", 0.0, mobile, t06), 5.0, "mobile carts pay shipping")
	check_eq(Mutations.resolve("cart.shipping", 0.0, _context("/shoply/cart", 2), t06), 0.0, "desktop is free")
	mobile["product"]["cart"]["quantity"] = 1
	check_eq(Mutations.resolve("cart.shipping", 0.0, mobile, t06), 0.0, "one item is untouched; the defect starts at two")
	var t07: Array = _catalog().get_scenario("T07")["mutations"]
	var tablet := _context("/shoply/orders/order-1042", 0)
	tablet["test"]["viewport"] = "TABLET"
	check_eq(Mutations.resolve("orders.cancelAction.visible", true, tablet, t07), false, "tablets lose Cancel order")
	check_eq(Mutations.resolve("orders.cancelAction.visible", true, _context("/shoply/orders/order-1042", 0), t07), true, "desktop keeps it")


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


## Every Mutation shows when all of its conditions hold and hides when any one fails,
## and Shoply reads every target a Mutation changes.
func test_every_mutation_is_active_only_under_its_conditions() -> void:
	var catalog := _catalog()
	var product := FileAccess.get_file_as_string("res://scripts/ui/shoply/shoply_view.gd")
	check(not product.is_empty(), "the Shoply view is where the test looks")
	# The fields the game puts in the QA context; a misspelled field would never match.
	var real: Dictionary = DesktopSession.qa_context()
	var count := 0
	for ticket_id in catalog.ticket_ids():
		for mutation in catalog.get_scenario(ticket_id)["mutations"]:
			count += 1
			var id := str(mutation["id"])
			check(product.contains('mutate.call("%s"' % mutation["target"]), "%s changes a target Shoply reads" % id)
			var conditions: Array = mutation.get("conditions", [])
			for condition in conditions:
				check(not Conditions.is_missing(Conditions.read_value(condition["field"], real)), "%s reads %s, which the game provides" % [id, condition["field"]])
			var context: Variant = _context_for(conditions)
			check(context != null and Mutations.is_active(mutation, context), "%s is active under its conditions" % id)
			for index in conditions.size():
				var broken: Variant = _context_for(conditions, index)
				check(broken != null and not Mutations.is_active(mutation, broken),
					"%s hides when %s %s fails" % [id, conditions[index]["field"], conditions[index]["operator"]])
	check(count > 0, "the Ticket set has Mutations")


## The product never knows which Ticket is being tested.
func test_shoply_never_branches_on_a_ticket() -> void:
	var ticket := RegEx.create_from_string("\\bT\\d{2}\\b|SCENARIO-|BUG-T|MUTATION-")
	var paths: Array = ["res://scripts/autoload/shoply_store.gd", "res://scripts/domain/shoply_rules.gd"]
	for file in DirAccess.get_files_at("res://scripts/ui/shoply"):
		if file.ends_with(".gd"):
			paths.append("res://scripts/ui/shoply/%s" % file)
	for path in paths:
		var source := FileAccess.get_file_as_string(path)
		check(not source.is_empty(), "%s is read" % path)
		var found := ticket.search(source)
		check(found == null, "%s mentions %s" % [path, found.get_string() if found != null else ""])


## A context where every condition holds, except the one at `broken`, which fails.
## Null when no value of the field does that.
func _context_for(conditions: Array, broken := -1) -> Variant:
	var context := _context("/shoply", 1)
	var fields := {}
	for condition in conditions:
		fields[condition["field"]] = true
	for field in fields:
		var on_field: Array = conditions.filter(func(condition): return condition["field"] == field)
		var wanted := func(value: Variant) -> bool:
			_set_field(context, field, value)
			for condition in on_field:
				if Conditions.matches(condition, context) != (conditions.find(condition) != broken):
					return false
			return true
		var chosen: Variant = null
		var found := false
		for value in _candidates(on_field):
			if wanted.call(value):
				chosen = value
				found = true
				break
		if not found:
			return null
		_set_field(context, field, chosen)
	return context


## Values that pass or fail each condition on one field.
static func _candidates(on_field: Array) -> Array:
	var values: Array = []
	for condition in on_field:
		var value: Variant = condition["value"]
		match typeof(value):
			TYPE_STRING:
				values.append_array([value, value + "x", "x" + value])
			TYPE_INT, TYPE_FLOAT:
				values.append_array([value, value + 1, value - 1])
			TYPE_BOOL:
				values.append_array([value, not value])
			TYPE_ARRAY:
				values.append_array(value + ["__other__"])
	return values


static func _set_field(context: Dictionary, field: String, value: Variant) -> void:
	var parts := field.split(".")
	var node: Dictionary = context[parts[0]]
	for index in range(1, parts.size() - 1):
		if not node.has(parts[index]):
			node[parts[index]] = {}
		node = node[parts[index]]
	node[parts[-1]] = value


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
	var right := _answers(deduction)
	var wrong := right.duplicate()
	wrong["who"] = "the design team"
	check_eq(GameState.check_deduction(deduction, wrong)["right"], 2, "two of three blanks are right")
	var state := GameState.create_initial(["T01"])
	var missed := GameState.answer_deduction(state, deduction, wrong)
	check(not missed["story"]["deductions"][deduction["id"]]["solved"], "a wrong guess keeps it open")
	var retried := GameState.answer_deduction(missed, deduction, right)
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
	var wrong := _answers(deduction)
	wrong["when"] = "18:40"
	state = GameState.answer_deduction(state, deduction, wrong)
	log = MessengerLog.build(catalog, state)
	check_eq([log["entries"][-2]["kind"], log["entries"][-1]["args"]], ["player", [2, 3]], "the lead says how many parts hold up")
	state = GameState.answer_deduction(state, deduction, _answers(deduction))
	log = MessengerLog.build(catalog, state)
	check_eq(log["entries"][-1]["ticketId"], "T02", "next briefing card")


func test_missed_flags_bring_a_nudge_then_the_answer() -> void:
	var catalog := _catalog()
	var state := GameState.start_ticket(GameState.create_initial(catalog.ticket_ids()), "T01", 1)
	check_eq(_assists(MessengerLog.build(catalog, state)).size(), 0, "no help before a miss")
	var reported := MessengerLog.build(catalog, GameState.apply_review(state, { "id": "R0", "ticketId": "T01", "kind": "BUG" }, { "valid": false, "hint": "Look again." }, {}, 2))
	var tail: Array = reported["entries"].slice(-3)
	check_eq(tail[0]["kind"], "report", "the report is the player's message")
	check_eq([tail[1]["from"], tail[1]["text"]], ["Mina Seo", "Look again."], "the sender replies with the hint")
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


func test_help_comes_in_private() -> void:
	var catalog := _catalog()
	var state := GameState.start_ticket(GameState.create_initial(catalog.ticket_ids()), "T01", 1)
	state = GameState.apply_review(state, { "id": "R1", "ticketId": "T01", "kind": "BUG" }, { "valid": false, "hint": "Look again." }, {}, 2)
	var log := MessengerLog.build(catalog, state)
	check_eq(log["entries"][-2]["in"], "# shoply-autumn-release", "the sender replies to the report in the channel")
	check_eq(_assists(log)[0]["in"], "@Mina Seo", "the tip comes as a direct message")
	state = GameState.ask_hint(state, "T01")
	check(GameState.ask_hint(state, "T01") == state, "a hint is asked once")
	state = GameState.apply_review(state, { "id": "R2", "ticketId": "T01", "kind": "BUG" }, { "valid": false, "hint": "Look again." }, {}, 3)
	var ids: Array = MessengerLog.build(catalog, state)["entries"].map(func(entry): return entry["id"])
	check(ids.find("SCENARIO-T01:hintAsked") > ids.find("report:R1") and ids.find("SCENARIO-T01:hintAsked") < ids.find("report:R2"), "the hint sits where it was asked")
	check_eq(ids[ids.find("SCENARIO-T01:hintAsked") + 1], "SCENARIO-T01:hint:0", "and the answer follows")


func test_tickets_wait_at_their_first_message() -> void:
	var catalog := _catalog()
	var entries: Array = MessengerLog.build(catalog, _chapter_one_done(0))["entries"]
	var ids: Array = entries.map(func(entry): return entry["id"])
	var first := MessengerLog.next_gate(entries, 0)
	check(first["id"] == "SCENARIO-T01:briefing:0" and first["day"], "the first Ticket starts a day")
	var t02 := MessengerLog.next_gate(entries, ids.find("SCENARIO-T02:briefing:0"))
	check(not t02["day"] and t02["since"] < t02["time"], "T02 is later the same day")
	check(MessengerLog.next_gate(entries, ids.find("SCENARIO-T03:briefing:0"))["day"], "T03 is the next day")
	check(MessengerLog.next_gate(entries, ids.find("SCENARIO-T02:briefing:1")).is_empty(), "only a Ticket's first message waits")


func test_directory_shows_people_from_their_ticket() -> void:
	var directory: RefCounted = Directory.load_from()
	var before: Array = directory.visible_orgs(["T01"])
	check_eq(before.map(func(org): return org["id"]), ["northstar", "shoply"], "our company and the first client")
	check(directory.find("elena-brooks", ["T01"]) == null and directory.find("elena-brooks", ["T01", "T08"]) != null, "Elena from T08")
	check_eq(directory.direct_reports("elena-brooks", ["T01", "T08"]), ["leo-ortiz"], "Leo reports to her")
	check(not directory.facts("grace-yoon", ["T13"]).any(func(fact): return "Leadership Program" in fact), "a line shows from its own Ticket")
	check_eq(Directory.id_of("Mina Seo"), "mina-seo", "chat names map to directory ids")


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


func test_board_conclusion_needs_every_part_right() -> void:
	var deduction: Dictionary = _catalog().get_scenario("T04")["story"]["deduction"]
	var right := _answers(deduction)
	var wrong := right.duplicate()
	wrong["who"] = "ops-temp"
	check(not GameState.check_deduction(deduction, wrong)["correct"], "wrong conclusion")
	var state := GameState.create_initial(["T04"])
	state = GameState.answer_deduction(state, deduction, wrong)
	check(not state["story"]["deductions"][deduction["id"]]["solved"], "not solved with a wrong part")
	state = GameState.answer_deduction(state, deduction, right)
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
	check_eq(Addresses.parse("docs.northstar.local/Shoply-Pricing-Rules")["slug"], "shoply-pricing-rules", "docs")
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


func _ids(intranet: RefCounted, query: String, state: Dictionary) -> Array:
	return intranet.search(query, state).map(func(document): return document["id"])


func test_some_records_are_a_search_away_from_others() -> void:
	var intranet: RefCounted = Intranet.load_from()
	var state := GameState.create_initial(_catalog().ticket_ids())
	check(_ids(intranet, "TWO_FOR_50", state).has("DOC-PRICING-RULES"), "the rule name finds the registry")
	check(not _ids(intranet, "Spring Duo", state).has("DOC-PROMO-ARCHIVE"), "the campaign waits for the registry")
	state = GameState.find_document(state, "DOC-PRICING-RULES")
	check(_ids(intranet, "spring duo", state).has("DOC-PROMO-ARCHIVE"), "the registry names the campaign")
	check(not _ids(intranet, "TWO_FOR_50", state).has("DOC-PROMO-ARCHIVE"), "the rule name alone does not reach the archive")
	check(_ids(intranet, "promotion", state).has("DOC-PROMO-CALENDAR"), "decoys answer broad searches")
	check(not _ids(intranet, "WS-14", state).has("DOC-ASSET-REGISTER"), "the desk waits for the key")
	state = GameState.find_document(GameState.find_document(state, "DOC-MOBILE-FEES"), "DOC-API-KEYS")
	check(_ids(intranet, "ws-14", state).has("DOC-ASSET-REGISTER"), "the key names the desk")
	state = GameState.note_search_miss(GameState.note_search_miss(state, "DOC-API-KEYS"), "DOC-API-KEYS")
	check_eq(GameState.search_misses(state, "DOC-API-KEYS"), 2, "missed searches are counted")


func test_flag_fills_in_severity_from_the_ticket() -> void:
	var scenario: Dictionary = _catalog().get_scenario("T03")
	check_eq(Draft.severity_for(scenario, scenario["ticket"]["requirements"][0]), "HIGH", "defect severity")
	check_eq(Draft.severity_for(scenario, scenario["ticket"]["requirements"][1]), "MEDIUM", "default severity")
