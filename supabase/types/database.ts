
export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[]

export type Database = {
  
  "api": {
          Tables: {
            [_ in never]: never
          }
          Views: {
            [_ in never]: never
          }
          Functions: {
            "get_current_auth_context":
{ Args: Record<PropertyKey, never>; Returns: Json
                           },
"list_users":
{ Args: { "p_keyword"?: string,"p_page"?: number,"p_page_size"?: number,"p_role_id"?: string }; Returns: Json
                           },
"sync_role_permissions":
{ Args: { "p_permission_ids": (string)[],"p_role_id": string }; Returns: undefined
                           },
"sync_user_roles":
{ Args: { "p_role_ids": (string)[],"p_user_id": string }; Returns: undefined
                           }
          }
          Enums: {
            [_ in never]: never
          }
          CompositeTypes: {
            [_ in never]: never
          }
        },"equip": {
          Tables: {
            "devices": {
                  Row: {
                    "created_at": string,"created_by": string | null,"device_number": string,"id": string,"is_disabled": boolean,"license_number": string | null,"model": string | null,"name": string,"qr_code": string | null,"sort_order": number,"source_code": string | null,"spec": string | null,"state_code": string | null,"unit": string | null,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"created_by"?: string | null,"device_number": string,"id"?: string,"is_disabled"?: boolean,"license_number"?: string | null,"model"?: string | null,"name": string,"qr_code"?: string | null,"sort_order"?: number,"source_code"?: string | null,"spec"?: string | null,"state_code"?: string | null,"unit"?: string | null,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "created_at"?: string,"created_by"?: string | null,"device_number"?: string,"id"?: string,"is_disabled"?: boolean,"license_number"?: string | null,"model"?: string | null,"name"?: string,"qr_code"?: string | null,"sort_order"?: number,"source_code"?: string | null,"spec"?: string | null,"state_code"?: string | null,"unit"?: string | null,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    
                  ]
                }
          }
          Views: {
            [_ in never]: never
          }
          Functions: {
            [_ in never]: never
          }
          Enums: {
            [_ in never]: never
          }
          CompositeTypes: {
            [_ in never]: never
          }
        },"hrm": {
          Tables: {
            "employees": {
                  Row: {
                    "auth_id": string | null,"birth_date": string | null,"code": string,"created_at": string,"created_by": string | null,"email": string | null,"employment_type_code": string | null,"entry_date": string | null,"external_id": string | null,"external_version": number | null,"gender_code": string | null,"hire_date": string | null,"id": string,"id_card": string | null,"is_disabled": boolean | null,"leave_date": string | null,"name": string,"organization_id": string | null,"phone": string | null,"sort_order": number | null,"status_code": string | null,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "auth_id"?: string | null,"birth_date"?: string | null,"code": string,"created_at"?: string,"created_by"?: string | null,"email"?: string | null,"employment_type_code"?: string | null,"entry_date"?: string | null,"external_id"?: string | null,"external_version"?: number | null,"gender_code"?: string | null,"hire_date"?: string | null,"id"?: string,"id_card"?: string | null,"is_disabled"?: boolean | null,"leave_date"?: string | null,"name": string,"organization_id"?: string | null,"phone"?: string | null,"sort_order"?: number | null,"status_code"?: string | null,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "auth_id"?: string | null,"birth_date"?: string | null,"code"?: string,"created_at"?: string,"created_by"?: string | null,"email"?: string | null,"employment_type_code"?: string | null,"entry_date"?: string | null,"external_id"?: string | null,"external_version"?: number | null,"gender_code"?: string | null,"hire_date"?: string | null,"id"?: string,"id_card"?: string | null,"is_disabled"?: boolean | null,"leave_date"?: string | null,"name"?: string,"organization_id"?: string | null,"phone"?: string | null,"sort_order"?: number | null,"status_code"?: string | null,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "employees_organization_id_fkey"
      columns: ["organization_id"]
isOneToOne: false
      referencedRelation: "organizations"
      referencedColumns: ["id"]
    }
                  ]
                },"organizations": {
                  Row: {
                    "address": string | null,"city_code": string | null,"code": string,"country_code": string | null,"created_at": string,"created_by": string | null,"district_code": string | null,"external_id": string | null,"external_version": number | null,"full_name": string | null,"id": string,"is_disabled": boolean,"latitude": number | null,"longitude": number | null,"name": string,"org_category_code": string | null,"org_type_code": string,"parent_id": string | null,"province_code": string | null,"sort_order": number,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "address"?: string | null,"city_code"?: string | null,"code": string,"country_code"?: string | null,"created_at"?: string,"created_by"?: string | null,"district_code"?: string | null,"external_id"?: string | null,"external_version"?: number | null,"full_name"?: string | null,"id"?: string,"is_disabled"?: boolean,"latitude"?: number | null,"longitude"?: number | null,"name": string,"org_category_code"?: string | null,"org_type_code": string,"parent_id"?: string | null,"province_code"?: string | null,"sort_order"?: number,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "address"?: string | null,"city_code"?: string | null,"code"?: string,"country_code"?: string | null,"created_at"?: string,"created_by"?: string | null,"district_code"?: string | null,"external_id"?: string | null,"external_version"?: number | null,"full_name"?: string | null,"id"?: string,"is_disabled"?: boolean,"latitude"?: number | null,"longitude"?: number | null,"name"?: string,"org_category_code"?: string | null,"org_type_code"?: string,"parent_id"?: string | null,"province_code"?: string | null,"sort_order"?: number,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "organizations_parent_id_fkey"
      columns: ["parent_id"]
isOneToOne: false
      referencedRelation: "organizations"
      referencedColumns: ["id"]
    }
                  ]
                }
          }
          Views: {
            [_ in never]: never
          }
          Functions: {
            [_ in never]: never
          }
          Enums: {
            [_ in never]: never
          }
          CompositeTypes: {
            [_ in never]: never
          }
        },"iam": {
          Tables: {
            "permissions": {
                  Row: {
                    "action": Database["iam"]['Enums']["permission_action"],"created_at": string,"created_by": string | null,"description": string | null,"id": string,"is_disabled": boolean,"module": Database["iam"]['Enums']["permission_module"],"name": string,"sort_order": number,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "action": Database["iam"]['Enums']["permission_action"],"created_at"?: string,"created_by"?: string | null,"description"?: string | null,"id"?: string,"is_disabled"?: boolean,"module": Database["iam"]['Enums']["permission_module"],"name": string,"sort_order"?: number,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "action"?: Database["iam"]['Enums']["permission_action"],"created_at"?: string,"created_by"?: string | null,"description"?: string | null,"id"?: string,"is_disabled"?: boolean,"module"?: Database["iam"]['Enums']["permission_module"],"name"?: string,"sort_order"?: number,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    
                  ]
                },"role_permissions": {
                  Row: {
                    "created_at": string,"created_by": string | null,"id": string,"permission_id": string,"role_id": string,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"created_by"?: string | null,"id"?: string,"permission_id": string,"role_id": string,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "created_at"?: string,"created_by"?: string | null,"id"?: string,"permission_id"?: string,"role_id"?: string,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "role_permissions_permission_id_fkey"
      columns: ["permission_id"]
isOneToOne: false
      referencedRelation: "permissions"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "role_permissions_role_id_fkey"
      columns: ["role_id"]
isOneToOne: false
      referencedRelation: "roles"
      referencedColumns: ["id"]
    }
                  ]
                },"roles": {
                  Row: {
                    "code": string,"created_at": string,"created_by": string | null,"description": string | null,"id": string,"is_disabled": boolean,"name": string,"sort_order": number,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "code": string,"created_at"?: string,"created_by"?: string | null,"description"?: string | null,"id"?: string,"is_disabled"?: boolean,"name": string,"sort_order"?: number,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "code"?: string,"created_at"?: string,"created_by"?: string | null,"description"?: string | null,"id"?: string,"is_disabled"?: boolean,"name"?: string,"sort_order"?: number,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    
                  ]
                },"user_profiles": {
                  Row: {
                    "avatar_path": string | null,"created_at": string,"display_name": string | null,"updated_at": string | null,"user_id": string
                  }
                  ComputedFields: never
                  Insert: {
                    "avatar_path"?: string | null,"created_at"?: string,"display_name"?: string | null,"updated_at"?: string | null,"user_id": string
                  }
                  Update: {
                    "avatar_path"?: string | null,"created_at"?: string,"display_name"?: string | null,"updated_at"?: string | null,"user_id"?: string
                  }
                  Relationships: [
                    
                  ]
                },"user_roles": {
                  Row: {
                    "assigned_at": string,"assigned_by": string | null,"id": string,"role_id": string,"user_id": string
                  }
                  ComputedFields: never
                  Insert: {
                    "assigned_at"?: string,"assigned_by"?: string | null,"id"?: string,"role_id": string,"user_id": string
                  }
                  Update: {
                    "assigned_at"?: string,"assigned_by"?: string | null,"id"?: string,"role_id"?: string,"user_id"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "user_roles_role_id_fkey"
      columns: ["role_id"]
isOneToOne: false
      referencedRelation: "roles"
      referencedColumns: ["id"]
    }
                  ]
                }
          }
          Views: {
            [_ in never]: never
          }
          Functions: {
            "get_current_auth_context":
{ Args: Record<PropertyKey, never>; Returns: Json
                           },
"has_permission":
{ Args: { "p_action": Database["iam"]['Enums']["permission_action"],"p_module": Database["iam"]['Enums']["permission_module"] }; Returns: boolean
                           }
          }
          Enums: {
            "permission_action": "read"|"write"|"delete","permission_module": "iam"|"master_data"|"hrm"|"proj"|"equip"|"tbm"|"mqtt"
          }
          CompositeTypes: {
            [_ in never]: never
          }
        },"master_data": {
          Tables: {
            "admin_regions": {
                  Row: {
                    "code": string,"created_at": string,"created_by": string | null,"full_name": string,"is_disabled": boolean,"level": number,"name": string,"parent_code": string | null,"pinyin_code": string,"short_name": string,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "code": string,"created_at"?: string,"created_by"?: string | null,"full_name": string,"is_disabled"?: boolean,"level": number,"name": string,"parent_code"?: string | null,"pinyin_code": string,"short_name": string,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "code"?: string,"created_at"?: string,"created_by"?: string | null,"full_name"?: string,"is_disabled"?: boolean,"level"?: number,"name"?: string,"parent_code"?: string | null,"pinyin_code"?: string,"short_name"?: string,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "admin_regions_parent_code_fkey"
      columns: ["parent_code"]
isOneToOne: false
      referencedRelation: "admin_regions"
      referencedColumns: ["code"]
    }
                  ]
                },"countries": {
                  Row: {
                    "code": string,"created_at": string,"created_by": string | null,"full_name": string | null,"is_disabled": boolean,"name": string,"sort_order": number,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "code": string,"created_at"?: string,"created_by"?: string | null,"full_name"?: string | null,"is_disabled"?: boolean,"name": string,"sort_order"?: number,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "code"?: string,"created_at"?: string,"created_by"?: string | null,"full_name"?: string | null,"is_disabled"?: boolean,"name"?: string,"sort_order"?: number,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    
                  ]
                },"dictionary_items": {
                  Row: {
                    "code": string,"created_at": string,"created_by": string | null,"description": string | null,"dictionary_type_code": string,"is_disabled": boolean,"name": string,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "code": string,"created_at"?: string,"created_by"?: string | null,"description"?: string | null,"dictionary_type_code": string,"is_disabled"?: boolean,"name": string,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "code"?: string,"created_at"?: string,"created_by"?: string | null,"description"?: string | null,"dictionary_type_code"?: string,"is_disabled"?: boolean,"name"?: string,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "dictionary_items_dictionary_type_code_fkey"
      columns: ["dictionary_type_code"]
isOneToOne: false
      referencedRelation: "dictionary_types"
      referencedColumns: ["code"]
    }
                  ]
                },"dictionary_types": {
                  Row: {
                    "code": string,"created_at": string,"created_by": string | null,"description": string | null,"is_disabled": boolean,"name": string,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "code": string,"created_at"?: string,"created_by"?: string | null,"description"?: string | null,"is_disabled"?: boolean,"name": string,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "code"?: string,"created_at"?: string,"created_by"?: string | null,"description"?: string | null,"is_disabled"?: boolean,"name"?: string,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    
                  ]
                },"geological_types": {
                  Row: {
                    "code": string,"created_at": string,"created_by": string | null,"is_disabled": boolean,"name": string,"parent_code": string | null,"remark": string | null,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "code": string,"created_at"?: string,"created_by"?: string | null,"is_disabled"?: boolean,"name": string,"parent_code"?: string | null,"remark"?: string | null,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "code"?: string,"created_at"?: string,"created_by"?: string | null,"is_disabled"?: boolean,"name"?: string,"parent_code"?: string | null,"remark"?: string | null,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "geological_types_parent_code_fkey"
      columns: ["parent_code"]
isOneToOne: false
      referencedRelation: "geological_types"
      referencedColumns: ["code"]
    }
                  ]
                }
          }
          Views: {
            [_ in never]: never
          }
          Functions: {
            [_ in never]: never
          }
          Enums: {
            [_ in never]: never
          }
          CompositeTypes: {
            [_ in never]: never
          }
        },"mqtt": {
          Tables: {
            "acl": {
                  Row: {
                    "action": string,"created_at": string,"created_by": string | null,"id": number,"is_disabled": boolean,"permission": string,"sort_order": number,"topic": string,"updated_at": string | null,"updated_by": string | null,"username": string
                  }
                  ComputedFields: never
                  Insert: {
                    "action": string,"created_at"?: string,"created_by"?: string | null,"id"?: never,"is_disabled"?: boolean,"permission": string,"sort_order"?: number,"topic": string,"updated_at"?: string | null,"updated_by"?: string | null,"username": string
                  }
                  Update: {
                    "action"?: string,"created_at"?: string,"created_by"?: string | null,"id"?: never,"is_disabled"?: boolean,"permission"?: string,"sort_order"?: number,"topic"?: string,"updated_at"?: string | null,"updated_by"?: string | null,"username"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "acl_username_fkey"
      columns: ["username"]
isOneToOne: false
      referencedRelation: "users"
      referencedColumns: ["username"]
    }
                  ]
                },"users": {
                  Row: {
                    "created_at": string,"created_by": string | null,"id": number,"is_disabled": boolean,"is_superuser": boolean,"password_hash": string,"salt": string,"sort_order": number,"updated_at": string | null,"updated_by": string | null,"username": string
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"created_by"?: string | null,"id"?: never,"is_disabled"?: boolean,"is_superuser"?: boolean,"password_hash": string,"salt": string,"sort_order"?: number,"updated_at"?: string | null,"updated_by"?: string | null,"username": string
                  }
                  Update: {
                    "created_at"?: string,"created_by"?: string | null,"id"?: never,"is_disabled"?: boolean,"is_superuser"?: boolean,"password_hash"?: string,"salt"?: string,"sort_order"?: number,"updated_at"?: string | null,"updated_by"?: string | null,"username"?: string
                  }
                  Relationships: [
                    
                  ]
                }
          }
          Views: {
            [_ in never]: never
          }
          Functions: {
            [_ in never]: never
          }
          Enums: {
            [_ in never]: never
          }
          CompositeTypes: {
            [_ in never]: never
          }
        },"proj": {
          Tables: {
            "engineering_units": {
                  Row: {
                    "address": string | null,"city_code": string | null,"created_at": string,"created_by": string | null,"district_code": string | null,"engineering_unit_type_code": string,"full_name": string | null,"id": string,"is_disabled": boolean,"latitude": number | null,"longitude": number | null,"name": string,"overview": string | null,"project_id": string,"province_code": string | null,"sort_order": number,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "address"?: string | null,"city_code"?: string | null,"created_at"?: string,"created_by"?: string | null,"district_code"?: string | null,"engineering_unit_type_code": string,"full_name"?: string | null,"id"?: string,"is_disabled"?: boolean,"latitude"?: number | null,"longitude"?: number | null,"name": string,"overview"?: string | null,"project_id": string,"province_code"?: string | null,"sort_order"?: number,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "address"?: string | null,"city_code"?: string | null,"created_at"?: string,"created_by"?: string | null,"district_code"?: string | null,"engineering_unit_type_code"?: string,"full_name"?: string | null,"id"?: string,"is_disabled"?: boolean,"latitude"?: number | null,"longitude"?: number | null,"name"?: string,"overview"?: string | null,"project_id"?: string,"province_code"?: string | null,"sort_order"?: number,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "engineering_units_project_id_fkey"
      columns: ["project_id"]
isOneToOne: false
      referencedRelation: "projects"
      referencedColumns: ["id"]
    }
                  ]
                },"projects": {
                  Row: {
                    "address": string | null,"city_code": string | null,"code": string,"country_code": string | null,"created_at": string,"created_by": string | null,"district_code": string | null,"external_id": string | null,"external_version": number | null,"full_name": string | null,"id": string,"is_disabled": boolean,"key_points": string | null,"latitude": number | null,"longitude": number | null,"management_mode_code": string,"name": string,"organization_id": string | null,"overview": string | null,"project_sub_type_code": string | null,"project_type_code": string,"province_code": string | null,"region_code": string | null,"sort_order": number,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "address"?: string | null,"city_code"?: string | null,"code": string,"country_code"?: string | null,"created_at"?: string,"created_by"?: string | null,"district_code"?: string | null,"external_id"?: string | null,"external_version"?: number | null,"full_name"?: string | null,"id"?: string,"is_disabled"?: boolean,"key_points"?: string | null,"latitude"?: number | null,"longitude"?: number | null,"management_mode_code": string,"name": string,"organization_id"?: string | null,"overview"?: string | null,"project_sub_type_code"?: string | null,"project_type_code": string,"province_code"?: string | null,"region_code"?: string | null,"sort_order"?: number,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "address"?: string | null,"city_code"?: string | null,"code"?: string,"country_code"?: string | null,"created_at"?: string,"created_by"?: string | null,"district_code"?: string | null,"external_id"?: string | null,"external_version"?: number | null,"full_name"?: string | null,"id"?: string,"is_disabled"?: boolean,"key_points"?: string | null,"latitude"?: number | null,"longitude"?: number | null,"management_mode_code"?: string,"name"?: string,"organization_id"?: string | null,"overview"?: string | null,"project_sub_type_code"?: string | null,"project_type_code"?: string,"province_code"?: string | null,"region_code"?: string | null,"sort_order"?: number,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    
                  ]
                },"tunnel_plan_days": {
                  Row: {
                    "created_at": string,"created_by": string | null,"id": number,"plan_advance_meter": number | null,"plan_id": number,"plan_ring_count": number,"remark": string | null,"updated_at": string | null,"updated_by": string | null,"work_date": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"created_by"?: string | null,"id"?: number,"plan_advance_meter"?: number | null,"plan_id": number,"plan_ring_count": number,"remark"?: string | null,"updated_at"?: string | null,"updated_by"?: string | null,"work_date"?: string | null
                  }
                  Update: {
                    "created_at"?: string,"created_by"?: string | null,"id"?: number,"plan_advance_meter"?: number | null,"plan_id"?: number,"plan_ring_count"?: number,"remark"?: string | null,"updated_at"?: string | null,"updated_by"?: string | null,"work_date"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "tunnel_plan_days_plan_id_fkey"
      columns: ["plan_id"]
isOneToOne: false
      referencedRelation: "tunnel_plans"
      referencedColumns: ["id"]
    }
                  ]
                },"tunnel_plans": {
                  Row: {
                    "created_at": string,"created_by": string | null,"id": number,"plan_name": string,"remark": string | null,"status": string,"tunnel_id": string,"updated_at": string | null,"updated_by": string | null,"version": number
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"created_by"?: string | null,"id"?: number,"plan_name": string,"remark"?: string | null,"status": string,"tunnel_id": string,"updated_at"?: string | null,"updated_by"?: string | null,"version"?: number
                  }
                  Update: {
                    "created_at"?: string,"created_by"?: string | null,"id"?: number,"plan_name"?: string,"remark"?: string | null,"status"?: string,"tunnel_id"?: string,"updated_at"?: string | null,"updated_by"?: string | null,"version"?: number
                  }
                  Relationships: [
                    {
      foreignKeyName: "tunnel_plans_tunnel_id_fkey"
      columns: ["tunnel_id"]
isOneToOne: false
      referencedRelation: "tunnels"
      referencedColumns: ["id"]
    }
                  ]
                },"tunnel_risks": {
                  Row: {
                    "created_at": string,"created_by": string | null,"description": string | null,"end_chainage": number,"id": string,"is_disabled": boolean,"latitude": number | null,"longitude": number | null,"name": string,"risk_level_code": string,"start_chainage": number,"tunnel_id": string,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"created_by"?: string | null,"description"?: string | null,"end_chainage": number,"id"?: string,"is_disabled"?: boolean,"latitude"?: number | null,"longitude"?: number | null,"name": string,"risk_level_code": string,"start_chainage": number,"tunnel_id": string,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "created_at"?: string,"created_by"?: string | null,"description"?: string | null,"end_chainage"?: number,"id"?: string,"is_disabled"?: boolean,"latitude"?: number | null,"longitude"?: number | null,"name"?: string,"risk_level_code"?: string,"start_chainage"?: number,"tunnel_id"?: string,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "tunnel_risks_tunnel_id_fkey"
      columns: ["tunnel_id"]
isOneToOne: false
      referencedRelation: "tunnels"
      referencedColumns: ["id"]
    }
                  ]
                },"tunnel_segments": {
                  Row: {
                    "created_at": string,"created_by": string | null,"end_ring": number,"id": string,"inner_diameter": number | null,"is_disabled": boolean,"name": string,"outer_diameter": number | null,"ring_thickness": number | null,"ring_width": number | null,"sort_order": number,"start_ring": number,"tunnel_id": string,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"created_by"?: string | null,"end_ring": number,"id"?: string,"inner_diameter"?: number | null,"is_disabled"?: boolean,"name": string,"outer_diameter"?: number | null,"ring_thickness"?: number | null,"ring_width"?: number | null,"sort_order"?: number,"start_ring": number,"tunnel_id": string,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "created_at"?: string,"created_by"?: string | null,"end_ring"?: number,"id"?: string,"inner_diameter"?: number | null,"is_disabled"?: boolean,"name"?: string,"outer_diameter"?: number | null,"ring_thickness"?: number | null,"ring_width"?: number | null,"sort_order"?: number,"start_ring"?: number,"tunnel_id"?: string,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "tunnel_segments_tunnel_id_fkey"
      columns: ["tunnel_id"]
isOneToOne: false
      referencedRelation: "tunnels"
      referencedColumns: ["id"]
    }
                  ]
                },"tunnels": {
                  Row: {
                    "chainage_adjustment": number,"chainage_prefix": string,"created_at": string,"created_by": string | null,"end_chainage": number,"end_ring": number,"engineering_unit_id": string,"excavation_diameter": number | null,"full_name": string | null,"id": string,"is_disabled": boolean,"name": string,"overview": string | null,"sort_order": number,"start_chainage": number,"start_ring": number,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "chainage_adjustment"?: number,"chainage_prefix"?: string,"created_at"?: string,"created_by"?: string | null,"end_chainage": number,"end_ring": number,"engineering_unit_id": string,"excavation_diameter"?: number | null,"full_name"?: string | null,"id"?: string,"is_disabled"?: boolean,"name": string,"overview"?: string | null,"sort_order"?: number,"start_chainage": number,"start_ring": number,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "chainage_adjustment"?: number,"chainage_prefix"?: string,"created_at"?: string,"created_by"?: string | null,"end_chainage"?: number,"end_ring"?: number,"engineering_unit_id"?: string,"excavation_diameter"?: number | null,"full_name"?: string | null,"id"?: string,"is_disabled"?: boolean,"name"?: string,"overview"?: string | null,"sort_order"?: number,"start_chainage"?: number,"start_ring"?: number,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "tunnels_engineering_unit_id_fkey"
      columns: ["engineering_unit_id"]
isOneToOne: false
      referencedRelation: "engineering_units"
      referencedColumns: ["id"]
    }
                  ]
                }
          }
          Views: {
            [_ in never]: never
          }
          Functions: {
            [_ in never]: never
          }
          Enums: {
            [_ in never]: never
          }
          CompositeTypes: {
            [_ in never]: never
          }
        },"public": {
          Tables: {
            [_ in never]: never
          }
          Views: {
            [_ in never]: never
          }
          Functions: {
            [_ in never]: never
          }
          Enums: {
            [_ in never]: never
          }
          CompositeTypes: {
            [_ in never]: never
          }
        },"system": {
          Tables: {
            "applications": {
                  Row: {
                    "base_url": string,"code": string,"created_at": string,"created_by": string | null,"description": string | null,"icon": string | null,"is_disabled": boolean,"is_visible": boolean,"name": string,"sort_order": number,"updated_at": string,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "base_url": string,"code": string,"created_at"?: string,"created_by"?: string | null,"description"?: string | null,"icon"?: string | null,"is_disabled"?: boolean,"is_visible"?: boolean,"name": string,"sort_order"?: number,"updated_at"?: string,"updated_by"?: string | null
                  }
                  Update: {
                    "base_url"?: string,"code"?: string,"created_at"?: string,"created_by"?: string | null,"description"?: string | null,"icon"?: string | null,"is_disabled"?: boolean,"is_visible"?: boolean,"name"?: string,"sort_order"?: number,"updated_at"?: string,"updated_by"?: string | null
                  }
                  Relationships: [
                    
                  ]
                },"menus": {
                  Row: {
                    "app_code": string,"code": string,"created_at": string,"created_by": string | null,"icon": string | null,"id": string,"is_disabled": boolean,"is_visible": boolean,"name": string,"parent_id": string | null,"path_url": string | null,"sort_order": number,"updated_at": string,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "app_code"?: string,"code": string,"created_at"?: string,"created_by"?: string | null,"icon"?: string | null,"id"?: string,"is_disabled"?: boolean,"is_visible"?: boolean,"name": string,"parent_id"?: string | null,"path_url"?: string | null,"sort_order"?: number,"updated_at"?: string,"updated_by"?: string | null
                  }
                  Update: {
                    "app_code"?: string,"code"?: string,"created_at"?: string,"created_by"?: string | null,"icon"?: string | null,"id"?: string,"is_disabled"?: boolean,"is_visible"?: boolean,"name"?: string,"parent_id"?: string | null,"path_url"?: string | null,"sort_order"?: number,"updated_at"?: string,"updated_by"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "menus_app_code_fkey"
      columns: ["app_code"]
isOneToOne: false
      referencedRelation: "applications"
      referencedColumns: ["code"]
    },{
      foreignKeyName: "menus_parent_id_fkey"
      columns: ["parent_id"]
isOneToOne: false
      referencedRelation: "menus"
      referencedColumns: ["id"]
    }
                  ]
                },"notification_attempts": {
                  Row: {
                    "attempt_no": number,"error_message": string | null,"finished_at": string | null,"id": number,"outbox_id": number,"provider_message_id": string | null,"response_code": string | null,"started_at": string,"status": string
                  }
                  ComputedFields: never
                  Insert: {
                    "attempt_no": number,"error_message"?: string | null,"finished_at"?: string | null,"id"?: never,"outbox_id": number,"provider_message_id"?: string | null,"response_code"?: string | null,"started_at"?: string,"status": string
                  }
                  Update: {
                    "attempt_no"?: number,"error_message"?: string | null,"finished_at"?: string | null,"id"?: never,"outbox_id"?: number,"provider_message_id"?: string | null,"response_code"?: string | null,"started_at"?: string,"status"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "notification_attempts_outbox_id_fkey"
      columns: ["outbox_id"]
isOneToOne: false
      referencedRelation: "notification_outbox"
      referencedColumns: ["id"]
    }
                  ]
                },"notification_event_types": {
                  Row: {
                    "code": string,"default_level": string,"description": string | null,"is_disabled": boolean,"name": string,"sort_order": number
                  }
                  ComputedFields: never
                  Insert: {
                    "code": string,"default_level"?: string,"description"?: string | null,"is_disabled"?: boolean,"name": string,"sort_order"?: number
                  }
                  Update: {
                    "code"?: string,"default_level"?: string,"description"?: string | null,"is_disabled"?: boolean,"name"?: string,"sort_order"?: number
                  }
                  Relationships: [
                    
                  ]
                },"notification_events": {
                  Row: {
                    "created_at": string,"created_by": string | null,"event_type_code": string,"id": number,"level": string,"occurred_at": string,"organization_id": string | null,"payload": NonNullable<Json>,"processed_at": string | null,"processing_error": string | null,"project_id": string | null,"retry_count": number,"source_id": string,"source_type_code": string,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"created_by"?: string | null,"event_type_code": string,"id"?: never,"level"?: string,"occurred_at": string,"organization_id"?: string | null,"payload": NonNullable<Json>,"processed_at"?: string | null,"processing_error"?: string | null,"project_id"?: string | null,"retry_count"?: number,"source_id": string,"source_type_code": string,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "created_at"?: string,"created_by"?: string | null,"event_type_code"?: string,"id"?: never,"level"?: string,"occurred_at"?: string,"organization_id"?: string | null,"payload"?: NonNullable<Json>,"processed_at"?: string | null,"processing_error"?: string | null,"project_id"?: string | null,"retry_count"?: number,"source_id"?: string,"source_type_code"?: string,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "notification_events_event_type_code_fkey"
      columns: ["event_type_code"]
isOneToOne: false
      referencedRelation: "notification_event_types"
      referencedColumns: ["code"]
    },{
      foreignKeyName: "notification_events_source_type_code_fkey"
      columns: ["source_type_code"]
isOneToOne: false
      referencedRelation: "notification_sources"
      referencedColumns: ["code"]
    }
                  ]
                },"notification_outbox": {
                  Row: {
                    "attempt_count": number,"channel": string,"content": string,"created_at": string,"dedup_key": string,"event_id": number,"id": number,"last_error": string | null,"next_retry_at": string | null,"processing_at": string | null,"provider_message_id": string | null,"recipient": string,"rule_id": number | null,"sent_at": string | null,"status": string,"title": string,"updated_at": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "attempt_count"?: number,"channel": string,"content": string,"created_at"?: string,"dedup_key": string,"event_id": number,"id"?: never,"last_error"?: string | null,"next_retry_at"?: string | null,"processing_at"?: string | null,"provider_message_id"?: string | null,"recipient": string,"rule_id"?: number | null,"sent_at"?: string | null,"status"?: string,"title"?: string,"updated_at"?: string | null
                  }
                  Update: {
                    "attempt_count"?: number,"channel"?: string,"content"?: string,"created_at"?: string,"dedup_key"?: string,"event_id"?: number,"id"?: never,"last_error"?: string | null,"next_retry_at"?: string | null,"processing_at"?: string | null,"provider_message_id"?: string | null,"recipient"?: string,"rule_id"?: number | null,"sent_at"?: string | null,"status"?: string,"title"?: string,"updated_at"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "notification_outbox_event_id_fkey"
      columns: ["event_id"]
isOneToOne: false
      referencedRelation: "notification_events"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "notification_outbox_rule_id_fkey"
      columns: ["rule_id"]
isOneToOne: false
      referencedRelation: "notification_rules"
      referencedColumns: ["id"]
    }
                  ]
                },"notification_rules": {
                  Row: {
                    "channel": string,"created_at": string,"created_by": string | null,"description": string | null,"event_type_code": string,"id": number,"is_disabled": boolean,"min_level": string,"name": string,"sort_order": number,"source_type_code": string,"template_id": number,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "channel": string,"created_at"?: string,"created_by"?: string | null,"description"?: string | null,"event_type_code": string,"id"?: never,"is_disabled"?: boolean,"min_level"?: string,"name": string,"sort_order"?: number,"source_type_code": string,"template_id": number,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "channel"?: string,"created_at"?: string,"created_by"?: string | null,"description"?: string | null,"event_type_code"?: string,"id"?: never,"is_disabled"?: boolean,"min_level"?: string,"name"?: string,"sort_order"?: number,"source_type_code"?: string,"template_id"?: number,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "notification_rules_event_type_code_fkey"
      columns: ["event_type_code"]
isOneToOne: false
      referencedRelation: "notification_event_types"
      referencedColumns: ["code"]
    },{
      foreignKeyName: "notification_rules_source_type_code_fkey"
      columns: ["source_type_code"]
isOneToOne: false
      referencedRelation: "notification_sources"
      referencedColumns: ["code"]
    },{
      foreignKeyName: "notification_rules_template_id_fkey"
      columns: ["template_id"]
isOneToOne: false
      referencedRelation: "notification_templates"
      referencedColumns: ["id"]
    }
                  ]
                },"notification_sources": {
                  Row: {
                    "code": string,"description": string | null,"is_disabled": boolean,"name": string,"sort_order": number
                  }
                  ComputedFields: never
                  Insert: {
                    "code": string,"description"?: string | null,"is_disabled"?: boolean,"name": string,"sort_order"?: number
                  }
                  Update: {
                    "code"?: string,"description"?: string | null,"is_disabled"?: boolean,"name"?: string,"sort_order"?: number
                  }
                  Relationships: [
                    
                  ]
                },"notification_subscriptions": {
                  Row: {
                    "created_at": string,"created_by": string | null,"employee_id": string,"event_type_code": string,"id": number,"is_disabled": boolean,"min_level": string,"project_id": string | null,"source_type_code": string,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"created_by"?: string | null,"employee_id": string,"event_type_code": string,"id"?: number,"is_disabled"?: boolean,"min_level"?: string,"project_id"?: string | null,"source_type_code": string,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "created_at"?: string,"created_by"?: string | null,"employee_id"?: string,"event_type_code"?: string,"id"?: number,"is_disabled"?: boolean,"min_level"?: string,"project_id"?: string | null,"source_type_code"?: string,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "notification_subscriptions_event_type_code_fkey"
      columns: ["event_type_code"]
isOneToOne: false
      referencedRelation: "notification_event_types"
      referencedColumns: ["code"]
    },{
      foreignKeyName: "notification_subscriptions_source_type_code_fkey"
      columns: ["source_type_code"]
isOneToOne: false
      referencedRelation: "notification_sources"
      referencedColumns: ["code"]
    }
                  ]
                },"notification_templates": {
                  Row: {
                    "body_template": string,"channel": string,"created_at": string,"created_by": string | null,"description": string | null,"id": number,"is_disabled": boolean,"name": string,"sort_order": number,"title_template": string | null,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "body_template": string,"channel": string,"created_at"?: string,"created_by"?: string | null,"description"?: string | null,"id"?: never,"is_disabled"?: boolean,"name": string,"sort_order"?: number,"title_template"?: string | null,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "body_template"?: string,"channel"?: string,"created_at"?: string,"created_by"?: string | null,"description"?: string | null,"id"?: never,"is_disabled"?: boolean,"name"?: string,"sort_order"?: number,"title_template"?: string | null,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    
                  ]
                },"parameter_alarm_subscriptions": {
                  Row: {
                    "cooldown_minutes": number,"created_at": string,"created_by": string | null,"employee_id": string,"id": string,"is_disabled": boolean,"parameter_code": string,"severity_code": string | null,"tbm_code": string,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "cooldown_minutes"?: number,"created_at"?: string,"created_by"?: string | null,"employee_id": string,"id"?: string,"is_disabled"?: boolean,"parameter_code": string,"severity_code"?: string | null,"tbm_code": string,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "cooldown_minutes"?: number,"created_at"?: string,"created_by"?: string | null,"employee_id"?: string,"id"?: string,"is_disabled"?: boolean,"parameter_code"?: string,"severity_code"?: string | null,"tbm_code"?: string,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    
                  ]
                },"settings": {
                  Row: {
                    "created_at": string,"created_by": string | null,"description": string | null,"key": string,"updated_at": string | null,"updated_by": string | null,"value": NonNullable<Json>
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"created_by"?: string | null,"description"?: string | null,"key": string,"updated_at"?: string | null,"updated_by"?: string | null,"value": NonNullable<Json>
                  }
                  Update: {
                    "created_at"?: string,"created_by"?: string | null,"description"?: string | null,"key"?: string,"updated_at"?: string | null,"updated_by"?: string | null,"value"?: NonNullable<Json>
                  }
                  Relationships: [
                    
                  ]
                }
          }
          Views: {
            [_ in never]: never
          }
          Functions: {
            "claim_notification_outbox":
{ Args: { "p_limit": number }; Returns: {
              "attempt_count": number,
"channel": string,
"content": string,
"created_at": string,
"dedup_key": string,
"event_id": number,
"id": number,
"last_error": string | null,
"next_retry_at": string | null,
"processing_at": string | null,
"provider_message_id": string | null,
"recipient": string,
"rule_id": number | null,
"sent_at": string | null,
"status": string,
"title": string,
"updated_at": string | null
            }[]
                          SetofOptions: {
        from: "*"
        to: "notification_outbox"
        isOneToOne: false
        isSetofReturn: true
      } },
"dispatch_notification_event":
{ Args: { "p_event_id": number,"p_tasks": Json }; Returns: boolean
                           },
"fail_notification_event":
{ Args: { "p_error": string,"p_event_id": number }; Returns: undefined
                           }
          }
          Enums: {
            [_ in never]: never
          }
          CompositeTypes: {
            [_ in never]: never
          }
        },"tbm": {
          Tables: {
            "assignments": {
                  Row: {
                    "advance_direction": string,"created_at": string,"created_by": string | null,"end_date": string | null,"id": string,"remark": string | null,"start_date": string,"tbm_code": string,"tunnel_id": string,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "advance_direction": string,"created_at"?: string,"created_by"?: string | null,"end_date"?: string | null,"id"?: string,"remark"?: string | null,"start_date": string,"tbm_code": string,"tunnel_id": string,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "advance_direction"?: string,"created_at"?: string,"created_by"?: string | null,"end_date"?: string | null,"id"?: string,"remark"?: string | null,"start_date"?: string,"tbm_code"?: string,"tunnel_id"?: string,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "assignments_tbm_code_fkey"
      columns: ["tbm_code"]
isOneToOne: false
      referencedRelation: "tbms"
      referencedColumns: ["code"]
    },{
      foreignKeyName: "assignments_tunnel_id_fkey"
      columns: ["tunnel_id"]
isOneToOne: false
      referencedRelation: "v_assignable_tunnels"
      referencedColumns: ["id"]
    }
                  ]
                },"connection_status": {
                  Row: {
                    "last_heartbeat_at": string | null,"last_realdata_at": string | null,"last_sampled_at": string | null,"tbm_code": string,"updated_at": string
                  }
                  ComputedFields: never
                  Insert: {
                    "last_heartbeat_at"?: string | null,"last_realdata_at"?: string | null,"last_sampled_at"?: string | null,"tbm_code": string,"updated_at"?: string
                  }
                  Update: {
                    "last_heartbeat_at"?: string | null,"last_realdata_at"?: string | null,"last_sampled_at"?: string | null,"tbm_code"?: string,"updated_at"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "connection_status_tbm_code_fkey"
      columns: ["tbm_code"]
isOneToOne: true
      referencedRelation: "tbms"
      referencedColumns: ["code"]
    }
                  ]
                },"connection_status_history": {
                  Row: {
                    "created_at": string,"end_at": string | null,"id": number,"remark": string | null,"source": string,"start_at": string,"status": string,"tbm_code": string,"type": string,"updated_at": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"end_at"?: string | null,"id"?: never,"remark"?: string | null,"source"?: string,"start_at": string,"status": string,"tbm_code": string,"type": string,"updated_at"?: string | null
                  }
                  Update: {
                    "created_at"?: string,"end_at"?: string | null,"id"?: never,"remark"?: string | null,"source"?: string,"start_at"?: string,"status"?: string,"tbm_code"?: string,"type"?: string,"updated_at"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "connection_status_history_tbm_code_fkey"
      columns: ["tbm_code"]
isOneToOne: false
      referencedRelation: "tbms"
      referencedColumns: ["code"]
    }
                  ]
                },"parameter_alarm_verifications": {
                  Row: {
                    "alarm_id": number,"id": number,"new_status": string,"previous_status": string,"remark": string | null,"verified_at": string,"verified_by": string
                  }
                  ComputedFields: never
                  Insert: {
                    "alarm_id": number,"id"?: never,"new_status": string,"previous_status": string,"remark"?: string | null,"verified_at"?: string,"verified_by": string
                  }
                  Update: {
                    "alarm_id"?: number,"id"?: never,"new_status"?: string,"previous_status"?: string,"remark"?: string | null,"verified_at"?: string,"verified_by"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "parameter_alarm_verifications_alarm_id_fkey"
      columns: ["alarm_id"]
isOneToOne: false
      referencedRelation: "parameter_alarms"
      referencedColumns: ["id"]
    }
                  ]
                },"parameter_alarms": {
                  Row: {
                    "alarm_value": number,"chainage": number | null,"created_at": string,"created_by": string | null,"id": number,"occurred_at": string,"parameter_code": string,"ring_no": number | null,"rule_snapshot": NonNullable<Json>,"severity_code": string,"tbm_code": string,"tunnel_id": string
                  }
                  ComputedFields: never
                  Insert: {
                    "alarm_value": number,"chainage"?: number | null,"created_at"?: string,"created_by"?: string | null,"id"?: never,"occurred_at": string,"parameter_code": string,"ring_no"?: number | null,"rule_snapshot": NonNullable<Json>,"severity_code": string,"tbm_code": string,"tunnel_id": string
                  }
                  Update: {
                    "alarm_value"?: number,"chainage"?: number | null,"created_at"?: string,"created_by"?: string | null,"id"?: never,"occurred_at"?: string,"parameter_code"?: string,"ring_no"?: number | null,"rule_snapshot"?: NonNullable<Json>,"severity_code"?: string,"tbm_code"?: string,"tunnel_id"?: string
                  }
                  Relationships: [
                    {
      foreignKeyName: "parameter_alarms_parameter_code_fkey"
      columns: ["parameter_code"]
isOneToOne: false
      referencedRelation: "parameters"
      referencedColumns: ["code"]
    },{
      foreignKeyName: "parameter_alarms_tbm_code_fkey"
      columns: ["tbm_code"]
isOneToOne: false
      referencedRelation: "tbms"
      referencedColumns: ["code"]
    },{
      foreignKeyName: "parameter_alarms_tunnel_id_fkey"
      columns: ["tunnel_id"]
isOneToOne: false
      referencedRelation: "v_assignable_tunnels"
      referencedColumns: ["id"]
    }
                  ]
                },"parameter_control_items": {
                  Row: {
                    "description": string | null,"id": number,"max_value": number | null,"min_value": number | null,"name": string,"parameter_code": string | null,"scheme_id": string,"sort_order": number,"target_value": number | null,"unit": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "description"?: string | null,"id"?: never,"max_value"?: number | null,"min_value"?: number | null,"name": string,"parameter_code"?: string | null,"scheme_id": string,"sort_order"?: number,"target_value"?: number | null,"unit"?: string | null
                  }
                  Update: {
                    "description"?: string | null,"id"?: never,"max_value"?: number | null,"min_value"?: number | null,"name"?: string,"parameter_code"?: string | null,"scheme_id"?: string,"sort_order"?: number,"target_value"?: number | null,"unit"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "parameter_control_items_scheme_id_fkey"
      columns: ["scheme_id"]
isOneToOne: false
      referencedRelation: "parameter_control_schemes"
      referencedColumns: ["id"]
    }
                  ]
                },"parameter_control_schemes": {
                  Row: {
                    "created_at": string,"description": string | null,"effective_at": string | null,"end_ring": number | null,"id": string,"name": string,"start_ring": number | null,"status": string,"tunnel_id": string,"version": number
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"description"?: string | null,"effective_at"?: string | null,"end_ring"?: number | null,"id"?: string,"name": string,"start_ring"?: number | null,"status"?: string,"tunnel_id": string,"version"?: number
                  }
                  Update: {
                    "created_at"?: string,"description"?: string | null,"effective_at"?: string | null,"end_ring"?: number | null,"id"?: string,"name"?: string,"start_ring"?: number | null,"status"?: string,"tunnel_id"?: string,"version"?: number
                  }
                  Relationships: [
                    {
      foreignKeyName: "parameter_control_schemes_tunnel_id_fkey"
      columns: ["tunnel_id"]
isOneToOne: false
      referencedRelation: "v_assignable_tunnels"
      referencedColumns: ["id"]
    }
                  ]
                },"parameter_threshold_defaults": {
                  Row: {
                    "created_at": string,"created_by": string | null,"id": number,"is_disabled": boolean,"min_record_delta": number,"min_record_interval_seconds": number,"parameter_code": string,"reference_value": number | null,"remark": string | null,"severity_code": string,"threshold_type": string,"threshold_value": number,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"created_by"?: string | null,"id"?: never,"is_disabled"?: boolean,"min_record_delta"?: number,"min_record_interval_seconds"?: number,"parameter_code": string,"reference_value"?: number | null,"remark"?: string | null,"severity_code": string,"threshold_type": string,"threshold_value": number,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "created_at"?: string,"created_by"?: string | null,"id"?: never,"is_disabled"?: boolean,"min_record_delta"?: number,"min_record_interval_seconds"?: number,"parameter_code"?: string,"reference_value"?: number | null,"remark"?: string | null,"severity_code"?: string,"threshold_type"?: string,"threshold_value"?: number,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "parameter_threshold_defaults_parameter_code_fkey"
      columns: ["parameter_code"]
isOneToOne: false
      referencedRelation: "parameters"
      referencedColumns: ["code"]
    }
                  ]
                },"parameter_thresholds": {
                  Row: {
                    "created_at": string,"created_by": string | null,"end_ring": number,"id": number,"is_disabled": boolean,"min_record_delta": number,"min_record_interval_seconds": number,"reference_value": number | null,"remark": string | null,"severity_code": string,"start_ring": number,"tbm_parameter_id": number,"threshold_type": string,"threshold_value": number,"tunnel_id": string | null,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"created_by"?: string | null,"end_ring": number,"id"?: never,"is_disabled"?: boolean,"min_record_delta"?: number,"min_record_interval_seconds"?: number,"reference_value"?: number | null,"remark"?: string | null,"severity_code": string,"start_ring": number,"tbm_parameter_id": number,"threshold_type": string,"threshold_value": number,"tunnel_id"?: string | null,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "created_at"?: string,"created_by"?: string | null,"end_ring"?: number,"id"?: never,"is_disabled"?: boolean,"min_record_delta"?: number,"min_record_interval_seconds"?: number,"reference_value"?: number | null,"remark"?: string | null,"severity_code"?: string,"start_ring"?: number,"tbm_parameter_id"?: number,"threshold_type"?: string,"threshold_value"?: number,"tunnel_id"?: string | null,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "parameter_thresholds_tbm_parameter_id_fkey"
      columns: ["tbm_parameter_id"]
isOneToOne: false
      referencedRelation: "tbm_parameters"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "parameter_thresholds_tunnel_id_fkey"
      columns: ["tunnel_id"]
isOneToOne: false
      referencedRelation: "v_assignable_tunnels"
      referencedColumns: ["id"]
    }
                  ]
                },"parameters": {
                  Row: {
                    "code": string,"created_at": string,"created_by": string | null,"data_type": string,"description": string | null,"digits": number | null,"is_disabled": boolean,"name": string,"sort_order": number,"subsystem_code": string,"unit": string | null,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "code": string,"created_at"?: string,"created_by"?: string | null,"data_type": string,"description"?: string | null,"digits"?: number | null,"is_disabled"?: boolean,"name": string,"sort_order"?: number,"subsystem_code": string,"unit"?: string | null,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "code"?: string,"created_at"?: string,"created_by"?: string | null,"data_type"?: string,"description"?: string | null,"digits"?: number | null,"is_disabled"?: boolean,"name"?: string,"sort_order"?: number,"subsystem_code"?: string,"unit"?: string | null,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "parameters_subsystem_code_fkey"
      columns: ["subsystem_code"]
isOneToOne: false
      referencedRelation: "subsystems"
      referencedColumns: ["code"]
    }
                  ]
                },"ring_phase_records": {
                  Row: {
                    "created_at": string,"created_by": string | null,"end_chainage": number | null,"ended_at": string | null,"id": number,"ring_no": number,"start_chainage": number | null,"started_at": string,"tbm_code": string,"tbm_phase_type": string,"tunnel_id": string,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"created_by"?: string | null,"end_chainage"?: number | null,"ended_at"?: string | null,"id"?: never,"ring_no": number,"start_chainage"?: number | null,"started_at": string,"tbm_code": string,"tbm_phase_type": string,"tunnel_id": string,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "created_at"?: string,"created_by"?: string | null,"end_chainage"?: number | null,"ended_at"?: string | null,"id"?: never,"ring_no"?: number,"start_chainage"?: number | null,"started_at"?: string,"tbm_code"?: string,"tbm_phase_type"?: string,"tunnel_id"?: string,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "ring_phase_records_tbm_code_fkey"
      columns: ["tbm_code"]
isOneToOne: false
      referencedRelation: "tbms"
      referencedColumns: ["code"]
    },{
      foreignKeyName: "ring_phase_records_tunnel_id_fkey"
      columns: ["tunnel_id"]
isOneToOne: false
      referencedRelation: "v_assignable_tunnels"
      referencedColumns: ["id"]
    }
                  ]
                },"shield_crec1137": {
                  Row: {
                    "b000000001": boolean | null,"b000000002": boolean | null,"created_at": string,"id": number,"s010101010": number | null,"s010101011": number | null,"s010101012": number | null,"s010101013": number | null,"s010102004": number | null,"s010103006": number | null,"s010109001": number | null,"s010111001": number | null,"s010114003": number | null,"s011306002": number | null,"s011311001": number | null,"s020901001": number | null,"s020901002": number | null,"s020901003": number | null,"s020901004": number | null,"s020901005": number | null,"s020901006": number | null,"s020901007": number | null,"s020901008": number | null,"s020901009": number | null,"s020901010": number | null,"s020901011": number | null,"s020901012": number | null,"s020901013": number | null,"s020901014": number | null,"s020902001": number | null,"s020902002": number | null,"s020906001": number | null,"s020906002": number | null,"s020906003": number | null,"s020906004": number | null,"s021711001": number | null,"s021711002": number | null,"s030006002": number | null,"s030006004": number | null,"s030007001": number | null,"s030007002": number | null,"s030007003": number | null,"s030008001": number | null,"s030008002": number | null,"s030008003": number | null,"s030102001": number | null,"s030103001": number | null,"s030104001": number | null,"s030105001": number | null,"s030108001": number | null,"s030202001": number | null,"s030203001": number | null,"s030204001": number | null,"s030205001": number | null,"s030208001": number | null,"s030302001": number | null,"s030303001": number | null,"s030304001": number | null,"s030305001": number | null,"s030308001": number | null,"s030402001": number | null,"s030403001": number | null,"s030404001": number | null,"s030405001": number | null,"s030408001": number | null,"s030502001": number | null,"s030503001": number | null,"s030504001": number | null,"s030505001": number | null,"s030508001": number | null,"s030602001": number | null,"s030603001": number | null,"s030604001": number | null,"s030605001": number | null,"s030608001": number | null,"s030702001": number | null,"s030703001": number | null,"s030704001": number | null,"s030705001": number | null,"s030708001": number | null,"s050001001": number | null,"s050001010": number | null,"s050001011": number | null,"s050001012": number | null,"s050001013": number | null,"s050001019": number | null,"s050001020": number | null,"s050001021": number | null,"s050001022": number | null,"s050006005": number | null,"s050006006": number | null,"s050006007": number | null,"s050006008": number | null,"s050009003": number | null,"s050100008": number | null,"s050109001": number | null,"s051206001": number | null,"s051206002": number | null,"s070102001": number | null,"s070109001": number | null,"s070201001": number | null,"s070201003": number | null,"s070204001": number | null,"s070204005": number | null,"s070301001": number | null,"s070401002": number | null,"s070606001": number | null,"s070606002": number | null,"s080201001": number | null,"s080201002": number | null,"s090109003": number | null,"s100100005": number | null,"s100100006": number | null,"s100100007": number | null,"s100100008": number | null,"s100111009": number | null,"s100111010": number | null,"s100206003": number | null,"s100206004": number | null,"s100206006": number | null,"s100206007": number | null,"s100206009": number | null,"s100206010": number | null,"s200013001": number | null,"s200013002": number | null,"s200101001": number | null,"s200113005": number | null,"s200113006": number | null,"s200113007": number | null,"s200113008": number | null,"s200113009": number | null,"s200113010": number | null,"s200201001": number | null,"s200301001": number | null,"s200313003": number | null,"s200313004": number | null,"s200313005": number | null,"s200313006": number | null,"s200313007": number | null,"s200313008": number | null,"s200401001": number | null,"s200701001": number | null,"s200701002": number | null,"s210013001": number | null,"s210013002": number | null,"s210013003": number | null,"s210013004": number | null,"s210013005": number | null,"s210013006": number | null,"s210101002": number | null,"s210113001": number | null,"s210113002": number | null,"s210201002": number | null,"s210213001": number | null,"s210213002": number | null,"s210301002": number | null,"s210313001": number | null,"s210313002": number | null,"s210401002": number | null,"s210413001": number | null,"s210413002": number | null,"s210501002": number | null,"s210513001": number | null,"s210513002": number | null,"s210601002": number | null,"s210613001": number | null,"s210613002": number | null,"s220830001": number | null,"s220830002": number | null,"s220830005": number | null,"s220840001": number | null,"s220840002": number | null,"s220840005": number | null,"s220850001": number | null,"s220850002": number | null,"s220850005": number | null,"s220850006": number | null,"s220850007": number | null,"s220850010": number | null,"s240101001": number | null,"s240113001": number | null,"s240113002": number | null,"s240301002": number | null,"s260001001": number | null,"s260001002": number | null,"s260013001": number | null,"s260013002": number | null,"s260200005": number | null,"s260201002": number | null,"s260201004": number | null,"s260201007": number | null,"s260213009": number | null,"s260301002": number | null,"s260813012": number | null,"s261912001": number | null,"s270406001": number | null,"s270500002": number | null,"s270513003": number | null,"s280101001": number | null,"s280101002": number | null,"s280101003": number | null,"s280101004": number | null,"s280101005": number | null,"s280101006": number | null,"s280101007": number | null,"s280101008": number | null,"s280113001": number | null,"s280113002": number | null,"s280113003": number | null,"s280113004": number | null,"s280113005": number | null,"s280113006": number | null,"s280113007": number | null,"s280113008": number | null,"s280301001": number | null,"s280301002": number | null,"s280301003": number | null,"s280301004": number | null,"s280301005": number | null,"s280301006": number | null,"s280301007": number | null,"s280301008": number | null,"s280313001": number | null,"s280313002": number | null,"s280313003": number | null,"s280313004": number | null,"s280313005": number | null,"s280313006": number | null,"s280313007": number | null,"s280313008": number | null,"s280501001": number | null,"s280501002": number | null,"s280501003": number | null,"s280501004": number | null,"s280501005": number | null,"s280501006": number | null,"s280501007": number | null,"s280501008": number | null,"s280513001": number | null,"s280513002": number | null,"s280513003": number | null,"s280513004": number | null,"s280513005": number | null,"s280513006": number | null,"s280513007": number | null,"s280513008": number | null,"s280613001": number | null,"s280613002": number | null,"s300101001": number | null,"s301301001": number | null,"s302004001": number | null,"s310007001": number | null,"s310007002": number | null,"s310008001": number | null,"s310203001": number | null,"s310203002": number | null,"s310203003": number | null,"s310207001": number | null,"s310207002": number | null,"s310207003": number | null,"sampled_at": string,"t030100001": number | null,"t030100002": number | null,"t030100003": number | null,"t030100004": number | null,"t030100005": number | null,"t030100006": number | null,"t030100007": number | null,"t030100008": number | null,"t030100009": number | null,"t030100010": number | null,"t030100011": number | null,"t030100012": number | null,"t030100013": number | null,"t030100014": number | null,"t030100015": number | null,"t030102015": number | null,"t030102016": number | null,"t030102017": number | null,"t030102018": number | null,"t030102019": number | null,"t030102020": number | null,"t030102021": number | null,"tbm_code": string,"updated_at": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "b000000001"?: boolean | null,"b000000002"?: boolean | null,"created_at"?: string,"id"?: never,"s010101010"?: number | null,"s010101011"?: number | null,"s010101012"?: number | null,"s010101013"?: number | null,"s010102004"?: number | null,"s010103006"?: number | null,"s010109001"?: number | null,"s010111001"?: number | null,"s010114003"?: number | null,"s011306002"?: number | null,"s011311001"?: number | null,"s020901001"?: number | null,"s020901002"?: number | null,"s020901003"?: number | null,"s020901004"?: number | null,"s020901005"?: number | null,"s020901006"?: number | null,"s020901007"?: number | null,"s020901008"?: number | null,"s020901009"?: number | null,"s020901010"?: number | null,"s020901011"?: number | null,"s020901012"?: number | null,"s020901013"?: number | null,"s020901014"?: number | null,"s020902001"?: number | null,"s020902002"?: number | null,"s020906001"?: number | null,"s020906002"?: number | null,"s020906003"?: number | null,"s020906004"?: number | null,"s021711001"?: number | null,"s021711002"?: number | null,"s030006002"?: number | null,"s030006004"?: number | null,"s030007001"?: number | null,"s030007002"?: number | null,"s030007003"?: number | null,"s030008001"?: number | null,"s030008002"?: number | null,"s030008003"?: number | null,"s030102001"?: number | null,"s030103001"?: number | null,"s030104001"?: number | null,"s030105001"?: number | null,"s030108001"?: number | null,"s030202001"?: number | null,"s030203001"?: number | null,"s030204001"?: number | null,"s030205001"?: number | null,"s030208001"?: number | null,"s030302001"?: number | null,"s030303001"?: number | null,"s030304001"?: number | null,"s030305001"?: number | null,"s030308001"?: number | null,"s030402001"?: number | null,"s030403001"?: number | null,"s030404001"?: number | null,"s030405001"?: number | null,"s030408001"?: number | null,"s030502001"?: number | null,"s030503001"?: number | null,"s030504001"?: number | null,"s030505001"?: number | null,"s030508001"?: number | null,"s030602001"?: number | null,"s030603001"?: number | null,"s030604001"?: number | null,"s030605001"?: number | null,"s030608001"?: number | null,"s030702001"?: number | null,"s030703001"?: number | null,"s030704001"?: number | null,"s030705001"?: number | null,"s030708001"?: number | null,"s050001001"?: number | null,"s050001010"?: number | null,"s050001011"?: number | null,"s050001012"?: number | null,"s050001013"?: number | null,"s050001019"?: number | null,"s050001020"?: number | null,"s050001021"?: number | null,"s050001022"?: number | null,"s050006005"?: number | null,"s050006006"?: number | null,"s050006007"?: number | null,"s050006008"?: number | null,"s050009003"?: number | null,"s050100008"?: number | null,"s050109001"?: number | null,"s051206001"?: number | null,"s051206002"?: number | null,"s070102001"?: number | null,"s070109001"?: number | null,"s070201001"?: number | null,"s070201003"?: number | null,"s070204001"?: number | null,"s070204005"?: number | null,"s070301001"?: number | null,"s070401002"?: number | null,"s070606001"?: number | null,"s070606002"?: number | null,"s080201001"?: number | null,"s080201002"?: number | null,"s090109003"?: number | null,"s100100005"?: number | null,"s100100006"?: number | null,"s100100007"?: number | null,"s100100008"?: number | null,"s100111009"?: number | null,"s100111010"?: number | null,"s100206003"?: number | null,"s100206004"?: number | null,"s100206006"?: number | null,"s100206007"?: number | null,"s100206009"?: number | null,"s100206010"?: number | null,"s200013001"?: number | null,"s200013002"?: number | null,"s200101001"?: number | null,"s200113005"?: number | null,"s200113006"?: number | null,"s200113007"?: number | null,"s200113008"?: number | null,"s200113009"?: number | null,"s200113010"?: number | null,"s200201001"?: number | null,"s200301001"?: number | null,"s200313003"?: number | null,"s200313004"?: number | null,"s200313005"?: number | null,"s200313006"?: number | null,"s200313007"?: number | null,"s200313008"?: number | null,"s200401001"?: number | null,"s200701001"?: number | null,"s200701002"?: number | null,"s210013001"?: number | null,"s210013002"?: number | null,"s210013003"?: number | null,"s210013004"?: number | null,"s210013005"?: number | null,"s210013006"?: number | null,"s210101002"?: number | null,"s210113001"?: number | null,"s210113002"?: number | null,"s210201002"?: number | null,"s210213001"?: number | null,"s210213002"?: number | null,"s210301002"?: number | null,"s210313001"?: number | null,"s210313002"?: number | null,"s210401002"?: number | null,"s210413001"?: number | null,"s210413002"?: number | null,"s210501002"?: number | null,"s210513001"?: number | null,"s210513002"?: number | null,"s210601002"?: number | null,"s210613001"?: number | null,"s210613002"?: number | null,"s220830001"?: number | null,"s220830002"?: number | null,"s220830005"?: number | null,"s220840001"?: number | null,"s220840002"?: number | null,"s220840005"?: number | null,"s220850001"?: number | null,"s220850002"?: number | null,"s220850005"?: number | null,"s220850006"?: number | null,"s220850007"?: number | null,"s220850010"?: number | null,"s240101001"?: number | null,"s240113001"?: number | null,"s240113002"?: number | null,"s240301002"?: number | null,"s260001001"?: number | null,"s260001002"?: number | null,"s260013001"?: number | null,"s260013002"?: number | null,"s260200005"?: number | null,"s260201002"?: number | null,"s260201004"?: number | null,"s260201007"?: number | null,"s260213009"?: number | null,"s260301002"?: number | null,"s260813012"?: number | null,"s261912001"?: number | null,"s270406001"?: number | null,"s270500002"?: number | null,"s270513003"?: number | null,"s280101001"?: number | null,"s280101002"?: number | null,"s280101003"?: number | null,"s280101004"?: number | null,"s280101005"?: number | null,"s280101006"?: number | null,"s280101007"?: number | null,"s280101008"?: number | null,"s280113001"?: number | null,"s280113002"?: number | null,"s280113003"?: number | null,"s280113004"?: number | null,"s280113005"?: number | null,"s280113006"?: number | null,"s280113007"?: number | null,"s280113008"?: number | null,"s280301001"?: number | null,"s280301002"?: number | null,"s280301003"?: number | null,"s280301004"?: number | null,"s280301005"?: number | null,"s280301006"?: number | null,"s280301007"?: number | null,"s280301008"?: number | null,"s280313001"?: number | null,"s280313002"?: number | null,"s280313003"?: number | null,"s280313004"?: number | null,"s280313005"?: number | null,"s280313006"?: number | null,"s280313007"?: number | null,"s280313008"?: number | null,"s280501001"?: number | null,"s280501002"?: number | null,"s280501003"?: number | null,"s280501004"?: number | null,"s280501005"?: number | null,"s280501006"?: number | null,"s280501007"?: number | null,"s280501008"?: number | null,"s280513001"?: number | null,"s280513002"?: number | null,"s280513003"?: number | null,"s280513004"?: number | null,"s280513005"?: number | null,"s280513006"?: number | null,"s280513007"?: number | null,"s280513008"?: number | null,"s280613001"?: number | null,"s280613002"?: number | null,"s300101001"?: number | null,"s301301001"?: number | null,"s302004001"?: number | null,"s310007001"?: number | null,"s310007002"?: number | null,"s310008001"?: number | null,"s310203001"?: number | null,"s310203002"?: number | null,"s310203003"?: number | null,"s310207001"?: number | null,"s310207002"?: number | null,"s310207003"?: number | null,"sampled_at": string,"t030100001"?: number | null,"t030100002"?: number | null,"t030100003"?: number | null,"t030100004"?: number | null,"t030100005"?: number | null,"t030100006"?: number | null,"t030100007"?: number | null,"t030100008"?: number | null,"t030100009"?: number | null,"t030100010"?: number | null,"t030100011"?: number | null,"t030100012"?: number | null,"t030100013"?: number | null,"t030100014"?: number | null,"t030100015"?: number | null,"t030102015"?: number | null,"t030102016"?: number | null,"t030102017"?: number | null,"t030102018"?: number | null,"t030102019"?: number | null,"t030102020"?: number | null,"t030102021"?: number | null,"tbm_code": string,"updated_at"?: string | null
                  }
                  Update: {
                    "b000000001"?: boolean | null,"b000000002"?: boolean | null,"created_at"?: string,"id"?: never,"s010101010"?: number | null,"s010101011"?: number | null,"s010101012"?: number | null,"s010101013"?: number | null,"s010102004"?: number | null,"s010103006"?: number | null,"s010109001"?: number | null,"s010111001"?: number | null,"s010114003"?: number | null,"s011306002"?: number | null,"s011311001"?: number | null,"s020901001"?: number | null,"s020901002"?: number | null,"s020901003"?: number | null,"s020901004"?: number | null,"s020901005"?: number | null,"s020901006"?: number | null,"s020901007"?: number | null,"s020901008"?: number | null,"s020901009"?: number | null,"s020901010"?: number | null,"s020901011"?: number | null,"s020901012"?: number | null,"s020901013"?: number | null,"s020901014"?: number | null,"s020902001"?: number | null,"s020902002"?: number | null,"s020906001"?: number | null,"s020906002"?: number | null,"s020906003"?: number | null,"s020906004"?: number | null,"s021711001"?: number | null,"s021711002"?: number | null,"s030006002"?: number | null,"s030006004"?: number | null,"s030007001"?: number | null,"s030007002"?: number | null,"s030007003"?: number | null,"s030008001"?: number | null,"s030008002"?: number | null,"s030008003"?: number | null,"s030102001"?: number | null,"s030103001"?: number | null,"s030104001"?: number | null,"s030105001"?: number | null,"s030108001"?: number | null,"s030202001"?: number | null,"s030203001"?: number | null,"s030204001"?: number | null,"s030205001"?: number | null,"s030208001"?: number | null,"s030302001"?: number | null,"s030303001"?: number | null,"s030304001"?: number | null,"s030305001"?: number | null,"s030308001"?: number | null,"s030402001"?: number | null,"s030403001"?: number | null,"s030404001"?: number | null,"s030405001"?: number | null,"s030408001"?: number | null,"s030502001"?: number | null,"s030503001"?: number | null,"s030504001"?: number | null,"s030505001"?: number | null,"s030508001"?: number | null,"s030602001"?: number | null,"s030603001"?: number | null,"s030604001"?: number | null,"s030605001"?: number | null,"s030608001"?: number | null,"s030702001"?: number | null,"s030703001"?: number | null,"s030704001"?: number | null,"s030705001"?: number | null,"s030708001"?: number | null,"s050001001"?: number | null,"s050001010"?: number | null,"s050001011"?: number | null,"s050001012"?: number | null,"s050001013"?: number | null,"s050001019"?: number | null,"s050001020"?: number | null,"s050001021"?: number | null,"s050001022"?: number | null,"s050006005"?: number | null,"s050006006"?: number | null,"s050006007"?: number | null,"s050006008"?: number | null,"s050009003"?: number | null,"s050100008"?: number | null,"s050109001"?: number | null,"s051206001"?: number | null,"s051206002"?: number | null,"s070102001"?: number | null,"s070109001"?: number | null,"s070201001"?: number | null,"s070201003"?: number | null,"s070204001"?: number | null,"s070204005"?: number | null,"s070301001"?: number | null,"s070401002"?: number | null,"s070606001"?: number | null,"s070606002"?: number | null,"s080201001"?: number | null,"s080201002"?: number | null,"s090109003"?: number | null,"s100100005"?: number | null,"s100100006"?: number | null,"s100100007"?: number | null,"s100100008"?: number | null,"s100111009"?: number | null,"s100111010"?: number | null,"s100206003"?: number | null,"s100206004"?: number | null,"s100206006"?: number | null,"s100206007"?: number | null,"s100206009"?: number | null,"s100206010"?: number | null,"s200013001"?: number | null,"s200013002"?: number | null,"s200101001"?: number | null,"s200113005"?: number | null,"s200113006"?: number | null,"s200113007"?: number | null,"s200113008"?: number | null,"s200113009"?: number | null,"s200113010"?: number | null,"s200201001"?: number | null,"s200301001"?: number | null,"s200313003"?: number | null,"s200313004"?: number | null,"s200313005"?: number | null,"s200313006"?: number | null,"s200313007"?: number | null,"s200313008"?: number | null,"s200401001"?: number | null,"s200701001"?: number | null,"s200701002"?: number | null,"s210013001"?: number | null,"s210013002"?: number | null,"s210013003"?: number | null,"s210013004"?: number | null,"s210013005"?: number | null,"s210013006"?: number | null,"s210101002"?: number | null,"s210113001"?: number | null,"s210113002"?: number | null,"s210201002"?: number | null,"s210213001"?: number | null,"s210213002"?: number | null,"s210301002"?: number | null,"s210313001"?: number | null,"s210313002"?: number | null,"s210401002"?: number | null,"s210413001"?: number | null,"s210413002"?: number | null,"s210501002"?: number | null,"s210513001"?: number | null,"s210513002"?: number | null,"s210601002"?: number | null,"s210613001"?: number | null,"s210613002"?: number | null,"s220830001"?: number | null,"s220830002"?: number | null,"s220830005"?: number | null,"s220840001"?: number | null,"s220840002"?: number | null,"s220840005"?: number | null,"s220850001"?: number | null,"s220850002"?: number | null,"s220850005"?: number | null,"s220850006"?: number | null,"s220850007"?: number | null,"s220850010"?: number | null,"s240101001"?: number | null,"s240113001"?: number | null,"s240113002"?: number | null,"s240301002"?: number | null,"s260001001"?: number | null,"s260001002"?: number | null,"s260013001"?: number | null,"s260013002"?: number | null,"s260200005"?: number | null,"s260201002"?: number | null,"s260201004"?: number | null,"s260201007"?: number | null,"s260213009"?: number | null,"s260301002"?: number | null,"s260813012"?: number | null,"s261912001"?: number | null,"s270406001"?: number | null,"s270500002"?: number | null,"s270513003"?: number | null,"s280101001"?: number | null,"s280101002"?: number | null,"s280101003"?: number | null,"s280101004"?: number | null,"s280101005"?: number | null,"s280101006"?: number | null,"s280101007"?: number | null,"s280101008"?: number | null,"s280113001"?: number | null,"s280113002"?: number | null,"s280113003"?: number | null,"s280113004"?: number | null,"s280113005"?: number | null,"s280113006"?: number | null,"s280113007"?: number | null,"s280113008"?: number | null,"s280301001"?: number | null,"s280301002"?: number | null,"s280301003"?: number | null,"s280301004"?: number | null,"s280301005"?: number | null,"s280301006"?: number | null,"s280301007"?: number | null,"s280301008"?: number | null,"s280313001"?: number | null,"s280313002"?: number | null,"s280313003"?: number | null,"s280313004"?: number | null,"s280313005"?: number | null,"s280313006"?: number | null,"s280313007"?: number | null,"s280313008"?: number | null,"s280501001"?: number | null,"s280501002"?: number | null,"s280501003"?: number | null,"s280501004"?: number | null,"s280501005"?: number | null,"s280501006"?: number | null,"s280501007"?: number | null,"s280501008"?: number | null,"s280513001"?: number | null,"s280513002"?: number | null,"s280513003"?: number | null,"s280513004"?: number | null,"s280513005"?: number | null,"s280513006"?: number | null,"s280513007"?: number | null,"s280513008"?: number | null,"s280613001"?: number | null,"s280613002"?: number | null,"s300101001"?: number | null,"s301301001"?: number | null,"s302004001"?: number | null,"s310007001"?: number | null,"s310007002"?: number | null,"s310008001"?: number | null,"s310203001"?: number | null,"s310203002"?: number | null,"s310203003"?: number | null,"s310207001"?: number | null,"s310207002"?: number | null,"s310207003"?: number | null,"sampled_at"?: string,"t030100001"?: number | null,"t030100002"?: number | null,"t030100003"?: number | null,"t030100004"?: number | null,"t030100005"?: number | null,"t030100006"?: number | null,"t030100007"?: number | null,"t030100008"?: number | null,"t030100009"?: number | null,"t030100010"?: number | null,"t030100011"?: number | null,"t030100012"?: number | null,"t030100013"?: number | null,"t030100014"?: number | null,"t030100015"?: number | null,"t030102015"?: number | null,"t030102016"?: number | null,"t030102017"?: number | null,"t030102018"?: number | null,"t030102019"?: number | null,"t030102020"?: number | null,"t030102021"?: number | null,"tbm_code"?: string,"updated_at"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "shield_crec1137_tbm_code_fkey"
      columns: ["tbm_code"]
isOneToOne: false
      referencedRelation: "tbms"
      referencedColumns: ["code"]
    }
                  ]
                },"shield_lx21": {
                  Row: {
                    "b000000001": boolean | null,"b000000002": boolean | null,"created_at": string,"id": number,"s010101010": number | null,"s010101011": number | null,"s010102004": number | null,"s010103006": number | null,"s010109001": number | null,"s020901001": number | null,"s020901002": number | null,"s020901003": number | null,"s020901004": number | null,"s020901005": number | null,"s020901008": number | null,"s020901010": number | null,"s020901012": number | null,"s020901013": number | null,"s020902002": number | null,"s020906001": number | null,"s020906002": number | null,"s020906003": number | null,"s020906004": number | null,"s040211001": number | null,"s050001001": number | null,"s050001019": number | null,"s050001020": number | null,"s050001021": number | null,"s050001022": number | null,"s050006005": number | null,"s050006006": number | null,"s050006007": number | null,"s050006008": number | null,"s050009003": number | null,"s050100008": number | null,"s050109001": number | null,"s070102001": number | null,"s070109001": number | null,"s070201001": number | null,"s070201003": number | null,"s070204001": number | null,"s070301001": number | null,"s070401002": number | null,"s070606001": number | null,"s070606002": number | null,"s080201002": number | null,"s090109003": number | null,"s100100005": number | null,"s100100006": number | null,"s100100007": number | null,"s100100008": number | null,"s100111009": number | null,"s100111010": number | null,"s100206003": number | null,"s100206004": number | null,"s100206006": number | null,"s100206007": number | null,"s200013001": number | null,"s200201001": number | null,"s200301001": number | null,"s200401001": number | null,"s200701002": number | null,"s210013001": number | null,"s210013002": number | null,"s210013003": number | null,"s210013004": number | null,"s210013005": number | null,"s210013006": number | null,"s240113001": number | null,"s240113002": number | null,"s280013001": number | null,"s280013002": number | null,"s300101001": number | null,"s301301001": number | null,"s302004001": number | null,"sampled_at": string,"tbm_code": string,"updated_at": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "b000000001"?: boolean | null,"b000000002"?: boolean | null,"created_at"?: string,"id"?: never,"s010101010"?: number | null,"s010101011"?: number | null,"s010102004"?: number | null,"s010103006"?: number | null,"s010109001"?: number | null,"s020901001"?: number | null,"s020901002"?: number | null,"s020901003"?: number | null,"s020901004"?: number | null,"s020901005"?: number | null,"s020901008"?: number | null,"s020901010"?: number | null,"s020901012"?: number | null,"s020901013"?: number | null,"s020902002"?: number | null,"s020906001"?: number | null,"s020906002"?: number | null,"s020906003"?: number | null,"s020906004"?: number | null,"s040211001"?: number | null,"s050001001"?: number | null,"s050001019"?: number | null,"s050001020"?: number | null,"s050001021"?: number | null,"s050001022"?: number | null,"s050006005"?: number | null,"s050006006"?: number | null,"s050006007"?: number | null,"s050006008"?: number | null,"s050009003"?: number | null,"s050100008"?: number | null,"s050109001"?: number | null,"s070102001"?: number | null,"s070109001"?: number | null,"s070201001"?: number | null,"s070201003"?: number | null,"s070204001"?: number | null,"s070301001"?: number | null,"s070401002"?: number | null,"s070606001"?: number | null,"s070606002"?: number | null,"s080201002"?: number | null,"s090109003"?: number | null,"s100100005"?: number | null,"s100100006"?: number | null,"s100100007"?: number | null,"s100100008"?: number | null,"s100111009"?: number | null,"s100111010"?: number | null,"s100206003"?: number | null,"s100206004"?: number | null,"s100206006"?: number | null,"s100206007"?: number | null,"s200013001"?: number | null,"s200201001"?: number | null,"s200301001"?: number | null,"s200401001"?: number | null,"s200701002"?: number | null,"s210013001"?: number | null,"s210013002"?: number | null,"s210013003"?: number | null,"s210013004"?: number | null,"s210013005"?: number | null,"s210013006"?: number | null,"s240113001"?: number | null,"s240113002"?: number | null,"s280013001"?: number | null,"s280013002"?: number | null,"s300101001"?: number | null,"s301301001"?: number | null,"s302004001"?: number | null,"sampled_at": string,"tbm_code": string,"updated_at"?: string | null
                  }
                  Update: {
                    "b000000001"?: boolean | null,"b000000002"?: boolean | null,"created_at"?: string,"id"?: never,"s010101010"?: number | null,"s010101011"?: number | null,"s010102004"?: number | null,"s010103006"?: number | null,"s010109001"?: number | null,"s020901001"?: number | null,"s020901002"?: number | null,"s020901003"?: number | null,"s020901004"?: number | null,"s020901005"?: number | null,"s020901008"?: number | null,"s020901010"?: number | null,"s020901012"?: number | null,"s020901013"?: number | null,"s020902002"?: number | null,"s020906001"?: number | null,"s020906002"?: number | null,"s020906003"?: number | null,"s020906004"?: number | null,"s040211001"?: number | null,"s050001001"?: number | null,"s050001019"?: number | null,"s050001020"?: number | null,"s050001021"?: number | null,"s050001022"?: number | null,"s050006005"?: number | null,"s050006006"?: number | null,"s050006007"?: number | null,"s050006008"?: number | null,"s050009003"?: number | null,"s050100008"?: number | null,"s050109001"?: number | null,"s070102001"?: number | null,"s070109001"?: number | null,"s070201001"?: number | null,"s070201003"?: number | null,"s070204001"?: number | null,"s070301001"?: number | null,"s070401002"?: number | null,"s070606001"?: number | null,"s070606002"?: number | null,"s080201002"?: number | null,"s090109003"?: number | null,"s100100005"?: number | null,"s100100006"?: number | null,"s100100007"?: number | null,"s100100008"?: number | null,"s100111009"?: number | null,"s100111010"?: number | null,"s100206003"?: number | null,"s100206004"?: number | null,"s100206006"?: number | null,"s100206007"?: number | null,"s200013001"?: number | null,"s200201001"?: number | null,"s200301001"?: number | null,"s200401001"?: number | null,"s200701002"?: number | null,"s210013001"?: number | null,"s210013002"?: number | null,"s210013003"?: number | null,"s210013004"?: number | null,"s210013005"?: number | null,"s210013006"?: number | null,"s240113001"?: number | null,"s240113002"?: number | null,"s280013001"?: number | null,"s280013002"?: number | null,"s300101001"?: number | null,"s301301001"?: number | null,"s302004001"?: number | null,"sampled_at"?: string,"tbm_code"?: string,"updated_at"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "shield_lx21_tbm_code_fkey"
      columns: ["tbm_code"]
isOneToOne: false
      referencedRelation: "tbms"
      referencedColumns: ["code"]
    }
                  ]
                },"subsystems": {
                  Row: {
                    "code": string,"created_at": string,"created_by": string | null,"description": string | null,"is_disabled": boolean,"name": string,"sort_order": number,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "code": string,"created_at"?: string,"created_by"?: string | null,"description"?: string | null,"is_disabled"?: boolean,"name": string,"sort_order"?: number,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "code"?: string,"created_at"?: string,"created_by"?: string | null,"description"?: string | null,"is_disabled"?: boolean,"name"?: string,"sort_order"?: number,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    
                  ]
                },"tbm_parameter_threshold_rules": {
                  Row: {
                    "created_at": string,"created_by": string | null,"end_ring": number,"id": number,"is_disabled": boolean,"min_record_delta": number,"min_record_interval_ms": number,"reference_value": number | null,"remark": string | null,"severity_code": string,"start_ring": number,"tbm_parameter_id": number,"threshold_type": string,"threshold_value": number,"tunnel_id": string | null,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"created_by"?: string | null,"end_ring": number,"id"?: never,"is_disabled"?: boolean,"min_record_delta"?: number,"min_record_interval_ms"?: number,"reference_value"?: number | null,"remark"?: string | null,"severity_code": string,"start_ring": number,"tbm_parameter_id": number,"threshold_type": string,"threshold_value": number,"tunnel_id"?: string | null,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "created_at"?: string,"created_by"?: string | null,"end_ring"?: number,"id"?: never,"is_disabled"?: boolean,"min_record_delta"?: number,"min_record_interval_ms"?: number,"reference_value"?: number | null,"remark"?: string | null,"severity_code"?: string,"start_ring"?: number,"tbm_parameter_id"?: number,"threshold_type"?: string,"threshold_value"?: number,"tunnel_id"?: string | null,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "tbm_parameter_threshold_rules_tbm_parameter_id_fkey"
      columns: ["tbm_parameter_id"]
isOneToOne: false
      referencedRelation: "tbm_parameters"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "tbm_parameter_threshold_rules_tunnel_id_fkey"
      columns: ["tunnel_id"]
isOneToOne: false
      referencedRelation: "v_assignable_tunnels"
      referencedColumns: ["id"]
    }
                  ]
                },"tbm_parameters": {
                  Row: {
                    "created_at": string,"created_by": string | null,"custom_name": string | null,"custom_unit": string | null,"id": number,"is_disabled": boolean,"parameter_code": string,"remark": string | null,"tbm_code": string,"updated_at": string | null,"updated_by": string | null,"value_max": number | null,"value_min": number | null
                  }
                  ComputedFields: never
                  Insert: {
                    "created_at"?: string,"created_by"?: string | null,"custom_name"?: string | null,"custom_unit"?: string | null,"id"?: never,"is_disabled"?: boolean,"parameter_code": string,"remark"?: string | null,"tbm_code": string,"updated_at"?: string | null,"updated_by"?: string | null,"value_max"?: number | null,"value_min"?: number | null
                  }
                  Update: {
                    "created_at"?: string,"created_by"?: string | null,"custom_name"?: string | null,"custom_unit"?: string | null,"id"?: never,"is_disabled"?: boolean,"parameter_code"?: string,"remark"?: string | null,"tbm_code"?: string,"updated_at"?: string | null,"updated_by"?: string | null,"value_max"?: number | null,"value_min"?: number | null
                  }
                  Relationships: [
                    {
      foreignKeyName: "tbm_parameters_parameter_code_fkey"
      columns: ["parameter_code"]
isOneToOne: false
      referencedRelation: "parameters"
      referencedColumns: ["code"]
    },{
      foreignKeyName: "tbm_parameters_tbm_code_fkey"
      columns: ["tbm_code"]
isOneToOne: false
      referencedRelation: "tbms"
      referencedColumns: ["code"]
    }
                  ]
                },"tbms": {
                  Row: {
                    "code": string,"created_at": string,"created_by": string | null,"device_id": string | null,"diameter": number | null,"is_disabled": boolean,"name": string,"sort_order": number,"tbm_type_code": string,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Insert: {
                    "code": string,"created_at"?: string,"created_by"?: string | null,"device_id"?: string | null,"diameter"?: number | null,"is_disabled"?: boolean,"name": string,"sort_order"?: number,"tbm_type_code": string,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Update: {
                    "code"?: string,"created_at"?: string,"created_by"?: string | null,"device_id"?: string | null,"diameter"?: number | null,"is_disabled"?: boolean,"name"?: string,"sort_order"?: number,"tbm_type_code"?: string,"updated_at"?: string | null,"updated_by"?: string | null
                  }
                  Relationships: [
                    
                  ]
                }
          }
          Views: {
            "v_assignable_tunnels": {
                  Row: {
                    "engineering_unit_id": string,"engineering_unit_name": string | null,"id": string,"name": string,"project_id": string,"project_name": string
                  }
                  ComputedFields: never
                  Relationships: [
                    
                  ]
                },"v_current_assignments": {
                  Row: {
                    "advance_direction": string,"end_chainage": number,"end_ring": number,"engineering_unit_id": string,"engineering_unit_name": string,"id": string,"organization_id": string | null,"organization_name": string | null,"project_id": string,"project_name": string,"start_chainage": number,"start_ring": number,"tbm_code": string,"tbm_name": string,"tunnel_id": string,"tunnel_name": string
                  }
                  ComputedFields: never
                  Relationships: [
                    {
      foreignKeyName: "assignments_tbm_code_fkey"
      columns: ["tbm_code"]
isOneToOne: false
      referencedRelation: "tbms"
      referencedColumns: ["code"]
    },{
      foreignKeyName: "assignments_tunnel_id_fkey"
      columns: ["tunnel_id"]
isOneToOne: false
      referencedRelation: "v_assignable_tunnels"
      referencedColumns: ["id"]
    }
                  ]
                },"v_parameter_threshold_list": {
                  Row: {
                    "created_at": string,"created_by": string | null,"data_type": string,"digits": number | null,"end_ring": number,"id": number,"is_disabled": boolean,"min_record_delta": number,"min_record_interval_ms": number,"parameter_code": string,"parameter_name": string | null,"parameter_unit": string | null,"reference_value": number | null,"remark": string | null,"severity_code": string,"severity_name": string | null,"start_ring": number,"subsystem_code": string,"tbm_code": string,"tbm_parameter_id": number,"threshold_type": string,"threshold_value": number,"tunnel_id": string | null,"updated_at": string | null,"updated_by": string | null,"value_max": number | null,"value_min": number | null
                  }
                  ComputedFields: never
                  Relationships: [
                    {
      foreignKeyName: "parameters_subsystem_code_fkey"
      columns: ["subsystem_code"]
isOneToOne: false
      referencedRelation: "subsystems"
      referencedColumns: ["code"]
    },{
      foreignKeyName: "tbm_parameter_threshold_rules_tbm_parameter_id_fkey"
      columns: ["tbm_parameter_id"]
isOneToOne: false
      referencedRelation: "tbm_parameters"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "tbm_parameter_threshold_rules_tunnel_id_fkey"
      columns: ["tunnel_id"]
isOneToOne: false
      referencedRelation: "v_assignable_tunnels"
      referencedColumns: ["id"]
    },{
      foreignKeyName: "tbm_parameters_parameter_code_fkey"
      columns: ["parameter_code"]
isOneToOne: false
      referencedRelation: "parameters"
      referencedColumns: ["code"]
    },{
      foreignKeyName: "tbm_parameters_tbm_code_fkey"
      columns: ["tbm_code"]
isOneToOne: false
      referencedRelation: "tbms"
      referencedColumns: ["code"]
    }
                  ]
                },"v_parameter_threshold_rules": {
                  Row: {
                    "data_type": string | null,"digits": number | null,"end_ring": number | null,"min_record_delta": number | null,"min_record_interval_seconds": number | null,"parameter_code": string | null,"parameter_name": string | null,"parameter_unit": string | null,"reference_value": number | null,"severity_code": string | null,"severity_name": string | null,"start_ring": number | null,"subsystem_code": string | null,"tbm_code": string | null,"threshold_type": string | null,"threshold_value": number | null,"value_max": number | null,"value_min": number | null
                  }
                  ComputedFields: never
                  Relationships: [
                    
                  ]
                },"v_tbm_assignments_list": {
                  Row: {
                    "advance_direction": string,"created_at": string,"created_by": string | null,"end_chainage": number | null,"end_date": string | null,"end_ring": number | null,"id": string,"project_name": string | null,"remark": string | null,"section_name": string | null,"start_chainage": number | null,"start_date": string,"start_ring": number | null,"tbm_code": string,"tbm_name": string | null,"tunnel_id": string,"tunnel_name": string | null,"updated_at": string | null,"updated_by": string | null
                  }
                  ComputedFields: never
                  Relationships: [
                    {
      foreignKeyName: "assignments_tbm_code_fkey"
      columns: ["tbm_code"]
isOneToOne: false
      referencedRelation: "tbms"
      referencedColumns: ["code"]
    },{
      foreignKeyName: "assignments_tunnel_id_fkey"
      columns: ["tunnel_id"]
isOneToOne: false
      referencedRelation: "v_assignable_tunnels"
      referencedColumns: ["id"]
    }
                  ]
                }
          }
          Functions: {
            "apply_parameter_alarm":
{ Args: { "p_alarm_value": number,"p_chainage": number,"p_occurred_at": string,"p_parameter_code": string,"p_ring_no": number,"p_rule_snapshot": Json,"p_severity_code": string,"p_tbm_code": string,"p_tunnel_id": string }; Returns: number
                           },
"apply_ring_phase":
{ Args: { "p_chainage": number,"p_phase_type": string,"p_ring_no": number,"p_started_at": string,"p_tbm_code": string,"p_tunnel_id": string }; Returns: Json
                           },
"get_organization_context":
{ Args: { "p_tbm_code": string }; Returns: {
              "engineering_unit_id": string,"organization_id": string,"project_id": string,"tbm_code": string,"tunnel_id": string
            }[]
                           },
"get_parameter_alarms":
{ Args: { "p_end_time": string,"p_start_time": string,"p_tbm_codes": (string)[] }; Returns: {
              "alarm_value": number,"chainage": number,"digits": number,"id": number,"min_record_delta": number,"min_record_interval_ms": number,"occurred_at": string,"parameter_code": string,"parameter_name": string,"parameter_unit": string,"project_name": string,"reference_value": number,"ring_no": number,"severity_code": string,"severity_name": string,"tbm_code": string,"tbm_name": string,"threshold_type": string,"threshold_value": number,"tunnel_name": string
            }[]
                           },
"get_ring_phase_details":
{ Args: { "p_end_time": string,"p_start_time": string,"p_tbm_codes": (string)[] }; Returns: {
              "cutter_change_seconds": number,"excavation_seconds": number,"fault_seconds": number,"maintenance_seconds": number,"project_name": string,"ring_no": number,"segment_erection_seconds": number,"stopped_seconds": number,"tbm_code": string,"tbm_name": string,"total_seconds": number,"tunnel_name": string,"unknown_seconds": number,"waiting_seconds": number
            }[]
                           },
"get_ring_progress":
{ Args: { "p_end_time": string,"p_start_time": string,"p_tbm_codes": (string)[] }; Returns: {
              "first_ring": number,"last_ring": number,"observed_ring_count": number,"project_name": string,"ring_numbers": (number)[],"ring_span": number,"tbm_code": string,"tbm_name": string,"tunnel_name": string
            }[]
                           },
"sync_realdata_table":
{ Args: { "p_tbm_code": string }; Returns: string
                           }
          }
          Enums: {
            [_ in never]: never
          }
          CompositeTypes: {
            [_ in never]: never
          }
        }
}

type DatabaseWithoutInternals = Omit<Database, '__InternalSupabase'>

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never
> = DefaultSchemaTableNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
  ? (DefaultSchema["Tables"] & DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
      Row: infer R
    }
    ? R
    : never
  : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never
> = DefaultSchemaTableNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
  ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
      Insert: infer I
    }
    ? I
    : never
  : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never
> = DefaultSchemaTableNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
  ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
      Update: infer U
    }
    ? U
    : never
  : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never
> = DefaultSchemaEnumNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
  ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
  : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never
> = PublicCompositeTypeNameOrOptions extends { schema: keyof DatabaseWithoutInternals }
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
  ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
  : never

export const Constants = {
  "api": {
          Enums: {
            
          }
        },"equip": {
          Enums: {
            
          }
        },"hrm": {
          Enums: {
            
          }
        },"iam": {
          Enums: {
            "permission_action": ["read", "write", "delete"],"permission_module": ["iam", "master_data", "hrm", "proj", "equip", "tbm", "mqtt"]
          }
        },"master_data": {
          Enums: {
            
          }
        },"mqtt": {
          Enums: {
            
          }
        },"proj": {
          Enums: {
            
          }
        },"public": {
          Enums: {
            
          }
        },"system": {
          Enums: {
            
          }
        },"tbm": {
          Enums: {
            
          }
        }
} as const
