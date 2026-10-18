import { docSlug, formatAddress, parseAddress } from './browserAddress'

describe('browser addresses', () => {
  it('accepts the Shoply host with or without a protocol', () => {
    expect(parseAddress('shoply.local')).toEqual({ kind: 'shoply', path: '/shoply' })
    expect(parseAddress('  HTTPS://www.Shoply.local/cart/  ')).toEqual({
      kind: 'shoply',
      path: '/shoply/cart',
    })
    expect(parseAddress('shoply.local/orders/order-1042?ref=mail')).toEqual({
      kind: 'shoply',
      path: '/shoply/orders/order-1042',
    })
  })

  it('opens intranet docs and rejects unknown hosts', () => {
    expect(parseAddress('docs.nothingwrong.local/Shoply-Pricing-Rules')).toEqual({
      kind: 'docs',
      slug: 'shoply-pricing-rules',
    })
    expect(parseAddress('shoply.com')).toEqual({ kind: 'unreachable', address: 'shoply.com' })
    expect(parseAddress('')).toEqual({ kind: 'newtab' })
  })

  it('formats locations back into addresses', () => {
    expect(formatAddress({ kind: 'shoply', path: '/shoply/checkout' })).toBe('https://shoply.local/checkout')
    expect(formatAddress({ kind: 'shoply', path: '/shoply' })).toBe('https://shoply.local/')
    expect(docSlug('Checkout interaction specification')).toBe('checkout-interaction-specification')
  })
})
