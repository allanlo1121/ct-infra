-- =====================================================
-- IAM FUNCTION PERMISSIONS
-- =====================================================

grant usage on schema api to authenticated;
grant usage on schema iam to authenticated;


-- =====================================================
-- GET CURRENT AUTH CONTEXT
-- =====================================================

-- IAM 内部函数
revoke execute
on function iam.get_current_auth_context()
from public, anon, authenticated;

grant execute
on function iam.get_current_auth_context()
to authenticated;


-- API 对外函数
revoke execute
on function api.get_current_auth_context()
from public, anon, authenticated;

grant execute
on function api.get_current_auth_context()
to authenticated;


-- =====================================================
-- HAS PERMISSION
-- =====================================================

-- 内部函数执行权限
revoke all
on function iam.has_permission(
  iam.permission_module,
  iam.permission_action
)
from public, anon, authenticated;

grant execute
on function iam.has_permission(
  iam.permission_module,
  iam.permission_action
)
to authenticated;