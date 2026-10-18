import { expect, test, type Page } from '@playwright/test'

const CHAT_TIMEOUT = { timeout: 20_000 }

function win(page: Page, name: string) {
  return page.getByRole('region', { name, exact: true })
}

async function openApp(page: Page, name: string) {
  await page.getByRole('navigation', { name: 'Desktop' }).getByRole('button', { name, exact: true }).click()
}

async function goTo(page: Page, address: string) {
  await openApp(page, 'Browser')
  const input = win(page, 'Browser').getByRole('textbox', { name: 'Address' })
  await input.fill(address)
  await input.press('Enter')
}

async function startTicketFromChat(page: Page, ticketId: string) {
  await openApp(page, 'Messenger')
  await win(page, 'Messenger').getByRole('button', { name: `Open ${ticketId} in QA Tracker` }).click(CHAT_TIMEOUT)
  await win(page, 'QA Tracker').getByRole('button', { name: 'Start test' }).click()
}

async function submitReport(
  page: Page,
  requirement: RegExp,
  observation: RegExp,
  severity: 'LOW' | 'MEDIUM' | 'HIGH',
) {
  await openApp(page, 'QA Tracker')
  const tracker = win(page, 'QA Tracker')
  await tracker.getByRole('button', { name: 'Create report' }).click()
  await tracker.getByRole('radio', { name: requirement }).check()
  await tracker.getByRole('radio', { name: observation }).check()
  await tracker.getByRole('radio', { name: new RegExp(`^${severity}`) }).check()
  await tracker.getByRole('button', { name: 'Submit for QA Review' }).click()
  await expect(tracker.getByRole('heading', { name: 'VALID' })).toBeVisible()
  await expect(tracker.getByText('100 / 100')).toBeVisible()
}

async function replyInChat(page: Page, answer: RegExp, nextExpected: string | RegExp) {
  await win(page, 'QA Tracker').getByRole('button', { name: 'The team replied · Open Messenger' }).click()
  const reply = page.getByRole('group', { name: 'Reply' })
  await reply.getByRole('button', { name: answer }).click(CHAT_TIMEOUT)
  await expect(page.getByRole('list', { name: 'Team chat' })).toContainText(nextExpected, CHAT_TIMEOUT)
}

test('plays T01 through T04 on the QA workstation, from briefing to chapter finale', async ({ page }) => {
  test.setTimeout(180_000)
  await page.setViewportSize({ width: 1440, height: 900 })
  await page.goto('/start')
  await page.evaluate(() => window.localStorage.clear())
  await page.reload()

  await expect(page).toHaveTitle('Nothing Wrong')
  await expect(page.getByRole('heading', { name: 'NOTHING WRONG' })).toBeVisible()
  await page.getByRole('link', { name: /Start work/i }).click()
  await expect(page.getByRole('heading', { name: 'J. PARK' })).toBeVisible()
  await page.getByRole('button', { name: 'Sign in' }).click()
  await expect(page).toHaveURL(/\/desktop$/)

  // The briefing arrives as a chat notification.
  await expect(page.locator('.os-toast').filter({ hasText: 'Maya Kim' }).first()).toBeVisible(CHAT_TIMEOUT)
  await openApp(page, 'Messenger')
  const chat = page.getByRole('list', { name: 'Team chat' })
  await expect(chat).toContainText('Nothing wrong with this build.', CHAT_TIMEOUT)

  // T01: tutorial. Accept in QA Tracker, open the link, compare with the spec.
  await startTicketFromChat(page, 'T01')
  const guide = page.getByRole('complementary', { name: 'First Ticket tutorial' })
  await expect(guide).toContainText('Open Shoply in the Browser.')
  await goTo(page, 'docs.nothingwrong.local/checkout-interaction-specification')
  await expect(win(page, 'Browser').getByText(/Primary action: solid dark fill/)).toBeVisible()
  await openApp(page, 'QA Tracker')
  await win(page, 'QA Tracker').getByRole('button', { name: 'shoply.local/product/everyday-pack' }).click()

  const browser = win(page, 'Browser')
  await expect(browser.getByRole('heading', { name: 'Everyday Carry Pack' })).toBeVisible()
  await expect(guide).toContainText('Try Shoply as a customer.')
  const productViewport = browser.getByTestId('product-viewport')
  await browser.getByRole('button', { name: 'Tablet' }).click()
  await expect(productViewport).toHaveCSS('width', '768px')
  await browser.getByRole('button', { name: 'Mobile' }).click()
  await expect(productViewport).toHaveCSS('width', '390px')
  await browser.getByRole('button', { name: 'Desktop' }).click()

  await browser.getByRole('button', { name: 'Add to bag' }).click()
  await browser.getByRole('link', { name: 'View bag' }).click()
  await browser.getByRole('link', { name: 'Continue to checkout' }).click()
  await expect(guide).toContainText('Check this screen against the Ticket.')
  await expect(browser.getByRole('button', { name: 'Confirm order' })).toHaveAttribute('data-variant', 'secondary')
  await browser.getByRole('button', { name: 'Capture' }).click()
  await expect(guide).toContainText('Turn your observation into a Report.')

  await openApp(page, 'QA Notes')
  await expect(win(page, 'QA Notes').getByRole('list', { name: 'Captured values' })).toContainText(
    'Confirm order button: Secondary action style',
  )

  await submitReport(
    page,
    /final confirmation control is presented as the primary action/,
    /Confirm order button: Secondary action style/,
    'LOW',
  )
  await expect(win(page, 'QA Tracker').getByText('Level up! You are now Level 2.')).toBeVisible()
  await win(page, 'QA Tracker').getByRole('button', { name: 'The team replied · Open Messenger' }).click()
  await expect(chat).toContainText('02:14 · release-bot', CHAT_TIMEOUT)
  const reply = page.getByRole('group', { name: 'Reply' })
  await reply.getByRole('button', { name: /designer changed the button/ }).click(CHAT_TIMEOUT)
  await expect(chat).toContainText('Look at the author again.', CHAT_TIMEOUT)
  await reply.getByRole('button', { name: /automated merge modified it overnight/ }).click(CHAT_TIMEOUT)
  await expect(chat).toContainText('charged less than expected', CHAT_TIMEOUT)

  // Progress survives a reload without replaying the chat.
  await page.reload()
  await openApp(page, 'QA Tracker')
  await expect(win(page, 'QA Tracker').getByText('100 XP', { exact: true })).toBeVisible()
  await expect(win(page, 'QA Tracker').getByText('102', { exact: true })).toBeVisible()

  // T02: guided data check.
  await startTicketFromChat(page, 'T02')
  await openApp(page, 'QA Tracker')
  await win(page, 'QA Tracker').getByRole('button', { name: 'shoply.local/product/everyday-pack' }).click()
  await browser.getByRole('button', { name: 'Add to bag' }).click()
  await browser.getByRole('link', { name: 'View bag' }).click()
  await browser.getByLabel('Quantity for Everyday Carry Pack').selectOption('2')
  await expect(page.getByRole('complementary', { name: 'Guided Ticket' })).toContainText('does every figure agree?')
  await expect(browser.locator('[data-evidence-target="cart.subtotal"]')).toHaveText('$50.00')
  await expect(browser.locator('[data-evidence-target="cart.lineTotal"]')).toHaveText('$60.00')
  await browser.getByRole('button', { name: 'Capture' }).click()
  await submitReport(page, /subtotal equals product price multiplied by quantity/, /^Subtotal: \$50\.00/, 'MEDIUM')
  await replyInChat(page, /same overnight merge by release-bot/, 'Cancellations actually dropped')

  // T03: the player types the order address from the briefing.
  await startTicketFromChat(page, 'T03')
  await goTo(page, 'shoply.local/orders/order-1042')
  await expect(browser.getByRole('heading', { name: 'Order details' })).toBeVisible()
  await expect(browser.getByRole('group', { name: 'Shoply account' })).toHaveCount(0)
  await browser.getByRole('link', { name: 'Cancel order' }).click()
  await expect(browser.getByRole('heading', { name: 'Payment details' })).toBeVisible()
  await expect(browser.getByRole('textbox', { name: 'Address' })).toHaveValue('https://shoply.local/payment')
  await browser.getByRole('button', { name: 'Capture' }).click()
  await submitReport(page, /Cancel Order opens the return or cancellation flow/, /Screen shown: Payment details/, 'HIGH')
  await replyInChat(page, /release-bot merged old, archived branches/, 'Account Switcher')

  // T04: open-ended conditional check with the Account Switcher.
  await startTicketFromChat(page, 'T04')
  await goTo(page, 'shoply.local')
  await expect(browser.getByRole('group', { name: 'Shoply account' })).toBeVisible()
  await browser.getByRole('button', { name: 'Add to bag' }).click()
  await browser.getByRole('link', { name: 'View bag' }).click()
  await browser.getByLabel('Coupon code').fill('SAVE20')
  await browser.getByRole('button', { name: 'Apply' }).click()
  await expect(browser.getByText('SAVE20 is available to Gold members only')).toBeVisible()
  await browser.getByRole('button', { name: 'Gold' }).click()
  await expect(browser.locator('[data-evidence-target="cart.discount"]')).toHaveText('−$6.00')
  await browser.getByLabel('Quantity for Everyday Carry Pack').selectOption('3')
  await expect(browser.locator('[data-evidence-target="cart.discount"]')).toHaveText('−$9.00')
  await browser.getByRole('button', { name: 'Capture' }).click()
  await submitReport(page, /20% discount at every quantity/, /Discount: −\$9\.00/, 'MEDIUM')
  await replyInChat(page, /widened merge rule/, 'Chapter 1 · Release Candidate 3 complete.')
  await expect(chat).toContainText('That was me.')

  await openApp(page, 'QA Tracker')
  const tracker = win(page, 'QA Tracker')
  await expect(tracker.getByText('400 XP', { exact: true })).toBeVisible()
  await expect(tracker.getByText('111', { exact: true })).toBeVisible()
  await tracker.getByRole('button', { name: 'Case File', exact: true }).click()
  await expect(tracker.getByText('Case closed')).toBeVisible()
  await page.reload()
  await openApp(page, 'QA Tracker')
  await expect(win(page, 'QA Tracker').getByText('400 XP', { exact: true })).toBeVisible()
  await expect(win(page, 'QA Tracker').getByText('111', { exact: true })).toBeVisible()
})
