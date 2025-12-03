var lines = File.ReadAllLines("input.txt").Where(l => !string.IsNullOrWhiteSpace(l)).ToArray();

int position = 50;
int zeroCountPart1 = 0;
int zeroCountPart2 = 0;

foreach (var line in lines)
{
    char direction = line[0];
    int distance = int.Parse(line[1..]);

    int newPosition;
    if (direction == 'L')
        newPosition = ((position - distance) % 100 + 100) % 100;
    else
        newPosition = (position + distance) % 100;

    // Part 1: count only when ending at 0
    if (newPosition == 0)
        zeroCountPart1++;

    // Part 2: count all times dial passes through 0 during rotation (including ending at 0)
    // For left rotation: we hit 0 when (position - x) % 100 == 0 for x in [1, distance]
    // For right rotation: we hit 0 when (position + x) % 100 == 0 for x in [1, distance]
    int firstHit;
    if (direction == 'L')
        firstHit = position == 0 ? 100 : position;
    else
        firstHit = position == 0 ? 100 : (100 - position);

    if (firstHit <= distance)
        zeroCountPart2 += 1 + (distance - firstHit) / 100;

    position = newPosition;
}

Console.WriteLine($"Day 01 Part 1: {zeroCountPart1}");
Console.WriteLine($"Day 01 Part 2: {zeroCountPart2}");
