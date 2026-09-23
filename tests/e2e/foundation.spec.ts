import { expect, test } from '@playwright/test'

test('loads the foundation route', async ({ page }) => {
  await page.goto('/')

  await expect(page).toHaveURL(/\/start$/)
  await expect(
    page.getByRole('heading', { name: 'Project foundation ready' }),
  ).toBeVisible()
  await expect(page).toHaveTitle('Nothing Wrong')
})
