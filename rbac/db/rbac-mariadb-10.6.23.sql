-- RBAC schema for MariaDB 10.6.23
-- Tables: app, permission, role, role_permission, user, app_user_role

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS app_user_role;
DROP TABLE IF EXISTS role_permission;
DROP TABLE IF EXISTS `permission`;
DROP TABLE IF EXISTS `role`;
DROP TABLE IF EXISTS `user`;
DROP TABLE IF EXISTS app;

SET FOREIGN_KEY_CHECKS = 1;

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
