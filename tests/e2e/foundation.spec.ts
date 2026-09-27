import { expect, test } from '@playwright/test'

test('completes the refresh-safe T01 through T03 QA gameplay loops', async ({ page }) => {
  await page.goto('/start')
  await page.evaluate(() => window.localStorage.clear())
  await page.reload()

  await expect(page).toHaveURL(/\/start$/)
  await expect(page.getByRole('heading', { name: 'NOTHING WRONG' })).toBeVisible()
  await expect(page).toHaveTitle('Nothing Wrong')

  await page.getByRole('link', { name: /Start work/i }).click()
  await expect(page.getByRole('heading', { name: 'Company login' })).toBeVisible()
  await page.getByRole('button', { name: 'Enter workspace' }).click()

  await expect(page.getByRole('heading', { name: /Good morning/ })).toBeVisible()
  await page.getByRole('link', { name: /Checkout confirmation design review/ }).click()
  await expect(
    page.getByRole('heading', { name: 'Checkout confirmation design review' }),
  ).toBeVisible()
  await page.getByRole('button', { name: 'Start test' }).click()

  await expect(page).toHaveURL(/\/test\/T01$/)
  await expect(page.getByRole('heading', { name: 'Everyday Carry Pack' })).toBeVisible()
  const productViewport = page.getByTestId('product-viewport')
  const desktopWidth = await productViewport.evaluate(
    (element) => element.getBoundingClientRect().width,
  )
  expect(desktopWidth).toBeGreaterThan(768)
  await page.getByRole('button', { name: 'Tablet' }).click()
  await expect(productViewport).toHaveCSS('width', '768px')
  await page.getByRole('button', { name: 'Mobile' }).click()
  await expect(productViewport).toHaveCSS('width', '390px')
  await page.getByRole('button', { name: 'Desktop' }).click()

  await page.getByRole('button', { name: 'Add to bag' }).click()
  await page.getByRole('link', { name: 'View bag' }).click()
  await expect(page.getByRole('heading', { name: 'Shopping bag' })).toBeVisible()

  await page.getByLabel('Quantity for Everyday Carry Pack').selectOption('2')
  await expect(page.getByText('Free')).toBeVisible()
  await page.getByRole('link', { name: 'Continue to checkout' }).click()

  const confirmButton = page.getByRole('button', { name: 'Confirm order' })
  await expect(confirmButton).toBeVisible()
  await expect(confirmButton).toHaveAttribute('data-variant', 'secondary')
  await page.getByRole('button', { name: 'Capture evidence' }).click()
  await expect(page.getByRole('img', { name: /Evidence preview/ })).toBeVisible()
  await page.getByRole('button', { name: 'Create report' }).click()

  await expect(page).toHaveURL(/\/reports\/T01$/)
  await expect(
    page.getByRole('heading', { name: 'Document what you can prove.' }),
  ).toBeVisible()
  await page.getByLabel('Expected behavior').selectOption('Primary action style')
  await page.getByLabel('Actual behavior').selectOption('Secondary action style')
  await page.getByRole('button', { name: 'Submit for QA Review' }).click()

  await expect(page).toHaveURL(/\/review\/T01$/)
  await expect(page.getByRole('heading', { name: 'VALID' })).toBeVisible()
  await expect(page.getByText('100 / 100')).toBeVisible()
  await expect(page.getByText('40', { exact: true })).toBeVisible()
  await expect(page.getByText('25', { exact: true })).toBeVisible()
  await expect(page.getByText('20', { exact: true })).toBeVisible()
  await expect(page.getByText('15', { exact: true })).toBeVisible()
  await expect(page.getByText('+100', { exact: true })).toBeVisible()
  await expect(page.getByText('+2', { exact: true })).toBeVisible()
  await page.getByRole('link', { name: 'Return to Dashboard' }).click()

  await expect(page.getByText('Resolved')).toBeVisible()
  await expect(page.getByText('100 XP', { exact: true })).toBeVisible()
  await expect(page.getByText('102', { exact: true })).toBeVisible()
  await page.reload()
  await expect(page.getByText('Resolved')).toBeVisible()
  await expect(page.getByText('100 XP', { exact: true })).toBeVisible()
  await expect(page.getByText('102', { exact: true })).toBeVisible()

  await page.getByRole('link', { name: /Cart subtotal verification/ }).click()
  await expect(page.getByRole('heading', { name: 'Cart subtotal verification' })).toBeVisible()
  await page.getByRole('button', { name: 'Start test' }).click()

  await expect(page).toHaveURL(/\/test\/T02$/)
  await page.getByRole('button', { name: 'Add to bag' }).click()
  await page.getByRole('link', { name: 'View bag' }).click()
  await page.getByLabel('Quantity for Everyday Carry Pack').selectOption('2')
  await expect(page.locator('[data-evidence-target="cart.subtotal"]')).toHaveText('$50.00')
  await expect(page.getByText('$60.00')).toHaveCount(2)

  await page.getByRole('button', { name: 'Capture evidence' }).click()
  await expect(page.getByRole('img', { name: /Evidence preview/ })).toBeVisible()
  await page.getByRole('button', { name: 'Create report' }).click()

  await expect(page).toHaveURL(/\/reports\/T02$/)
  await page
    .getByLabel('Expected behavior')
    .selectOption('Subtotal should be $60.00 for two $30.00 items')
  await page
    .getByLabel('Actual behavior')
    .selectOption('Subtotal is displayed as $50.00')
  await page.getByLabel('Severity').selectOption('MEDIUM')
  await page.getByRole('button', { name: 'Submit for QA Review' }).click()

  await expect(page).toHaveURL(/\/review\/T02$/)
  await expect(page.getByRole('heading', { name: 'VALID' })).toBeVisible()
  await expect(page.getByText('100 / 100')).toBeVisible()
  await page.getByRole('link', { name: 'Return to Dashboard' }).click()

  await expect(page.getByText('200 XP', { exact: true })).toBeVisible()
  await expect(page.getByText('104', { exact: true })).toBeVisible()
  await expect(page.getByText('1 open')).toBeVisible()
  await page.reload()
  await expect(page.getByText('200 XP', { exact: true })).toBeVisible()
  await expect(page.getByText('104', { exact: true })).toBeVisible()
  await expect(page.getByText('1 open')).toBeVisible()

  await page.getByRole('link', { name: /Order cancellation routing/ }).click()
  await expect(page.getByRole('heading', { name: 'Order cancellation routing' })).toBeVisible()
  await page.getByRole('button', { name: 'Start test' }).click()

  await expect(page).toHaveURL(/\/test\/T03$/)
  await expect(page.getByRole('heading', { name: 'Order details' })).toBeVisible()
  await page.getByRole('link', { name: 'Cancel order' }).click()
  await expect(page.getByRole('heading', { name: 'Payment details' })).toBeVisible()
  await expect(page.getByLabel('Fake URL')).toContainText('shoply.local/payment')
  await page.getByRole('button', { name: 'Capture evidence' }).click()
  await page.getByRole('button', { name: 'Create report' }).click()

  await expect(page).toHaveURL(/\/reports\/T03$/)
  await page
    .getByLabel('Expected behavior')
    .selectOption('Cancellation flow should open for a processing order')
  await page
    .getByLabel('Actual behavior')
    .selectOption('Payment flow opens after selecting Cancel order')
  await page.getByLabel('Severity').selectOption('HIGH')
  await page.getByRole('button', { name: 'Submit for QA Review' }).click()

  await expect(page).toHaveURL(/\/review\/T03$/)
  await expect(page.getByRole('heading', { name: 'VALID' })).toBeVisible()
  await expect(page.getByText('100 / 100')).toBeVisible()
  await page.getByRole('link', { name: 'Return to Dashboard' }).click()

  await expect(page.getByText('300 XP', { exact: true })).toBeVisible()
  await expect(page.getByText('106', { exact: true })).toBeVisible()
  await expect(page.getByText('0 open')).toBeVisible()
  await page.reload()
  await expect(page.getByText('300 XP', { exact: true })).toBeVisible()
  await expect(page.getByText('106', { exact: true })).toBeVisible()
  await expect(page.getByText('0 open')).toBeVisible()
})
