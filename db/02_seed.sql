-- FitSense Seed Data
-- 15 products, 7 brand size guides, test user profiles

-- ─── BRAND SIZE GUIDES ───────────────────────────────────────────────────────

INSERT INTO brand_size_guides (brand, category, size_chart, fit_note) VALUES
(
  'Snitch', 'top',
  '{"S": {"chest_cm": 96}, "M": {"chest_cm": 101}, "L": {"chest_cm": 106}, "XL": {"chest_cm": 111}, "XXL": {"chest_cm": 116}}',
  'Snitch runs slim. If between sizes or you prefer a relaxed fit, size up.'
),
(
  'Snitch', 'bottom',
  '{"28": {"waist_cm": 71}, "30": {"waist_cm": 76}, "32": {"waist_cm": 81}, "34": {"waist_cm": 86}, "36": {"waist_cm": 91}}',
  'True to size on bottoms.'
),
(
  'Libas', 'top',
  '{"XS": {"chest_cm": 84}, "S": {"chest_cm": 89}, "M": {"chest_cm": 94}, "L": {"chest_cm": 99}, "XL": {"chest_cm": 104}, "XXL": {"chest_cm": 109}}',
  'Libas cuts true to size. Stay at your usual size.'
),
(
  'Libas', 'bottom',
  '{"XS": {"waist_cm": 66}, "S": {"waist_cm": 71}, "M": {"waist_cm": 76}, "L": {"waist_cm": 81}, "XL": {"waist_cm": 86}}',
  'True to size.'
),
(
  'Bewakoof', 'top',
  '{"S": {"chest_cm": 98}, "M": {"chest_cm": 103}, "L": {"chest_cm": 108}, "XL": {"chest_cm": 113}, "XXL": {"chest_cm": 118}}',
  'Bewakoof runs slightly large. Consider sizing down if you prefer a fitted look.'
),
(
  'Manyavar', 'top',
  '{"S": {"chest_cm": 96}, "M": {"chest_cm": 101}, "L": {"chest_cm": 106}, "XL": {"chest_cm": 111}, "XXL": {"chest_cm": 116}, "3XL": {"chest_cm": 121}}',
  'True to size. Traditional fit with ease built in.'
),
(
  'H&M', 'top',
  '{"XS": {"chest_cm": 82}, "S": {"chest_cm": 88}, "M": {"chest_cm": 94}, "L": {"chest_cm": 100}, "XL": {"chest_cm": 106}, "XXL": {"chest_cm": 112}}',
  'H&M runs slim for Indian body types. Size up one if your chest is on the fuller side.'
)
ON CONFLICT (brand, category) DO NOTHING;


-- ─── PRODUCT CATALOG ─────────────────────────────────────────────────────────

INSERT INTO product_catalog (url, name, brand, price, fabric, colours, category, description) VALUES

-- Snitch
('https://www.snitch.co.in/products/sand-linen-coord-set',
 'Sand Linen Co-ord Set', 'Snitch', 1299,
 '60% Linen 40% Cotton', ARRAY['sand', 'olive'],
 'coord',
 'Breathable linen co-ord, relaxed summer fit. Half-sleeve shirt + drawstring shorts.'),

('https://www.snitch.co.in/products/navy-oversized-tee',
 'Navy Oversized Drop Shoulder Tee', 'Snitch', 699,
 '100% Cotton', ARRAY['navy', 'black', 'white'],
 'top',
 'Drop-shoulder oversized tee, boxy fit. Ideal for streetwear layering.'),

('https://www.snitch.co.in/products/olive-cargo-jogger',
 'Olive Cargo Jogger', 'Snitch', 999,
 '98% Cotton 2% Spandex', ARRAY['olive', 'beige', 'black'],
 'bottom',
 'Relaxed cargo jogger with side pockets. Drawstring waist.'),

-- Libas
('https://www.libas.in/products/blue-floral-kurta-set',
 'Blue Floral Printed Kurta Set', 'Libas', 1499,
 '100% Viscose', ARRAY['blue', 'white'],
 'ethnic',
 'Floral printed A-line kurta with matching palazzo. Festive occasion wear.'),

('https://www.libas.in/products/cream-embroidered-kurti',
 'Cream Embroidered Straight Kurti', 'Libas', 899,
 '100% Cotton', ARRAY['cream', 'off-white'],
 'ethnic',
 'Subtle thread embroidery on cotton. Easy casual ethnic wear.'),

('https://www.libas.in/products/teal-silk-anarkali',
 'Teal Silk Blend Anarkali', 'Libas', 2199,
 '60% Silk 40% Polyester', ARRAY['teal', 'gold'],
 'ethnic',
 'Flared anarkali with contrast dupatta. Wedding guest ready.'),

-- Bewakoof
('https://www.bewakoof.com/p/mens-graphic-oversized-tee',
 'Graphic Oversized Tee', 'Bewakoof', 499,
 '100% Cotton', ARRAY['white', 'black', 'yellow'],
 'top',
 'Pop-culture graphic print, boxy oversized silhouette. Daily casual.'),

('https://www.bewakoof.com/p/mens-slim-fit-jeans-black',
 'Black Slim Fit Jeans', 'Bewakoof', 899,
 '98% Cotton 2% Elastane', ARRAY['black'],
 'bottom',
 'Slim fit denim, mid-rise. Versatile everyday pair.'),

-- Manyavar
('https://www.manyavar.com/products/royal-blue-sherwani',
 'Royal Blue Embroidered Sherwani', 'Manyavar', 8999,
 'Silk Blend', ARRAY['royal blue', 'gold'],
 'ethnic',
 'Heavy embroidered sherwani with churidar and dupatta. Wedding/sangeet wear.'),

('https://www.manyavar.com/products/beige-kurta-pajama',
 'Beige Printed Kurta Pajama Set', 'Manyavar', 2499,
 'Cotton Silk', ARRAY['beige', 'cream'],
 'ethnic',
 'Subtle block print kurta with matching pajama. Puja/casual occasion.'),

-- H&M
('https://www2.hm.com/en_in/productpage.regular-fit-linen-shirt',
 'Regular Fit Linen Shirt', 'H&M', 1799,
 '100% Linen', ARRAY['white', 'light blue', 'sage green'],
 'top',
 'Clean-cut linen shirt. European regular fit — runs slim for Indian builds.'),

('https://www2.hm.com/en_in/productpage.slim-fit-chinos',
 'Slim Fit Chinos', 'H&M', 1999,
 '98% Cotton 2% Elastane', ARRAY['khaki', 'navy', 'olive'],
 'bottom',
 'Classic slim fit chinos. Smart casual versatility.'),

('https://www2.hm.com/en_in/productpage.oversized-hoodie',
 'Oversized Hoodie', 'H&M', 2499,
 '70% Cotton 30% Polyester', ARRAY['grey marl', 'black', 'cream'],
 'top',
 'Dropped shoulders, kangaroo pocket. Premium weight cotton blend.'),

-- Mixed
('https://www.snitch.co.in/products/white-resort-shirt',
 'White Printed Resort Shirt', 'Snitch', 849,
 '55% Linen 45% Viscose', ARRAY['white', 'ecru'],
 'top',
 'Relaxed resort-style printed shirt. Half-sleeve, Cuban collar.'),

('https://www.libas.in/products/rust-bandhani-co-ord',
 'Rust Bandhani Co-ord Set', 'Libas', 1799,
 '100% Cotton', ARRAY['rust', 'orange'],
 'ethnic',
 'Bandhani print co-ord — kurta + straight pant. Festive casual.')

ON CONFLICT (url) DO NOTHING;


-- ─── TEST USER PROFILES ───────────────────────────────────────────────────────

-- Test Priya (default test user)
INSERT INTO users (
  telegram_id, username, top_size, bottom_size, fit_feel,
  chest_min_cm, chest_max_cm, skin_tone,
  style_preferences, budget_band, onboarding_done
) VALUES (
  999000001, 'test_priya', 'M', '30', 'relaxed',
  92, 98, 'warm_medium',
  ARRAY['casual_western', 'ethnic'], '500_1500', TRUE
) ON CONFLICT (telegram_id) DO NOTHING;

-- Test Rahul
INSERT INTO users (
  telegram_id, username, top_size, bottom_size, fit_feel,
  chest_min_cm, chest_max_cm, skin_tone,
  style_preferences, budget_band, onboarding_done
) VALUES (
  999000002, 'test_rahul', 'L', '32', 'true-to-size',
  103, 108, 'cool_medium',
  ARRAY['casual_western'], '1000_3000', TRUE
) ON CONFLICT (telegram_id) DO NOTHING;
