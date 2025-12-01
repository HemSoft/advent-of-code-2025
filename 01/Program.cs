using System.Text.RegularExpressions;

var (pos, count) = (50, 0);
foreach (var m in Regex.Matches(File.ReadAllText("input.txt"), @"([LR])(\d+)").Cast<Match>())
{
    pos = ((pos + (m.Groups[1].Value == "R" ? 1 : -1) * int.Parse(m.Groups[2].Value)) % 100 + 100) % 100;
    if (pos == 0) count++;
}
Console.WriteLine($"Day 01 Answer: {count}");

