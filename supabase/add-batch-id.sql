-- Add batch_id to the devices table as requested for inventory tracking
alter table public.devices add column batch_id text;
