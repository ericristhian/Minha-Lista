-- =====================================================
-- Aula 10 • Minha Lista • Passos 2 e 3
-- Cole tudo no Dashboard: SQL Editor -> New query -> Run
-- =====================================================

-- PASSO 2: tabela items
create table public.items (
  id uuid primary key default gen_random_uuid(),
  name text not null
    check (length(trim(name)) > 0),
  user_id uuid not null
    references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

-- PASSO 3a: habilitar RLS
alter table public.items
  enable row level security;

-- PASSO 3b: privilégios mínimos (GRANT / REVOKE)
revoke all on table public.items
  from anon, authenticated;

grant usage on schema public
  to authenticated;

grant select, insert, update, delete
  on table public.items
  to authenticated;

-- PASSO 3c: quatro políticas (uma por operação)
create policy "items_select_own"
on public.items
for select to authenticated
using ((select auth.uid()) = user_id);

create policy "items_insert_own"
on public.items
for insert to authenticated
with check ((select auth.uid()) = user_id);

create policy "items_update_own"
on public.items
for update to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "items_delete_own"
on public.items
for delete to authenticated
using ((select auth.uid()) = user_id);
