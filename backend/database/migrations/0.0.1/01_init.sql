CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

create table version (
  version varchar unique not null,
  executed bool not null default false,
  "current" bool not null default false
);

create table user (
  id uuid primary key default uuid_generate_v4() not null,
  
  -- credentials
  email varchar unique,
  password varchar,
  
  -- telegram data
  tg_id varchar,
  private_chat_id varchar
);

create table "group" (
  id uuid primary key default uuid_generate_v4() not null,
  name varchar not null
);