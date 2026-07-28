-- ============================================================
-- Run this in Supabase SQL Editor to allow users to create orders
-- ============================================================

-- Orders: Users can insert their own orders and read their own orders
create policy "Users can insert own orders"
  on public.orders for insert
  with check (auth.uid() = user_id);

create policy "Users can read own orders"
  on public.orders for select
  using (auth.uid() = user_id);

-- Order Items: Users can insert and read items for their own orders
create policy "Users can insert own order items"
  on public.order_items for insert
  with check (
    exists (
      select 1 from public.orders 
      where id = order_items.order_id and user_id = auth.uid()
    )
  );

create policy "Users can read own order items"
  on public.order_items for select
  using (
    exists (
      select 1 from public.orders 
      where id = order_items.order_id and user_id = auth.uid()
    )
  );
