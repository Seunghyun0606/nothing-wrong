import { useEffect, useMemo, useRef } from 'react'

import { useGameSession } from '../../game/session/GameSessionProvider'
import { buildMessengerLog } from '../../game/story/messengerLog'
import {
  getStoryChapter,
  isTicketUnlocked,
  SCENARIO_CATALOG,
} from '../../scenarios/shoply/tickets'
import { useDesktop } from './DesktopProvider'

/** Pause before each teammate message. Tests deliver instantly. */
export const MESSAGE_DELAY_MS = import.meta.env.MODE === 'test' ? 0 : 900
/** Extra pause before the very first message of a new game, while the desktop settles. */
export const FIRST_MESSAGE_DELAY_MS = import.meta.env.MODE === 'test' ? 0 : 1800

export function useMessengerLog() {
  const { state } = useGameSession()
  const log = useMemo(
    () =>
      buildMessengerLog({
        scenarios: SCENARIO_CATALOG,
        state,
        isTicketUnlocked,
        getChapter: getStoryChapter,
      }),
    [state],
  )
  const delivered = Math.min(state.story.deliveredCount, log.entries.length)
  const unread = Math.max(0, delivered - Math.min(state.story.readCount, delivered))

  return { ...log, delivered, unread }
}

/** Delivers queued chat entries one at a time and notifies the player. Mount once. */
export function useMessengerDelivery() {
  const { markMessagesDelivered, markMessagesRead } = useGameSession()
  const desktop = useDesktop()
  const { entries, delivered } = useMessengerLog()
  const messengerVisible =
    desktop.windows.messenger.open && !desktop.windows.messenger.minimized
  const next = entries[delivered]
  const latest = useRef({ markMessagesDelivered, pushToast: desktop.pushToast, messengerVisible, next })
  latest.current = { markMessagesDelivered, pushToast: desktop.pushToast, messengerVisible, next }

  useEffect(() => {
    const pending = latest.current.next
    if (!pending) return

    if (MESSAGE_DELAY_MS === 0) {
      latest.current.markMessagesDelivered(entries.length)
      return
    }

    const delay = pending.kind === 'player'
      ? 0
      : delivered === 0
        ? FIRST_MESSAGE_DELAY_MS
        : MESSAGE_DELAY_MS
    const timer = window.setTimeout(() => {
      const current = latest.current
      current.markMessagesDelivered(delivered + 1)
      if (!current.messengerVisible && pending.kind === 'message') {
        current.pushToast({ title: pending.from, text: pending.text, app: 'messenger' })
      }
    }, delay)
    return () => window.clearTimeout(timer)
  }, [delivered, entries.length, next?.id])

  useEffect(() => {
    if (messengerVisible) markMessagesRead(delivered)
  }, [delivered, markMessagesRead, messengerVisible])
}
