-- ============================================================
-- Run this in Supabase SQL Editor to prepare for device registration
-- ============================================================

-- 1. Add the column you requested to device_registrations
alter table public.device_registrations 
add column approved_by_admin boolean not null default false;

-- 2. Allow logged-in users to read from the devices table 
-- (They need this to verify if a serial number exists)
create policy "Anyone can view devices"
  on public.devices for select
  using (true);

-- 3. Allow logged-in users to insert their own registrations
create policy "Users can register devices"
  on public.device_registrations for insert
  with check (auth.uid() = user_id);

-- 4. Allow users to read their own registrations
create policy "Users can read own registrations"
  on public.device_registrations for select
  using (auth.uid() = user_id);

-- 5. Create a dummy device so you have a valid serial number to test with.
-- This assigns a device to the "Climber Node" product.
insert into public.devices (product_id, serial_number, status)
select id, 'TEST-SN-9999', 'available'
from public.products
where name = 'Climber Node'
limit 1;
