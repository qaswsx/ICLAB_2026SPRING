# #!/usr/bin/env python3
# import random
# import os

# DAYS_IN_MONTH = {
#     1: 31, 2: 28, 3: 31,  4: 30,  5: 31,  6: 30,
#     7: 31, 8: 31, 9: 30, 10: 31, 11: 30, 12: 31,
# }

# random.seed(0x4242)

# NUM_SHOPS = 128
# DRAM_BASE = 0x10000

# OUT_LOCAL  = "dram.dat"
# OUT_TARGET = "../00_TESTBED/DRAM/dram.dat"

# shops = []

# for shop in range(NUM_SHOPS):
#     flour   = random.randint(1500, 4000)
#     butter  = random.randint(1500, 4000)
#     milk    = random.randint(1500, 4000)
#     sugar   = random.randint(1500, 4000)
#     fruit   = random.randint(1500, 4000)

#     month   = random.randint(1, 12)
#     day     = random.randint(1, DAYS_IN_MONTH[month])

#     sales   = random.randint(0, 50)
#     staff   = random.randint(5, 60)
#     balance = random.randint(0x400000, 0xF00000)
#     level   = random.randint(0, 60)

#     bucket = shop % 10

#     if shop < 16:
#         # No_Staff_Warn coverage
#         staff   = 0
#         balance = random.randint(0x800000, 0xF00000)
#         flour   = random.randint(2500, 4095)
#         butter  = random.randint(2500, 4095)
#         milk    = random.randint(2500, 4095)
#         sugar   = random.randint(2500, 4095)
#         fruit   = random.randint(2500, 4095)
#         month   = 1
#         day     = 1
#         level   = random.randint(0, 30)
#         sales   = random.randint(0, 20)

#     elif bucket == 1:
#         # Balance_Warn coverage
#         staff   = random.randint(10, 60)
#         balance = random.randint(0, 0xFFFF)
#         month   = 1
#         day     = 1

#     elif bucket == 2:
#         # Restock_Warn coverage
#         flour   = random.randint(3900, 4095)
#         butter  = random.randint(3900, 4095)
#         milk    = random.randint(3900, 4095)
#         sugar   = random.randint(3900, 4095)
#         fruit   = random.randint(3900, 4095)
#         balance = random.randint(0x800000, 0xF00000)
#         staff   = random.randint(10, 60)
#         month   = 1
#         day     = 1

#     elif bucket == 3:
#         # Staff_Warn coverage
#         staff   = random.randint(95, 100)
#         balance = random.randint(0x800000, 0xF00000)
#         month   = 1
#         day     = 1

#     elif bucket == 4:
#         # Stock_Warn coverage
#         flour   = random.randint(0, 80)
#         butter  = random.randint(0, 80)
#         milk    = random.randint(0, 80)
#         sugar   = random.randint(0, 80)
#         fruit   = random.randint(0, 80)
#         staff   = random.randint(10, 60)
#         balance = random.randint(0x800000, 0xF00000)
#         month   = 1
#         day     = 1

#     elif bucket == 5:
#         # High level + low balance
#         level   = random.randint(80, 100)
#         balance = random.randint(0, 0x40000)
#         staff   = random.randint(10, 60)
#         month   = 1
#         day     = 1

#     shops.append({
#         "flour": flour,
#         "butter": butter,
#         "milk": milk,
#         "sugar": sugar,
#         "fruit": fruit,
#         "month": month,
#         "day": day,
#         "sales": sales,
#         "staff": staff,
#         "balance": balance,
#         "level": level,
#     })


# def check_legal_shop(shop_id, s):
#     assert 0 <= s["flour"]   <= 4095, "flour range error at shop {}".format(shop_id)
#     assert 0 <= s["butter"]  <= 4095, "butter range error at shop {}".format(shop_id)
#     assert 0 <= s["milk"]    <= 4095, "milk range error at shop {}".format(shop_id)
#     assert 0 <= s["sugar"]   <= 4095, "sugar range error at shop {}".format(shop_id)
#     assert 0 <= s["fruit"]   <= 4095, "fruit range error at shop {}".format(shop_id)

#     assert 1 <= s["month"] <= 12, "month range error at shop {}".format(shop_id)
#     assert 1 <= s["day"] <= DAYS_IN_MONTH[s["month"]], "day range error at shop {}".format(shop_id)

#     assert 0 <= s["sales"]   <= 4095, "sales range error at shop {}".format(shop_id)
#     assert 0 <= s["staff"]   <= 100, "staff range error at shop {}".format(shop_id)
#     assert 0 <= s["balance"] <= 16777215, "balance range error at shop {}".format(shop_id)
#     assert 0 <= s["level"]   <= 100, "level range error at shop {}".format(shop_id)


# def write_dram(path):
#     directory = os.path.dirname(path)
#     if directory:
#         os.makedirs(directory, exist_ok=True)

#     with open(path, "w") as f:
#         for shop, s in enumerate(shops):
#             check_legal_shop(shop, s)

#             w0 = (
#                 (s["flour"]  << 52) |
#                 (s["butter"] << 40) |
#                 (s["month"]  << 32) |
#                 (s["milk"]   << 20) |
#                 (s["sugar"]  <<  8) |
#                 (s["day"]    <<  0)
#             )

#             w1 = (
#                 (s["fruit"]   << 52) |
#                 (s["sales"]   << 40) |
#                 (s["staff"]   << 32) |
#                 (s["balance"] <<  8) |
#                 (s["level"]   <<  0)
#             )

#             addr = DRAM_BASE + shop * 16

#             # 16 bytes per shop, little-endian:
#             # word0 bytes first, then word1 bytes
#             data_bytes = []

#             for b in range(8):
#                 data_bytes.append((w0 >> (b * 8)) & 0xFF)

#             for b in range(8):
#                 data_bytes.append((w1 >> (b * 8)) & 0xFF)

#             # Print 4 bytes per address line:
#             # @10000
#             # xx xx xx xx
#             # @10004
#             # xx xx xx xx
#             for off in range(0, 16, 4):
#                 f.write("@{:05X}\n".format(addr + off))
#                 f.write("{:02X} {:02X} {:02X} {:02X}\n".format(
#                     data_bytes[off],
#                     data_bytes[off + 1],
#                     data_bytes[off + 2],
#                     data_bytes[off + 3]
#                 ))


# write_dram(OUT_LOCAL)
# write_dram(OUT_TARGET)

# no_staff_shops = [i for i, s in enumerate(shops) if s["staff"] == 0]

# print("Generated {}".format(OUT_LOCAL))
# print("Generated {}".format(OUT_TARGET))
# print("Total shops: {}".format(NUM_SHOPS))
# print("No-staff shops: {}".format(no_staff_shops))
# print("Bucket distribution:")
# print("  shop < 16 : staff = 0")
# print("  bucket 1  : low balance")
# print("  bucket 2  : stock near cap")
# print("  bucket 3  : staff near 100")
# print("  bucket 4  : stock very low")
# print("  bucket 5  : high level + low balance")
# print("  others    : normal random")
# print("Done.")























#!/usr/bin/env python3
"""
gen_dram_ta_style.py

Generate dram.dat in a style that mimics what TA's reference dram.dat
likely looks like:
  - All shops have legal, naturally-distributed values
  - month/day is real-random for every shop (no 1/1 lock-in)
  - A controlled subset of shops carries "trigger fodder" for each
    warning type, but the fodder is sprinkled randomly across shop IDs
    (not packed into the first 16 shops) so the dat does not look
    structured
  - Sales is conservatively clamped against level upgrade threshold
"""

import os
import random

DAYS_IN_MONTH = {
    1: 31, 2: 28, 3: 31,  4: 30,  5: 31,  6: 30,
    7: 31, 8: 31, 9: 30, 10: 31, 11: 30, 12: 31,
}

random.seed(0xC0FFEE)

NUM_SHOPS = 128
DRAM_BASE = 0x10000

OUT_LOCAL  = "dram.dat"
OUT_TARGET = "../00_TESTBED/DRAM/dram.dat"


# ---------- helpers ----------
def rand_date():
    m = random.randint(1, 12)
    d = random.randint(1, DAYS_IN_MONTH[m])
    return m, d


def clamp_sales(sales, level):
    """Conservative: ensure sales < upgrade threshold."""
    if level >= 100:
        return min(sales, 4095)
    threshold = max(10, 10 * (level // 10))
    if sales >= threshold:
        return random.randint(0, threshold - 1)
    return sales


def normal_shop():
    """A naturally-distributed normal shop."""
    m, d = rand_date()
    return {
        "flour":   random.randint(200, 3800),
        "butter":  random.randint(200, 3800),
        "milk":    random.randint(200, 3800),
        "sugar":   random.randint(200, 3800),
        "fruit":   random.randint(200, 3800),
        "month":   m,
        "day":     d,
        "sales":   random.randint(0, 300),
        "staff":   random.randint(5, 80),
        "balance": random.randint(0x100000, 0xE00000),
        "level":   random.randint(0, 70),
    }


def make_no_staff(s):
    s["staff"]   = 0
    # keep other things "ok" so the shop is otherwise functional
    s["balance"] = random.randint(0x400000, 0xF00000)
    return s


def make_low_balance(s):
    s["balance"] = random.randint(0, 0x800)
    s["staff"]   = random.randint(10, 60)
    return s


def make_high_stock(s):
    s["flour"]  = random.randint(3950, 4095)
    s["butter"] = random.randint(3950, 4095)
    s["milk"]   = random.randint(3950, 4095)
    s["sugar"]  = random.randint(3950, 4095)
    s["fruit"]  = random.randint(3950, 4095)
    s["staff"]  = random.randint(10, 60)
    s["balance"] = random.randint(0x800000, 0xF00000)
    return s


def make_high_staff(s):
    s["staff"]   = random.randint(96, 100)
    s["balance"] = random.randint(0x800000, 0xF00000)
    return s


def make_low_stock(s):
    s["flour"]  = random.randint(0, 30)
    s["butter"] = random.randint(0, 30)
    s["milk"]   = random.randint(0, 30)
    s["sugar"]  = random.randint(0, 30)
    s["fruit"]  = random.randint(0, 30)
    s["staff"]  = random.randint(10, 60)
    s["balance"] = random.randint(0x800000, 0xF00000)
    return s


def make_high_level(s):
    s["level"]   = random.randint(95, 100)
    s["staff"]   = random.randint(10, 60)
    s["balance"] = random.randint(0x400000, 0xF00000)
    return s


def make_late_date(s):
    """Late date so pattern sending earlier date triggers Date_Warn."""
    s["month"] = random.randint(10, 12)
    s["day"]   = random.randint(20, DAYS_IN_MONTH[s["month"]])
    s["staff"] = random.randint(10, 60)
    return s


# ---------- build 128 shops ----------
# Step 1: every shop starts as a fully random normal shop
shops = [normal_shop() for _ in range(NUM_SHOPS)]

# Step 2: pick disjoint random subsets to overlay each "fodder" category
all_ids = list(range(NUM_SHOPS))
random.shuffle(all_ids)

# Allocate fodder shops from the shuffled list (disjoint)
def take(n, pool):
    out = pool[:n]
    del pool[:n]
    return out

no_staff_ids    = take(12, all_ids)  # No_Staff_Warn
low_balance_ids = take(12, all_ids)  # Balance_Warn
high_stock_ids  = take(10, all_ids)  # Restock_Warn
high_staff_ids  = take(10, all_ids)  # Staff_Warn
low_stock_ids   = take(10, all_ids)  # Stock_Warn
high_level_ids  = take(8,  all_ids)  # level=100 edge cases
late_date_ids   = take(10, all_ids)  # Date_Warn fodder
# Remaining ~56 stay as natural normal shops

for i in no_staff_ids:    make_no_staff(shops[i])
for i in low_balance_ids: make_low_balance(shops[i])
for i in high_stock_ids:  make_high_stock(shops[i])
for i in high_staff_ids:  make_high_staff(shops[i])
for i in low_stock_ids:   make_low_stock(shops[i])
for i in high_level_ids:  make_high_level(shops[i])
for i in late_date_ids:   make_late_date(shops[i])

# Step 3: sales clamp pass
for s in shops:
    s["sales"] = clamp_sales(s["sales"], s["level"])


# ---------- legality check ----------
def check_legal(i, s):
    assert 0 <= s["flour"]   <= 4095, f"flour shop {i}"
    assert 0 <= s["butter"]  <= 4095, f"butter shop {i}"
    assert 0 <= s["milk"]    <= 4095, f"milk shop {i}"
    assert 0 <= s["sugar"]   <= 4095, f"sugar shop {i}"
    assert 0 <= s["fruit"]   <= 4095, f"fruit shop {i}"
    assert 1 <= s["month"]   <= 12,   f"month shop {i}"
    assert 1 <= s["day"]     <= DAYS_IN_MONTH[s["month"]], f"day shop {i}"
    assert 0 <= s["sales"]   <= 4095, f"sales shop {i}"
    assert 0 <= s["staff"]   <= 100,  f"staff shop {i}"
    assert 0 <= s["balance"] <= 0xFFFFFF, f"balance shop {i}"
    assert 0 <= s["level"]   <= 100,  f"level shop {i}"


# ---------- write file ----------
def write_dram(path):
    d = os.path.dirname(path)
    if d:
        os.makedirs(d, exist_ok=True)
    with open(path, "w") as f:
        for i, s in enumerate(shops):
            check_legal(i, s)
            w0 = ((s["flour"]  << 52) | (s["butter"] << 40) |
                  (s["month"]  << 32) | (s["milk"]   << 20) |
                  (s["sugar"]  <<  8) | (s["day"]    <<  0))
            w1 = ((s["fruit"]  << 52) | (s["sales"]  << 40) |
                  (s["staff"]  << 32) | (s["balance"]<<  8) |
                  (s["level"]  <<  0))
            addr = DRAM_BASE + i * 16
            buf = [(w0 >> (b * 8)) & 0xFF for b in range(8)] + \
                  [(w1 >> (b * 8)) & 0xFF for b in range(8)]
            for off in range(0, 16, 4):
                f.write(f"@{addr+off:05X}\n")
                f.write(f"{buf[off]:02X} {buf[off+1]:02X} {buf[off+2]:02X} {buf[off+3]:02X}\n")


write_dram(OUT_LOCAL)
try:
    write_dram(OUT_TARGET)
except Exception as e:
    print(f"(Skipped writing to {OUT_TARGET}: {e})")


# ---------- stats ----------
def cnt(pred): return sum(1 for s in shops if pred(s))

print(f"Generated {OUT_LOCAL}")
print(f"Total shops: {NUM_SHOPS}")
print("Fodder distribution:")
print(f"  staff == 0                 : {cnt(lambda s: s['staff']==0)}")
print(f"  balance < 0x10000          : {cnt(lambda s: s['balance'] < 0x10000)}")
print(f"  stock_min > 3800           : {cnt(lambda s: min(s['flour'],s['butter'],s['milk'],s['sugar'],s['fruit']) > 3800)}")
print(f"  staff >= 95                : {cnt(lambda s: s['staff'] >= 95)}")
print(f"  stock_min < 100            : {cnt(lambda s: min(s['flour'],s['butter'],s['milk'],s['sugar'],s['fruit']) < 100)}")
print(f"  level >= 90                : {cnt(lambda s: s['level'] >= 90)}")
print(f"  late date (month>=10)      : {cnt(lambda s: s['month'] >= 10)}")

# Month distribution
from collections import Counter
mc = Counter(s["month"] for s in shops)
print("Month histogram:", dict(sorted(mc.items())))
print("Done.")