# Expected counts

Data rows per file (header excluded).

## Rows delivered in each folder

| Table | 00 | 01 | 02 | 03 | Bronze total after 03 |
|---|---:|---:|---:|---:|---:|
| `stores` | 7 | – | – | – | 7 |
| `products` | 60 | 62 | 60 | – | 182 |
| `customers` | 201 | – | – | – | 201 |
| `customers_cdc` | – | 21 | 15 | – | 36 |
| `orders` | 818 | 153 | 164 | 165 | 1300 |
| `order_items` | 1335 | 242 | 217 | 18 | 1812 |
| `returns` | 50 | 8 | 7 | – | 65 |

## Bronze rows after each release (append-only, cumulative)

| Table | after 00 | after 01 | after 02 | after 03 |
|---|---:|---:|---:|---:|
| `stores` | 7 | 7 | 7 | 7 |
| `products` | 60 | 122 | 182 | 182 |
| `customers` | 201 | 201 | 201 | 201 |
| `customers_cdc` | 0 | 21 | 36 | 36 |
| `orders` | 818 | 971 | 1135 | 1300 |
| `order_items` | 1335 | 1577 | 1794 | 1812 |
| `returns` | 50 | 58 | 65 | 65 |

## Clean silver after each release (valid, de-duplicated rows only)

Bad rows in 03 are not counted: they belong in the rejected-rows table. Customers include the 2 test accounts (silver keeps them; gold filters them out).

| After | Orders | Order lines | Current customers | Products in latest extract |
|---|---:|---:|---:|---:|
| 00_initial_full_load | 812 | 1335 | 200 | 60 |
| 01_incremental | 952 | 1577 | 206 | 62 |
| 02_incremental | 1082 | 1794 | 209 | 60 |
| 03_late_and_bad | 1090 | 1809 | 209 | 60 |

## What each folder plants

### 00_initial_full_load
- customers: 5 emails upper-case with leading spaces, 2 blank emails, 2 tiers in lower case, 1 exact duplicate row, 2 internal test accounts (`@test.maison.internal`), country written as UK / GB / United Kingdom, USA / US / United States, UAE / United Arab Emirates
- orders: 6 exact duplicate rows, 3 statuses in upper case, order O00253 belongs to C0201, a customer that only arrives in 01 (orphan); 8 late-October orders are missing (they arrive in 03)
- returns: R0001 refunds 1.5x the item amount; R0002 is dated before its order
- stores: S01 country `UK`, S07 country `United Kingdom`

### 01_incremental
- customers_cdc: 6 inserts (incl. late customer C0201), 8 tier upgrades and 4 city moves (SCD2), 3 email corrections (SCD1)
- products: full extract; 2 new (P061, P062), 6 price changes: P009, P033, P038, P039, P045, P057
- orders: 140 new + 13 status updates of earlier orders; 2 rows have the status typo `SHIPPD`
- order_items: 6 lines of this week's orders are missing (they arrive in 02)

### 02_incremental
- customers_cdc: 5 inserts, 6 tier upgrades, customer C0171 changes twice in this one file, 2 deletes (GDPR erasure: C0050, C0056); rows are not in lsn order, so apply them by lsn
- products: full extract; P006 discontinued (is_active=false); P013, P019 no longer in the file (hard deletes)
- orders: 130 new + 34 status updates (4 cancelled); new column `gift_wrap` (schema change)
- order_items: includes the 6 late lines for 01 orders

### 03_late_and_bad
- orders: 8 orders dated 25-29 Oct arrive two weeks late: O00085, O00087, O00318, O00393, O00394, O00440, O00449, O00591
- orders: bad rows: unknown customer C9999, unknown status `on_hold`, order date in 2027, unknown store S99
- orders: `orders__03_late_and_bad_resent.csv` is an exact copy of the 01 orders file (supplier re-sent it)
- order_items: lines of the late orders, plus bad rows: negative quantity, unknown product P999, item for an order that doesn't exist (O99999)
