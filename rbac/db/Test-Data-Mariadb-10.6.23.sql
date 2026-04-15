-- Deterministic test data for RBAC schema (MariaDB 10.6.23)
-- Intended DB: rbac
-- Safe to re-run: existing rows are deleted in FK-safe order.

SET NAMES utf8mb4;
START TRANSACTION;

-- 1) Clear existing data
DELETE FROM app_user_role;
DELETE FROM role_permission;
DELETE FROM `role`;
DELETE FROM `permission`;
DELETE FROM `user`;
DELETE FROM app;

-- 2) Applications
INSERT INTO app (id, code, name, description, is_active, created_at, updated_at) VALUES
  (1, 'BILLING',   'Billing Platform', 'Invoice lifecycle and payments', 1, '2026-01-10 09:00:00', '2026-01-10 09:00:00'),
  (2, 'HR_PORTAL', 'HR Portal',        'Employee and leave management',   1, '2026-01-10 09:05:00', '2026-01-10 09:05:00');

-- 3) Users
INSERT INTO `user` (id, username, password_hash, email, display_name, is_active, created_at, updated_at) VALUES
  (1, 'alice', '$2b$10$alice.demo.hash', 'alice@example.test', 'Alice Admin',    1, '2026-01-10 10:00:00', '2026-01-10 10:00:00'),
  (2, 'bob',   '$2b$10$bob.demo.hash',   'bob@example.test',   'Bob Manager',    1, '2026-01-10 10:01:00', '2026-01-10 10:01:00'),
  (3, 'carol', '$2b$10$carol.demo.hash', 'carol@example.test', 'Carol Analyst',  1, '2026-01-10 10:02:00', '2026-01-10 10:02:00'),
  (4, 'dave',  '$2b$10$dave.demo.hash',  'dave@example.test',  'Dave Auditor',   0, '2026-01-10 10:03:00', '2026-01-10 10:03:00'),
  (5, 'erin',  '$2b$10$erin.demo.hash',  'erin@example.test',  'Erin No Roles',  1, '2026-01-10 10:04:00', '2026-01-10 10:04:00');

-- 4) Permissions
INSERT INTO `permission` (id, app_id, code, name, description, created_at, updated_at) VALUES
  -- Billing app permissions
  (1, 1, 'INVOICE_READ',   'Read Invoice',    'View invoice details',     '2026-01-10 11:00:00', '2026-01-10 11:00:00'),
  (2, 1, 'INVOICE_CREATE', 'Create Invoice',  'Create a new invoice',     '2026-01-10 11:01:00', '2026-01-10 11:01:00'),
  (3, 1, 'INVOICE_APPROVE','Approve Invoice', 'Approve pending invoices', '2026-01-10 11:02:00', '2026-01-10 11:02:00'),
  (4, 1, 'PAYMENT_REFUND', 'Refund Payment',  'Issue payment refunds',    '2026-01-10 11:03:00', '2026-01-10 11:03:00'),
  (5, 1, 'AUDIT_EXPORT',   'Export Audit',    'Export billing audit log', '2026-01-10 11:04:00', '2026-01-10 11:04:00'),
  -- HR app permissions
  (6, 2, 'EMPLOYEE_READ',  'Read Employee',   'View employee records',    '2026-01-10 11:05:00', '2026-01-10 11:05:00'),
  (7, 2, 'EMPLOYEE_EDIT',  'Edit Employee',   'Update employee records',  '2026-01-10 11:06:00', '2026-01-10 11:06:00'),
  (8, 2, 'PAYROLL_RUN',    'Run Payroll',     'Execute payroll run',      '2026-01-10 11:07:00', '2026-01-10 11:07:00'),
  (9, 2, 'LEAVE_APPROVE',  'Approve Leave',   'Approve leave requests',   '2026-01-10 11:08:00', '2026-01-10 11:08:00');

-- 5) Roles
INSERT INTO `role` (id, app_id, code, name, description, created_at, updated_at) VALUES
  -- Billing roles
  (1, 1, 'BILLING_ADMIN',   'Billing Admin',   'Full billing access',             '2026-01-10 12:00:00', '2026-01-10 12:00:00'),
  (2, 1, 'BILLING_MANAGER', 'Billing Manager', 'Operational billing management',   '2026-01-10 12:01:00', '2026-01-10 12:01:00'),
  (3, 1, 'BILLING_ANALYST', 'Billing Analyst', 'Read and audit export access',     '2026-01-10 12:02:00', '2026-01-10 12:02:00'),
  (4, 1, 'BILLING_AUDITOR', 'Billing Auditor', 'Audit-only access',                '2026-01-10 12:03:00', '2026-01-10 12:03:00'),
  -- HR roles
  (5, 2, 'HR_ADMIN',        'HR Admin',        'Full HR access',                   '2026-01-10 12:04:00', '2026-01-10 12:04:00'),
  (6, 2, 'HR_MANAGER',      'HR Manager',      'Manager-level HR operations',      '2026-01-10 12:05:00', '2026-01-10 12:05:00'),
  (7, 2, 'HR_VIEWER',       'HR Viewer',       'Read-only HR access',              '2026-01-10 12:06:00', '2026-01-10 12:06:00');

-- 6) Role -> Permission mapping
INSERT INTO role_permission (role_id, permission_id, granted_at) VALUES
  -- BILLING_ADMIN gets all billing permissions
  (1, 1, '2026-01-10 12:30:00'),
  (1, 2, '2026-01-10 12:30:00'),
  (1, 3, '2026-01-10 12:30:00'),
  (1, 4, '2026-01-10 12:30:00'),
  (1, 5, '2026-01-10 12:30:00'),
  -- BILLING_MANAGER gets read/create/approve
  (2, 1, '2026-01-10 12:31:00'),
  (2, 2, '2026-01-10 12:31:00'),
  (2, 3, '2026-01-10 12:31:00'),
  -- BILLING_ANALYST gets read + audit export
  (3, 1, '2026-01-10 12:32:00'),
  (3, 5, '2026-01-10 12:32:00'),
  -- BILLING_AUDITOR gets audit export only
  (4, 5, '2026-01-10 12:33:00'),
  -- HR_ADMIN gets all HR permissions
  (5, 6, '2026-01-10 12:34:00'),
  (5, 7, '2026-01-10 12:34:00'),
  (5, 8, '2026-01-10 12:34:00'),
  (5, 9, '2026-01-10 12:34:00'),
  -- HR_MANAGER gets read/edit/leave-approve
  (6, 6, '2026-01-10 12:35:00'),
  (6, 7, '2026-01-10 12:35:00'),
  (6, 9, '2026-01-10 12:35:00'),
  -- HR_VIEWER gets read-only
  (7, 6, '2026-01-10 12:36:00');

-- 7) User -> Role mapping per app
INSERT INTO app_user_role (app_id, user_id, role_id, assigned_at) VALUES
  (1, 1, 1, '2026-01-10 13:00:00'), -- alice -> BILLING_ADMIN
  (2, 1, 7, '2026-01-10 13:01:00'), -- alice -> HR_VIEWER
  (1, 2, 2, '2026-01-10 13:02:00'), -- bob   -> BILLING_MANAGER
  (1, 3, 3, '2026-01-10 13:03:00'), -- carol -> BILLING_ANALYST
  (2, 3, 6, '2026-01-10 13:04:00'), -- carol -> HR_MANAGER
  (1, 4, 4, '2026-01-10 13:05:00'); -- dave  -> BILLING_AUDITOR (inactive user)

-- 8) Keep auto-increment values stable for subsequent inserts
ALTER TABLE app AUTO_INCREMENT = 3;
ALTER TABLE `user` AUTO_INCREMENT = 6;
ALTER TABLE `permission` AUTO_INCREMENT = 10;
ALTER TABLE `role` AUTO_INCREMENT = 8;

COMMIT;
