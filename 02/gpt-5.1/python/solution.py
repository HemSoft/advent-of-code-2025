with open("input.txt") as f:
    input_data = f.read().strip()


def digits_count(n: int) -> int:
    if n < 0:
        n = -n
    count = 1
    while n >= 10:
        n //= 10
        count += 1
    return count


def pow10(exp: int) -> int:
    res = 1
    for _ in range(exp):
        res *= 10
    return res


def sum_invalid_ids(s: str) -> int:
    sum_ids = 0
    for r in s.split(","):
        r = r.strip()
        if not r:
            continue
        parts = [p.strip() for p in r.split("-") if p.strip()]
        if len(parts) != 2:
            continue
        start = int(parts[0])
        end = int(parts[1])
        if end < start:
            start, end = end, start

        min_len = digits_count(start)
        max_len = digits_count(end)
        for length in range(min_len, max_len + 1):
            if length % 2 == 1:
                continue
            half = length // 2
            p10 = pow10(half)
            first = pow10(length - 1)
            last = pow10(length) - 1

            low = max(start, first)
            high = min(end, last)
            if low > high:
                continue

            den = p10 + 1
            a_start = (low + den - 1) // den  # ceil(low/den)
            a_end = high // den  # floor(high/den)
            if a_start > a_end:
                continue

            count = a_end - a_start + 1
            terms_sum = (a_start + a_end) * count // 2
            contrib = terms_sum * den
            sum_ids += contrib
    return sum_ids


part1 = sum_invalid_ids(input_data)
print(f"Day 02 Part 1: {part1}")


def sum_invalid_ids_part2(s: str) -> int:
    sum_ids = 0
    for r in s.split(","):
        r = r.strip()
        if not r:
            continue
        parts = [p.strip() for p in r.split("-") if p.strip()]
        if len(parts) != 2:
            continue
        start = int(parts[0])
        end = int(parts[1])
        if end < start:
            start, end = end, start

        min_len = digits_count(start)
        max_len = digits_count(end)
        for length in range(min_len, max_len + 1):
            for k in range(2, int(length ** 0.5) + 1):
                if length % k != 0:
                    continue

                base_len = length // k
                p10_base = pow10(base_len)
                first = pow10(length - 1)
                last = pow10(length) - 1

                low = max(start, first)
                high = min(end, last)
                if low > high:
                    continue

                geom = 0
                factor = 1
                for _ in range(k):
                    geom += factor
                    factor *= p10_base

                a_start = (low + geom - 1) // geom
                a_end = high // geom
                if a_start > a_end:
                    continue

                count = a_end - a_start + 1
                terms_sum = (a_start + a_end) * count // 2
                contrib = terms_sum * geom
                sum_ids += contrib
    return sum_ids


part2 = sum_invalid_ids_part2(input_data)
print(f"Day 02 Part 2: {part2}")
