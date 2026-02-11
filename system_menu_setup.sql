-- 1. 確保 "系統管理" (System Management) 父節點存在
IF NOT EXISTS (SELECT 1 FROM AppFunctions WHERE FunctionCode = 'SYS_MGMT')
BEGIN
    INSERT INTO AppFunctions (ParentID, FunctionName, FunctionCode, IconKey, RoutePath, SortOrder, IsActive, CreatedAt)
    VALUES (NULL, '系統管理', 'SYS_MGMT', 'settings', '/system', 90, 1, GETDATE());
END

-- 取得父節點 ID
DECLARE @SysMgmtID INT;
SELECT @SysMgmtID = FunctionID FROM AppFunctions WHERE FunctionCode = 'SYS_MGMT';

-- 2. 功能選單維護 (Function/Menu Management)
-- 對應前台: FunctionManagementPage (Tab 1)
IF EXISTS (SELECT 1 FROM AppFunctions WHERE FunctionName = '功能選單維護' OR FunctionCode = 'FUNC_MGMT')
BEGIN
    UPDATE AppFunctions 
    SET ParentID = @SysMgmtID, 
        FunctionName = '功能選單維護',
        FunctionCode = 'FUNC_MGMT', 
        IconKey = 'menu', 
        RoutePath = '/system/functions', 
        SortOrder = 1,
        IsActive = 1
    WHERE FunctionName = '功能選單維護' OR FunctionCode = 'FUNC_MGMT';
END
ELSE
BEGIN
    INSERT INTO AppFunctions (ParentID, FunctionName, FunctionCode, IconKey, RoutePath, SortOrder, IsActive, CreatedAt)
    VALUES (@SysMgmtID, '功能選單維護', 'FUNC_MGMT', 'menu', '/system/functions', 1, 1, GETDATE());
END

-- 3. 角色與權限設定 (Role & Permission Matrix)
-- 對應前台: RolePermissionPage (Tab 2)
IF EXISTS (SELECT 1 FROM AppFunctions WHERE FunctionName = '角色與權限設定' OR FunctionCode = 'ROLE_PERM')
BEGIN
    UPDATE AppFunctions 
    SET ParentID = @SysMgmtID,
        FunctionName = '角色與權限設定',
        FunctionCode = 'ROLE_PERM',
        IconKey = 'admin_panel_settings',
        RoutePath = '/system/permissions',
        SortOrder = 2,
        IsActive = 1
    WHERE FunctionName = '角色與權限設定' OR FunctionCode = 'ROLE_PERM';
END
ELSE
BEGIN
    INSERT INTO AppFunctions (ParentID, FunctionName, FunctionCode, IconKey, RoutePath, SortOrder, IsActive, CreatedAt)
    VALUES (@SysMgmtID, '角色與權限設定', 'ROLE_PERM', 'admin_panel_settings', '/system/permissions', 2, 1, GETDATE());
END

-- 4. 用戶角色指派 (User Role Assignment / User Management)
-- 對應前台: UserManagementPage (Tab 3)
IF EXISTS (SELECT 1 FROM AppFunctions WHERE FunctionName = '用戶角色指派' OR FunctionCode = 'USER_MGMT')
BEGIN
    UPDATE AppFunctions 
    SET ParentID = @SysMgmtID,
        FunctionName = '用戶角色指派', -- 或 '用戶管理'
        FunctionCode = 'USER_MGMT',
        IconKey = 'people',
        RoutePath = '/system/users',
        SortOrder = 3,
        IsActive = 1
    WHERE FunctionName = '用戶角色指派' OR FunctionCode = 'USER_MGMT';
END
ELSE
BEGIN
    INSERT INTO AppFunctions (ParentID, FunctionName, FunctionCode, IconKey, RoutePath, SortOrder, IsActive, CreatedAt)
    VALUES (@SysMgmtID, '用戶角色指派', 'USER_MGMT', 'people', '/system/users', 3, 1, GETDATE());
END
