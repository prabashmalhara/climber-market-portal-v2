-- ============================================================
-- Run this in Supabase SQL Editor AFTER the schema.sql
-- ============================================================

-- 1. TRIGGER FUNCTION: Auto-create a public.users row when someone signs up
-- When Supabase Auth creates a new user in auth.users, this trigger
-- automatically inserts a matching row in public.users with role='customer'.
-- ============================================================
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.users (id, email, full_name, role)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    'customer'
  );
  return new;
end;
$$ language plpgsql security definer;

-- Attach the trigger to auth.users
-- "after insert" means: run this function after a new auth user is created
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 2. RLS POLICIES FOR USERS TABLE
-- Customers can read their own profile
-- Customers can update their own profile
-- ============================================================
create policy "Users can read own profile"
  on public.users for select
  using (auth.uid() = id);

create policy "Users can update own profile"
  on public.users for update
  using (auth.uid() = id)
  with check (auth.uid() = id);
