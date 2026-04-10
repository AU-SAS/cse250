# CSE250 Database Management Systems

## Next Steps

- Change the user data type to INT.
- Create the database from `db/rbac-mariadb-10.6.23.sql`.
- Create some test entries into the database and write the sql at `docs/Admin-DB.md`.
- Document the REST APIs and the JSON DTO (Data Transfer Object)s `docs/REST.md`.
- Create a Node project in this directory for REST API using Express.
- Create an automated test setup for validating all REST APIs.
- Create a Markdown document at `./Admin-REST.md` to run all the REST APIs using fenced code blocks for bash commands using the curl tool.
- An Admin frontend with login using Vite and the React framework that supports all the REST APIs.
- Integrate RBAC into a project such as `../my-uni`.

## Vite

Vite (French for "quick", pronounced /vit/) is a modern frontend build tool that provides an extremely fast development environment and optimized production builds. Created by Evan You (creator of Vue.js), it replaces traditional bundlers like Webpack, using native ES modules and esbuild to enable near-instant server starts and lightning-fast Hot Module Replacement (HMR).

Create a bare-metal version of Vite:

```bash
npm create vite@latest my-uni --template vanilla

```
