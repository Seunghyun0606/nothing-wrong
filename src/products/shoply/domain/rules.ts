import type {
  CouponCode,
  CouponResult,
  OrderSummary,
  PricedCartItem,
  ShoplyTier,
} from './types'

export const STANDARD_SHIPPING = 5
export const FREE_SHIPPING_THRESHOLD = 50

function roundCurrency(value: number): number {
  return Math.round((value + Number.EPSILON) * 100) / 100
}

export function calculateSubtotal(items: readonly PricedCartItem[]): number {
  return roundCurrency(
    items.reduce((total, item) => {
      if (!Number.isInteger(item.quantity) || item.quantity < 1) {
        throw new Error('Cart quantity must be a positive integer')
      }
      if (!Number.isFinite(item.product.price) || item.product.price < 0) {
        throw new Error('Product price must be a non-negative number')
      }
      return total + item.product.price * item.quantity
    }, 0),
  )
}

export function evaluateCoupon(
  subtotal: number,
  requestedCode: string,
  tier: ShoplyTier,
): CouponResult {
  const code = requestedCode.trim().toUpperCase()
  if (code === '') {
    return { discount: 0, valid: true, message: 'No coupon applied' }
  }

  if (code === 'SAVE10') {
    return {
      code: 'SAVE10',
      discount: roundCurrency(subtotal * 0.1),
      valid: true,
      message: 'SAVE10 applied — 10% off',
    }
  }

  if (code === 'SAVE20') {
    if (tier !== 'GOLD') {
      return {
        code: 'SAVE20',
        discount: 0,
        valid: false,
        message: 'SAVE20 is available to Gold members only',
      }
    }
    return {
      code: 'SAVE20',
      discount: roundCurrency(subtotal * 0.2),
      valid: true,
      message: 'SAVE20 applied — Gold 20% off',
    }
  }

  return { discount: 0, valid: false, message: 'Coupon code not recognized' }
}

export function calculateShipping(subtotal: number): number {
  return subtotal >= FREE_SHIPPING_THRESHOLD ? 0 : STANDARD_SHIPPING
}

export function calculateOrderSummary(
  items: readonly PricedCartItem[],
  requestedCode: string,
  tier: ShoplyTier,
): OrderSummary {
  const subtotal = calculateSubtotal(items)
  const coupon = evaluateCoupon(subtotal, requestedCode, tier)
  const shipping = calculateShipping(subtotal)

  return {
    ...coupon,
    subtotal,
    shipping,
    total: roundCurrency(subtotal - coupon.discount + shipping),
  }
}

export function isCouponCode(value: string): value is CouponCode {
  return value === 'SAVE10' || value === 'SAVE20'
}
