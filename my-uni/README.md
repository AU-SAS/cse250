# My University

## Next Steps

- Improve the schema `db/uni-mariadb-10.6.23.sql` with reference to the RBAC schema at `../rbac/db/rbac-mariadb-10.6.23.sql`.
- Create some test entries into the database and write the sql at `docs/Admin-DB.md`.
- Document the REST APIs and the JSON DTO (Data Transfer Object)s `docs/REST.md`.
- Integrate RBAC into this project. 
   - Add an app entry for this application into RBAC. Entry details:
     - code: MY-UNI
     - name: My University
     - description: A minimal project to showcase RBAC integration. It implements the most basic aspects on University teaching, entities such as, Student and Teacher.
   - Model Student and Teacher as RBAC users.