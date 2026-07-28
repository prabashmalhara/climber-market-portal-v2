-- ============================================================
-- Sample products for testing. Run in Supabase SQL Editor.
-- ============================================================

insert into public.products (name, description, category, price, stock_count, image_url, is_active)
values
  (
    'Climber Node',
    'Compact LoRa-enabled wearable device for mountain climbers. Features GPS tracking, SOS alerts, and real-time location broadcasting to basecamp. Waterproof IP67 rated with 72-hour battery life.',
    'hardware',
    149.99,
    25,
    '',
    true
  ),
  (
    'BLE-Watch',
    'Rugged biometric wrist hub that connects to the Climber Node via Bluetooth. Tracks health metrics, displays alerts, and allows quick interaction without reaching for the primary node.',
    'hardware',
    129.99,
    40,
    '',
    true
  ),
  (
    'Basecamp Node',
    'High-power LoRa gateway designed for basecamp deployment. Receives signals from all Climber Nodes within range, aggregates location data, and provides a local mesh network hub. Solar panel compatible.',
    'hardware',
    299.99,
    10,
    '',
    true
  ),
  (
    'Repeater Node',
    'Signal relay station for extending LoRa coverage across mountain terrain. Place on ridgelines or high points to bridge communication gaps between climbers and basecamp. Weatherproof enclosure included.',
    'hardware',
    199.99,
    15,
    '',
    true
  ),
  (
    'Climber App',
    'Mobile companion app for Climber Node users. View your real-time position, send SOS alerts, check battery status, and communicate with basecamp. Available for iOS and Android.',
    'software',
    29.99,
    999,
    '',
    true
  ),
  (
    'Dashboard Software',
    'Full-featured Flutter-based monitoring dashboard for basecamp operators. Visualize all climber positions on a topographic map, manage alerts, review historical routes, and export expedition data.',
    'software',
    79.99,
    999,
    '',
    true
  );
