# RBAC REST API and JSON DTOs

This document defines the REST contract for the RBAC service backed by `db/rbac-mariadb-10.6.23.sql`.
It is aligned with deterministic test data in `db/Test-Data-Mariadb-10.6.23.sql`.

## Conventions

- Base path: `/api/v1`
- Content type: `application/json`
- Time format: ISO-8601 UTC (example: `2026-01-10T13:00:00Z`)
- ID fields are numeric and stable in test fixtures
- `code` fields are uppercase, snake-case strings

## Error DTO

All non-2xx responses should use this shape.

```json
{
  "error": "VALIDATION_ERROR",
  "message": "appCode is required",
  "details": [
    {
      "field": "appCode",
      "reason": "must not be blank"
    }
  ],
  "timestamp": "2026-01-10T13:10:00Z",
  "path": "/api/v1/authorizations/check"
}
```

## DTO Catalog

### App DTOs

`AppDto`

```json
{
  "id": 1,
  "code": "BILLING",
  "name": "Billing Platform",
  "description": "Invoice lifecycle and payments",
  "isActive": true,
  "createdAt": "2026-01-10T09:00:00Z",
  "updatedAt": "2026-01-10T09:00:00Z"
}
```

`CreateAppRequest`

```json
{
  "code": "BILLING",
  "name": "Billing Platform",
  "description": "Invoice lifecycle and payments",
  "isActive": true
}
```

`UpdateAppRequest`

```json
{
  "name": "Billing Platform",
  "description": "Invoice lifecycle and payments",
  "isActive": true
}
```

### User DTOs

`UserDto`

```json
{
  "id": 1,
  "username": "alice",
  "email": "alice@example.test",
  "displayName": "Alice Admin",
  "isActive": true,
  "createdAt": "2026-01-10T10:00:00Z",
  "updatedAt": "2026-01-10T10:00:00Z"
}
```

`CreateUserRequest`

```json
{
  "username": "alice",
  "password": "StrongTemporaryPassword",
  "email": "alice@example.test",
  "displayName": "Alice Admin",
  "isActive": true
}
```

`UpdateUserRequest`

```json
{
  "email": "alice@example.test",
  "displayName": "Alice Admin",
  "isActive": true
}
```

### Permission DTOs

`PermissionDto`

```json
{
  "id": 1,
  "appId": 1,
  "appCode": "BILLING",
  "code": "INVOICE_READ",
  "name": "Read Invoice",
  "description": "View invoice details",
  "createdAt": "2026-01-10T11:00:00Z",
  "updatedAt": "2026-01-10T11:00:00Z"
}
```

`CreatePermissionRequest`

```json
{
  "appId": 1,
  "code": "INVOICE_READ",
  "name": "Read Invoice",
  "description": "View invoice details"
}
```

`UpdatePermissionRequest`

```json
{
  "name": "Read Invoice",
  "description": "View invoice details"
}
```

### Role DTOs

`RoleDto`

```json
{
  "id": 1,
  "appId": 1,
  "appCode": "BILLING",
  "code": "BILLING_ADMIN",
  "name": "Billing Admin",
  "description": "Full billing access",
  "createdAt": "2026-01-10T12:00:00Z",
  "updatedAt": "2026-01-10T12:00:00Z"
}
```

`CreateRoleRequest`

```json
{
  "appId": 1,
  "code": "BILLING_ADMIN",
  "name": "Billing Admin",
  "description": "Full billing access"
}
```

`UpdateRoleRequest`

```json
{
  "name": "Billing Admin",
  "description": "Full billing access"
}
```

### Assignment DTOs

`RolePermissionAssignmentDto`

```json
{
  "roleId": 1,
  "permissionId": 4,
  "grantedAt": "2026-01-10T12:30:00Z"
}
```

`AppUserRoleAssignmentDto`

```json
{
  "appId": 1,
  "userId": 2,
  "roleId": 2,
  "assignedAt": "2026-01-10T13:02:00Z"
}
```

`AssignPermissionToRoleRequest`

```json
{
  "permissionId": 4
}
```

`AssignRoleToUserRequest`

```json
{
  "userId": 2,
  "roleId": 2
}
```

### Authorization DTOs

`AuthorizationCheckRequest`

```json
{
  "username": "bob",
  "appCode": "BILLING",
  "permissionCode": "INVOICE_APPROVE"
}
```

`AuthorizationCheckResponse`

```json
{
  "username": "bob",
  "appCode": "BILLING",
  "permissionCode": "INVOICE_APPROVE",
  "allowed": true,
  "reason": "Permission granted via role BILLING_MANAGER"
}
```

`UserAccessSnapshotDto`

```json
{
  "user": {
    "id": 3,
    "username": "carol",
    "isActive": true
  },
  "apps": [
    {
      "appCode": "BILLING",
      "roles": ["BILLING_ANALYST"],
      "permissions": ["AUDIT_EXPORT", "INVOICE_READ"]
    },
    {
      "appCode": "HR_PORTAL",
      "roles": ["HR_MANAGER"],
      "permissions": ["EMPLOYEE_EDIT", "EMPLOYEE_READ", "LEAVE_APPROVE"]
    }
  ]
}
```

## REST Endpoints

### Applications

1. `GET /api/v1/apps`
   - Response: `200 OK` + `AppDto[]`
2. `GET /api/v1/apps/{appId}`
   - Response: `200 OK` + `AppDto`
3. `POST /api/v1/apps`
   - Request: `CreateAppRequest`
   - Response: `201 Created` + `AppDto`
4. `PUT /api/v1/apps/{appId}`
   - Request: `UpdateAppRequest`
   - Response: `200 OK` + `AppDto`
5. `DELETE /api/v1/apps/{appId}`
   - Response: `204 No Content`

### Users

1. `GET /api/v1/users`
   - Response: `200 OK` + `UserDto[]`
2. `GET /api/v1/users/{userId}`
   - Response: `200 OK` + `UserDto`
3. `POST /api/v1/users`
   - Request: `CreateUserRequest`
   - Response: `201 Created` + `UserDto`
4. `PUT /api/v1/users/{userId}`
   - Request: `UpdateUserRequest`
   - Response: `200 OK` + `UserDto`
5. `DELETE /api/v1/users/{userId}`
   - Response: `204 No Content`

### Permissions

1. `GET /api/v1/apps/{appId}/permissions`
   - Response: `200 OK` + `PermissionDto[]`
2. `GET /api/v1/permissions/{permissionId}`
   - Response: `200 OK` + `PermissionDto`
3. `POST /api/v1/permissions`
   - Request: `CreatePermissionRequest`
   - Response: `201 Created` + `PermissionDto`
4. `PUT /api/v1/permissions/{permissionId}`
   - Request: `UpdatePermissionRequest`
   - Response: `200 OK` + `PermissionDto`
5. `DELETE /api/v1/permissions/{permissionId}`
   - Response: `204 No Content`

### Roles

1. `GET /api/v1/apps/{appId}/roles`
   - Response: `200 OK` + `RoleDto[]`
2. `GET /api/v1/roles/{roleId}`
   - Response: `200 OK` + `RoleDto`
3. `POST /api/v1/roles`
   - Request: `CreateRoleRequest`
   - Response: `201 Created` + `RoleDto`
4. `PUT /api/v1/roles/{roleId}`
   - Request: `UpdateRoleRequest`
   - Response: `200 OK` + `RoleDto`
5. `DELETE /api/v1/roles/{roleId}`
   - Response: `204 No Content`

### Role-Permission assignments

1. `GET /api/v1/roles/{roleId}/permissions`
   - Response: `200 OK` + `PermissionDto[]`
2. `POST /api/v1/roles/{roleId}/permissions`
   - Request: `AssignPermissionToRoleRequest`
   - Response: `201 Created` + `RolePermissionAssignmentDto`
3. `DELETE /api/v1/roles/{roleId}/permissions/{permissionId}`
   - Response: `204 No Content`

### User-Role assignments per app

1. `GET /api/v1/apps/{appId}/users/{userId}/roles`
   - Response: `200 OK` + `RoleDto[]`
2. `POST /api/v1/apps/{appId}/user-roles`
   - Request: `AssignRoleToUserRequest`
   - Response: `201 Created` + `AppUserRoleAssignmentDto`
3. `DELETE /api/v1/apps/{appId}/users/{userId}/roles/{roleId}`
   - Response: `204 No Content`

### Authorization queries

1. `POST /api/v1/authorizations/check`
   - Request: `AuthorizationCheckRequest`
   - Response: `200 OK` + `AuthorizationCheckResponse`
2. `GET /api/v1/users/{userId}/access-snapshot`
   - Response: `200 OK` + `UserAccessSnapshotDto`

## Example test vectors from seeded data

1. `POST /api/v1/authorizations/check`
   - request: `{ "username": "bob", "appCode": "BILLING", "permissionCode": "INVOICE_APPROVE" }`
   - expected response: `allowed = true`
2. `POST /api/v1/authorizations/check`
   - request: `{ "username": "bob", "appCode": "BILLING", "permissionCode": "PAYMENT_REFUND" }`
   - expected response: `allowed = false`
3. `POST /api/v1/authorizations/check`
   - request: `{ "username": "alice", "appCode": "HR_PORTAL", "permissionCode": "PAYROLL_RUN" }`
   - expected response: `allowed = false`
4. `POST /api/v1/authorizations/check`
   - request: `{ "username": "carol", "appCode": "HR_PORTAL", "permissionCode": "EMPLOYEE_EDIT" }`
   - expected response: `allowed = true`
5. `POST /api/v1/authorizations/check`
   - request: `{ "username": "erin", "appCode": "BILLING", "permissionCode": "INVOICE_READ" }`
   - expected response: `allowed = false`

## Validation rules (recommended)

1. `app.code`, `role.code`, `permission.code`, `username` are required and unique in their scope.
2. `role.appId` and `permission.appId` must refer to existing app rows.
3. Role-permission assignment should be app-consistent (role and permission must belong to same app).
4. App-user-role assignment should be app-consistent (role.appId must equal path `appId`).
5. Authorization checks should return `allowed = false` when user is inactive.
