
create trigger trg_iam_roles_audit_insert
before insert on iam.roles
for each row
execute function system.audit_insert();

create trigger trg_iam_roles_audit_update
before update on iam.roles
for each row
execute function system.audit_update();

create trigger trg_iam_roles_audit_delete
before delete on iam.roles
for each row
execute function system.audit_delete();


create trigger trg_iam_permissions_audit_insert
before insert on iam.permissions
for each row
execute function system.audit_insert();

create trigger trg_iam_permissions_audit_update
before update on iam.permissions
for each row
execute function system.audit_update();

create trigger trg_iam_permissions_audit_delete
before delete on iam.permissions
for each row
execute function system.audit_delete();


create trigger trg_iam_role_permissions_audit_insert
before insert on iam.role_permissions
for each row
execute function system.audit_insert();

create trigger trg_iam_role_permissions_audit_update
before update on iam.role_permissions
for each row
execute function system.audit_update();

create trigger trg_iam_role_permissions_audit_delete
before delete on iam.role_permissions
for each row
execute function system.audit_delete();