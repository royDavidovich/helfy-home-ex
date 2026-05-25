-- =============================================================================
-- Helfy Electronics — MySQL 8.0 Schema + Seed Data
-- =============================================================================
-- This file runs automatically on first `docker-compose up` via
-- /docker-entrypoint-initdb.d/. To re-run: npm run db:reset
--
-- NOTE ON IMAGE URLS:
--   All image_url values use Unsplash's CDN format:
--   https://images.unsplash.com/photo-<id>?w=600&h=600&fit=crop&auto=format
--   If any URL returns 404, replace with:
--   https://picsum.photos/seed/<sku>/600/600
-- =============================================================================

SET NAMES utf8mb4;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;

-- =============================================================================
-- SCHEMA
-- =============================================================================

CREATE DATABASE IF NOT EXISTS `helfy_home`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `helfy_home`;

-- -----------------------------------------------------------------------------
-- users
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `users` (
  `id`            BIGINT UNSIGNED   NOT NULL AUTO_INCREMENT,
  `email`         VARCHAR(255)      NOT NULL,
  `password_hash` VARCHAR(255)      NOT NULL,
  `first_name`    VARCHAR(100)      NOT NULL,
  `last_name`     VARCHAR(100)      NOT NULL,
  `role`          ENUM('customer','admin') NOT NULL DEFAULT 'customer',
  `created_at`    TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_users_email` (`email`),
  KEY `idx_users_role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- refresh_tokens
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `refresh_tokens` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`     BIGINT UNSIGNED NOT NULL,
  `token_hash`  CHAR(64)        NOT NULL COMMENT 'SHA-256 of refresh JWT jti',
  `expires_at`  TIMESTAMP       NOT NULL,
  `revoked_at`  TIMESTAMP       NULL DEFAULT NULL,
  `created_at`  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_refresh_token_hash` (`token_hash`),
  KEY `idx_refresh_tokens_user_id` (`user_id`),
  KEY `idx_refresh_tokens_expires_at` (`expires_at`),
  CONSTRAINT `fk_refresh_tokens_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- categories
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `categories` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`        VARCHAR(100)    NOT NULL,
  `slug`        VARCHAR(120)    NOT NULL,
  `parent_id`   BIGINT UNSIGNED NULL DEFAULT NULL COMMENT 'Reserved for v2 nested categories',
  `sort_order`  INT             NOT NULL DEFAULT 0,
  `created_at`  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_categories_slug` (`slug`),
  KEY `idx_categories_parent_id` (`parent_id`),
  CONSTRAINT `fk_categories_parent`
    FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- products
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `products` (
  `id`          BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `category_id` BIGINT UNSIGNED  NOT NULL,
  `sku`         VARCHAR(64)      NOT NULL,
  `name`        VARCHAR(255)     NOT NULL,
  `slug`        VARCHAR(280)     NOT NULL,
  `description` TEXT             NULL,
  `price`       DECIMAL(10,2)    NOT NULL,
  `stock`       INT              NOT NULL DEFAULT 0,
  `image_url`   VARCHAR(500)     NULL,
  `is_active`   TINYINT(1)       NOT NULL DEFAULT 1,
  `created_at`  TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_products_sku` (`sku`),
  UNIQUE KEY `uq_products_slug` (`slug`),
  KEY `idx_products_category_id` (`category_id`),
  KEY `idx_products_is_active` (`is_active`),
  FULLTEXT KEY `ft_products_search` (`name`, `description`),
  CONSTRAINT `fk_products_category`
    FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- carts
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `carts` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`     BIGINT UNSIGNED NOT NULL,
  `created_at`  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_carts_user_id` (`user_id`),
  CONSTRAINT `fk_carts_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- cart_items
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `cart_items` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `cart_id`     BIGINT UNSIGNED NOT NULL,
  `product_id`  BIGINT UNSIGNED NOT NULL,
  `quantity`    INT             NOT NULL,
  `created_at`  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_cart_items_cart_product` (`cart_id`, `product_id`),
  KEY `idx_cart_items_product_id` (`product_id`),
  CONSTRAINT `fk_cart_items_cart`
    FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_cart_items_product`
    FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `chk_cart_items_quantity` CHECK (`quantity` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- orders
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `orders` (
  `id`                      BIGINT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`                 BIGINT UNSIGNED  NOT NULL,
  `order_number`            CHAR(12)         NOT NULL,
  `status`                  ENUM('pending','paid','shipped','delivered','cancelled') NOT NULL DEFAULT 'pending',
  `subtotal`                DECIMAL(10,2)    NOT NULL,
  `shipping_total`          DECIMAL(10,2)    NOT NULL DEFAULT 0.00,
  `tax_total`               DECIMAL(10,2)    NOT NULL DEFAULT 0.00,
  `grand_total`             DECIMAL(10,2)    NOT NULL,
  `currency`                CHAR(3)          NOT NULL DEFAULT 'USD',
  `shipping_full_name`      VARCHAR(200)     NOT NULL,
  `shipping_address_line1`  VARCHAR(255)     NOT NULL,
  `shipping_address_line2`  VARCHAR(255)     NULL DEFAULT NULL,
  `shipping_city`           VARCHAR(100)     NOT NULL,
  `shipping_postal_code`    VARCHAR(20)      NOT NULL,
  `shipping_country`        CHAR(2)          NOT NULL COMMENT 'ISO-3166 alpha-2',
  `shipping_phone`          VARCHAR(30)      NULL DEFAULT NULL,
  `placed_at`               TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`              TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_orders_order_number` (`order_number`),
  KEY `idx_orders_user_placed` (`user_id`, `placed_at`),
  KEY `idx_orders_status` (`status`),
  CONSTRAINT `fk_orders_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- order_items
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `order_items` (
  `id`            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id`      BIGINT UNSIGNED NOT NULL,
  `product_id`    BIGINT UNSIGNED NOT NULL,
  `product_name`  VARCHAR(255)    NOT NULL COMMENT 'Snapshot at purchase time',
  `product_sku`   VARCHAR(64)     NOT NULL COMMENT 'Snapshot at purchase time',
  `unit_price`    DECIMAL(10,2)   NOT NULL COMMENT 'Snapshot at purchase time',
  `quantity`      INT             NOT NULL,
  `line_total`    DECIMAL(10,2)   NOT NULL COMMENT 'unit_price * quantity',
  `created_at`    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_order_items_order_id` (`order_id`),
  KEY `idx_order_items_product_id` (`product_id`),
  CONSTRAINT `fk_order_items_order`
    FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_order_items_product`
    FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_order_items_quantity` CHECK (`quantity` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- SEED DATA
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Categories (5)
-- -----------------------------------------------------------------------------
INSERT INTO `categories` (`id`, `name`, `slug`, `parent_id`, `sort_order`) VALUES
(1, 'Smartphones',  'smartphones',  NULL, 1),
(2, 'Laptops',      'laptops',      NULL, 2),
(3, 'Audio',        'audio',        NULL, 3),
(4, 'Wearables',    'wearables',    NULL, 4),
(5, 'Smart Home',   'smart-home',   NULL, 5);

-- -----------------------------------------------------------------------------
-- Products (24)
-- Prices: $19 – $2,499
-- Images: Unsplash CDN (w=600&h=600&fit=crop&auto=format)
-- -----------------------------------------------------------------------------

-- ── Smartphones (5) ──────────────────────────────────────────────────────────
INSERT INTO `products`
  (`id`, `category_id`, `sku`, `name`, `slug`, `description`, `price`, `stock`, `image_url`, `is_active`)
VALUES
(1, 1, 'SP-001', 'Helfy ProMax 15',
 'helfy-promax-15',
 'The pinnacle of mobile engineering. A 6.7-inch Super AMOLED display with 120Hz adaptive refresh, a triple-lens 200MP camera system, and all-day battery life in a precision-machined titanium frame.',
 1299.00, 45,
 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=600&h=600&fit=crop&auto=format',
 1),

(2, 1, 'SP-002', 'Helfy Air 13',
 'helfy-air-13',
 'Impossibly thin at 6.9mm, the Air 13 packs a 6.1-inch OLED display and a 50MP dual-camera system into a featherweight 158g body. Available in Midnight Black and Arctic White.',
 799.00, 72,
 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=600&h=600&fit=crop&auto=format',
 1),

(3, 1, 'SP-003', 'Helfy Compact SE',
 'helfy-compact-se',
 'Big performance in a small package. The 5.4-inch Compact SE is perfect for one-handed use without sacrificing speed or camera quality. Ideal for those who prefer a classic form factor.',
 499.00, 88,
 'https://images.unsplash.com/photo-1580910051074-3eb694886505?w=600&h=600&fit=crop&auto=format',
 1),

(4, 1, 'SP-004', 'Helfy Fold 3',
 'helfy-fold-3',
 'Unfold a new dimension of productivity. The Fold 3 opens to a stunning 7.6-inch inner display, transforming from a compact phone into a full tablet experience in one seamless motion.',
 1899.00, 28,
 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=600&h=600&fit=crop&auto=format',
 1),

(5, 1, 'SP-005', 'Helfy Budget X1',
 'helfy-budget-x1',
 'Everything you need, nothing you don\'t. The Budget X1 delivers a sharp 6.5-inch display, reliable dual cameras, and two-day battery life at a price that doesn\'t compromise your wallet.',
 249.00, 120,
 'https://images.unsplash.com/photo-1567581935884-3349723552ca?w=600&h=600&fit=crop&auto=format',
 1),

-- ── Laptops (5) ──────────────────────────────────────────────────────────────
(6, 2, 'LT-001', 'Helfy Studio Pro 16',
 'helfy-studio-pro-16',
 'Built for creators who demand the best. The Studio Pro 16 features a 16-inch Liquid Retina XDR display, 32GB unified memory, and a 12-core processor that handles 8K video editing without breaking a sweat.',
 2499.00, 18,
 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=600&h=600&fit=crop&auto=format',
 1),

(7, 2, 'LT-002', 'Helfy UltraBook 14',
 'helfy-ultrabook-14',
 'The perfect travel companion. At just 1.2kg, the UltraBook 14 offers a brilliant 14-inch 2.8K OLED display, 16GB RAM, and up to 18 hours of battery life in a slim aluminium chassis.',
 1299.00, 34,
 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=600&h=600&fit=crop&auto=format',
 1),

(8, 2, 'LT-003', 'Helfy WorkStation 15',
 'helfy-workstation-15',
 'Engineered for power users. The WorkStation 15 packs a dedicated GPU, 32GB DDR5 RAM, and a 1TB NVMe SSD into a robust chassis designed for developers, data scientists, and engineers.',
 1799.00, 22,
 'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=600&h=600&fit=crop&auto=format',
 1),

(9, 2, 'LT-004', 'Helfy Chromebook Flex',
 'helfy-chromebook-flex',
 'Versatile, fast, and affordable. The Chromebook Flex features a 360° hinge, a bright 13.3-inch touchscreen, and all-day battery life — perfect for students and everyday computing.',
 449.00, 65,
 'https://images.unsplash.com/photo-1588872657578-7efd1f1555ed?w=600&h=600&fit=crop&auto=format',
 1),

(10, 2, 'LT-005', 'Helfy Gaming Rig 17',
 'helfy-gaming-rig-17',
 'Dominate every game. The Gaming Rig 17 sports a 17.3-inch 165Hz QHD display, RTX-class graphics, and an advanced cooling system that keeps performance at its peak during the longest sessions.',
 1999.00, 15,
 'https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=600&h=600&fit=crop&auto=format',
 1),

-- ── Audio (5) ─────────────────────────────────────────────────────────────────
(11, 3, 'AU-001', 'Helfy Noise Pro Headphones',
 'helfy-noise-pro-headphones',
 'Industry-leading active noise cancellation meets audiophile-grade sound. 40mm custom drivers, 30-hour battery, and a plush memory-foam headband make these the ultimate headphones for focus and travel.',
 349.00, 55,
 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&h=600&fit=crop&auto=format',
 1),

(12, 3, 'AU-002', 'Helfy Buds Pro',
 'helfy-buds-pro',
 'True wireless earbuds with adaptive ANC, spatial audio, and a custom-fit ear tip system. Six-hour battery life with 24 additional hours in the charging case. IPX4 water resistant.',
 199.00, 90,
 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=600&h=600&fit=crop&auto=format',
 1),

(13, 3, 'AU-003', 'Helfy SoundBar 360',
 'helfy-soundbar-360',
 'Fill any room with immersive 360° sound. The SoundBar 360 uses seven drivers and a dedicated subwoofer to deliver concert-quality audio. Pairs seamlessly via Bluetooth 5.3 or optical input.',
 499.00, 30,
 'https://images.unsplash.com/photo-1545454675-3531b543be5d?w=600&h=600&fit=crop&auto=format',
 1),

(14, 3, 'AU-004', 'Helfy Studio Monitor Speakers',
 'helfy-studio-monitor-speakers',
 'Reference-grade accuracy for music production and critical listening. Bi-amplified design with a 5-inch woofer and 1-inch tweeter per unit. Flat frequency response from 45Hz to 22kHz.',
 799.00, 20,
 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=600&h=600&fit=crop&auto=format',
 1),

(15, 3, 'AU-005', 'Helfy Pocket Speaker',
 'helfy-pocket-speaker',
 'Big sound in a tiny package. The Pocket Speaker delivers surprisingly rich audio from a palm-sized body. 12-hour battery, IP67 waterproof rating, and a built-in carabiner for adventures.',
 79.00, 110,
 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=600&h=600&fit=crop&auto=format',
 1),

-- ── Wearables (5) ─────────────────────────────────────────────────────────────
(16, 4, 'WR-001', 'Helfy Watch Ultra',
 'helfy-watch-ultra',
 'The most capable smartwatch ever made. Titanium case, sapphire crystal display, precision dual-frequency GPS, and an 18-day battery life. Built for athletes, explorers, and everyday achievers.',
 799.00, 40,
 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&h=600&fit=crop&auto=format',
 1),

(17, 4, 'WR-002', 'Helfy Watch Series 9',
 'helfy-watch-series-9',
 'Your health, always on your wrist. Continuous heart rate, blood oxygen, ECG, and sleep tracking in a sleek aluminium case with an always-on Retina display. Swimproof to 50 metres.',
 399.00, 68,
 'https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=600&h=600&fit=crop&auto=format',
 1),

(18, 4, 'WR-003', 'Helfy Fit Band Pro',
 'helfy-fit-band-pro',
 'Lightweight fitness tracking without compromise. The Fit Band Pro monitors steps, calories, sleep stages, and stress levels. Seven-day battery and a slim profile that disappears on your wrist.',
 99.00, 95,
 'https://images.unsplash.com/photo-1575311373937-040b8e1fd5b6?w=600&h=600&fit=crop&auto=format',
 1),

(19, 4, 'WR-004', 'Helfy AR Glasses',
 'helfy-ar-glasses',
 'The future of computing, on your face. Helfy AR Glasses overlay crisp digital information onto the real world with a 45° field of view. Lightweight titanium frame, 4-hour active use battery.',
 1299.00, 12,
 'https://images.unsplash.com/photo-1622979135225-d2ba269cf1ac?w=600&h=600&fit=crop&auto=format',
 1),

(20, 4, 'WR-005', 'Helfy Kids Watch',
 'helfy-kids-watch',
 'Safe, fun, and connected. The Helfy Kids Watch features GPS location sharing, two-way calling, and a durable shockproof case. Parents stay in control via the companion app.',
 149.00, 75,
 'https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=600&h=600&fit=crop&auto=format',
 1),

-- ── Smart Home (4) ────────────────────────────────────────────────────────────
(21, 5, 'SH-001', 'Helfy Hub Pro',
 'helfy-hub-pro',
 'The brain of your smart home. The Hub Pro connects and controls up to 200 devices across Zigbee, Z-Wave, Wi-Fi, and Bluetooth protocols. Local processing means no cloud dependency.',
 199.00, 50,
 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&h=600&fit=crop&auto=format',
 1),

(22, 5, 'SH-002', 'Helfy Cam 4K Outdoor',
 'helfy-cam-4k-outdoor',
 'Keep watch day and night. The Cam 4K Outdoor delivers crystal-clear 4K HDR video, colour night vision, and AI-powered person/vehicle detection. Weatherproof IP67, wired or solar-powered.',
 249.00, 60,
 'https://images.unsplash.com/photo-1557597774-9d273605dfa9?w=600&h=600&fit=crop&auto=format',
 1),

(23, 5, 'SH-003', 'Helfy Smart Bulb Pack (4x)',
 'helfy-smart-bulb-pack-4x',
 'Transform your lighting with 16 million colours and tunable white light from 2700K to 6500K. Voice and app controlled, no hub required. Each bulb is rated for 25,000 hours.',
 59.00, 130,
 'https://images.unsplash.com/photo-1565814329452-e1efa11c5b89?w=600&h=600&fit=crop&auto=format',
 1),

(24, 5, 'SH-004', 'Helfy Thermostat Pro',
 'helfy-thermostat-pro',
 'Intelligent climate control that learns your schedule and saves energy automatically. The Thermostat Pro features a premium stainless steel ring, a crisp colour display, and integrates with all major smart home platforms.',
 249.00, 42,
 'https://images.unsplash.com/photo-1567473030492-533b30c5494c?w=600&h=600&fit=crop&auto=format',
 1);

SET foreign_key_checks = 1;