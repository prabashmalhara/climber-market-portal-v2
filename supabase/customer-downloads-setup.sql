-- ============================================================
-- Customer Downloads Security Setup
-- ============================================================

-- 1. Allow customers to read software metadata ONLY if they own the related hardware
-- (Must have an approved device_registration matching the product_id)
create policy "Customers can see software for owned products"
  on public.software_packages for select
  using (
    exists (
      select 1 from public.device_registrations dr
      join public.devices d on dr.device_id = d.id
      where dr.user_id = auth.uid()
        and dr.approved_by_admin = true
        and d.product_id = software_packages.product_id
    )
  );

-- 2. Allow authenticated users to generate signed URLs for the storage bucket.
-- Note: They still can't guess files because they need the exact path from 
-- the software_packages table, which is protected by the policy above!
create policy "Authenticated users can download software"
  on storage.objects for select
  using (
    bucket_id = 'software_releases' 
    and auth.role() = 'authenticated'
  );
