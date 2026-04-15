# Test Data Narrative (MariaDB 10.6.23)

This document explains the deterministic seed data in `db/Test-Data-Mariadb-10.6.23.sql`.
The goal is to support hard-wired test values (exact IDs, codes, and expected permission outcomes).

## Scope

The dataset models 2 applications with separate role and permission sets:

1. Billing Platform (`app.id = 1`, `code = BILLING`)
2. HR Portal (`app.id = 2`, `code = HR_PORTAL`)

There are 5 users and 7 roles. One user is intentionally inactive, and one user intentionally has no role assignments.

## Entities and fixed IDs

### Applications

1. `1 -> BILLING`
2. `2 -> HR_PORTAL`

### Users

1. `1 -> alice` (active)
2. `2 -> bob` (active)
3. `3 -> carol` (active)
4. `4 -> dave` (inactive)
5. `5 -> erin` (active, no roles)

### Roles

Billing (`app_id = 1`):

1. `role.id = 1 -> BILLING_ADMIN`
2. `role.id = 2 -> BILLING_MANAGER`
3. `role.id = 3 -> BILLING_ANALYST`
4. `role.id = 4 -> BILLING_AUDITOR`

HR (`app_id = 2`):

1. `role.id = 5 -> HR_ADMIN`
2. `role.id = 6 -> HR_MANAGER`
3. `role.id = 7 -> HR_VIEWER`

### Permissions

Billing permissions (`app_id = 1`):

1. `permission.id = 1 -> INVOICE_READ`
2. `permission.id = 2 -> INVOICE_CREATE`
3. `permission.id = 3 -> INVOICE_APPROVE`
4. `permission.id = 4 -> PAYMENT_REFUND`
5. `permission.id = 5 -> AUDIT_EXPORT`

HR permissions (`app_id = 2`):

1. `permission.id = 6 -> EMPLOYEE_READ`
2. `permission.id = 7 -> EMPLOYEE_EDIT`
3. `permission.id = 8 -> PAYROLL_RUN`
4. `permission.id = 9 -> LEAVE_APPROVE`

## Role permission model

### Billing roles

1. `BILLING_ADMIN` -> `INVOICE_READ`, `INVOICE_CREATE`, `INVOICE_APPROVE`, `PAYMENT_REFUND`, `AUDIT_EXPORT`
2. `BILLING_MANAGER` -> `INVOICE_READ`, `INVOICE_CREATE`, `INVOICE_APPROVE`
3. `BILLING_ANALYST` -> `INVOICE_READ`, `AUDIT_EXPORT`
4. `BILLING_AUDITOR` -> `AUDIT_EXPORT`

### HR roles

1. `HR_ADMIN` -> `EMPLOYEE_READ`, `EMPLOYEE_EDIT`, `PAYROLL_RUN`, `LEAVE_APPROVE`
2. `HR_MANAGER` -> `EMPLOYEE_READ`, `EMPLOYEE_EDIT`, `LEAVE_APPROVE`
3. `HR_VIEWER` -> `EMPLOYEE_READ`

## User assignments

1. `alice (user_id = 1)`:
   - Billing: `BILLING_ADMIN`
   - HR: `HR_VIEWER`
2. `bob (user_id = 2)`:
   - Billing: `BILLING_MANAGER`
3. `carol (user_id = 3)`:
   - Billing: `BILLING_ANALYST`
   - HR: `HR_MANAGER`
4. `dave (user_id = 4, inactive)`:
   - Billing: `BILLING_AUDITOR`
5. `erin (user_id = 5)`:
   - No roles in any app

## Test-case narrative (expected behavior)

These examples are intended for hard-coded integration/service tests.

1. Alice has full billing access:
   - In `BILLING`, user `alice` should have `PAYMENT_REFUND` and `AUDIT_EXPORT`.
2. Alice has read-only HR access:
   - In `HR_PORTAL`, user `alice` should have `EMPLOYEE_READ`.
   - In `HR_PORTAL`, user `alice` should not have `EMPLOYEE_EDIT` or `PAYROLL_RUN`.
3. Bob can approve invoices but cannot refund:
   - In `BILLING`, user `bob` should have `INVOICE_APPROVE`.
   - In `BILLING`, user `bob` should not have `PAYMENT_REFUND`.
4. Carol has mixed cross-app access:
   - In `BILLING`, user `carol` should have `INVOICE_READ` and `AUDIT_EXPORT`.
   - In `BILLING`, user `carol` should not have `INVOICE_CREATE`.
   - In `HR_PORTAL`, user `carol` should have `EMPLOYEE_EDIT` and `LEAVE_APPROVE`.
   - In `HR_PORTAL`, user `carol` should not have `PAYROLL_RUN`.
5. Dave has role mapping but is inactive:
   - Permission-join queries may still return billing permissions for `dave`.
   - Authentication/business-layer tests should reject dave based on `user.is_active = 0`.
6. Erin is active but unassigned:
   - `erin` should resolve to zero roles and zero permissions in all apps.

## Data maintenance notes

1. IDs are explicit and stable to simplify hard-coded assertions.
2. Timestamps are fixed for deterministic snapshots.
3. The SQL script clears and reseeds all six tables each run.
4. Auto-increment values are reset after inserts to avoid drift for future records.
