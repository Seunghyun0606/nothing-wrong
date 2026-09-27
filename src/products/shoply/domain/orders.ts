import type { ShoplyOrder } from './types'

export const SHOPLY_ORDERS: readonly ShoplyOrder[] = [
  {
    id: 'order-1042',
    placedAt: 'September 22, 2026',
    status: 'PROCESSING',
    productId: 'everyday-pack',
    quantity: 1,
    total: 35,
  },
]

export function getShoplyOrder(orderId: string): ShoplyOrder | undefined {
  return SHOPLY_ORDERS.find((order) => order.id === orderId)
}
