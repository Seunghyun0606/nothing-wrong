import {
  createContext,
  useContext,
  useMemo,
  useState,
  type PropsWithChildren,
} from 'react'

import { getShoplyProduct } from './domain/catalog'
import type { CartItem, PricedCartItem, ShoplyUser } from './domain/types'

interface ShoplyContextValue {
  user: ShoplyUser
  items: readonly PricedCartItem[]
  itemCount: number
  coupon: string
  addToCart: (productId: string) => void
  setQuantity: (productId: string, quantity: number) => void
  removeFromCart: (productId: string) => void
  setCoupon: (code: string) => void
}

const ShoplyContext = createContext<ShoplyContextValue | null>(null)

export function ShoplyProvider({ children }: PropsWithChildren) {
  const [cart, setCart] = useState<CartItem[]>([])
  const [coupon, setCoupon] = useState('')
  const user = useMemo<ShoplyUser>(
    () => ({ id: 'shoply-basic-01', name: 'Jordan Park', tier: 'BASIC' }),
    [],
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
    }),
    [coupon, items, user],
  )

  return <ShoplyContext.Provider value={value}>{children}</ShoplyContext.Provider>
}

export function useShoply(): ShoplyContextValue {
  const value = useContext(ShoplyContext)
  if (!value) throw new Error('useShoply must be used inside ShoplyProvider')
  return value
}
