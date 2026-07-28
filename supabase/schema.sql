-- ============================================================
-- Summit Gear Portal — Database Schema
-- Run this ONCE in Supabase SQL Editor (supabase.com → your project → SQL Editor)
-- ============================================================

-- 1. USERS (extends Supabase Auth)
-- Supabase Auth already creates auth.users with id, email, password etc.
-- This table stores EXTRA profile info and links to auth.users via id.
-- ============================================================
create table public.users (
  id uuid references auth.users(id) on delete cascade primary key,
  email text not null,
  full_name text not null default '',
  phone text default '',
  role text not null default 'customer' check (role in ('customer', 'admin')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 2. PRODUCTS
-- The items you sell: Climber Node, Basecamp Node, Repeater Node,
-- Climber App, Flutter Dashboard, etc.
-- ============================================================
create table public.products (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  description text default '',
  category text not null check (category in ('hardware', 'software')),
  price decimal(10,2) not null default 0.00,
  stock_count integer not null default 0,
  image_url text default '',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 3. ORDERS
-- A customer places an order. Admin manually approves it (no payment gateway).
-- Status flow: pending → approved → shipped → delivered  (or → cancelled)
-- ============================================================
create table public.orders (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.users(id) on delete cascade not null,
  status text not null default 'pending'
    check (status in ('pending', 'approved', 'shipped', 'delivered', 'cancelled')),
  total_amount decimal(10,2) not null default 0.00,
  shipping_address text default '',
  notes text default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 4. ORDER_ITEMS
-- Each order can have multiple products (e.g., 2 Climber Nodes + 1 App).
-- This is a "junction table" — it connects orders to products.
-- ============================================================
create table public.order_items (
  id uuid default gen_random_uuid() primary key,
  order_id uuid references public.orders(id) on delete cascade not null,
  product_id uuid references public.products(id) on delete cascade not null,
  quantity integer not null default 1 check (quantity > 0),
  unit_price decimal(10,2) not null default 0.00,
  created_at timestamptz not null default now()
);

-- 5. DEVICES
-- Individual physical units with serial numbers.
-- Admin adds these to stock. Each device belongs to a product type.
-- status: available → sold → registered
-- ============================================================
create table public.devices (
  id uuid default gen_random_uuid() primary key,
  product_id uuid references public.products(id) on delete cascade not null,
  serial_number text not null unique,
  status text not null default 'available'
    check (status in ('available', 'sold', 'registered')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- 6. DEVICE_REGISTRATIONS
-- When a customer receives a device, they register its serial number.
-- This links the device to their account and unlocks software downloads.
-- ============================================================
create table public.device_registrations (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.users(id) on delete cascade not null,
  device_id uuid references public.devices(id) on delete cascade not null unique,
  registered_at timestamptz not null default now()
);

-- 7. SOFTWARE_PACKAGES
-- Firmware and software files uploaded by admin.
-- Tied to a product (e.g., "Climber App v2.1" belongs to the Climber App product).
-- Customers can download these after registering the matching device.
-- ============================================================
create table public.software_packages (
  id uuid default gen_random_uuid() primary key,
  product_id uuid references public.products(id) on delete cascade not null,
  name text not null,
  version text not null default '1.0.0',
  description text default '',
  file_url text not null default '',
  file_size_bytes bigint default 0,
  is_active boolean not null default true,
  uploaded_at timestamptz not null default now()
);

-- 8. ADMIN_LOGS
-- Audit trail: every admin action is logged here (approved order, added stock, etc.)
-- ============================================================
create table public.admin_logs (
  id uuid default gen_random_uuid() primary key,
  admin_id uuid references public.users(id) on delete set null,
  action text not null,
  target_type text not null default '',
  target_id uuid,
  details jsonb default '{}',
  created_at timestamptz not null default now()
);

-- ============================================================
-- INDEXES — speed up common queries
-- ============================================================
create index idx_orders_user_id on public.orders(user_id);
create index idx_orders_status on public.orders(status);
create index idx_order_items_order_id on public.order_items(order_id);
create index idx_devices_serial on public.devices(serial_number);
create index idx_devices_product_id on public.devices(product_id);
create index idx_device_reg_user_id on public.device_registrations(user_id);
create index idx_software_product_id on public.software_packages(product_id);
create index idx_admin_logs_admin_id on public.admin_logs(admin_id);

-- ============================================================
-- ROW LEVEL SECURITY (RLS) — we'll add policies in a later step.
-- For now, just enable RLS on every table so Supabase enforces it.
-- Without policies, no one can read/write (safe default).
-- ============================================================
alter table public.users enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;
alter table public.devices enable row level security;
alter table public.device_registrations enable row level security;
alter table public.software_packages enable row level security;
alter table public.admin_logs enable row level security;
