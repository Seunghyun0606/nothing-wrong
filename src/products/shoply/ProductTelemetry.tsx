import { createContext, useContext, type PropsWithChildren } from 'react'

export interface ProductInteraction {
  type: string
  target?: string
  payload?: Record<string, unknown>
}

const ProductTelemetryContext = createContext<(action: ProductInteraction) => void>(
  () => undefined,
)

interface ProductTelemetryProviderProps extends PropsWithChildren {
  onInteraction: (action: ProductInteraction) => void
}

export function ProductTelemetryProvider({
  children,
  onInteraction,
}: ProductTelemetryProviderProps) {
  return (
    <ProductTelemetryContext.Provider value={onInteraction}>
      {children}
    </ProductTelemetryContext.Provider>
  )
}

export function useProductTelemetry() {
  return useContext(ProductTelemetryContext)
}
