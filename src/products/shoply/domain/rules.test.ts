import { SHOPLY_PRODUCTS } from './catalog'
import {
  calculateOrderSummary,
  calculateShipping,
  calculateSubtotal,
  evaluateCoupon,
} from './rules'

const product = SHOPLY_PRODUCTS[0]

if (!product) throw new Error('Shoply test product is missing')

function cart(quantity: number) {
  return [{ productId: product.id, quantity, product }]
}

describe('normal Shoply business rules', () => {
  it('calculates subtotal as price multiplied by quantity', () => {
    expect(calculateSubtotal(cart(2))).toBe(60)
  })

  it('applies SAVE10 to every customer', () => {
    expect(evaluateCoupon(60, 'save10', 'BASIC')).toMatchObject({
      code: 'SAVE10',
      discount: 6,
      valid: true,
    })
  })

  it('applies SAVE20 only to Gold customers', () => {
    expect(evaluateCoupon(60, 'SAVE20', 'BASIC')).toMatchObject({
      discount: 0,
      valid: false,
    })
    expect(evaluateCoupon(60, 'SAVE20', 'GOLD')).toMatchObject({
      code: 'SAVE20',
      discount: 12,
      valid: true,
    })
  })

  it('charges $5 shipping below $50 and provides free shipping at $50', () => {
    expect(calculateShipping(49.99)).toBe(5)
    expect(calculateShipping(50)).toBe(0)
  })

  it('uses the pre-discount subtotal for shipping eligibility', () => {
    expect(calculateOrderSummary(cart(2), 'SAVE10', 'BASIC')).toEqual({
      code: 'SAVE10',
      discount: 6,
      valid: true,
      message: 'SAVE10 applied — 10% off',
      subtotal: 60,
      shipping: 0,
      total: 54,
    })
  })

  it('rejects invalid cart quantities', () => {
    expect(() => calculateSubtotal(cart(0))).toThrow(
      'Cart quantity must be a positive integer',
    )
  })
})
