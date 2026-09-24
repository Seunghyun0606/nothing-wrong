import { expect, test } from '@playwright/test'

test('completes the refresh-safe T01 QA gameplay loop', async ({ page }) => {
  await page.goto('/')

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
  await page.getByRole('link', { name: 'Return to Dashboard' }).click()

  await expect(page.getByText('Resolved')).toBeVisible()
  await expect(page.getByText('100 XP', { exact: true })).toBeVisible()
  await expect(page.getByText('102')).toBeVisible()
  await page.reload()
  await expect(page.getByText('Resolved')).toBeVisible()
  await expect(page.getByText('100 XP', { exact: true })).toBeVisible()
})
