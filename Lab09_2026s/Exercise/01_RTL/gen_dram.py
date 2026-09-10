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
# Python 3.6/3.7/3.8 compatible
# Patch dram.dat shop 0 to force Make_and_Sell balance overflow.
# Usage:
#   python3 patch_make_ovf_dram_py38.py
#
# It backs up the original dram.dat as dram.dat.bak_make_ovf.

from __future__ import print_function
from pathlib import Path
import shutil

DRAM_PATH = Path("../00_TESTBED/DRAM/dram.dat")
BASE = 0x10000
SHOP_NUM = 128
SHOP_BYTE = 16
SHOP_ID = 0

def load_readmemh(path):
    mem = {}
    cur_addr = 0

    with path.open("r") as f:
        for raw in f:
            line = raw.split("//")[0].strip()
            if not line:
                continue

            for tok in line.split():
                if not tok:
                    continue
                if tok.startswith("@"):
                    cur_addr = int(tok[1:], 16)
                else:
                    if "x" in tok.lower() or "z" in tok.lower():
                        val = 0
                    else:
                        val = int(tok, 16) & 0xFF
                    mem[cur_addr] = val
                    cur_addr += 1

    return mem

def write_readmemh(path, mem):
    with path.open("w") as f:
        f.write("@10000\n")
        for addr in range(BASE, BASE + SHOP_NUM * SHOP_BYTE):
            f.write("{:02x}\n".format(mem.get(addr, 0) & 0xFF))

def patch_shop0(mem):
    addr = BASE + SHOP_ID * SHOP_BYTE

    # Force shop 0:
    # Fruit_Cake + Party_Pack at level 100:
    # price_each = floor(400 * (10 + 10) / 10) + floor(100^2 / 200)
    #            = 800 + 50 = 850
    # total price = 850 * 8 = 6800
    #
    # balance = 16,777,000
    # 16,777,000 + 6,800 = 16,783,800 > 16,777,215
    # Correct write-back must saturate to 24'hffffff.
    flour   = 4095
    butter  = 4095
    milk    = 4095
    sugar   = 4095
    fruit   = 4095
    month   = 12
    day     = 1
    sales   = 0
    staff   = 1
    balance = 16777000
    level   = 100

    word0 = (
        (flour  << 52) |
        (butter << 40) |
        (month  << 32) |
        (milk   << 20) |
        (sugar  << 8)  |
        day
    )

    word1 = (
        (fruit   << 52) |
        (sales   << 40) |
        (staff   << 32) |
        (balance << 8)  |
        level
    )

    # pseudo_DRAM / pattern use little-endian byte layout:
    # word = {mem[addr+7], ..., mem[addr+0]}
    for i in range(8):
        mem[addr + i] = (word0 >> (8 * i)) & 0xFF
    for i in range(8):
        mem[addr + 8 + i] = (word1 >> (8 * i)) & 0xFF

def main():
    if not DRAM_PATH.exists():
        raise FileNotFoundError("Cannot find {}".format(DRAM_PATH))

    backup = DRAM_PATH.with_name(DRAM_PATH.name + ".bak_make_ovf")
    shutil.copyfile(str(DRAM_PATH), str(backup))

    mem = load_readmemh(DRAM_PATH)
    patch_shop0(mem)
    write_readmemh(DRAM_PATH, mem)

    print("patched {}".format(DRAM_PATH))
    print("backup  {}".format(backup))
    print("shop 0: all stocks=4095, staff=1, level=100, balance=16777000")
    print("Pattern 0 Make Fruit_Cake Party_Pack should force balance saturation.")

if __name__ == "__main__":
    main()
