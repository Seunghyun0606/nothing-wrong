import { T01_SCENARIO } from '../../scenarios/shoply/t01'
import { T02_SCENARIO } from '../../scenarios/shoply/t02'
import { resolveGuideStep } from './resolveGuideStep'

function context(currentPath: string, quantity = 0, capturedPaths: string[] = []) {
  return {
    test: { account: 'BASIC' as const, viewport: 'DESKTOP' as const, locale: 'en-US', currentPath },
    productState: { cart: { quantity }, coupon: '' },
    workspace: { evidenceCount: capturedPaths.length, capturedPaths },
  }
}

describe('resolveGuideStep', () => {
  it('follows the T01 journey from product to Report', () => {
    const steps = T01_SCENARIO.guide!.workspace!
    expect(resolveGuideStep(steps, context('/shoply/product/everyday-pack'))?.id).toBe('T01-GUIDE-PRODUCT')
    expect(resolveGuideStep(steps, context('/shoply/cart', 1))?.id).toBe('T01-GUIDE-CART')
    expect(resolveGuideStep(steps, context('/shoply/checkout', 1))?.id).toBe('T01-GUIDE-CHECKOUT')
    expect(resolveGuideStep(steps, context('/shoply/orders'))?.id).toBe('T01-GUIDE-DETOUR')
    expect(
      resolveGuideStep(steps, context('/shoply/product/everyday-pack', 1, ['/shoply/checkout']))?.id,
    ).toBe('T01-GUIDE-CAPTURED')
  })

  it('nudges T02 toward a second item without naming the defect', () => {
    const steps = T02_SCENARIO.guide!.workspace!
    expect(resolveGuideStep(steps, context('/shoply/cart', 1))?.id).toBe('T02-GUIDE-QUANTITY')
    expect(resolveGuideStep(steps, context('/shoply/cart', 2))?.id).toBe('T02-GUIDE-MATH')
    for (const step of steps) {
      expect(step.instruction).not.toMatch(/\$50/)
    }
  })
})
