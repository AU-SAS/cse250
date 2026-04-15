const express = require('express');
const { query } = require('../lib/db');
const { ApiError, asyncHandler, parseId } = require('../lib/http');

const router = express.Router();

function requireField(body, field) {
  const v = body[field];
  if (v === undefined || v === null || String(v).trim() === '') {
    throw new ApiError(400, `${field} is required`, [{ field, reason: 'must not be blank' }]);
  }
  return v;
}

router.get('/health', (_req, res) => {
  res.json({ status: 'ok' });
});

// Apps
router.get('/apps', asyncHandler(async (_req, res) => {
  const rows = await query('SELECT id, code, name, description, is_active AS isActive, created_at AS createdAt, updated_at AS updatedAt FROM app ORDER BY id');
  res.json(rows);
}));

router.get('/apps/:appId', asyncHandler(async (req, res) => {
  const appId = parseId(req.params.appId, 'appId');
  const rows = await query('SELECT id, code, name, description, is_active AS isActive, created_at AS createdAt, updated_at AS updatedAt FROM app WHERE id = ?', [appId]);
  if (!rows.length) throw new ApiError(404, 'App not found');
  res.json(rows[0]);
}));

router.post('/apps', asyncHandler(async (req, res) => {
  const code = String(requireField(req.body, 'code')).trim();
  const name = String(requireField(req.body, 'name')).trim();
  const description = req.body.description ?? null;
  const isActive = req.body.isActive === undefined ? true : Boolean(req.body.isActive);

  await query('INSERT INTO app (code, name, description, is_active) VALUES (?, ?, ?, ?)', [code, name, description, isActive ? 1 : 0]);
  const rows = await query('SELECT id, code, name, description, is_active AS isActive, created_at AS createdAt, updated_at AS updatedAt FROM app WHERE id = LAST_INSERT_ID()');
  res.status(201).json(rows[0]);
}));

router.put('/apps/:appId', asyncHandler(async (req, res) => {
  const appId = parseId(req.params.appId, 'appId');
  const name = String(requireField(req.body, 'name')).trim();
  const description = req.body.description ?? null;
  const isActive = req.body.isActive === undefined ? true : Boolean(req.body.isActive);

  const result = await query('UPDATE app SET name = ?, description = ?, is_active = ? WHERE id = ?', [name, description, isActive ? 1 : 0, appId]);
  if (!result.affectedRows) throw new ApiError(404, 'App not found');
  const rows = await query('SELECT id, code, name, description, is_active AS isActive, created_at AS createdAt, updated_at AS updatedAt FROM app WHERE id = ?', [appId]);
  res.json(rows[0]);
}));

router.delete('/apps/:appId', asyncHandler(async (req, res) => {
  const appId = parseId(req.params.appId, 'appId');
  const result = await query('DELETE FROM app WHERE id = ?', [appId]);
  if (!result.affectedRows) throw new ApiError(404, 'App not found');
  res.status(204).send();
}));

// Users
router.get('/users', asyncHandler(async (_req, res) => {
  const rows = await query('SELECT id, username, email, display_name AS displayName, is_active AS isActive, created_at AS createdAt, updated_at AS updatedAt FROM `user` ORDER BY id');
  res.json(rows);
}));

router.get('/users/:userId', asyncHandler(async (req, res) => {
  const userId = parseId(req.params.userId, 'userId');
  const rows = await query('SELECT id, username, email, display_name AS displayName, is_active AS isActive, created_at AS createdAt, updated_at AS updatedAt FROM `user` WHERE id = ?', [userId]);
  if (!rows.length) throw new ApiError(404, 'User not found');
  res.json(rows[0]);
}));

router.post('/users', asyncHandler(async (req, res) => {
  const username = String(requireField(req.body, 'username')).trim();
  const password = String(requireField(req.body, 'password')).trim();
  const email = req.body.email ?? null;
  const displayName = req.body.displayName ?? null;
  const isActive = req.body.isActive === undefined ? true : Boolean(req.body.isActive);

  await query('INSERT INTO `user` (username, password_hash, email, display_name, is_active) VALUES (?, ?, ?, ?, ?)', [username, password, email, displayName, isActive ? 1 : 0]);
  const rows = await query('SELECT id, username, email, display_name AS displayName, is_active AS isActive, created_at AS createdAt, updated_at AS updatedAt FROM `user` WHERE id = LAST_INSERT_ID()');
  res.status(201).json(rows[0]);
}));

router.put('/users/:userId', asyncHandler(async (req, res) => {
  const userId = parseId(req.params.userId, 'userId');
  const email = req.body.email ?? null;
  const displayName = req.body.displayName ?? null;
  const isActive = req.body.isActive === undefined ? true : Boolean(req.body.isActive);

  const result = await query('UPDATE `user` SET email = ?, display_name = ?, is_active = ? WHERE id = ?', [email, displayName, isActive ? 1 : 0, userId]);
  if (!result.affectedRows) throw new ApiError(404, 'User not found');
  const rows = await query('SELECT id, username, email, display_name AS displayName, is_active AS isActive, created_at AS createdAt, updated_at AS updatedAt FROM `user` WHERE id = ?', [userId]);
  res.json(rows[0]);
}));

router.delete('/users/:userId', asyncHandler(async (req, res) => {
  const userId = parseId(req.params.userId, 'userId');
  const result = await query('DELETE FROM `user` WHERE id = ?', [userId]);
  if (!result.affectedRows) throw new ApiError(404, 'User not found');
  res.status(204).send();
}));

// Permissions
router.get('/apps/:appId/permissions', asyncHandler(async (req, res) => {
  const appId = parseId(req.params.appId, 'appId');
  const rows = await query('SELECT p.id, p.app_id AS appId, a.code AS appCode, p.code, p.name, p.description, p.created_at AS createdAt, p.updated_at AS updatedAt FROM `permission` p JOIN app a ON a.id = p.app_id WHERE p.app_id = ? ORDER BY p.id', [appId]);
  res.json(rows);
}));

router.get('/permissions/:permissionId', asyncHandler(async (req, res) => {
  const permissionId = parseId(req.params.permissionId, 'permissionId');
  const rows = await query('SELECT p.id, p.app_id AS appId, a.code AS appCode, p.code, p.name, p.description, p.created_at AS createdAt, p.updated_at AS updatedAt FROM `permission` p JOIN app a ON a.id = p.app_id WHERE p.id = ?', [permissionId]);
  if (!rows.length) throw new ApiError(404, 'Permission not found');
  res.json(rows[0]);
}));

router.post('/permissions', asyncHandler(async (req, res) => {
  const appId = parseId(requireField(req.body, 'appId'), 'appId');
  const code = String(requireField(req.body, 'code')).trim();
  const name = String(requireField(req.body, 'name')).trim();
  const description = req.body.description ?? null;

  await query('INSERT INTO `permission` (app_id, code, name, description) VALUES (?, ?, ?, ?)', [appId, code, name, description]);
  const rows = await query('SELECT p.id, p.app_id AS appId, a.code AS appCode, p.code, p.name, p.description, p.created_at AS createdAt, p.updated_at AS updatedAt FROM `permission` p JOIN app a ON a.id = p.app_id WHERE p.id = LAST_INSERT_ID()');
  res.status(201).json(rows[0]);
}));

router.put('/permissions/:permissionId', asyncHandler(async (req, res) => {
  const permissionId = parseId(req.params.permissionId, 'permissionId');
  const name = String(requireField(req.body, 'name')).trim();
  const description = req.body.description ?? null;

  const result = await query('UPDATE `permission` SET name = ?, description = ? WHERE id = ?', [name, description, permissionId]);
  if (!result.affectedRows) throw new ApiError(404, 'Permission not found');
  const rows = await query('SELECT p.id, p.app_id AS appId, a.code AS appCode, p.code, p.name, p.description, p.created_at AS createdAt, p.updated_at AS updatedAt FROM `permission` p JOIN app a ON a.id = p.app_id WHERE p.id = ?', [permissionId]);
  res.json(rows[0]);
}));

router.delete('/permissions/:permissionId', asyncHandler(async (req, res) => {
  const permissionId = parseId(req.params.permissionId, 'permissionId');
  const result = await query('DELETE FROM `permission` WHERE id = ?', [permissionId]);
  if (!result.affectedRows) throw new ApiError(404, 'Permission not found');
  res.status(204).send();
}));

// Roles
router.get('/apps/:appId/roles', asyncHandler(async (req, res) => {
  const appId = parseId(req.params.appId, 'appId');
  const rows = await query('SELECT r.id, r.app_id AS appId, a.code AS appCode, r.code, r.name, r.description, r.created_at AS createdAt, r.updated_at AS updatedAt FROM `role` r JOIN app a ON a.id = r.app_id WHERE r.app_id = ? ORDER BY r.id', [appId]);
  res.json(rows);
}));

router.get('/roles/:roleId', asyncHandler(async (req, res) => {
  const roleId = parseId(req.params.roleId, 'roleId');
  const rows = await query('SELECT r.id, r.app_id AS appId, a.code AS appCode, r.code, r.name, r.description, r.created_at AS createdAt, r.updated_at AS updatedAt FROM `role` r JOIN app a ON a.id = r.app_id WHERE r.id = ?', [roleId]);
  if (!rows.length) throw new ApiError(404, 'Role not found');
  res.json(rows[0]);
}));

router.post('/roles', asyncHandler(async (req, res) => {
  const appId = parseId(requireField(req.body, 'appId'), 'appId');
  const code = String(requireField(req.body, 'code')).trim();
  const name = String(requireField(req.body, 'name')).trim();
  const description = req.body.description ?? null;

  await query('INSERT INTO `role` (app_id, code, name, description) VALUES (?, ?, ?, ?)', [appId, code, name, description]);
  const rows = await query('SELECT r.id, r.app_id AS appId, a.code AS appCode, r.code, r.name, r.description, r.created_at AS createdAt, r.updated_at AS updatedAt FROM `role` r JOIN app a ON a.id = r.app_id WHERE r.id = LAST_INSERT_ID()');
  res.status(201).json(rows[0]);
}));

router.put('/roles/:roleId', asyncHandler(async (req, res) => {
  const roleId = parseId(req.params.roleId, 'roleId');
  const name = String(requireField(req.body, 'name')).trim();
  const description = req.body.description ?? null;

  const result = await query('UPDATE `role` SET name = ?, description = ? WHERE id = ?', [name, description, roleId]);
  if (!result.affectedRows) throw new ApiError(404, 'Role not found');
  const rows = await query('SELECT r.id, r.app_id AS appId, a.code AS appCode, r.code, r.name, r.description, r.created_at AS createdAt, r.updated_at AS updatedAt FROM `role` r JOIN app a ON a.id = r.app_id WHERE r.id = ?', [roleId]);
  res.json(rows[0]);
}));

router.delete('/roles/:roleId', asyncHandler(async (req, res) => {
  const roleId = parseId(req.params.roleId, 'roleId');
  const result = await query('DELETE FROM `role` WHERE id = ?', [roleId]);
  if (!result.affectedRows) throw new ApiError(404, 'Role not found');
  res.status(204).send();
}));

// Role-permission assignments
router.get('/roles/:roleId/permissions', asyncHandler(async (req, res) => {
  const roleId = parseId(req.params.roleId, 'roleId');
  const rows = await query(
    'SELECT p.id, p.app_id AS appId, a.code AS appCode, p.code, p.name, p.description, p.created_at AS createdAt, p.updated_at AS updatedAt FROM role_permission rp JOIN `permission` p ON p.id = rp.permission_id JOIN app a ON a.id = p.app_id WHERE rp.role_id = ? ORDER BY p.id',
    [roleId]
  );
  res.json(rows);
}));

router.post('/roles/:roleId/permissions', asyncHandler(async (req, res) => {
  const roleId = parseId(req.params.roleId, 'roleId');
  const permissionId = parseId(requireField(req.body, 'permissionId'), 'permissionId');

  const pairs = await query(
    'SELECT r.app_id AS roleAppId, p.app_id AS permissionAppId FROM `role` r JOIN `permission` p WHERE r.id = ? AND p.id = ?',
    [roleId, permissionId]
  );
  if (!pairs.length) throw new ApiError(404, 'Role or permission not found');
  if (pairs[0].roleAppId !== pairs[0].permissionAppId) {
    throw new ApiError(400, 'Role and permission must belong to the same app');
  }

  await query('INSERT IGNORE INTO role_permission (role_id, permission_id) VALUES (?, ?)', [roleId, permissionId]);
  const rows = await query('SELECT role_id AS roleId, permission_id AS permissionId, granted_at AS grantedAt FROM role_permission WHERE role_id = ? AND permission_id = ?', [roleId, permissionId]);
  res.status(201).json(rows[0]);
}));

router.delete('/roles/:roleId/permissions/:permissionId', asyncHandler(async (req, res) => {
  const roleId = parseId(req.params.roleId, 'roleId');
  const permissionId = parseId(req.params.permissionId, 'permissionId');
  const result = await query('DELETE FROM role_permission WHERE role_id = ? AND permission_id = ?', [roleId, permissionId]);
  if (!result.affectedRows) throw new ApiError(404, 'Role-permission assignment not found');
  res.status(204).send();
}));

// User-role assignments (per app)
router.get('/apps/:appId/users/:userId/roles', asyncHandler(async (req, res) => {
  const appId = parseId(req.params.appId, 'appId');
  const userId = parseId(req.params.userId, 'userId');
  const rows = await query(
    'SELECT r.id, r.app_id AS appId, a.code AS appCode, r.code, r.name, r.description, r.created_at AS createdAt, r.updated_at AS updatedAt FROM app_user_role aur JOIN `role` r ON r.id = aur.role_id JOIN app a ON a.id = r.app_id WHERE aur.app_id = ? AND aur.user_id = ? ORDER BY r.id',
    [appId, userId]
  );
  res.json(rows);
}));

router.post('/apps/:appId/user-roles', asyncHandler(async (req, res) => {
  const appId = parseId(req.params.appId, 'appId');
  const userId = parseId(requireField(req.body, 'userId'), 'userId');
  const roleId = parseId(requireField(req.body, 'roleId'), 'roleId');

  const roleRows = await query('SELECT app_id AS appId FROM `role` WHERE id = ?', [roleId]);
  if (!roleRows.length) throw new ApiError(404, 'Role not found');
  if (roleRows[0].appId !== appId) {
    throw new ApiError(400, 'Role appId must match path appId');
  }

  const userRows = await query('SELECT id FROM `user` WHERE id = ?', [userId]);
  if (!userRows.length) throw new ApiError(404, 'User not found');

  await query('INSERT IGNORE INTO app_user_role (app_id, user_id, role_id) VALUES (?, ?, ?)', [appId, userId, roleId]);
  const rows = await query('SELECT app_id AS appId, user_id AS userId, role_id AS roleId, assigned_at AS assignedAt FROM app_user_role WHERE app_id = ? AND user_id = ? AND role_id = ?', [appId, userId, roleId]);
  res.status(201).json(rows[0]);
}));

router.delete('/apps/:appId/users/:userId/roles/:roleId', asyncHandler(async (req, res) => {
  const appId = parseId(req.params.appId, 'appId');
  const userId = parseId(req.params.userId, 'userId');
  const roleId = parseId(req.params.roleId, 'roleId');

  const result = await query('DELETE FROM app_user_role WHERE app_id = ? AND user_id = ? AND role_id = ?', [appId, userId, roleId]);
  if (!result.affectedRows) throw new ApiError(404, 'App-user-role assignment not found');
  res.status(204).send();
}));

// Authorization queries
router.post('/authorizations/check', asyncHandler(async (req, res) => {
  const username = String(requireField(req.body, 'username')).trim();
  const appCode = String(requireField(req.body, 'appCode')).trim();
  const permissionCode = String(requireField(req.body, 'permissionCode')).trim();

  const rows = await query(
    `SELECT u.is_active AS isActive, r.code AS roleCode
     FROM \`user\` u
     JOIN app_user_role aur ON aur.user_id = u.id
     JOIN app a ON a.id = aur.app_id
     JOIN \`role\` r ON r.id = aur.role_id
     JOIN role_permission rp ON rp.role_id = r.id
     JOIN \`permission\` p ON p.id = rp.permission_id
     WHERE u.username = ? AND a.code = ? AND p.code = ?
     LIMIT 1`,
    [username, appCode, permissionCode]
  );

  if (!rows.length) {
    return res.json({ username, appCode, permissionCode, allowed: false, reason: 'No matching role-permission assignment' });
  }
  if (!rows[0].isActive) {
    return res.json({ username, appCode, permissionCode, allowed: false, reason: 'User is inactive' });
  }

  return res.json({ username, appCode, permissionCode, allowed: true, reason: `Permission granted via role ${rows[0].roleCode}` });
}));

router.get('/users/:userId/access-snapshot', asyncHandler(async (req, res) => {
  const userId = parseId(req.params.userId, 'userId');
  const users = await query('SELECT id, username, is_active AS isActive FROM `user` WHERE id = ?', [userId]);
  if (!users.length) throw new ApiError(404, 'User not found');

  const rows = await query(
    `SELECT a.code AS appCode, r.code AS roleCode, p.code AS permissionCode
     FROM app_user_role aur
     JOIN app a ON a.id = aur.app_id
     JOIN \`role\` r ON r.id = aur.role_id
     LEFT JOIN role_permission rp ON rp.role_id = r.id
     LEFT JOIN \`permission\` p ON p.id = rp.permission_id
     WHERE aur.user_id = ?
     ORDER BY a.code, r.code, p.code`,
    [userId]
  );

  const appMap = new Map();
  for (const row of rows) {
    if (!appMap.has(row.appCode)) {
      appMap.set(row.appCode, { appCode: row.appCode, roles: new Set(), permissions: new Set() });
    }
    const entry = appMap.get(row.appCode);
    entry.roles.add(row.roleCode);
    if (row.permissionCode) entry.permissions.add(row.permissionCode);
  }

  const apps = Array.from(appMap.values()).map((x) => ({
    appCode: x.appCode,
    roles: Array.from(x.roles).sort(),
    permissions: Array.from(x.permissions).sort()
  }));

  res.json({ user: users[0], apps });
}));

module.exports = router;
