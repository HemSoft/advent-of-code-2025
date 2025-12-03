import * as fs from 'fs';

const input = fs.readFileSync('input.txt', 'utf-8').trim();

function digitsCount(n: bigint): number {
	if (n < 0n) n = -n;
	let count = 1;
	while (n >= 10n) {
		n /= 10n;
		count++;
	}
	return count;
}

function pow10(exp: number): bigint {
	let result = 1n;
	for (let i = 0; i < exp; i++) {
		result *= 10n;
	}
	return result;
}

function sumInvalidIds(input: string): bigint {
	let sum = 0n;
	const ranges = input.split(',');

	for (const r0 of ranges) {
		const r = r0.trim();
		if (!r) continue;
		const parts = r.split('-').map(p => p.trim());
		if (parts.length !== 2) continue;

		let start = BigInt(parts[0]);
		let end = BigInt(parts[1]);
		if (end < start) {
			const tmp = start;
			start = end;
			end = tmp;
		}

		const minLen = digitsCount(start);
		const maxLen = digitsCount(end);
		for (let len = minLen; len <= maxLen; len++) {
			if (len % 2 !== 0) continue;

			const half = len / 2;
			const pow = pow10(half);
			const first = pow10(len - 1);
			const last = pow10(len) - 1n;

			let low = start > first ? start : first;
			let high = end < last ? end : last;
			if (low > high) continue;

			const den = pow + 1n;
			let aStart = (low + den - 1n) / den; // ceil(low/den)
			let aEnd = high / den; // floor(high/den)
			if (aStart > aEnd) continue;

			const count = aEnd - aStart + 1n;
			const termsSum = (aStart + aEnd) * count / 2n;
			const contrib = termsSum * den;
			sum += contrib;
		}
	}

	return sum;
}

const part1 = sumInvalidIds(input);
console.log(`Day 02 Part 1: ${part1.toString()}`);

function sumInvalidIdsPart2(input: string): bigint {
	let sum = 0n;
	const ranges = input.split(',');

	for (const r0 of ranges) {
		const r = r0.trim();
		if (!r) continue;
		const parts = r.split('-').map(p => p.trim());
		if (parts.length !== 2) continue;

		let start = BigInt(parts[0]);
		let end = BigInt(parts[1]);
		if (end < start) {
			const tmp = start;
			start = end;
			end = tmp;
		}

		const minLen = digitsCount(start);
		const maxLen = digitsCount(end);
		for (let len = minLen; len <= maxLen; len++) {
			for (let k = 2; k * k <= len; k++) {
				if (len % k !== 0) continue;

				const baseLen = len / k;
				const powBase = pow10(baseLen);
				const first = pow10(len - 1);
				const last = pow10(len) - 1n;

				let low = start > first ? start : first;
				let high = end < last ? end : last;
				if (low > high) continue;

				let geom = 0n;
				let factor = 1n;
				for (let i = 0; i < k; i++) {
					geom += factor;
					factor *= powBase;
				}

				const aStart = (low + geom - 1n) / geom;
				const aEnd = high / geom;
				if (aStart > aEnd) continue;

				const count = aEnd - aStart + 1n;
				const termsSum = (aStart + aEnd) * count / 2n;
				const contrib = termsSum * geom;
				sum += contrib;
			}
		}
	}

	return sum;
}

const part2 = sumInvalidIdsPart2(input);
console.log(`Day 02 Part 2: ${part2.toString()}`);
