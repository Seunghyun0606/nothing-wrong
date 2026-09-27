export type ShoplyTier = 'BASIC' | 'GOLD'

export interface ShoplyUser {
  id: string
  name: string
  tier: ShoplyTier
}

export interface ShoplyProduct {
  id: string
  name: string
  category: string
  description: string
  price: number
  stock: number
  accent: string
}

export interface CartItem {
  productId: string
  quantity: number
}

export interface PricedCartItem extends CartItem {
  product: ShoplyProduct
}

export type CouponCode = 'SAVE10' | 'SAVE20'

export interface CouponResult {
  code?: CouponCode
  discount: number
  valid: boolean
  message: string
}

export interface OrderSummary extends CouponResult {
  subtotal: number
  shipping: number
  total: number
}

export type ShoplyOrderStatus = 'PROCESSING' | 'SHIPPED' | 'DELIVERED' | 'CANCELLED'

export interface ShoplyOrder {
  id: string
  placedAt: string
  status: ShoplyOrderStatus
  productId: string
  quantity: number
  total: number
}
