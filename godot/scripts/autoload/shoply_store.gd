## Shoply's in-memory product state. Port of ShoplyProvider.tsx and domain/seed.ts.
## Restarts from the active Scenario seed whenever the current Ticket changes.
extends Node

signal changed

const Rules := preload("res://scripts/domain/shoply_rules.gd")
const DATA_PATH := "res://data/shoply.json"

var products: Array = []
var base_orders: Array = []
var cart: Array = []
var coupon := ""
var account := "BASIC"
var orders: Array = []
var session_key := ""
var _initial: Dictionary = {}


func _ready() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	if typeof(parsed) == TYPE_DICTIONARY:
		products = parsed.get("products", [])
		base_orders = parsed.get("orders", [])
	GameSession.changed.connect(_sync_with_session)
	_sync_with_session(true)


func _sync_with_session(force := false) -> void:
	var current: Variant = GameSession.state.get("currentTicketId")
	var key := str(current) if current != null else "standalone"
	if key == session_key and not force:
		return
	var scenario: Variant = GameSession.scenario(str(current)) if current != null else null
	var seed: Dictionary = scenario["seed"]["productState"] if scenario != null else {}
	var starting_account := "BASIC"
	if scenario != null and scenario["ticket"]["startingContext"]["account"] == "GOLD":
		starting_account = "GOLD"
	restart(key, seed, starting_account)


func restart(key: String, seed: Dictionary, starting_account: String) -> void:
	session_key = key
	_initial = initial_state(seed)
	cart = _initial["cart"].duplicate(true)
	coupon = _initial["coupon"]
	orders = _initial["orders"].duplicate(true)
	account = starting_account
	changed.emit()


func initial_state(seed: Dictionary) -> Dictionary:
	var seeded_cart: Array = []
	var raw_cart: Variant = seed.get("cart", [])
	if typeof(raw_cart) == TYPE_ARRAY:
		for item in raw_cart:
			var product: Variant = get_product(str(item.get("productId", "")))
			if product != null and int(item.get("quantity", 0)) > 0:
				seeded_cart.append({ "productId": product["id"], "quantity": mini(int(item["quantity"]), int(product["stock"])) })
	var statuses: Dictionary = seed.get("orderStatuses", {})
	var seeded_orders: Array = []
	for order in base_orders:
		var copy: Dictionary = order.duplicate(true)
		copy["status"] = statuses.get(order["id"], order["status"])
		seeded_orders.append(copy)
	return { "cart": seeded_cart, "coupon": str(seed.get("coupon", "")).strip_edges().to_upper(), "orders": seeded_orders }


func get_product(product_id: String) -> Variant:
	for product in products:
		if product["id"] == product_id:
			return product
	return null


func get_order(order_id: String) -> Variant:
	for order in orders:
		if order["id"] == order_id:
			return order
	return null


func user() -> Dictionary:
	if account == "GOLD":
		return { "id": "shoply-gold-01", "name": "Avery Chen", "tier": "GOLD" }
	return { "id": "shoply-basic-01", "name": "Jordan Park", "tier": "BASIC" }


func items() -> Array:
	var result: Array = []
	for item in cart:
		var product: Variant = get_product(item["productId"])
		if product != null:
			result.append({ "productId": item["productId"], "quantity": int(item["quantity"]), "product": product })
	return result


func item_count() -> int:
	var count := 0
	for item in cart:
		count += int(item["quantity"])
	return count


func add_to_cart(product_id: String) -> void:
	var product: Variant = get_product(product_id)
	if product == null:
		return
	for item in cart:
		if item["productId"] == product_id:
			item["quantity"] = mini(int(item["quantity"]) + 1, int(product["stock"]))
			changed.emit()
			return
	cart.append({ "productId": product_id, "quantity": 1 })
	changed.emit()


func set_quantity(product_id: String, quantity: int) -> void:
	var product: Variant = get_product(product_id)
	if product == null:
		return
	for item in cart:
		if item["productId"] == product_id:
			item["quantity"] = clampi(quantity, 1, int(product["stock"]))
	changed.emit()


func remove_from_cart(product_id: String) -> void:
	cart = cart.filter(func(item): return item["productId"] != product_id)
	changed.emit()


func set_coupon(code: String) -> void:
	coupon = code.strip_edges().to_upper()
	changed.emit()


func place_order() -> Variant:
	var current_items := items()
	if current_items.is_empty():
		return null
	var highest := 1000
	for order in orders:
		highest = maxi(highest, int(str(order["id"]).trim_prefix("order-")))
	var summary := Rules.order_summary(current_items, coupon, account)
	var order := {
		"id": "order-%d" % (highest + 1),
		"placedAt": "Today",
		"status": "PROCESSING",
		"productId": current_items[0]["productId"],
		"quantity": item_count(),
		"total": summary["total"],
	}
	orders.push_front(order)
	cart = []
	coupon = ""
	changed.emit()
	return order


func cancel_order(order_id: String) -> void:
	for order in orders:
		if order["id"] == order_id and order["status"] == "PROCESSING":
			order["status"] = "CANCELLED"
	changed.emit()


func switch_account(tier: String, reset_product_state: bool) -> void:
	if tier == account:
		return
	account = tier
	if reset_product_state:
		cart = _initial["cart"].duplicate(true)
		coupon = _initial["coupon"]
		orders = _initial["orders"].duplicate(true)
	changed.emit()
