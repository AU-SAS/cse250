# Issue: Rename `app_user_role` to `user_role`?

## Context
Current join table name: `app_user_role`

Current structure includes:
- `app_id`
- `user_id`
- `role_id`
- Primary key: `(app_id, user_id, role_id)`

This means role assignment is app-scoped, not global.

## Discussion Summary
- Proposal: rename `app_user_role` to `user_role` for naming simplicity.
- Concern: other core tables (`role`, `permission`, `user`) do not use `app_` prefix.
- Counterpoint: `app_user_role` is a join table where `app_id` is part of the business meaning, not just metadata.

## Recommendation
Keep `app_user_role` as-is unless the data model changes to global role assignment.

Reason:
- `app_user_role` clearly communicates assignment scope (user has a role within an app).
- `user_role` may imply global role assignment and create ambiguity.

## Rename Criteria
Rename to `user_role` only if:
1. `app_id` is removed from the table, and
2. roles are no longer app-scoped.

If app scope remains, prefer keeping `app_user_role`.

---
>> codex permission is specific to app, but we have not used a prefix 'app' here. why not? Note that 'app_user_role' uses app prefix to clarify the app specificity.

permission (and role) are modeled as entity tables scoped by app_id, so scope is encoded in data/constraints, not table name:

- permission.app_id FK to app
- UNIQUE (app_id, code)
  (same pattern for role)

app_user_role is a 3-way assignment table (app + user + role), and app_ is used to prevent the misleading interpretation that roles are global per user.

So the current convention is effectively:

- entity tables: simple nouns (permission, role)
- cross-scope join table: explicit scope in name (app_user_role)

If you want stricter symmetry, rename both permission and role to app_permission and app_role together, not just one.
