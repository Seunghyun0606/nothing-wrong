## Builds Shoply storefront pages. Product code: it reads Mutations only through
## `mutate(target, base)` and never branches on Ticket IDs.
extends RefCounted

const Kit := preload("res://scripts/ui/kit.gd")
const P := preload("res://scripts/ui/palette.gd")
const Rules := preload("res://scripts/domain/shoply_rules.gd")

var navigate: Callable          ## func(path: String)
var record: Callable            ## func(type: String, target: String, payload: Dictionary)
var mutate: Callable            ## func(target: String, base: Variant) -> Variant
var rerender: Callable          ## func() — rebuild after view-only state changes
var heading := ""               ## The page title, used as the Evidence heading
var narrow := false             ## Tablet/Mobile layout
var product_added := false
var confirmed_order: Variant = null
var coupon_draft := ""


func build(root: VBoxContainer, path: String) -> void:
	var normalized := path.split("?")[0].trim_suffix("/")
	heading = ""
	root.add_child(_header())
	var page := Kit.vbox(18)
	root.add_child(Kit.margin(page, 20 if narrow else 40, 28, 20 if narrow else 40, 40))

	var product_match := RegEx.create_from_string("^/shoply/product/([^/]+)$").search(normalized)
	var cancel_match := RegEx.create_from_string("^/shoply/orders/([^/]+)/cancel$").search(normalized)
	var order_match := RegEx.create_from_string("^/shoply/orders/([^/]+)$").search(normalized)
	if normalized == "/shoply":
		_home(page)
	elif product_match:
		_product(page, product_match.get_string(1))
	elif normalized == "/shoply/cart":
		_cart(page)
	elif normalized == "/shoply/checkout":
		_checkout(page)
	elif normalized == "/shoply/orders":
		_orders(page)
	elif cancel_match:
		_cancel(page, cancel_match.get_string(1))
	elif order_match:
		_order_detail(page, order_match.get_string(1))
	elif normalized == "/shoply/payment":
		_payment(page)
	else:
		page.add_child(_serif("Page not found.", 34))
		page.add_child(_text("The requested Shoply page does not exist."))


# --- building blocks ---------------------------------------------------------

func _text(value: String, size: int = 16, color: Color = P.SHOP_INK) -> Label:
	return Kit.label(value, size, color)


func _serif(value: String, size: int) -> Label:
	if size >= 30 and heading == "":
		heading = value
	return Kit.heading(value, size, P.SHOP_INK)


func _caps(value: String, color: Color = P.SHOP_ACCENT) -> Label:
	return Kit.kicker(value, color)


func _shop_button(value: String, on_press: Callable, outlined: bool = false) -> Button:
	var node := Kit.button(value, on_press)
	var fill := P.SHOP_BG if outlined else P.SHOP_INK
	node.add_theme_stylebox_override("normal", Kit.style(fill, P.SHOP_INK, 2, 22, 12, 1))
	node.add_theme_stylebox_override("hover", Kit.style(Color("#6d665d") if outlined else Color("#3b362f"), P.SHOP_INK, 2, 22, 12, 1))
	node.add_theme_stylebox_override("pressed", Kit.style(Color("#3b362f"), P.SHOP_INK, 2, 22, 12, 1))
	var font := P.SHOP_INK if outlined else Color.WHITE
	node.add_theme_color_override("font_color", font)
	node.add_theme_color_override("font_hover_color", Color.WHITE)
	node.add_theme_color_override("font_pressed_color", Color.WHITE)
	node.add_theme_font_override("font", Kit.bold_font())
	return node


func _shop_link(value: String, path: String, evidence: Array = []) -> Button:
	var node := Kit.link(value, navigate.bind(path))
	node.add_theme_color_override("font_color", P.SHOP_INK)
	node.add_theme_color_override("font_hover_color", P.SHOP_ACCENT)
	node.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	if not evidence.is_empty():
		Kit.evidence(node, evidence[0], evidence[1], evidence[2] if evidence.size() > 2 else "")
	return node


func _shop_action(value: String, on_press: Callable) -> Button:
	var node := Kit.link(value, on_press)
	node.add_theme_color_override("font_color", P.SHOP_INK)
	node.add_theme_color_override("font_hover_color", P.SHOP_ACCENT)
	node.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	return node


func _row(separation: int = 16) -> BoxContainer:
	var box := BoxContainer.new()
	box.vertical = narrow
	box.add_theme_constant_override("separation", separation)
	return box


func _card() -> PanelContainer:
	return Kit.panel(P.SHOP_BG.lightened(0.4), P.SHOP_LINE, 2, 22)


func _header() -> Control:
	var bar := Kit.panel(P.SHOP_BG, P.SHOP_LINE, 0, 14)
	var row := Kit.hbox(18)
	bar.add_child(row)
	var logo := Kit.link("shoply.", navigate.bind("/shoply"))
	logo.name = "ShoplyLogo"
	logo.add_theme_font_size_override("font_size", 24)
	logo.add_theme_font_override("font", Kit.bold_font())
	logo.add_theme_color_override("font_color", P.SHOP_INK)
	row.add_child(logo)
	if not narrow:
		row.add_child(_shop_link("Shop", "/shoply"))
	row.add_child(Kit.spacer())
	if not narrow:
		row.add_child(Kit.label(ShoplyStore.user()["name"], 14, P.SHOP_MUTED, false))
	row.add_child(_shop_link("Orders", "/shoply/orders"))
	row.add_child(_shop_link("Bag (%d)" % ShoplyStore.item_count(), "/shoply/cart"))
	return bar


func _summary(parent: Container) -> void:
	var items := ShoplyStore.items()
	var summary := Rules.order_summary(items, ShoplyStore.coupon, ShoplyStore.account)
	var subtotal := float(mutate.call("cart.subtotal", summary["subtotal"]))
	var normal_rate := 0.0 if summary["subtotal"] == 0.0 else float(summary["discount"]) / float(summary["subtotal"])
	var rate := float(mutate.call("cart.discountRate", normal_rate))
	var discount := roundf(subtotal * rate * 100.0) / 100.0
	var shipping := float(mutate.call("cart.shipping", summary["shipping"]))
	var total := roundf((subtotal - discount + shipping) * 100.0) / 100.0

	var card := _card()
	card.name = "OrderSummary"
	var column := Kit.vbox(10)
	card.add_child(column)
	column.add_child(_serif("Order summary", 22))
	_summary_line(column, "Subtotal", Rules.money(subtotal), "cart.subtotal")
	if float(summary["discount"]) > 0.0:
		_summary_line(column, "Discount", "−%s" % Rules.money(discount), "cart.discount")
	_summary_line(column, "Shipping", "Free" if shipping == 0.0 else Rules.money(shipping), "cart.shipping")
	column.add_child(HSeparator.new())
	_summary_line(column, "Total", Rules.money(total), "cart.total", true)
	parent.add_child(card)


func _summary_line(parent: Container, title: String, value: String, target: String, strong: bool = false) -> void:
	var line := Kit.hbox(10)
	line.add_child(_text(title, 18 if strong else 15, P.SHOP_INK if strong else P.SHOP_MUTED))
	var amount := Kit.heading(value, 18, P.SHOP_INK) if strong else Kit.label(value, 15, P.SHOP_INK, false)
	amount.autowrap_mode = TextServer.AUTOWRAP_OFF
	amount.size_flags_horizontal = Control.SIZE_SHRINK_END
	Kit.evidence(amount, target, title)
	line.add_child(amount)
	parent.add_child(line)


# --- pages -------------------------------------------------------------------

const ACCENTS := { "coral": Color("#e8b49a"), "sand": Color("#e6cfa1"), "slate": Color("#b8c2cc") }


func _home(page: VBoxContainer) -> void:
	page.add_child(_caps("Autumn essentials"))
	page.add_child(_serif("Carry less. Carry better.", 36))
	page.add_child(_text("Free shipping on orders of $50.00 or more.", 15, P.SHOP_MUTED))
	var grid := GridContainer.new()
	grid.columns = 1 if narrow else 3
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	for product in ShoplyStore.products:
		var card := _card()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var body := Kit.vbox(8)
		card.add_child(body)
		var art: Control = Kit.picture("products/%s" % product["id"])
		if art == null:
			art = ColorRect.new()
			art.color = ACCENTS.get(product.get("accent", ""), P.SHOP_CORAL)
		art.custom_minimum_size = Vector2(0, 140)
		body.add_child(art)
		body.add_child(_caps(product["category"], P.SHOP_MUTED))
		body.add_child(_serif(product["name"], 20))
		body.add_child(_text(Rules.money(float(product["price"])), 16))
		body.add_child(_shop_link("View product →", "/shoply/product/%s" % product["id"]))
		grid.add_child(card)
	page.add_child(grid)


func _product(page: VBoxContainer, product_id: String) -> void:
	var product: Variant = ShoplyStore.get_product(product_id)
	if product == null:
		page.add_child(_serif("Product not found.", 34))
		return
	var row := _row(36)
	page.add_child(row)
	var photo := Kit.picture("products/%s" % product["id"])
	var art := Kit.panel(ACCENTS.get(product.get("accent", ""), P.SHOP_CORAL), Color.TRANSPARENT, 2, 0 if photo else 24)
	art.custom_minimum_size = Vector2(0 if narrow else 420, 300)
	art.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if photo:
		art.add_child(photo)
	var art_label := _caps(product.get("tagline", ""), P.SHOP_INK)
	art_label.size_flags_vertical = Control.SIZE_SHRINK_END
	art.add_child(Kit.margin(art_label, 24, 24, 24, 24) if photo else art_label)
	row.add_child(art)
	var copy := Kit.vbox(12)
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_child(_caps(product["category"]))
	copy.add_child(_serif(product["name"], 36))
	var price_text := str(mutate.call("product.priceText", Rules.money(float(product["price"]))))
	var price := Kit.heading(price_text, 24, P.SHOP_INK)
	Kit.evidence(price, "product.price", "Product price", price_text)
	copy.add_child(price)
	copy.add_child(_text(product["description"], 15, P.SHOP_MUTED))
	for feature in product.get("features", []):
		copy.add_child(_text("—  %s" % feature, 15))
	var add := _shop_button("Add to bag", func():
		product_added = true
		ShoplyStore.add_to_cart(product["id"])
		record.call("ADD_TO_CART", product["id"], {}))
	add.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	copy.add_child(add)
	if product_added:
		var added := Kit.hbox(6)
		added.add_child(_text("Added to bag.", 15))
		added.add_child(_shop_link("View bag", "/shoply/cart"))
		copy.add_child(added)
	var stock := _text("%d in stock · Ships in 1–2 business days" % int(product["stock"]), 13, P.SHOP_MUTED)
	Kit.evidence(stock, "product.stock", "Stock", "%d in stock" % int(product["stock"]))
	copy.add_child(stock)
	row.add_child(copy)


func _cart(page: VBoxContainer) -> void:
	page.add_child(_caps("Your selection"))
	page.add_child(_serif("Shopping bag", 36))
	var items := ShoplyStore.items()
	if items.is_empty():
		page.add_child(_serif("Your bag is empty.", 22))
		page.add_child(_text("Thoughtful essentials are waiting.", 15, P.SHOP_MUTED))
		page.add_child(_shop_button("Explore the collection", navigate.bind("/shoply")))
		return
	var row := _row(28)
	page.add_child(row)
	var left := Kit.vbox(14)
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 1.5
	row.add_child(left)
	for item in items:
		var product: Dictionary = item["product"]
		var card := _card()
		var line := Kit.hbox(16)
		card.add_child(line)
		var info := Kit.vbox(4)
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.add_child(_caps(product["category"], P.SHOP_MUTED))
		info.add_child(_serif(product["name"], 20))
		var available := int(mutate.call("cart.stock", int(product["stock"])))
		var left_text := _text("%d available" % available, 13, P.SHOP_MUTED)
		Kit.evidence(left_text, "cart.stock", "Stock", "%d available" % available)
		info.add_child(left_text)
		if bool(mutate.call("cart.removeAction.visible", true)):
			var remove := _shop_action("Remove", func():
				ShoplyStore.remove_from_cart(product["id"])
				record.call("REMOVE_FROM_CART", product["id"], {}))
			Kit.evidence(remove, "cart.removeAction", "Remove action", "Remove")
			info.add_child(remove)
		else:
			var stuck := _text("To change your bag, contact support.", 13, P.SHOP_MUTED)
			Kit.evidence(stuck, "cart.removeAction", "Remove action", "Not shown, contact support")
			info.add_child(stuck)
		line.add_child(info)
		var quantity_box := Kit.vbox(2)
		quantity_box.add_child(_text("Qty", 13, P.SHOP_MUTED))
		var quantity := OptionButton.new()
		quantity.name = "Quantity"
		quantity.tooltip_text = "Quantity for %s" % product["name"]
		var most := clampi(available, 1, 4)
		for value in range(1, most + 1):
			quantity.add_item(str(value), value)
		quantity.select(clampi(int(item["quantity"]), 1, most) - 1)
		quantity.item_selected.connect(func(index):
			var next: int = index + 1
			ShoplyStore.set_quantity(product["id"], next)
			record.call("CHANGE_QUANTITY", product["id"], { "quantity": next }))
		Kit.evidence(quantity_box, "cart.quantity", "Quantity", str(item["quantity"]))
		quantity_box.add_child(quantity)
		line.add_child(quantity_box)
		var line_total := Kit.heading(Rules.money(float(product["price"]) * int(item["quantity"])), 18, P.SHOP_INK)
		line_total.autowrap_mode = TextServer.AUTOWRAP_OFF
		Kit.evidence(line_total, "cart.lineTotal", "Line total")
		line.add_child(line_total)
		left.add_child(card)

	var coupon_box := Kit.vbox(6)
	coupon_box.add_child(_text("Coupon code", 14, P.SHOP_MUTED))
	var coupon_row := Kit.hbox(8)
	var coupon_input := LineEdit.new()
	coupon_input.name = "CouponCode"
	coupon_input.placeholder_text = "SAVE10"
	coupon_input.text = coupon_draft if coupon_draft != "" else ShoplyStore.coupon
	coupon_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	coupon_input.text_changed.connect(func(value): coupon_draft = value)
	var apply := func():
		var code := coupon_input.text.strip_edges().to_upper()
		coupon_draft = code
		ShoplyStore.set_coupon(code)
		record.call("APPLY_COUPON", "", { "code": code })
	coupon_input.text_submitted.connect(func(_value): apply.call())
	coupon_row.add_child(coupon_input)
	coupon_row.add_child(_shop_button("Apply", apply, true))
	coupon_box.add_child(coupon_row)
	if ShoplyStore.coupon != "":
		var subtotal := 0.0
		for item in items:
			subtotal += float(item["product"]["price"]) * int(item["quantity"])
		var result := Rules.evaluate_coupon(subtotal, ShoplyStore.coupon, ShoplyStore.account)
		var message := _text(result["message"], 14, P.SUCCESS if result["valid"] else P.DANGER)
		Kit.evidence(message, "cart.couponMessage", "Coupon message")
		coupon_box.add_child(message)
	left.add_child(coupon_box)

	var right := Kit.vbox(12)
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_summary(right)
	right.add_child(_shop_button("Continue to checkout", navigate.bind("/shoply/checkout")))
	right.add_child(_text("Secure checkout · 30-day returns", 13, P.SHOP_MUTED))
	row.add_child(right)


func _checkout(page: VBoxContainer) -> void:
	var steps := Kit.hbox(18)
	for step in ["Bag", "Details", "Confirmation"]:
		var active: bool = (step == "Confirmation") == (confirmed_order != null) and step != "Bag"
		steps.add_child(_caps(step, P.SHOP_INK if active else P.SHOP_MUTED))
	page.add_child(steps)
	var user := ShoplyStore.user()
	if confirmed_order != null:
		var card := _card()
		var body := Kit.vbox(10)
		body.add_child(_caps("Order confirmed · %s" % str(confirmed_order["id"]).replace("order-", "#")))
		body.add_child(_serif("Thanks, %s." % user["name"], 32))
		body.add_child(_text("Your order is confirmed and will ship within two business days.", 15))
		var links := Kit.hbox(12)
		links.add_child(_shop_link("View order", "/shoply/orders/%s" % confirmed_order["id"]))
		links.add_child(_shop_link("Continue shopping", "/shoply"))
		body.add_child(links)
		card.add_child(body)
		page.add_child(card)
		return
	if ShoplyStore.items().is_empty():
		page.add_child(_serif("Your bag is ready for something useful.", 30))
		page.add_child(_shop_button("Return to product", navigate.bind("/shoply/product/everyday-pack")))
		return
	var row := _row(28)
	page.add_child(row)
	var form := Kit.vbox(10)
	form.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	form.size_flags_stretch_ratio = 1.5
	form.add_child(_caps("Secure checkout"))
	form.add_child(_serif("Delivery details", 36))
	for field in [["Full name", user["name"]], ["Street address", "42 Mercer Street"], ["City", "Portland"],
			["Postal code", "97205"], ["Card number", "4242 4242 4242 4242"], ["Expiry", "10/29"], ["Security code", "123"]]:
		form.add_child(_caps(field[0], P.SHOP_MUTED))
		var input := LineEdit.new()
		input.text = field[1]
		form.add_child(input)
	row.add_child(form)
	var side := Kit.vbox(12)
	side.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_summary(side)
	var variant := str(mutate.call("checkout.confirmButton", "primary"))
	var on_confirm := func():
		record.call("CONFIRM_ORDER", "checkout.confirmButton", {})
		confirmed_order = ShoplyStore.place_order()
		rerender.call()
	var confirm := _shop_button("Confirm order", on_confirm, variant != "primary")
	confirm.name = "ConfirmOrder"
	confirm.set_meta("variant", variant)
	Kit.evidence(confirm, "checkout.confirmButton", "Confirm order button", "%s action style" % variant.capitalize())
	side.add_child(confirm)
	side.add_child(_text("Your payment details are encrypted.", 13, P.SHOP_MUTED))
	row.add_child(side)


func _orders(page: VBoxContainer) -> void:
	page.add_child(_caps("Your account"))
	page.add_child(_serif("Orders", 36))
	for order in ShoplyStore.orders:
		var product: Variant = ShoplyStore.get_product(order["productId"])
		var card := _card()
		var line := Kit.hbox(16)
		card.add_child(line)
		var info := Kit.vbox(2)
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.add_child(_text("Order %s" % str(order["id"]).replace("order-", "#"), 13, P.SHOP_MUTED))
		info.add_child(_serif(product["name"] if product != null else "Shoply item", 18))
		info.add_child(_text("Placed %s · Qty %d" % [order["placedAt"], int(order["quantity"])], 13, P.SHOP_MUTED))
		line.add_child(info)
		line.add_child(_caps(str(order["status"]).to_lower(), P.SHOP_ACCENT))
		line.add_child(_text(Rules.money(float(order["total"])), 15))
		line.add_child(_shop_link("View order →", "/shoply/orders/%s" % order["id"]))
		page.add_child(card)


func _order_detail(page: VBoxContainer, order_id: String) -> void:
	var order: Variant = ShoplyStore.get_order(order_id)
	if order == null:
		page.add_child(_serif("Order not found.", 34))
		return
	page.add_child(_shop_link("← All orders", "/shoply/orders"))
	page.add_child(_caps("Order %s" % order_id.replace("order-", "#")))
	page.add_child(_serif("Order details", 36))
	var status := _caps(str(order["status"]).to_lower(), P.SHOP_ACCENT)
	Kit.evidence(status, "orders.status", "Order status")
	page.add_child(status)
	var row := _row(24)
	page.add_child(row)
	var product: Variant = ShoplyStore.get_product(order["productId"])
	var details := _card()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var detail_body := Kit.vbox(8)
	detail_body.add_child(_serif(product["name"] if product != null else "Shoply item", 22))
	for pair in [["Placed", order["placedAt"]], ["Quantity", str(int(order["quantity"]))], ["Delivery", "Standard shipping"]]:
		detail_body.add_child(_text("%s   %s" % pair, 15))
	var charged := float(order["total"])
	if float(order.get("discount", 0.0)) > 0.0:
		var kept := float(mutate.call("orders.discountKept", 1.0))
		charged = Rules.round_currency(float(order["subtotal"]) - float(order["discount"]) * kept + float(order["shipping"]))
	var total := _text("Total   %s" % Rules.money(charged), 15)
	Kit.evidence(total, "orders.total", "Order total", Rules.money(charged))
	detail_body.add_child(total)
	details.add_child(detail_body)
	row.add_child(details)
	var actions := _card()
	actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var actions_body := Kit.vbox(10)
	actions_body.add_child(_serif("Need to make a change?", 20))
	if order["status"] == "PROCESSING" and not bool(mutate.call("orders.cancelAction.visible", true)):
		var help := _text("To change this order, contact support.", 15)
		Kit.evidence(help, "orders.cancelAction", "Cancel action", "Not shown, contact support")
		actions_body.add_child(help)
	elif order["status"] == "PROCESSING":
		actions_body.add_child(_text("This order is still processing and can be cancelled before shipment.", 15))
		var normal_destination := "/shoply/orders/%s/cancel" % order_id
		var destination := str(mutate.call("orders.cancelAction.destination", normal_destination))
		var cancel := _shop_button("Cancel order", func():
			record.call("CANCEL_ORDER", order_id, { "destination": destination })
			navigate.call(destination))
		cancel.name = "CancelOrder"
		Kit.evidence(cancel, "orders.cancelAction", "Cancel action")
		actions_body.add_child(cancel)
	else:
		actions_body.add_child(_text("This order has been %s and can no longer be cancelled." % str(order["status"]).to_lower(), 15))
	actions.add_child(actions_body)
	row.add_child(actions)


func _cancel(page: VBoxContainer, order_id: String) -> void:
	var order: Variant = ShoplyStore.get_order(order_id)
	if order == null:
		page.add_child(_serif("Order not found.", 34))
		return
	var processing: bool = order["status"] == "PROCESSING"
	var card := _card()
	Kit.evidence(card, "orders.cancelFlow", "Screen shown", "Cancel your order" if processing else "Order cancelled")
	var body := Kit.vbox(12)
	card.add_child(body)
	body.add_child(_caps("Order %s" % order_id.replace("order-", "#")))
	if processing:
		body.add_child(_serif("Cancel your order", 32))
		body.add_child(_text("Select a reason below. We will stop fulfillment and return the payment to your original method.", 15))
		var group := ButtonGroup.new()
		for reason in ["Ordered by mistake", "Need to change the delivery address", "Found another product"]:
			var choice := CheckBox.new()
			choice.text = reason
			choice.button_group = group
			choice.add_theme_color_override("font_color", P.SHOP_INK)
			choice.button_pressed = reason == "Ordered by mistake"
			body.add_child(choice)
		body.add_child(_shop_button("Confirm cancellation", func():
			ShoplyStore.cancel_order(order_id)
			record.call("CONFIRM_CANCELLATION", order_id, {})))
		body.add_child(_shop_link("Keep this order", "/shoply/orders/%s" % order_id))
	else:
		body.add_child(_serif("Order cancelled", 32))
		body.add_child(_text("Fulfillment has stopped. Your refund will return to the original payment method.", 15))
		body.add_child(_shop_link("Return to orders", "/shoply/orders"))
	page.add_child(card)


func _payment(page: VBoxContainer) -> void:
	var card := _card()
	Kit.evidence(card, "payment.form", "Screen shown", "Payment details (enter a card to continue with this purchase)")
	var body := Kit.vbox(10)
	card.add_child(body)
	body.add_child(_caps("Secure checkout"))
	body.add_child(_serif("Payment details", 32))
	body.add_child(_text("Enter a card to continue with this purchase.", 15))
	for field in [["Card number", "4242 4242 4242 4242"], ["Name on card", "Jordan Park"], ["Expiry", "MM / YY"], ["Security code", "CVC"]]:
		body.add_child(_caps(field[0], P.SHOP_MUTED))
		var input := LineEdit.new()
		input.placeholder_text = field[1]
		body.add_child(input)
	body.add_child(_shop_button("Pay now", func(): pass))
	body.add_child(_shop_link("Return to orders", "/shoply/orders"))
	page.add_child(card)
