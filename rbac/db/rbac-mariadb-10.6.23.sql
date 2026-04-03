-- RBAC schema for MariaDB 10.6.23
-- Tables: app, permission, role, role_permission, user, app_user_role
--
-- RBAC schema overview (simple English):
-- Purpose: manage which users can do what in which app using roles and permissions.
--
-- app:
--   One row per application. Other tables attach to an app via app_id.
--
-- user:
--   One row per user account.
--
-- permission:
--   A named ability/action within a specific app (e.g., "READ_REPORTS").
--   Each permission belongs to exactly one app (permission.app_id -> app.id).
--
-- role:
--   A named role within a specific app (e.g., "ADMIN", "VIEWER").
--   Each role belongs to exactly one app (role.app_id -> app.id).
--
-- role_permission (many-to-many):
--   Connects roles to permissions (what a role grants).
--   A role can have many permissions; a permission can be in many roles.
--
-- app_user_role (many-to-many):
--   Assigns users to roles within an app.
--   A user can have many roles; a role can be assigned to many users.
--
-- Foreign-key behavior summary:
--   ON DELETE CASCADE deletes dependent rows automatically.
--   ON UPDATE RESTRICT prevents changing primary key IDs that are referenced elsewhere.

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS app_user_role;
DROP TABLE IF EXISTS role_permission;
DROP TABLE IF EXISTS `permission`;
DROP TABLE IF EXISTS `role`;
DROP TABLE IF EXISTS `user`;
DROP TABLE IF EXISTS app;

SET FOREIGN_KEY_CHECKS = 1;

-- app: Applications being secured by RBAC.
-- Parent table referenced by permission.app_id and role.app_id.
CREATE TABLE app (
  id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  code VARCHAR(100) NOT NULL,
  name VARCHAR(200) NOT NULL,
  description VARCHAR(500) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_app_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- user: User accounts that can be assigned roles.
-- Referenced by app_user_role.user_id.
CREATE TABLE `user` (
  id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  username VARCHAR(100) NOT NULL,
  email VARCHAR(254) NULL,
  display_name VARCHAR(200) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_user_username (username),
  UNIQUE KEY uk_user_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- permission: Actions/abilities within an app (unique per app by (app_id, code)).
-- Child of app; referenced by role_permission.permission_id.
CREATE TABLE `permission` (
  id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  app_id SMALLINT UNSIGNED NOT NULL,
  code VARCHAR(100) NOT NULL,
  name VARCHAR(200) NOT NULL,
  description VARCHAR(500) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_permission_app_code (app_id, code),
  KEY idx_permission_app_id (app_id),
  CONSTRAINT fk_permission_app
    FOREIGN KEY (app_id) REFERENCES app(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- role: Role definitions within an app (unique per app by (app_id, code)).
-- Child of app; referenced by role_permission.role_id and app_user_role.role_id.
CREATE TABLE `role` (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  app_id SMALLINT UNSIGNED NOT NULL,
  code VARCHAR(100) NOT NULL,
  name VARCHAR(200) NOT NULL,
  description VARCHAR(500) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_role_app_code (app_id, code),
  KEY idx_role_app_id (app_id),
  CONSTRAINT fk_role_app
    FOREIGN KEY (app_id) REFERENCES app(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- role_permission: Join table that grants permissions to roles (many-to-many).
-- Each row means: this role includes this permission.
CREATE TABLE role_permission (
  role_id BIGINT UNSIGNED NOT NULL,
  permission_id SMALLINT UNSIGNED NOT NULL,
  granted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (role_id, permission_id),
  KEY idx_role_permission_permission_id (permission_id),
  CONSTRAINT fk_role_permission_role
    FOREIGN KEY (role_id) REFERENCES `role`(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  CONSTRAINT fk_role_permission_permission
    FOREIGN KEY (permission_id) REFERENCES `permission`(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- app_user_role: Join table that assigns users to roles within an app (many-to-many).
-- Each row means: this user has this role for this app.
CREATE TABLE app_user_role (
  app_id SMALLINT UNSIGNED NOT NULL,
  user_id SMALLINT UNSIGNED NOT NULL,
  role_id BIGINT UNSIGNED NOT NULL,
  assigned_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (app_id, user_id, role_id),
  KEY idx_app_user_role_user_id (user_id),
  KEY idx_app_user_role_role_id (role_id),
  CONSTRAINT fk_app_user_role_app
    FOREIGN KEY (app_id) REFERENCES app(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  CONSTRAINT fk_app_user_role_user
    FOREIGN KEY (user_id) REFERENCES `user`(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT,
  CONSTRAINT fk_app_user_role_role
    FOREIGN KEY (role_id) REFERENCES `role`(id)
    ON DELETE CASCADE
    ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
