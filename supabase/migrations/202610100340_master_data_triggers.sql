

create trigger trg_countries_audit_insert
before insert on master_data.countries
for each row
execute function system.audit_insert();

create trigger trg_countries_audit_update
before update on master_data.countries
for each row
execute function system.audit_update();

create trigger trg_countries_audit_delete
before delete on master_data.countries
for each row
execute function system.audit_delete();


create trigger trg_admin_regions_audit_insert
before insert on master_data.admin_regions
for each row
execute function system.audit_insert();

create trigger trg_admin_regions_audit_update
before update on master_data.admin_regions
for each row
execute function system.audit_update();

create trigger trg_admin_regions_audit_delete
before delete on master_data.admin_regions
for each row
execute function system.audit_delete();

create trigger trg_dictionary_items_audit_insert
before insert on master_data.dictionary_items
for each row
execute function system.audit_insert();

create trigger trg_dictionary_items_audit_update
before update on master_data.dictionary_items
for each row
execute function system.audit_update();

create trigger trg_dictionary_items_audit_delete
before delete on master_data.dictionary_items
for each row
execute function system.audit_delete();

create trigger trg_dictionary_types_audit_insert
before insert on master_data.dictionary_types
for each row
execute function system.audit_insert();

create trigger trg_dictionary_types_audit_update
before update on master_data.dictionary_types
for each row
execute function system.audit_update();

create trigger trg_dictionary_types_audit_delete
before delete on master_data.dictionary_types
for each row
execute function system.audit_delete();