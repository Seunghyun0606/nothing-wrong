export const SHOPLY_HOST = 'shoply.local'
export const DOCS_HOST = 'docs.nothingwrong.local'

export type BrowserLocation =
  | { kind: 'newtab' }
  | { kind: 'shoply'; path: string }
  | { kind: 'docs'; slug: string }
  | { kind: 'unreachable'; address: string }

export const NEW_TAB: BrowserLocation = { kind: 'newtab' }

/** Turns typed text or a link into a location in the in-game browser. */
export function parseAddress(input: string): BrowserLocation {
  const trimmed = input.trim()
  if (trimmed === '' || /^about:/i.test(trimmed)) return NEW_TAB

  const withoutProtocol = trimmed.replace(/^[a-z]+:\/\//i, '')
  const [rawHost = '', ...rest] = withoutProtocol.split('/')
  const host = rawHost.toLowerCase().replace(/^www\./, '').replace(/:\d+$/, '')
  const path = rest.join('/').split(/[?#]/)[0]?.replace(/\/+$/, '') ?? ''

  if (host === SHOPLY_HOST) {
    return { kind: 'shoply', path: path ? `/shoply/${path}` : '/shoply' }
  }

  if (host === DOCS_HOST) {
    return { kind: 'docs', slug: path.split('/')[0]?.toLowerCase() ?? '' }
  }

  return { kind: 'unreachable', address: trimmed }
}

export function shoplyLocation(path: string): BrowserLocation {
  return { kind: 'shoply', path }
}

export function formatAddress(location: BrowserLocation): string {
  switch (location.kind) {
    case 'newtab':
      return ''
    case 'shoply':
      return `https://${SHOPLY_HOST}${location.path.replace(/^\/shoply/, '') || '/'}`
    case 'docs':
      return `https://${DOCS_HOST}/${location.slug}`
    case 'unreachable':
      return location.address
  }
}

export function docSlug(name: string): string {
  return name
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
}

export function docUrl(name: string): string {
  return `https://${DOCS_HOST}/${docSlug(name)}`
}

export function shoplyUrl(path: string): string {
  return formatAddress(shoplyLocation(path))
}

/** Address shown to the player without the protocol, e.g. shoply.local/cart. */
export function displayAddress(url: string): string {
  return url.replace(/^[a-z]+:\/\//i, '')
}
