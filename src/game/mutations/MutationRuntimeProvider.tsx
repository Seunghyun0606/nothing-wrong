import { createContext, useContext, useMemo, type PropsWithChildren } from 'react'

import type { Mutation } from '../domain/schemas'
import { resolveMutation, type MutationRuntimeContext } from './resolveMutation'

interface MutationRuntimeValue {
  mutations: readonly Mutation[]
  context: MutationRuntimeContext
}

const EMPTY_RUNTIME: MutationRuntimeValue = {
  mutations: [],
  context: {
    test: {
      account: 'GUEST',
      viewport: 'DESKTOP',
      locale: 'en-US',
      currentPath: '/',
    },
    productState: {},
  },
}

const MutationRuntimeContextValue = createContext<MutationRuntimeValue>(EMPTY_RUNTIME)

interface MutationRuntimeProviderProps extends PropsWithChildren {
  mutations: readonly Mutation[]
  context: MutationRuntimeContext
}

export function MutationRuntimeProvider({
  mutations,
  context,
  children,
}: MutationRuntimeProviderProps) {
  const value = useMemo(() => ({ mutations, context }), [context, mutations])

  return (
    <MutationRuntimeContextValue.Provider value={value}>
      {children}
    </MutationRuntimeContextValue.Provider>
  )
}

export function useMutationValue<T>(target: string, baseValue: T): T {
  const runtime = useContext(MutationRuntimeContextValue)
  return resolveMutation(target, baseValue, runtime.context, runtime.mutations)
}
