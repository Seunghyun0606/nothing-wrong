## Shoply pricing rules. Port of src/products/shoply/domain/rules.ts.
## Items are { "product": {...}, "quantity": int }.
extends RefCounted

const STANDARD_SHIPPING := 5.0
const FREE_SHIPPING_THRESHOLD := 50.0


static func round_currency(value: float) -> float:
	return round(value * 100.0) / 100.0


static func subtotal(items: Array) -> float:
	var total := 0.0
	for item in items:
		total += float(item["product"]["price"]) * int(item["quantity"])
	return round_currency(total)


static func evaluate_coupon(amount: float, requested_code: String, tier: String) -> Dictionary:
	var code := requested_code.strip_edges().to_upper()
	if code == "":
		return { "discount": 0.0, "valid": true, "message": "No coupon applied" }
	if code == "SAVE10":
		return { "code": "SAVE10", "discount": round_currency(amount * 0.1), "valid": true, "message": "SAVE10 applied — 10% off" }
	if code == "SAVE20":
		if tier != "GOLD":
			return { "code": "SAVE20", "discount": 0.0, "valid": false, "message": "SAVE20 is available to Gold members only" }
		return { "code": "SAVE20", "discount": round_currency(amount * 0.2), "valid": true, "message": "SAVE20 applied — Gold 20% off" }
	return { "discount": 0.0, "valid": false, "message": "Coupon code not recognized" }


static func shipping(amount: float) -> float:
	return 0.0 if amount >= FREE_SHIPPING_THRESHOLD else STANDARD_SHIPPING


static func order_summary(items: Array, coupon: String, tier: String) -> Dictionary:
	var amount := subtotal(items)
	var result := evaluate_coupon(amount, coupon, tier)
	var ship := shipping(amount)
	result["subtotal"] = amount
	result["shipping"] = ship
	result["total"] = round_currency(amount - float(result["discount"]) + ship)
	return result


## Formats like Intl en-US currency: $1,234.50
static func money(value: float) -> String:
	var cents := int(round(absf(value) * 100.0))
	var dollars := str(cents / 100)
	var grouped := ""
	while dollars.length() > 3:
		grouped = "," + dollars.right(3) + grouped
		dollars = dollars.left(dollars.length() - 3)
	return "%s$%s%s.%02d" % ["-" if value < 0 else "", dollars, grouped, cents % 100]
