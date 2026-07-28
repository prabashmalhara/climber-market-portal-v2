-- ============================================================
-- Setup Supabase Storage for Software/Firmware Uploads
-- ============================================================

-- 1. Create a private bucket named 'software_releases'
-- (We use insert ... on conflict do nothing so it doesn't crash if run twice)
insert into storage.buckets (id, name, public)
values ('software_releases', 'software_releases', false)
on conflict (id) do nothing;

-- 2. Allow Admins to upload files to this bucket
create policy "Admins can upload software"
  on storage.objects for insert
  with check (
    bucket_id = 'software_releases' and 
    public.is_admin()
  );

-- 3. Allow Admins to read all files in this bucket
create policy "Admins can view software"
  on storage.objects for select
  using (
    bucket_id = 'software_releases' and 
    public.is_admin()
  );

-- Note: We will add policies for customers to download their allowed files in the next step!
