
-- =====================================================
-- GLOBAL SCHEMAS
-- =====================================================

create schema if not exists api;

create schema if not exists iam;

create schema if not exists system;

create schema if not exists master_data;

create schema if not exists hrm;

create schema if not exists proj;

create schema if not exists equip;

create schema if not exists tbm;

create schema if not exists mqtt;

create schema if not exists telemetry;


-- =====================================================
-- GLOBAL EXTENSIONS
-- =====================================================

create schema if not exists extensions;

create extension if not exists btree_gist
with schema extensions;

create extension if not exists pgcrypto;

















