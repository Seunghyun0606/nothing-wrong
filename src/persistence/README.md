# Persistence

Versioned storage adapters live here. `gameStateStorage.ts` owns the
`nothingwrong.gameState` localStorage boundary and validates every SaveFile before
reading or writing Game State.

Domain and UI modules must not access localStorage directly. Tests inject the minimal
`StorageLike` interface instead of depending on browser globals.
