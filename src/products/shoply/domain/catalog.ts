import type { ShoplyProduct } from './types'

export const SHOPLY_PRODUCTS: readonly ShoplyProduct[] = [
  {
    id: 'everyday-pack',
    name: 'Everyday Carry Pack',
    category: 'Bags / Everyday',
    description:
      'A structured 18L pack with a padded laptop sleeve, quick-access top pocket, and weather-resistant recycled shell.',
    price: 30,
    stock: 12,
    accent: 'coral',
  },
]

export function getShoplyProduct(productId: string): ShoplyProduct | undefined {
  return SHOPLY_PRODUCTS.find((product) => product.id === productId)
}
