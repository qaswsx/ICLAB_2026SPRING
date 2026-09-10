import random
from pathlib import Path

SEED = 123
OUT_FILE = Path(__file__).with_name("dram.dat")

BASE_ADDR = 0x10000
SHOP_NUM = 128
SHOP_SIZE = 16

MAX_STOCK = 4095
MAX_SALES = 4095
MAX_STAFF = 100
MAX_LEVEL = 100
MAX_BALANCE = 16777215

random.seed(SEED)


def clamp(v, lo, hi):
    return max(lo, min(hi, v))


def valid_date():
    month = random.randint(1, 12)
    if month == 2:
        day = random.randint(1, 28)
    elif month in (4, 6, 9, 11):
        day = random.randint(1, 30)
    else:
        day = random.randint(1, 31)
    return month, day


def make_shop(flour, butter, milk, sugar, fruit,
              month, day, sales, staff, level, balance):
    return {
        "flour":   clamp(flour,   0, MAX_STOCK),
        "butter":  clamp(butter,  0, MAX_STOCK),
        "milk":    clamp(milk,    0, MAX_STOCK),
        "sugar":   clamp(sugar,   0, MAX_STOCK),
        "fruit":   clamp(fruit,   0, MAX_STOCK),
        "month":   clamp(month,   1, 12),
        "day":     clamp(day,     1, 31),
        "sales":   clamp(sales,   0, MAX_SALES),
        "staff":   clamp(staff,   0, MAX_STAFF),
        "level":   clamp(level,   0, MAX_LEVEL),
        "balance": clamp(balance, 0, MAX_BALANCE),
    }


def shop_safe(level=0, sales=0, staff=1, balance=1000000, month=1, day=1,
              flour=4095, butter=4095, milk=4095, sugar=4095, fruit=4095):
    return make_shop(
        flour=flour, butter=butter, milk=milk, sugar=sugar, fruit=fruit,
        month=month, day=day,
        sales=sales, staff=staff, level=level, balance=balance
    )


def pack_shop(s):
    flour   = s["flour"]
    butter  = s["butter"]
    milk    = s["milk"]
    sugar   = s["sugar"]
    fruit   = s["fruit"]
    month   = s["month"]
    day     = s["day"]
    sales   = s["sales"]
    staff   = s["staff"]
    level   = s["level"]
    balance = s["balance"]

    b = [0] * 16

    b[0]  = day & 0xFF
    b[1]  = sugar & 0xFF
    b[2]  = ((milk & 0xF) << 4) | ((sugar >> 8) & 0xF)
    b[3]  = (milk >> 4) & 0xFF

    b[4]  = month & 0xFF
    b[5]  = butter & 0xFF
    b[6]  = ((flour & 0xF) << 4) | ((butter >> 8) & 0xF)
    b[7]  = (flour >> 4) & 0xFF

    b[8]  = level & 0xFF
    b[9]  = balance & 0xFF
    b[10] = (balance >> 8) & 0xFF
    b[11] = (balance >> 16) & 0xFF

    b[12] = staff & 0xFF
    b[13] = sales & 0xFF
    b[14] = ((fruit & 0xF) << 4) | ((sales >> 8) & 0xF)
    b[15] = (fruit >> 4) & 0xFF

    return b


def random_shop(idx):
    m, d = valid_date()

    flour  = random.randint(0, MAX_STOCK)
    butter = random.randint(0, MAX_STOCK)
    milk   = random.randint(0, MAX_STOCK)
    sugar  = random.randint(0, MAX_STOCK)
    fruit  = random.randint(0, MAX_STOCK)

    sales   = random.randint(0, 300)
    staff   = random.randint(0, 100)
    level   = random.randint(0, 100)
    balance = random.randint(0, MAX_BALANCE)

    bucket = idx % 10

    if bucket == 0:
        staff = 0
        balance = random.randint(100000, 1000000)

    elif bucket == 1:
        balance = random.randint(0, 2000)
        staff = random.randint(1, 20)

    elif bucket == 2:
        flour  = random.randint(3900, 4095)
        butter = random.randint(3900, 4095)
        milk   = random.randint(3900, 4095)
        sugar  = random.randint(3900, 4095)
        fruit  = random.randint(3900, 4095)
        balance = random.randint(1000000, MAX_BALANCE)

    elif bucket == 3:
        staff = random.randint(95, 100)
        balance = random.randint(1000000, MAX_BALANCE)

    elif bucket == 4:
        flour  = random.randint(0, 80)
        butter = random.randint(0, 80)
        milk   = random.randint(0, 80)
        sugar  = random.randint(0, 80)
        fruit  = random.randint(0, 80)
        staff = random.randint(1, 30)
        balance = random.randint(100000, 1000000)

    elif bucket == 5:
        level = random.randint(95, 100)
        sales = random.randint(4000, 4095)
        staff = random.randint(1, 20)
        balance = random.randint(16000000, MAX_BALANCE)

    return make_shop(
        flour, butter, milk, sugar, fruit,
        m, d,
        sales, staff, level, balance
    )


shops = []

# ================================================================
# 0~19: upgrade verification pairs
# ================================================================
shops.append(shop_safe(level=9,  sales=9,   staff=1, balance=1430))   # 0
shops.append(shop_safe(level=19, sales=9,   staff=1, balance=1567))   # 1
shops.append(shop_safe(level=99, sales=89,  staff=1, balance=2623))   # 2
shops.append(shop_safe(level=8,  sales=49,  staff=1, balance=21640))  # 3
shops.append(shop_safe(level=98, sales=179, staff=1, balance=46792))  # 4
shops.append(shop_safe(level=0,  sales=9,   staff=1, balance=19980))  # 5
shops.append(shop_safe(level=1,  sales=9,   staff=1, balance=19340))  # 6
shops.append(shop_safe(level=89, sales=79,  staff=1, balance=44860))  # 7
shops.append(shop_safe(level=49, sales=39,  staff=1, balance=34180))  # 8
shops.append(shop_safe(level=10, sales=9,   staff=1, balance=22968))  # 9

for i in range(10, 20):
    shops.append(shop_safe(level=i, sales=0, staff=1, balance=1000000))

# ================================================================
# 20~39: Make_and_Sell corners
# ================================================================
for i in range(20, 28):
    shops.append(shop_safe(level=i-20, sales=0, staff=1, balance=1000000))

for i in range(28, 36):
    shops.append(shop_safe(level=0, sales=0, staff=1, balance=1000000,
                           flour=0, butter=0, milk=0, sugar=0, fruit=0))

shops.append(shop_safe(level=0, sales=0, staff=0, balance=1000000))                 # 36 no staff
shops.append(shop_safe(level=0, sales=0, staff=1, balance=1000000, month=12, day=31)) # 37 earlier date
shops.append(shop_safe(level=0, sales=0, staff=1, balance=1000000))                 # 38 invalid input date
shops.append(shop_safe(level=100, sales=0, staff=1, balance=16777200))              # 39 balance saturation

# ================================================================
# 40~55: Restock corners
# ================================================================
names = ["flour", "butter", "milk", "sugar", "fruit"]

for idx in range(5):
    vals = dict(flour=1000, butter=1000, milk=1000, sugar=1000, fruit=1000)
    vals[names[idx]] = 4000
    shops.append(shop_safe(level=0, sales=0, staff=1, balance=1000000, **vals))

for idx in range(5):
    vals = dict(flour=1000, butter=1000, milk=1000, sugar=1000, fruit=1000)
    vals[names[idx]] = 4000
    shops.append(shop_safe(level=0, sales=0, staff=1, balance=1000000, **vals))

shops.append(shop_safe(level=0, sales=0, staff=1, balance=10, flour=4000))             # 50
shops.append(shop_safe(level=0, sales=0, staff=1, balance=1000000))                    # 51
shops.append(shop_safe(level=0, sales=0, staff=1, balance=16777215,
                       flour=100, butter=100, milk=100, sugar=100, fruit=100))         # 52
shops.append(shop_safe(level=0, sales=0, staff=1, balance=1000000, month=12, day=31))  # 53
shops.append(shop_safe(level=0, sales=0, staff=1, balance=1000000))                    # 54
shops.append(shop_safe(level=0, sales=0, staff=1, balance=1000000,
                       flour=3900, butter=3900, milk=1000, sugar=1000, fruit=1000))    # 55

# ================================================================
# 56~67: Hire Staff corners
# ================================================================
shops.append(shop_safe(level=0,   staff=90,  balance=1000000))                         # 56
shops.append(shop_safe(level=0,   staff=95,  balance=1000000))                         # 57
shops.append(shop_safe(level=0,   staff=95,  balance=10))                              # 58
shops.append(shop_safe(level=0,   staff=0,   balance=1000000))                         # 59
shops.append(shop_safe(level=0,   staff=50,  balance=1000000))                         # 60
shops.append(shop_safe(level=100, staff=50,  balance=1000000))                         # 61
shops.append(shop_safe(level=0,   staff=50,  balance=1000000, month=12, day=31))        # 62
shops.append(shop_safe(level=0,   staff=50,  balance=1000000))                         # 63
shops.append(shop_safe(level=0,   staff=50,  balance=2000))                            # 64
shops.append(shop_safe(level=0,   staff=50,  balance=1999))                            # 65
shops.append(shop_safe(level=0,   staff=100, balance=1000000))                         # 66
shops.append(shop_safe(level=0,   staff=99,  balance=1000000))                         # 67

# ================================================================
# 68~79: Pay Day corners
# ================================================================
shops.append(shop_safe(level=0,   staff=0,   balance=1000000))                         # 68
shops.append(shop_safe(level=0,   staff=1,   balance=20000))                           # 69
shops.append(shop_safe(level=0,   staff=1,   balance=19999))                           # 70
shops.append(shop_safe(level=5,   staff=2,   balance=1, sales=50))                     # 71
shops.append(shop_safe(level=0,   staff=1,   balance=1, sales=50))                     # 72
shops.append(shop_safe(level=99,  staff=1,   balance=1000000))                         # 73
shops.append(shop_safe(level=0,   staff=1,   balance=1000000, month=12, day=31))        # 74
shops.append(shop_safe(level=0,   staff=1,   balance=1000000))                         # 75
shops.append(shop_safe(level=0,   staff=10,  balance=16777215))                        # 76
shops.append(shop_safe(level=50,  staff=100, balance=16777215))                        # 77
shops.append(shop_safe(level=100, staff=1,   balance=50000))                           # 78
shops.append(shop_safe(level=25,  staff=5,   balance=1, sales=50))                     # 79

# ================================================================
# 80~89: Check Valid Date
# ================================================================
shops.append(shop_safe(month=1,  day=1))                                                # 80
shops.append(shop_safe(month=1,  day=1))                                                # 81
shops.append(shop_safe(month=12, day=31))                                               # 82
shops.append(shop_safe(month=1,  day=1))                                                # 83
shops.append(shop_safe(month=1,  day=1))                                                # 84
shops.append(shop_safe(month=1,  day=1))                                                # 85
shops.append(shop_safe(month=1,  day=1))                                                # 86
shops.append(shop_safe(month=1,  day=1))                                                # 87
shops.append(shop_safe(month=1,  day=1))                                                # 88
shops.append(shop_safe(month=1,  day=1))                                                # 89

# ================================================================
# 90~99: mixed follow-up / writeback-sensitive
# ================================================================
for i in range(90, 100):
    shops.append(shop_safe(level=0, sales=0, staff=1, balance=1000000))

assert len(shops) == 100

for i in range(100, SHOP_NUM):
    shops.append(random_shop(i))

assert len(shops) == SHOP_NUM

mem_bytes = []
for s in shops:
    mem_bytes.extend(pack_shop(s))

assert len(mem_bytes) == SHOP_NUM * SHOP_SIZE

with open(OUT_FILE, "w") as f:
    f.write(f"@{BASE_ADDR:05X}\n")
    for byte in mem_bytes:
        f.write(f"{byte:02X}\n")

print(f"Generated: {OUT_FILE}")
print(f"Address range: @{BASE_ADDR:05X} ~ @{BASE_ADDR + SHOP_NUM * SHOP_SIZE - 1:05X}")
print("Fixed corner data_no: 0~99")