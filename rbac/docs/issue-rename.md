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
