import { createShoplyInitialState } from './seed'

describe('createShoplyInitialState', () => {
  it('starts with an empty bag and the default order history', () => {
    expect(createShoplyInitialState()).toMatchObject({
      cart: [],
      coupon: '',
      orders: [{ id: 'order-1042', status: 'PROCESSING' }],
    })
  })

  it('applies cart, coupon, and order status seeds', () => {
    expect(
      createShoplyInitialState({
        cart: [{ productId: 'everyday-pack', quantity: 2 }],
        coupon: ' save20 ',
        orderStatuses: { 'order-1042': 'SHIPPED' },
      }),
    ).toMatchObject({
      cart: [{ productId: 'everyday-pack', quantity: 2 }],
      coupon: 'SAVE20',
      orders: [{ id: 'order-1042', status: 'SHIPPED' }],
    })
  })

  it('rejects malformed seeds', () => {
    expect(() => createShoplyInitialState({ cart: [{ productId: 'everyday-pack', quantity: 0 }] })).toThrow(
      /Invalid Shoply seed/,
    )
  })
})
