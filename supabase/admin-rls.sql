-- ============================================================
-- Run this in Supabase SQL Editor to give admins access to all data
-- ============================================================

-- 1. Create a helper function to check if the current user is an admin.
-- 'security definer' means it bypasses RLS so we don't get infinite recursion
-- when checking the users table against itself.
create or replace function public.is_admin()
returns boolean as $$
  select exists(
    select 1 from public.users where id = auth.uid() and role = 'admin'
  );
$$ language sql security definer;


-- 2. Add policies that allow admins to do EVERYTHING (select, insert, update, delete)
-- on all the important tables.

-- USERS
create policy "Admins can manage all users" 
  on public.users for all 
  using (public.is_admin());

-- ORDERS
create policy "Admins can manage all orders" 
  on public.orders for all 
  using (public.is_admin());

-- ORDER ITEMS
create policy "Admins can manage all order items" 
  on public.order_items for all 
  using (public.is_admin());

-- DEVICES
create policy "Admins can manage all devices" 
  on public.devices for all 
  using (public.is_admin());

-- DEVICE REGISTRATIONS
create policy "Admins can manage all registrations" 
  on public.device_registrations for all 
  using (public.is_admin());

-- SOFTWARE PACKAGES
create policy "Admins can manage all software packages" 
  on public.software_packages for all 
  using (public.is_admin());

-- ADMIN LOGS
create policy "Admins can manage all admin logs" 
  on public.admin_logs for all 
  using (public.is_admin());

