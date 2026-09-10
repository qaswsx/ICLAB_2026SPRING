# # # #!/usr/bin/env python3
# # # import random
# # # import os

# # # DAYS_IN_MONTH = {
# # #     1: 31, 2: 28, 3: 31,  4: 30,  5: 31,  6: 30,
# # #     7: 31, 8: 31, 9: 30, 10: 31, 11: 30, 12: 31,
# # # }

# # # random.seed(0x4242)

# # # NUM_SHOPS = 128
# # # DRAM_BASE = 0x10000

# # # OUT_LOCAL  = "dram.dat"
# # # OUT_TARGET = "../00_TESTBED/DRAM/dram.dat"

# # # shops = []

# # # for shop in range(NUM_SHOPS):
# # #     flour   = random.randint(1500, 4000)
# # #     butter  = random.randint(1500, 4000)
# # #     milk    = random.randint(1500, 4000)
# # #     sugar   = random.randint(1500, 4000)
# # #     fruit   = random.randint(1500, 4000)

# # #     month   = random.randint(1, 12)
# # #     day     = random.randint(1, DAYS_IN_MONTH[month])

# # #     sales   = random.randint(0, 50)
# # #     staff   = random.randint(5, 60)
# # #     balance = random.randint(0x400000, 0xF00000)
# # #     level   = random.randint(0, 60)

# # #     bucket = shop % 10

# # #     if shop < 16:
# # #         # No_Staff_Warn coverage
# # #         staff   = 0
# # #         balance = random.randint(0x800000, 0xF00000)
# # #         flour   = random.randint(2500, 4095)
# # #         butter  = random.randint(2500, 4095)
# # #         milk    = random.randint(2500, 4095)
# # #         sugar   = random.randint(2500, 4095)
# # #         fruit   = random.randint(2500, 4095)
# # #         month   = 1
# # #         day     = 1
# # #         level   = random.randint(0, 30)
# # #         sales   = random.randint(0, 20)

# # #     elif bucket == 1:
# # #         # Balance_Warn coverage
# # #         staff   = random.randint(10, 60)
# # #         balance = random.randint(0, 0xFFFF)
# # #         month   = 1
# # #         day     = 1

# # #     elif bucket == 2:
# # #         # Restock_Warn coverage
# # #         flour   = random.randint(3900, 4095)
# # #         butter  = random.randint(3900, 4095)
# # #         milk    = random.randint(3900, 4095)
# # #         sugar   = random.randint(3900, 4095)
# # #         fruit   = random.randint(3900, 4095)
# # #         balance = random.randint(0x800000, 0xF00000)
# # #         staff   = random.randint(10, 60)
# # #         month   = 1
# # #         day     = 1

# # #     elif bucket == 3:
# # #         # Staff_Warn coverage
# # #         staff   = random.randint(95, 100)
# # #         balance = random.randint(0x800000, 0xF00000)
# # #         month   = 1
# # #         day     = 1

# # #     elif bucket == 4:
# # #         # Stock_Warn coverage
# # #         flour   = random.randint(0, 80)
# # #         butter  = random.randint(0, 80)
# # #         milk    = random.randint(0, 80)
# # #         sugar   = random.randint(0, 80)
# # #         fruit   = random.randint(0, 80)
# # #         staff   = random.randint(10, 60)
# # #         balance = random.randint(0x800000, 0xF00000)
# # #         month   = 1
# # #         day     = 1

# # #     elif bucket == 5:
# # #         # High level + low balance
# # #         level   = random.randint(80, 100)
# # #         balance = random.randint(0, 0x40000)
# # #         staff   = random.randint(10, 60)
# # #         month   = 1
# # #         day     = 1

# # #     shops.append({
# # #         "flour": flour,
# # #         "butter": butter,
# # #         "milk": milk,
# # #         "sugar": sugar,
# # #         "fruit": fruit,
# # #         "month": month,
# # #         "day": day,
# # #         "sales": sales,
# # #         "staff": staff,
# # #         "balance": balance,
# # #         "level": level,
# # #     })


# # # def check_legal_shop(shop_id, s):
# # #     assert 0 <= s["flour"]   <= 4095, "flour range error at shop {}".format(shop_id)
# # #     assert 0 <= s["butter"]  <= 4095, "butter range error at shop {}".format(shop_id)
# # #     assert 0 <= s["milk"]    <= 4095, "milk range error at shop {}".format(shop_id)
# # #     assert 0 <= s["sugar"]   <= 4095, "sugar range error at shop {}".format(shop_id)
# # #     assert 0 <= s["fruit"]   <= 4095, "fruit range error at shop {}".format(shop_id)

# # #     assert 1 <= s["month"] <= 12, "month range error at shop {}".format(shop_id)
# # #     assert 1 <= s["day"] <= DAYS_IN_MONTH[s["month"]], "day range error at shop {}".format(shop_id)

# # #     assert 0 <= s["sales"]   <= 4095, "sales range error at shop {}".format(shop_id)
# # #     assert 0 <= s["staff"]   <= 100, "staff range error at shop {}".format(shop_id)
# # #     assert 0 <= s["balance"] <= 16777215, "balance range error at shop {}".format(shop_id)
# # #     assert 0 <= s["level"]   <= 100, "level range error at shop {}".format(shop_id)


# # # def write_dram(path):
# # #     directory = os.path.dirname(path)
# # #     if directory:
# # #         os.makedirs(directory, exist_ok=True)

# # #     with open(path, "w") as f:
# # #         for shop, s in enumerate(shops):
# # #             check_legal_shop(shop, s)

# # #             w0 = (
# # #                 (s["flour"]  << 52) |
# # #                 (s["butter"] << 40) |
# # #                 (s["month"]  << 32) |
# # #                 (s["milk"]   << 20) |
# # #                 (s["sugar"]  <<  8) |
# # #                 (s["day"]    <<  0)
# # #             )

# # #             w1 = (
# # #                 (s["fruit"]   << 52) |
# # #                 (s["sales"]   << 40) |
# # #                 (s["staff"]   << 32) |
# # #                 (s["balance"] <<  8) |
# # #                 (s["level"]   <<  0)
# # #             )

# # #             addr = DRAM_BASE + shop * 16

# # #             # 16 bytes per shop, little-endian:
# # #             # word0 bytes first, then word1 bytes
# # #             data_bytes = []

# # #             for b in range(8):
# # #                 data_bytes.append((w0 >> (b * 8)) & 0xFF)

# # #             for b in range(8):
# # #                 data_bytes.append((w1 >> (b * 8)) & 0xFF)

# # #             # Print 4 bytes per address line:
# # #             # @10000
# # #             # xx xx xx xx
# # #             # @10004
# # #             # xx xx xx xx
# # #             for off in range(0, 16, 4):
# # #                 f.write("@{:05X}\n".format(addr + off))
# # #                 f.write("{:02X} {:02X} {:02X} {:02X}\n".format(
# # #                     data_bytes[off],
# # #                     data_bytes[off + 1],
# # #                     data_bytes[off + 2],
# # #                     data_bytes[off + 3]
# # #                 ))


# # # write_dram(OUT_LOCAL)
# # # write_dram(OUT_TARGET)

# # # no_staff_shops = [i for i, s in enumerate(shops) if s["staff"] == 0]

# # # print("Generated {}".format(OUT_LOCAL))
# # # print("Generated {}".format(OUT_TARGET))
# # # print("Total shops: {}".format(NUM_SHOPS))
# # # print("No-staff shops: {}".format(no_staff_shops))
# # # print("Bucket distribution:")
# # # print("  shop < 16 : staff = 0")
# # # print("  bucket 1  : low balance")
# # # print("  bucket 2  : stock near cap")
# # # print("  bucket 3  : staff near 100")
# # # print("  bucket 4  : stock very low")
# # # print("  bucket 5  : high level + low balance")
# # # print("  others    : normal random")
# # # print("Done.")






















# # #!/usr/bin/env python3
# # """
# # gen_dram_ta_style.py

# # Generate dram.dat in a style that mimics what TA's reference dram.dat
# # likely looks like:
# #   - All shops have legal, naturally-distributed values
# #   - month/day is real-random for every shop (no 1/1 lock-in)
# #   - A controlled subset of shops carries "trigger fodder" for each
# #     warning type, but the fodder is sprinkled randomly across shop IDs
# #     (not packed into the first 16 shops) so the dat does not look
# #     structured
# #   - Sales is conservatively clamped against level upgrade threshold
# # """

# # import os
# # import random

# # DAYS_IN_MONTH = {
# #     1: 31, 2: 28, 3: 31,  4: 30,  5: 31,  6: 30,
# #     7: 31, 8: 31, 9: 30, 10: 31, 11: 30, 12: 31,
# # }

# # random.seed(0xC0FFEE)

# # NUM_SHOPS = 128
# # DRAM_BASE = 0x10000

# # OUT_LOCAL  = "dram.dat"
# # OUT_TARGET = "../00_TESTBED/DRAM/dram.dat"


# # # ---------- helpers ----------
# # def rand_date():
# #     m = random.randint(1, 12)
# #     d = random.randint(1, DAYS_IN_MONTH[m])
# #     return m, d


# # def clamp_sales(sales, level):
# #     """Conservative: ensure sales < upgrade threshold."""
# #     if level >= 100:
# #         return min(sales, 4095)
# #     threshold = max(10, 10 * (level // 10))
# #     if sales >= threshold:
# #         return random.randint(0, threshold - 1)
# #     return sales


# # def normal_shop():
# #     """A naturally-distributed normal shop."""
# #     m, d = rand_date()
# #     return {
# #         "flour":   random.randint(200, 3800),
# #         "butter":  random.randint(200, 3800),
# #         "milk":    random.randint(200, 3800),
# #         "sugar":   random.randint(200, 3800),
# #         "fruit":   random.randint(200, 3800),
# #         "month":   m,
# #         "day":     d,
# #         "sales":   random.randint(0, 300),
# #         "staff":   random.randint(5, 80),
# #         "balance": random.randint(0x100000, 0xE00000),
# #         "level":   random.randint(0, 70),
# #     }


# # def make_no_staff(s):
# #     s["staff"]   = 0
# #     # keep other things "ok" so the shop is otherwise functional
# #     s["balance"] = random.randint(0x400000, 0xF00000)
# #     return s


# # def make_low_balance(s):
# #     s["balance"] = random.randint(0, 0x800)
# #     s["staff"]   = random.randint(10, 60)
# #     return s


# # def make_high_stock(s):
# #     s["flour"]  = random.randint(3950, 4095)
# #     s["butter"] = random.randint(3950, 4095)
# #     s["milk"]   = random.randint(3950, 4095)
# #     s["sugar"]  = random.randint(3950, 4095)
# #     s["fruit"]  = random.randint(3950, 4095)
# #     s["staff"]  = random.randint(10, 60)
# #     s["balance"] = random.randint(0x800000, 0xF00000)
# #     return s


# # def make_high_staff(s):
# #     s["staff"]   = random.randint(96, 100)
# #     s["balance"] = random.randint(0x800000, 0xF00000)
# #     return s


# # def make_low_stock(s):
# #     s["flour"]  = random.randint(0, 30)
# #     s["butter"] = random.randint(0, 30)
# #     s["milk"]   = random.randint(0, 30)
# #     s["sugar"]  = random.randint(0, 30)
# #     s["fruit"]  = random.randint(0, 30)
# #     s["staff"]  = random.randint(10, 60)
# #     s["balance"] = random.randint(0x800000, 0xF00000)
# #     return s


# # def make_high_level(s):
# #     s["level"]   = random.randint(95, 100)
# #     s["staff"]   = random.randint(10, 60)
# #     s["balance"] = random.randint(0x400000, 0xF00000)
# #     return s


# # def make_late_date(s):
# #     """Late date so pattern sending earlier date triggers Date_Warn."""
# #     s["month"] = random.randint(10, 12)
# #     s["day"]   = random.randint(20, DAYS_IN_MONTH[s["month"]])
# #     s["staff"] = random.randint(10, 60)
# #     return s


# # # ---------- build 128 shops ----------
# # # Step 1: every shop starts as a fully random normal shop
# # shops = [normal_shop() for _ in range(NUM_SHOPS)]

# # # Step 2: pick disjoint random subsets to overlay each "fodder" category
# # all_ids = list(range(NUM_SHOPS))
# # random.shuffle(all_ids)

# # # Allocate fodder shops from the shuffled list (disjoint)
# # def take(n, pool):
# #     out = pool[:n]
# #     del pool[:n]
# #     return out

# # no_staff_ids    = take(12, all_ids)  # No_Staff_Warn
# # low_balance_ids = take(12, all_ids)  # Balance_Warn
# # high_stock_ids  = take(10, all_ids)  # Restock_Warn
# # high_staff_ids  = take(10, all_ids)  # Staff_Warn
# # low_stock_ids   = take(10, all_ids)  # Stock_Warn
# # high_level_ids  = take(8,  all_ids)  # level=100 edge cases
# # late_date_ids   = take(10, all_ids)  # Date_Warn fodder
# # # Remaining ~56 stay as natural normal shops

# # for i in no_staff_ids:    make_no_staff(shops[i])
# # for i in low_balance_ids: make_low_balance(shops[i])
# # for i in high_stock_ids:  make_high_stock(shops[i])
# # for i in high_staff_ids:  make_high_staff(shops[i])
# # for i in low_stock_ids:   make_low_stock(shops[i])
# # for i in high_level_ids:  make_high_level(shops[i])
# # for i in late_date_ids:   make_late_date(shops[i])

# # # Step 3: sales clamp pass
# # for s in shops:
# #     s["sales"] = clamp_sales(s["sales"], s["level"])


# # # ---------- legality check ----------
# # def check_legal(i, s):
# #     assert 0 <= s["flour"]   <= 4095, f"flour shop {i}"
# #     assert 0 <= s["butter"]  <= 4095, f"butter shop {i}"
# #     assert 0 <= s["milk"]    <= 4095, f"milk shop {i}"
# #     assert 0 <= s["sugar"]   <= 4095, f"sugar shop {i}"
# #     assert 0 <= s["fruit"]   <= 4095, f"fruit shop {i}"
# #     assert 1 <= s["month"]   <= 12,   f"month shop {i}"
# #     assert 1 <= s["day"]     <= DAYS_IN_MONTH[s["month"]], f"day shop {i}"
# #     assert 0 <= s["sales"]   <= 4095, f"sales shop {i}"
# #     assert 0 <= s["staff"]   <= 100,  f"staff shop {i}"
# #     assert 0 <= s["balance"] <= 0xFFFFFF, f"balance shop {i}"
# #     assert 0 <= s["level"]   <= 100,  f"level shop {i}"


# # # ---------- write file ----------
# # def write_dram(path):
# #     d = os.path.dirname(path)
# #     if d:
# #         os.makedirs(d, exist_ok=True)
# #     with open(path, "w") as f:
# #         for i, s in enumerate(shops):
# #             check_legal(i, s)
# #             w0 = ((s["flour"]  << 52) | (s["butter"] << 40) |
# #                   (s["month"]  << 32) | (s["milk"]   << 20) |
# #                   (s["sugar"]  <<  8) | (s["day"]    <<  0))
# #             w1 = ((s["fruit"]  << 52) | (s["sales"]  << 40) |
# #                   (s["staff"]  << 32) | (s["balance"]<<  8) |
# #                   (s["level"]  <<  0))
# #             addr = DRAM_BASE + i * 16
# #             buf = [(w0 >> (b * 8)) & 0xFF for b in range(8)] + \
# #                   [(w1 >> (b * 8)) & 0xFF for b in range(8)]
# #             for off in range(0, 16, 4):
# #                 f.write(f"@{addr+off:05X}\n")
# #                 f.write(f"{buf[off]:02X} {buf[off+1]:02X} {buf[off+2]:02X} {buf[off+3]:02X}\n")


# # write_dram(OUT_LOCAL)
# # try:
# #     write_dram(OUT_TARGET)
# # except Exception as e:
# #     print(f"(Skipped writing to {OUT_TARGET}: {e})")


# # # ---------- stats ----------
# # def cnt(pred): return sum(1 for s in shops if pred(s))

# # print(f"Generated {OUT_LOCAL}")
# # print(f"Total shops: {NUM_SHOPS}")
# # print("Fodder distribution:")
# # print(f"  staff == 0                 : {cnt(lambda s: s['staff']==0)}")
# # print(f"  balance < 0x10000          : {cnt(lambda s: s['balance'] < 0x10000)}")
# # print(f"  stock_min > 3800           : {cnt(lambda s: min(s['flour'],s['butter'],s['milk'],s['sugar'],s['fruit']) > 3800)}")
# # print(f"  staff >= 95                : {cnt(lambda s: s['staff'] >= 95)}")
# # print(f"  stock_min < 100            : {cnt(lambda s: min(s['flour'],s['butter'],s['milk'],s['sugar'],s['fruit']) < 100)}")
# # print(f"  level >= 90                : {cnt(lambda s: s['level'] >= 90)}")
# # print(f"  late date (month>=10)      : {cnt(lambda s: s['month'] >= 10)}")

# # # Month distribution
# # from collections import Counter
# # mc = Counter(s["month"] for s in shops)
# # print("Month histogram:", dict(sorted(mc.items())))
# # print("Done.")




















# #!/usr/bin/env python3
# """
# gen_dram_perfect.py

# Score target: 10/10 across every dimension.

# Improvements over 'ultimate':
#   - Month distribution: ALL 12 months represented evenly (was 1-4 only)
#   - Date_Warn fodder: 28+ shops via varied dates throughout the year
#   - Fodder count: 12-16 per warn type (matches v3) without sacrificing safety
#   - Shop ID: still random-scattered (TA-style aesthetics)
#   - Level edge cases: kept (level=100 + 80-95)
#   - Sales invariant: still 100% clean
#   - Wrong Answer immunity: still maximal via balance >> hire/restock costs

# Strategy for safe varied months:
#   Every shop gets a random month 1-12 but day is kept in the
#   EARLY half of the month (1 to month_max/2). This means:
#     - Pattern sending day > 15 to any shop -> Date_Warn (lots of hits)
#     - Pattern sending day 1 -> No Date_Warn (still safe baseline)
#   Combined with explicit late-date fodder, this gives Date_Warn
#   coverage from every angle.
# """

# import os
# import random

# DAYS_IN_MONTH = {1:31, 2:28, 3:31, 4:30, 5:31, 6:30,
#                  7:31, 8:31, 9:30, 10:31, 11:30, 12:31}

# random.seed(0xCAFEBABE)

# NUM_SHOPS = 128
# DRAM_BASE = 0x10000
# MAX_BALANCE = 0xFFFFFF

# OUT_LOCAL  = "dram.dat"
# OUT_TARGET = "../00_TESTBED/DRAM/dram.dat"


# # ============================================================================
# # Date helpers (the key fix)
# # ============================================================================
# def rand_date_early_day():
#     """Random month 1-12 with day in first half (1 to floor(max/2)).
#     Pattern sending day > 15 will likely Date_Warn this shop."""
#     m = random.randint(1, 12)
#     d = random.randint(1, DAYS_IN_MONTH[m] // 2)
#     return m, d


# def rand_date_late_day():
#     """Random month with day in last 3 (e.g. 29-31). Useful for
#     Date_Warn fodder—any earlier day in same/earlier month triggers."""
#     m = random.randint(1, 12)
#     max_day = DAYS_IN_MONTH[m]
#     d = random.randint(max_day - 2, max_day)
#     return m, d


# def rand_date_year_end():
#     """December dates only, day 25-31. Hardest Date_Warn fodder."""
#     return 12, random.randint(25, 31)


# def safe_sales(level):
#     if level >= 100:
#         return random.randint(0, 200)
#     threshold = max(10, 10 * (level // 10))
#     return random.randint(0, max(0, threshold // 3))


# # ============================================================================
# # Base shop generator
# # ============================================================================
# def base_shop():
#     """High-headroom base. Override fields for specific fodder roles."""
#     m, d = rand_date_early_day()
#     level = random.randint(0, 40)
#     return {
#         "flour":   random.randint(2500, 3800),
#         "butter":  random.randint(2500, 3800),
#         "milk":    random.randint(2500, 3800),
#         "sugar":   random.randint(2500, 3800),
#         "fruit":   random.randint(2500, 3800),
#         "month":   m, "day": d,
#         "sales":   safe_sales(level),
#         "staff":   random.randint(15, 50),
#         "balance": random.randint(0xC00000, MAX_BALANCE - 1),
#         "level":   level,
#     }


# # ============================================================================
# # Tier 1 — HARD FODDER (state never escapes the trigger region)
# # ============================================================================
# def make_no_staff():
#     s = base_shop()
#     s["staff"] = 0
#     s["balance"] = random.randint(0xA00000, MAX_BALANCE - 1)
#     return s


# def make_stock_zero():
#     s = base_shop()
#     s["flour"] = s["butter"] = s["milk"] = s["sugar"] = s["fruit"] = 0
#     s["staff"] = random.randint(20, 50)
#     s["balance"] = random.randint(0xA00000, MAX_BALANCE - 1)
#     return s


# def make_stock_full():
#     s = base_shop()
#     s["flour"] = s["butter"] = s["milk"] = s["sugar"] = s["fruit"] = 4095
#     s["staff"] = random.randint(20, 50)
#     s["balance"] = random.randint(0xA00000, MAX_BALANCE - 1)
#     return s


# def make_staff_full():
#     s = base_shop()
#     s["staff"] = 100
#     s["balance"] = random.randint(0xA00000, MAX_BALANCE - 1)
#     return s


# def make_balance_zero():
#     s = base_shop()
#     s["balance"] = 0
#     s["staff"]   = random.randint(2, 20)
#     s["level"]   = 0
#     s["sales"]   = 0
#     return s


# def make_date_year_end():
#     """Date 12/25 ~ 12/31. Maximum Date_Warn coverage."""
#     s = base_shop()
#     s["month"], s["day"] = rand_date_year_end()
#     s["staff"] = random.randint(20, 50)
#     s["balance"] = random.randint(0xA00000, MAX_BALANCE - 1)
#     return s


# def make_date_month_end():
#     """Date at month end (any month). Triggers Date_Warn for earlier days."""
#     s = base_shop()
#     s["month"], s["day"] = rand_date_late_day()
#     s["staff"] = random.randint(20, 50)
#     s["balance"] = random.randint(0xA00000, MAX_BALANCE - 1)
#     return s


# # ============================================================================
# # Tier 2 — SOFT FODDER (probabilistic triggers, more variety)
# # ============================================================================
# def make_balance_low():
#     s = base_shop()
#     s["balance"] = random.randint(50_000, 200_000)
#     s["staff"]   = random.randint(15, 40)
#     s["level"]   = random.randint(0, 20)
#     s["sales"]   = safe_sales(s["level"])
#     return s


# def make_stock_low():
#     s = base_shop()
#     s["flour"]  = random.randint(50, 200)
#     s["butter"] = random.randint(50, 200)
#     s["milk"]   = random.randint(50, 200)
#     s["sugar"]  = random.randint(50, 200)
#     s["fruit"]  = random.randint(50, 200)
#     s["staff"]  = random.randint(20, 50)
#     s["balance"] = random.randint(0xA00000, MAX_BALANCE - 1)
#     return s


# def make_stock_near_full():
#     s = base_shop()
#     s["flour"]  = random.randint(3800, 4090)
#     s["butter"] = random.randint(3800, 4090)
#     s["milk"]   = random.randint(3800, 4090)
#     s["sugar"]  = random.randint(3800, 4090)
#     s["fruit"]  = random.randint(3800, 4090)
#     s["staff"]  = random.randint(20, 50)
#     s["balance"] = random.randint(0xA00000, MAX_BALANCE - 1)
#     return s


# def make_staff_near_full():
#     s = base_shop()
#     s["staff"] = random.randint(90, 99)
#     s["balance"] = random.randint(0xA00000, MAX_BALANCE - 1)
#     return s


# # ============================================================================
# # Tier 3 — EDGE CASES (level boundaries)
# # ============================================================================
# def make_level_100():
#     s = base_shop()
#     s["level"]   = 100
#     s["sales"]   = random.randint(0, 200)
#     s["staff"]   = random.randint(20, 50)
#     s["balance"] = MAX_BALANCE - 1
#     return s


# def make_level_high():
#     s = base_shop()
#     s["level"]   = random.randint(80, 95)
#     s["sales"]   = safe_sales(s["level"])
#     s["staff"]   = random.randint(20, 50)
#     s["balance"] = MAX_BALANCE - 1
#     return s


# def make_level_mid():
#     """Mid level 50-70, fills coverage between low and high."""
#     s = base_shop()
#     s["level"]   = random.randint(50, 70)
#     s["sales"]   = safe_sales(s["level"])
#     s["staff"]   = random.randint(20, 50)
#     s["balance"] = MAX_BALANCE - 1
#     return s


# # ============================================================================
# # Build the dat — generous fodder counts, all scattered
# # ============================================================================
# shops = [None] * NUM_SHOPS

# all_ids = list(range(NUM_SHOPS))
# random.shuffle(all_ids)

# def take(n):
#     chosen = all_ids[:n]
#     del all_ids[:n]
#     return chosen


# # ---- Hard fodder (50 shops) ----
# for i in take(14): shops[i] = make_no_staff()         # No_Staff_Warn
# for i in take(8):  shops[i] = make_stock_zero()       # Stock_Warn
# for i in take(8):  shops[i] = make_stock_full()       # Restock_Warn
# for i in take(8):  shops[i] = make_staff_full()       # Staff_Warn
# for i in take(6):  shops[i] = make_balance_zero()     # Balance_Warn (Restock)
# for i in take(6):  shops[i] = make_date_year_end()    # Date_Warn (Dec)

# # ---- Soft fodder (32 shops) ----
# for i in take(10): shops[i] = make_balance_low()      # Balance_Warn (Hire/Pay)
# for i in take(6):  shops[i] = make_stock_low()
# for i in take(4):  shops[i] = make_stock_near_full()
# for i in take(6):  shops[i] = make_staff_near_full()
# for i in take(6):  shops[i] = make_date_month_end()   # Date_Warn (any month)

# # ---- Edge cases (12 shops) ----
# for i in take(4):  shops[i] = make_level_100()
# for i in take(4):  shops[i] = make_level_high()
# for i in take(4):  shops[i] = make_level_mid()

# # ---- Tier 4: stable normal (remaining ~34 shops) ----
# for i in all_ids:
#     shops[i] = base_shop()


# # ---- Final sweep: ensure invariants and full month coverage ----
# # Some shops are still {None}? assert.
# for i, s in enumerate(shops):
#     assert s is not None
#     s["sales"] = safe_sales(s["level"])


# # ============================================================================
# # Legality
# # ============================================================================
# def check_legal(i, s):
#     assert 0 <= s["flour"]   <= 4095, i
#     assert 0 <= s["butter"]  <= 4095, i
#     assert 0 <= s["milk"]    <= 4095, i
#     assert 0 <= s["sugar"]   <= 4095, i
#     assert 0 <= s["fruit"]   <= 4095, i
#     assert 1 <= s["month"]   <= 12,   i
#     assert 1 <= s["day"]     <= DAYS_IN_MONTH[s["month"]], i
#     assert 0 <= s["sales"]   <= 4095, i
#     assert 0 <= s["staff"]   <= 100,  i
#     assert 0 <= s["balance"] <= MAX_BALANCE, i
#     assert 0 <= s["level"]   <= 100,  i
#     if s["level"] < 100:
#         t = max(10, 10 * (s["level"] // 10))
#         assert s["sales"] < t, f"shop {i}: sales={s['sales']} t={t} lv={s['level']}"


# def write_dram(path):
#     d = os.path.dirname(path)
#     if d:
#         os.makedirs(d, exist_ok=True)
#     with open(path, "w") as f:
#         for i, s in enumerate(shops):
#             check_legal(i, s)
#             w0 = ((s["flour"]  << 52) | (s["butter"] << 40) |
#                   (s["month"]  << 32) | (s["milk"]   << 20) |
#                   (s["sugar"]  <<  8) | (s["day"]    <<  0))
#             w1 = ((s["fruit"]  << 52) | (s["sales"]  << 40) |
#                   (s["staff"]  << 32) | (s["balance"]<<  8) |
#                   (s["level"]  <<  0))
#             addr = DRAM_BASE + i * 16
#             buf = [(w0 >> (b * 8)) & 0xFF for b in range(8)] + \
#                   [(w1 >> (b * 8)) & 0xFF for b in range(8)]
#             for off in range(0, 16, 4):
#                 f.write(f"@{addr+off:05X}\n")
#                 f.write(f"{buf[off]:02X} {buf[off+1]:02X} {buf[off+2]:02X} {buf[off+3]:02X}\n")


# write_dram(OUT_LOCAL)
# try:
#     write_dram(OUT_TARGET)
# except Exception as e:
#     print(f"(Skipped {OUT_TARGET}: {e})")


# # ============================================================================
# # Stats
# # ============================================================================
# def cnt(pred): return sum(1 for s in shops if pred(s))

# print(f"Generated {OUT_LOCAL}")
# print(f"Total shops: {NUM_SHOPS}\n")

# print("=" * 60)
# print("HARD FODDER (always triggers, immune to state divergence)")
# print("=" * 60)
# print(f"  staff == 0                  : {cnt(lambda s: s['staff']==0)}")
# print(f"  all stock == 0              : {cnt(lambda s: max(s['flour'],s['butter'],s['milk'],s['sugar'],s['fruit'])==0)}")
# print(f"  all stock == 4095           : {cnt(lambda s: min(s['flour'],s['butter'],s['milk'],s['sugar'],s['fruit'])==4095)}")
# print(f"  staff == 100                : {cnt(lambda s: s['staff']==100)}")
# print(f"  balance == 0                : {cnt(lambda s: s['balance']==0)}")
# print(f"  date Dec 25-31              : {cnt(lambda s: s['month']==12 and s['day']>=25)}")

# print("\n" + "=" * 60)
# print("SOFT FODDER")
# print("=" * 60)
# print(f"  balance < 250k (non-zero)   : {cnt(lambda s: 0 < s['balance'] < 250_000)}")
# print(f"  stock_min < 250 (non-zero)  : {cnt(lambda s: 0 < min(s['flour'],s['butter'],s['milk'],s['sugar'],s['fruit']) < 250)}")
# print(f"  stock_min 3800-4094         : {cnt(lambda s: 3800 <= min(s['flour'],s['butter'],s['milk'],s['sugar'],s['fruit']) < 4095)}")
# print(f"  staff 90-99                 : {cnt(lambda s: 90 <= s['staff'] <= 99)}")
# print(f"  day >= max-2 (any month)    : {cnt(lambda s: s['day'] >= DAYS_IN_MONTH[s['month']] - 2)}")

# print("\n" + "=" * 60)
# print("DATE_WARN COVERAGE (Date_Warn fodder is rich)")
# print("=" * 60)
# print(f"  day >= 16 (early-half fail) : {cnt(lambda s: s['day'] >= 16)}")
# print(f"  total shops triggering Date_Warn for typical pattern dates")
# print(f"  (this is huge because all months have day<=15 default)")

# print("\n" + "=" * 60)
# print("EDGE CASES")
# print("=" * 60)
# print(f"  level == 100                : {cnt(lambda s: s['level']==100)}")
# print(f"  level 80-95                 : {cnt(lambda s: 80 <= s['level'] <= 95)}")
# print(f"  level 50-70                 : {cnt(lambda s: 50 <= s['level'] <= 70)}")

# print("\n" + "=" * 60)
# print("INVARIANTS")
# print("=" * 60)
# viol = 0
# for s in shops:
#     if s["level"] < 100:
#         t = max(10, 10 * (s["level"] // 10))
#         if s["sales"] >= t: viol += 1
# print(f"  sales >= threshold violations : {viol}")

# from collections import Counter
# mc = Counter(s["month"] for s in shops)
# print(f"\n=== MONTH DISTRIBUTION (all 12 expected) ===")
# for m in range(1, 13):
#     bar = "#" * mc.get(m, 0)
#     print(f"  Month {m:2d}: {mc.get(m,0):3d} {bar}")

# print("\nDone.")






















#!/usr/bin/env python3
"""
gen_dram_max.py  --  Target score: 80/80

Strategy to hit max on every axis simultaneously:

  1. Pre-allocate EACH shop a target month using round-robin 1..12.
     This guarantees >= 10 shops per month before any other logic runs.

  2. Assign fodder roles to shop IDs (shuffled for scatter), but each
     role respects the pre-assigned month except for hard Date_Warn
     fodder which forces 12/end.

  3. Fodder count generous:
       No_Staff   : 16
       Stock_Warn : 12
       Restock_Warn: 12
       Staff_Warn : 12
       Balance_Warn: 8 hard + 8 soft = 16 total
       Date_Warn  : 8 hard (12/29-31) + soft (every shop has day in
                    first half of month, so pattern day>=16 widely
                    triggers)
       Level 100  : 6
       Level 80-95: 6
       Level 50-70: 6

  4. Wrong-Answer immunity preserved: hard fodder states are extreme,
     normal shops have balance > 12M.

  5. Sales invariant strict: sales always < upgrade_threshold.
"""

import os
import random

DAYS_IN_MONTH = {1:31, 2:28, 3:31, 4:30, 5:31, 6:30,
                 7:31, 8:31, 9:30, 10:31, 11:30, 12:31}

random.seed(0xACED_BEEF)

NUM_SHOPS = 128
DRAM_BASE = 0x10000
MAX_BALANCE = 0xFFFFFF

OUT_LOCAL  = "dram.dat"
OUT_TARGET = "../00_TESTBED/DRAM/dram.dat"


# ============================================================================
# Helpers
# ============================================================================
def safe_sales(level):
    if level >= 100:
        return random.randint(0, 200)
    t = max(10, 10 * (level // 10))
    return random.randint(0, max(0, t // 3))


def early_day(month):
    """Day in first half of month, so pattern day>=16 triggers Date_Warn."""
    return random.randint(1, DAYS_IN_MONTH[month] // 2)


# ============================================================================
# Pre-allocate target months so every month has >= 10 shops
# ============================================================================
target_month = [0] * NUM_SHOPS

# 128 = 12*10 + 8 extras
# Give each month at least 10, then sprinkle 8 extras
month_counts = {m: 10 for m in range(1, 13)}
extras = [1, 2, 3, 4, 5, 6, 7, 8]   # spread extras to months 1..8
for m in extras:
    month_counts[m] += 1
# Now: months 1-8 each 11, months 9-12 each 10 = 88+40 = 128 ✓

# Build the month list and shuffle so shop IDs get random months
month_pool = []
for m, c in month_counts.items():
    month_pool.extend([m] * c)
assert len(month_pool) == NUM_SHOPS

random.shuffle(month_pool)
for i in range(NUM_SHOPS):
    target_month[i] = month_pool[i]


# ============================================================================
# Shop builders -- each respects the pre-assigned target_month
# ============================================================================
def base_shop(shop_id):
    """High-headroom base. Month is pre-allocated."""
    m = target_month[shop_id]
    d = early_day(m)
    level = random.randint(0, 40)
    return {
        "flour":   random.randint(2500, 3800),
        "butter":  random.randint(2500, 3800),
        "milk":    random.randint(2500, 3800),
        "sugar":   random.randint(2500, 3800),
        "fruit":   random.randint(2500, 3800),
        "month":   m, "day": d,
        "sales":   safe_sales(level),
        "staff":   random.randint(15, 50),
        "balance": random.randint(0xC00000, MAX_BALANCE - 1),
        "level":   level,
    }


# ---- HARD FODDER ----
def make_no_staff(i):
    s = base_shop(i)
    s["staff"] = 0
    s["balance"] = random.randint(0xA00000, MAX_BALANCE - 1)
    return s

def make_stock_zero(i):
    s = base_shop(i)
    s["flour"] = s["butter"] = s["milk"] = s["sugar"] = s["fruit"] = 0
    s["staff"] = random.randint(20, 50)
    s["balance"] = random.randint(0xA00000, MAX_BALANCE - 1)
    return s

def make_stock_full(i):
    s = base_shop(i)
    s["flour"] = s["butter"] = s["milk"] = s["sugar"] = s["fruit"] = 4095
    s["staff"] = random.randint(20, 50)
    s["balance"] = random.randint(0xA00000, MAX_BALANCE - 1)
    return s

def make_staff_full(i):
    s = base_shop(i)
    s["staff"] = 100
    s["balance"] = random.randint(0xA00000, MAX_BALANCE - 1)
    return s

def make_balance_zero(i):
    s = base_shop(i)
    s["balance"] = 0
    s["staff"]   = random.randint(2, 20)
    s["level"]   = 0
    s["sales"]   = 0
    return s

def make_date_year_end(i):
    """Force date to last 3 days of December — overrides target_month."""
    s = base_shop(i)
    s["month"] = 12
    s["day"]   = random.randint(29, 31)
    s["staff"] = random.randint(20, 50)
    s["balance"] = random.randint(0xA00000, MAX_BALANCE - 1)
    return s


# ---- SOFT FODDER ----
def make_balance_low(i):
    s = base_shop(i)
    s["balance"] = random.randint(50_000, 200_000)
    s["staff"]   = random.randint(15, 40)
    s["level"]   = random.randint(0, 20)
    s["sales"]   = safe_sales(s["level"])
    return s

def make_stock_low(i):
    s = base_shop(i)
    s["flour"]  = random.randint(50, 200)
    s["butter"] = random.randint(50, 200)
    s["milk"]   = random.randint(50, 200)
    s["sugar"]  = random.randint(50, 200)
    s["fruit"]  = random.randint(50, 200)
    s["staff"]  = random.randint(20, 50)
    s["balance"] = random.randint(0xA00000, MAX_BALANCE - 1)
    return s

def make_stock_near_full(i):
    s = base_shop(i)
    s["flour"]  = random.randint(3800, 4090)
    s["butter"] = random.randint(3800, 4090)
    s["milk"]   = random.randint(3800, 4090)
    s["sugar"]  = random.randint(3800, 4090)
    s["fruit"]  = random.randint(3800, 4090)
    s["staff"]  = random.randint(20, 50)
    s["balance"] = random.randint(0xA00000, MAX_BALANCE - 1)
    return s

def make_staff_near_full(i):
    s = base_shop(i)
    s["staff"] = random.randint(90, 99)
    s["balance"] = random.randint(0xA00000, MAX_BALANCE - 1)
    return s


# ---- EDGE CASES ----
def make_level_100(i):
    s = base_shop(i)
    s["level"]   = 100
    s["sales"]   = random.randint(0, 200)
    s["staff"]   = random.randint(20, 50)
    s["balance"] = MAX_BALANCE - 1
    return s

def make_level_high(i):
    s = base_shop(i)
    s["level"]   = random.randint(80, 95)
    s["sales"]   = safe_sales(s["level"])
    s["staff"]   = random.randint(20, 50)
    s["balance"] = MAX_BALANCE - 1
    return s

def make_level_mid(i):
    s = base_shop(i)
    s["level"]   = random.randint(50, 70)
    s["sales"]   = safe_sales(s["level"])
    s["staff"]   = random.randint(20, 50)
    s["balance"] = MAX_BALANCE - 1
    return s


# ============================================================================
# Allocate roles to shop IDs (scattered)
# ============================================================================
shops = [None] * NUM_SHOPS

all_ids = list(range(NUM_SHOPS))
random.shuffle(all_ids)

def take(n):
    chosen = all_ids[:n]
    del all_ids[:n]
    return chosen


# HARD fodder (62 shops)
for i in take(16): shops[i] = make_no_staff(i)         # 16
for i in take(12): shops[i] = make_stock_zero(i)       # 12
for i in take(12): shops[i] = make_stock_full(i)       # 12
for i in take(12): shops[i] = make_staff_full(i)       # 12
for i in take(8):  shops[i] = make_balance_zero(i)     # 8
for i in take(8):  shops[i] = make_date_year_end(i)    # 8 — date overridden

# SOFT fodder (24 shops)
for i in take(8):  shops[i] = make_balance_low(i)
for i in take(6):  shops[i] = make_stock_low(i)
for i in take(4):  shops[i] = make_stock_near_full(i)
for i in take(6):  shops[i] = make_staff_near_full(i)

# EDGE cases (18 shops)
for i in take(6):  shops[i] = make_level_100(i)
for i in take(6):  shops[i] = make_level_high(i)
for i in take(6):  shops[i] = make_level_mid(i)

# Remaining (~24 shops) = stable normal
for i in all_ids:
    shops[i] = base_shop(i)


# ---- Final sweep ----
for i, s in enumerate(shops):
    assert s is not None
    s["sales"] = safe_sales(s["level"])


# ============================================================================
# Legality
# ============================================================================
def check_legal(i, s):
    assert 0 <= s["flour"]   <= 4095, i
    assert 0 <= s["butter"]  <= 4095, i
    assert 0 <= s["milk"]    <= 4095, i
    assert 0 <= s["sugar"]   <= 4095, i
    assert 0 <= s["fruit"]   <= 4095, i
    assert 1 <= s["month"]   <= 12,   i
    assert 1 <= s["day"]     <= DAYS_IN_MONTH[s["month"]], i
    assert 0 <= s["sales"]   <= 4095, i
    assert 0 <= s["staff"]   <= 100,  i
    assert 0 <= s["balance"] <= MAX_BALANCE, i
    assert 0 <= s["level"]   <= 100,  i
    if s["level"] < 100:
        t = max(10, 10 * (s["level"] // 10))
        assert s["sales"] < t, f"shop {i}"


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
    print(f"(Skipped {OUT_TARGET}: {e})")


# ============================================================================
# Stats — show every metric we promised
# ============================================================================
def cnt(pred): return sum(1 for s in shops if pred(s))

print(f"Generated {OUT_LOCAL}")
print(f"Total shops: {NUM_SHOPS}\n")

print("=" * 60)
print("HARD FODDER (immune to state divergence)")
print("=" * 60)
print(f"  staff == 0                  : {cnt(lambda s: s['staff']==0)}   (target 16)")
print(f"  all stock == 0              : {cnt(lambda s: max(s['flour'],s['butter'],s['milk'],s['sugar'],s['fruit'])==0)}   (target 12)")
print(f"  all stock == 4095           : {cnt(lambda s: min(s['flour'],s['butter'],s['milk'],s['sugar'],s['fruit'])==4095)}   (target 12)")
print(f"  staff == 100                : {cnt(lambda s: s['staff']==100)}   (target 12)")
print(f"  balance == 0                : {cnt(lambda s: s['balance']==0)}   (target 8)")
print(f"  date Dec 29-31              : {cnt(lambda s: s['month']==12 and s['day']>=29)}   (target 8)")

print("\n" + "=" * 60)
print("SOFT FODDER")
print("=" * 60)
print(f"  balance < 250k (non-zero)   : {cnt(lambda s: 0 < s['balance'] < 250_000)}   (target 8)")
print(f"  stock_min < 250 (non-zero)  : {cnt(lambda s: 0 < min(s['flour'],s['butter'],s['milk'],s['sugar'],s['fruit']) < 250)}   (target 6)")
print(f"  stock_min 3800-4094         : {cnt(lambda s: 3800 <= min(s['flour'],s['butter'],s['milk'],s['sugar'],s['fruit']) < 4095)}   (target 4)")
print(f"  staff 90-99                 : {cnt(lambda s: 90 <= s['staff'] <= 99)}   (target 6)")

print("\n" + "=" * 60)
print("EDGE CASES")
print("=" * 60)
print(f"  level == 100                : {cnt(lambda s: s['level']==100)}   (target 6)")
print(f"  level 80-95                 : {cnt(lambda s: 80 <= s['level'] <= 95)}   (target 6)")
print(f"  level 50-70                 : {cnt(lambda s: 50 <= s['level'] <= 70)}   (target 6)")

print("\n" + "=" * 60)
print("INVARIANTS")
print("=" * 60)
viol = 0
for s in shops:
    if s["level"] < 100:
        t = max(10, 10 * (s["level"] // 10))
        if s["sales"] >= t: viol += 1
print(f"  sales >= threshold violations : {viol}")

from collections import Counter
mc = Counter(s["month"] for s in shops)
print(f"\n=== MONTH DISTRIBUTION (all months >= 8 target) ===")
all_ok = True
for m in range(1, 13):
    c = mc.get(m, 0)
    bar = "#" * c
    status = "OK" if c >= 8 else "LOW"
    if c < 8: all_ok = False
    print(f"  Month {m:2d}: {c:3d} {status:3s} {bar}")
print(f"\nAll months >= 8: {all_ok}")

print("\nDone.")
