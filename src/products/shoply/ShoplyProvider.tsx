import {
  createContext,
  useContext,
  useMemo,
  useState,
  type PropsWithChildren,
} from 'react'

import { getShoplyProduct } from './domain/catalog'
import { calculateOrderSummary } from './domain/rules'
import { createShoplyInitialState } from './domain/seed'
import type {
  CartItem,
  PricedCartItem,
  ShoplyOrder,
  ShoplyTier,
  ShoplyUser,
} from './domain/types'

interface ShoplyContextValue {
  user: ShoplyUser
  items: readonly PricedCartItem[]
  itemCount: number
  coupon: string
  orders: readonly ShoplyOrder[]
  addToCart: (productId: string) => void
  setQuantity: (productId: string, quantity: number) => void
  removeFromCart: (productId: string) => void
  setCoupon: (code: string) => void
  placeOrder: () => ShoplyOrder | undefined
  cancelOrder: (orderId: string) => void
  switchAccount: (tier: ShoplyTier, resetProductState: boolean) => void
}

const ShoplyContext = createContext<ShoplyContextValue | null>(null)

interface ShoplyProviderProps extends PropsWithChildren {
  initialAccount?: ShoplyTier
  seed?: Readonly<Record<string, unknown>>
  /** Changing this restarts Shoply from the seed without remounting its children. */
  sessionKey?: string
}

function nextOrderId(orders: readonly ShoplyOrder[]): string {
  const highest = orders.reduce((max, order) => {
    const number = Number(order.id.replace('order-', ''))
    return Number.isFinite(number) ? Math.max(max, number) : max
  }, 1000)
  return `order-${highest + 1}`
}

export function ShoplyProvider({
  children,
  initialAccount = 'BASIC',
  seed,
  sessionKey,
}: ShoplyProviderProps) {
  const [initialState, setInitialState] = useState(() => createShoplyInitialState(seed))
  const [cart, setCart] = useState<CartItem[]>(initialState.cart)
  const [coupon, setCoupon] = useState(initialState.coupon)
  const [account, setAccount] = useState<ShoplyTier>(initialAccount)
  const [orders, setOrders] = useState<ShoplyOrder[]>(initialState.orders)
  const [activeSessionKey, setActiveSessionKey] = useState(sessionKey)

  if (sessionKey !== activeSessionKey) {
    const restarted = createShoplyInitialState(seed)
    setActiveSessionKey(sessionKey)
    setInitialState(restarted)
    setCart(restarted.cart)
    setCoupon(restarted.coupon)
    setAccount(initialAccount)
    setOrders(restarted.orders)
  }
  const user = useMemo<ShoplyUser>(
    () => account === 'GOLD'
      ? { id: 'shoply-gold-01', name: 'Avery Chen', tier: account }
      : { id: 'shoply-basic-01', name: 'Jordan Park', tier: account },
    [account],
  )
  const items = useMemo(
    () =>
      cart.flatMap((item) => {
        const product = getShoplyProduct(item.productId)
        return product ? [{ ...item, product }] : []
      }),
    [cart],
  )

  const value = useMemo<ShoplyContextValue>(
    () => ({
      user,
      items,
      itemCount: items.reduce((count, item) => count + item.quantity, 0),
      coupon,
      orders,
      addToCart(productId) {
        const product = getShoplyProduct(productId)
        if (!product) {
          throw new Error(`Unknown Shoply product: ${productId}`)
        }
        setCart((current) => {
          const existing = current.find((item) => item.productId === productId)
          if (!existing) return [...current, { productId, quantity: 1 }]
          return current.map((item) =>
            item.productId === productId
              ? { ...item, quantity: Math.min(item.quantity + 1, product.stock) }
              : item,
          )
        })
      },
      setQuantity(productId, quantity) {
        const product = getShoplyProduct(productId)
        if (!product) return
        const nextQuantity = Math.max(1, Math.min(Math.trunc(quantity), product.stock))
        setCart((current) =>
          current.map((item) =>
            item.productId === productId ? { ...item, quantity: nextQuantity } : item,
          ),
        )
      },
      removeFromCart(productId) {
        setCart((current) => current.filter((item) => item.productId !== productId))
      },
      setCoupon,
      placeOrder() {
        const [firstItem] = items
        if (!firstItem) return undefined

        const summary = calculateOrderSummary(items, coupon, user.tier)
        const order: ShoplyOrder = {
          id: nextOrderId(orders),
          placedAt: 'Today',
          status: 'PROCESSING',
          productId: firstItem.productId,
          quantity: items.reduce((count, item) => count + item.quantity, 0),
          total: summary.total,
        }
        setOrders((current) => [order, ...current])
        setCart([])
        setCoupon('')
        return order
      },
      cancelOrder(orderId) {
        setOrders((current) =>
          current.map((order) =>
            order.id === orderId && order.status === 'PROCESSING'
              ? { ...order, status: 'CANCELLED' }
              : order,
          ),
        )
      },
      switchAccount(tier, resetProductState) {
        if (tier === account) return
        setAccount(tier)
        if (resetProductState) {
          setCart(initialState.cart)
          setCoupon(initialState.coupon)
          setOrders(initialState.orders)
        }
      },
    }),
    [account, coupon, initialState, items, orders, user],
  )

  return <ShoplyContext.Provider value={value}>{children}</ShoplyContext.Provider>
}

export function useShoply(): ShoplyContextValue {
  const value = useContext(ShoplyContext)
  if (!value) throw new Error('useShoply must be used inside ShoplyProvider')
  return value
}
