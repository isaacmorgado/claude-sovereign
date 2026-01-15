# Beta Tester Account Setup Plan

## Objective
Delete all existing users and create 3 beta tester accounts with full access on Railway production.

## Beta Tester Accounts

| Name | License Key | Customer ID | Email |
|------|-------------|-------------|-------|
| Josh Irizarry | `SPLICE-GW6N-88DP-5DDD` | `beta_josh_irizarry` | `josh@splice-beta.test` |
| Danny Isakov | `SPLICE-Y2Q9-6G9G-MFQE` | `beta_danny_isakov` | `danny@splice-beta.test` |
| Jimmy Nick | `SPLICE-UC2G-R5H8-UKHF` | `beta_jimmy_nick` | `jimmy@splice-beta.test` |

All accounts get:
- **Tier**: Team (highest tier, all features)
- **Processing Hours**: 999,999 (unlimited)
- **Music Credits**: 999,999 (unlimited)
- **Pre-activated license keys**

---

## Implementation Steps

### Step 1: Create Seed Script
Create `splice-backend/scripts/seed-beta-testers.js`:

```javascript
// 1. Connect to PostgreSQL using DATABASE_URL
// 2. DELETE FROM license_keys
// 3. DELETE FROM users
// 4. INSERT 3 beta users into users table
// 5. INSERT 3 license keys into license_keys table (pre-activated)
```

### Step 2: Run on Railway
Execute the script against Railway's PostgreSQL:
```bash
railway run node scripts/seed-beta-testers.js
```

---

## Files to Create/Modify

| File | Action |
|------|--------|
| `splice-backend/scripts/seed-beta-testers.js` | **CREATE** - Seed script |

---

## Database Operations

```sql
-- Clear existing data
DELETE FROM license_keys;
DELETE FROM users;

-- Insert beta users (Team tier, unlimited credits)
INSERT INTO users (stripe_customer_id, email, tier, hours_remaining, hours_total,
                   music_credits_remaining, music_credits_total, email_verified)
VALUES
  ('beta_josh_irizarry', 'josh@splice-beta.test', 'team', 999999, 999999, 999999, 999999, true),
  ('beta_danny_isakov', 'danny@splice-beta.test', 'team', 999999, 999999, 999999, 999999, true),
  ('beta_jimmy_nick', 'jimmy@splice-beta.test', 'team', 999999, 999999, 999999, 999999, true);

-- Insert pre-activated license keys
INSERT INTO license_keys (key, stripe_customer_id, activated_at, is_active)
VALUES
  ('SPLICE-GW6N-88DP-5DDD', 'beta_josh_irizarry', NOW(), true),
  ('SPLICE-Y2Q9-6G9G-MFQE', 'beta_danny_isakov', NOW(), true),
  ('SPLICE-UC2G-R5H8-UKHF', 'beta_jimmy_nick', NOW(), true);
```

---

## Verification
After running:
1. Query Railway DB to confirm 3 users exist
2. Query Railway DB to confirm 3 license keys exist
3. Test login with one license key on the website
