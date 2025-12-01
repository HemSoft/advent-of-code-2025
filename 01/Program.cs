using System.Text.RegularExpressions;

var input = await File.ReadAllTextAsync("input.txt").ConfigureAwait(false);
var rotations = RotationRegex().Matches(input)
    .Select(m => (Dir: m.Groups[1].Value, Dist: int.Parse(m.Groups[2].Value, System.Globalization.CultureInfo.InvariantCulture)))
    .ToArray();

// Part 1: count how many times the dial points at 0 at the *end* of a rotation.
var part1 = rotations.Aggregate((Pos: 50, Count: 0), (state, r) =>
{
    var delta = r.Dir == "R" ? r.Dist : -r.Dist;
    var newPos = Mod100(state.Pos + delta);
    return (newPos, state.Count + (newPos == 0 ? 1 : 0));
}).Count;

// Part 2: count how many times the dial points at 0 during any click, including ends.
var part2 = rotations.Aggregate((Pos: 50, Count: 0), (state, r) =>
{
    var delta = r.Dir == "R" ? r.Dist : -r.Dist;

    // Number of *steps* (clicks) in this rotation.
    var steps = Math.Abs(delta);

    // How many of those clicks land on position 0?
    // Each click moves by +1 or -1; stepping from current position pos for k steps
    // hits 0 when pos + k*sign ≡ 0 (mod 100). Solve k0 in [1, steps], then count every 100th step.
    var dirStep = delta > 0 ? 1 : -1;
    var pos = state.Pos;

    // Solve for first k where we land on 0.
    // pos + k*dirStep ≡ 0 (mod 100) -> k ≡ (-pos * dirStep) (mod 100)
    var k0 = Mod100((-pos * dirStep));

    // We only care about steps in the range [1, steps].
    long addedHits = 0;
    if (k0 > 0 && k0 <= steps)
    {
        // Total hits = 1 + number of additional hits every 100 steps.
        addedHits = 1 + (steps - k0) / 100;
    }

    var newPos = Mod100(pos + delta);
    return (newPos, state.Count + (int)addedHits);
}).Count;

Console.WriteLine($"Day 01 Part 1: {part1}");
Console.WriteLine($"Day 01 Part 2: {part2}");

static int Mod100(int value) => ((value % 100) + 100) % 100;

static partial class Program
{
    [GeneratedRegex(@"([LR])(\d+)")]
    private static partial Regex RotationRegex();
}

