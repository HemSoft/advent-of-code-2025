using System.Text.RegularExpressions;

var input = await File.ReadAllTextAsync("input.txt").ConfigureAwait(false);
var count = RotationRegex().Matches(input)
    .Select(m => (Dir: m.Groups[1].Value, Dist: int.Parse(m.Groups[2].Value, System.Globalization.CultureInfo.InvariantCulture)))
    .Aggregate((Pos: 50, Count: 0), (state, r) =>
    {
        var newPos = ((state.Pos + (r.Dir == "R" ? r.Dist : -r.Dist)) % 100 + 100) % 100;
        return (newPos, state.Count + (newPos == 0 ? 1 : 0));
    }).Count;

Console.WriteLine($"Day 01 Answer: {count}");

static partial class Program
{
    [GeneratedRegex(@"([LR])(\d+)")]
    private static partial Regex RotationRegex();
}

