import { defineConfig, devices } from '@playwright/test'

const port = Number(process.env.NOTHING_WRONG_E2E_PORT ?? '4173')
if (!Number.isInteger(port) || port < 1 || port > 65535) {
  throw new Error('NOTHING_WRONG_E2E_PORT must be an integer from 1 to 65535.')
}
const baseURL = `http://127.0.0.1:${port}`

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: Boolean(process.env.CI),
  retries: process.env.CI ? 2 : 0,
  reporter: 'list',
  use: {
    baseURL,
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
  webServer: {
    command: `npm run dev -- --host 127.0.0.1 --port ${port} --strictPort`,
    url: `${baseURL}/start`,
    reuseExistingServer: !process.env.CI,
  },
})
