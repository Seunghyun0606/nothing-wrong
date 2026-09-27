import type { QAAccount } from '../../game/domain/schemas'

export type SwitchableAccount = Exclude<QAAccount, 'GUEST'>

interface AccountSwitcherProps {
  value: SwitchableAccount
  onChange: (account: SwitchableAccount) => void
}

export function AccountSwitcher({ value, onChange }: AccountSwitcherProps) {
  return (
    <div className="account-switcher" role="group" aria-label="Shoply account">
      {(['BASIC', 'GOLD'] as const).map((account) => (
        <button
          key={account}
          type="button"
          aria-pressed={value === account}
          onClick={() => onChange(account)}
        >
          {account === 'BASIC' ? 'Basic' : 'Gold'}
        </button>
      ))}
    </div>
  )
}
