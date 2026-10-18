import { z } from 'zod'

import { getShoplyProduct } from './catalog'
import { SHOPLY_ORDERS } from './orders'
import type { CartItem, ShoplyOrder } from './types'

const ShoplySeedSchema = z.object({
  cart: z
    .array(
      z.object({
        productId: z.string().min(1),
        quantity: z.number().int().positive(),
      }),
    )
    .optional(),
  coupon: z.string().optional(),
  orderStatuses: z
    .record(z.string(), z.enum(['PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED']))
    .optional(),
})

export interface ShoplyInitialState {
  cart: CartItem[]
  coupon: string
  orders: ShoplyOrder[]
}

/** Builds Shoply's starting state from an optional seed, ignoring keys Shoply does not own. */
export function createShoplyInitialState(seed?: Readonly<Record<string, unknown>>): ShoplyInitialState {
  const parsed = ShoplySeedSchema.safeParse(seed ?? {})
  if (!parsed.success) {
    throw new Error(`Invalid Shoply seed: ${parsed.error.message}`)
  }

  const { cart = [], coupon = '', orderStatuses = {} } = parsed.data
  return {
    cart: cart.flatMap((item) => {
      const product = getShoplyProduct(item.productId)
      return product
        ? [{ productId: item.productId, quantity: Math.min(item.quantity, product.stock) }]
        : []
    }),
    coupon: coupon.trim().toUpperCase(),
    orders: SHOPLY_ORDERS.map((order) => ({
      ...order,
      status: orderStatuses[order.id] ?? order.status,
    })),
  }
}
