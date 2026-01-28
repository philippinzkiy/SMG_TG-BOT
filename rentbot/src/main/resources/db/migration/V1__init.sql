create table if not exists public.app_ping (
  id bigserial primary key,
  created_at timestamp not null default now()
);
