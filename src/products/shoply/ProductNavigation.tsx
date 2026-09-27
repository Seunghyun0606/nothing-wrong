import {
  createContext,
  useContext,
  useMemo,
  type MouseEvent,
  type MouseEventHandler,
  type PropsWithChildren,
} from 'react'
import { Link } from 'react-router-dom'

interface ProductNavigationValue {
  currentPath: string
  navigate: (path: string) => void
}

const ProductNavigationContext = createContext<ProductNavigationValue | null>(null)

interface ProductNavigationProviderProps extends PropsWithChildren {
  currentPath: string
  onNavigate: (path: string) => void
}

export function ProductNavigationProvider({
  children,
  currentPath,
  onNavigate,
}: ProductNavigationProviderProps) {
  const value = useMemo(
    () => ({ currentPath, navigate: onNavigate }),
    [currentPath, onNavigate],
  )

  return (
    <ProductNavigationContext.Provider value={value}>
      {children}
    </ProductNavigationContext.Provider>
  )
}

interface ProductLinkProps extends PropsWithChildren {
  className?: string
  to: string
  'aria-label'?: string
  'data-evidence-target'?: string
  onClick?: MouseEventHandler<HTMLAnchorElement>
}

export function ProductLink({ children, className, onClick, to, ...props }: ProductLinkProps) {
  const navigation = useContext(ProductNavigationContext)

  if (!navigation) {
    return <Link className={className} onClick={onClick} to={to} {...props}>{children}</Link>
  }

  function handleClick(event: MouseEvent<HTMLAnchorElement>) {
    onClick?.(event)
    if (event.defaultPrevented) return

    if (
      event.button !== 0 ||
      event.metaKey ||
      event.ctrlKey ||
      event.shiftKey ||
      event.altKey
    ) {
      return
    }

    event.preventDefault()
    navigation?.navigate(to)
  }

  return <a className={className} href={to} onClick={handleClick} {...props}>{children}</a>
}
