# Game

Framework-independent game contracts and engines live here.

- `domain/`: Zod-backed domain types, initial state, and Ticket lifecycle
- `mutations/`: context-aware, Product-agnostic Mutation evaluation
- `scenarios/`: Scenario input validation and explicit validation errors
- `test/`: reusable domain test fixtures only

This module must not import React or access browser persistence directly.
