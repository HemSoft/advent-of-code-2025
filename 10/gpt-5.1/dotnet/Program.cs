using System.Globalization;
using System.Text.RegularExpressions;

var input = File.ReadAllText("input.txt");
var lines = input.Split('\n', StringSplitOptions.RemoveEmptyEntries);

long part1 = 0;
long part2 = 0;

foreach (var rawLine in lines)
{
    var line = rawLine.Trim();
    if (line.Length == 0)
    {
        continue;
    }

    part1 += SolveMachine(line);
    part2 += SolveMachineJoltage(line);
}

Console.WriteLine($"Day 10 Part 1: {part1.ToString(CultureInfo.InvariantCulture)}");
Console.WriteLine($"Day 10 Part 2: {part2.ToString(CultureInfo.InvariantCulture)}");

static int SolveMachine(string line)
{
    var lightMatch = Regex.Match(line, @"\[([.#]+)\]");
    var pattern = lightMatch.Groups[1].Value;
    int n = pattern.Length;

    var target = new int[n];
    for (int i = 0; i < n; i++)
        target[i] = pattern[i] == '#' ? 1 : 0;

    var buttonMatches = Regex.Matches(line, @"\(([0-9,]+)\)");
    var buttons = new List<int[]>();

    foreach (Match m in buttonMatches)
    {
        var indices = m.Groups[1].Value.Split(',').Select(int.Parse).ToArray();
        buttons.Add(indices);
    }

    int numButtons = buttons.Count;

    var matrix = new int[n, numButtons + 1];
    for (int i = 0; i < n; i++)
    {
        matrix[i, numButtons] = target[i];
    }
    for (int j = 0; j < numButtons; j++)
    {
        foreach (var idx in buttons[j])
        {
            if (idx < n)
                matrix[idx, j] = 1;
        }
    }

    var pivotCol = new int[n];
    Array.Fill(pivotCol, -1);
    int rank = 0;

    for (int col = 0; col < numButtons && rank < n; col++)
    {
        int pivotRow = -1;
        for (int row = rank; row < n; row++)
        {
            if (matrix[row, col] == 1)
            {
                pivotRow = row;
                break;
            }
        }

        if (pivotRow == -1)
        {
            continue;
        }

        for (int k = 0; k <= numButtons; k++)
        {
            (matrix[rank, k], matrix[pivotRow, k]) = (matrix[pivotRow, k], matrix[rank, k]);
        }

        pivotCol[rank] = col;

        for (int row = 0; row < n; row++)
        {
            if (row != rank && matrix[row, col] == 1)
            {
                for (int k = 0; k <= numButtons; k++)
                {
                    matrix[row, k] ^= matrix[rank, k];
                }
            }
        }

        rank++;
    }

    for (int row = rank; row < n; row++)
    {
        if (matrix[row, numButtons] == 1)
        {
            return int.MaxValue;
        }
    }

    var freeVars = new List<int>();
    var pivotCols = new HashSet<int>(pivotCol.Where(x => x >= 0));
    for (int j = 0; j < numButtons; j++)
    {
        if (!pivotCols.Contains(j))
        {
            freeVars.Add(j);
        }
    }

    int minPresses = int.MaxValue;
    int numFree = freeVars.Count;

    for (int mask = 0; mask < (1 << numFree); mask++)
    {
        var solution = new int[numButtons];

        for (int i = 0; i < numFree; i++)
        {
            solution[freeVars[i]] = (mask >> i) & 1;
        }

        for (int row = rank - 1; row >= 0; row--)
        {
            int col = pivotCol[row];
            int val = matrix[row, numButtons];
            for (int j = col + 1; j < numButtons; j++)
            {
                val ^= matrix[row, j] * solution[j];
            }
            solution[col] = val;
        }

        int presses = solution.Sum();
        if (presses < minPresses)
        {
            minPresses = presses;
        }
    }

    return minPresses;
}

static long SolveMachineJoltage(string line)
{
    var targetMatch = Regex.Match(line, @"\{([0-9,]+)\}");
    if (!targetMatch.Success)
    {
        return 0;
    }

    var target = targetMatch.Groups[1]
        .Value
        .Split(',', StringSplitOptions.RemoveEmptyEntries)
        .Select(s => long.Parse(s, CultureInfo.InvariantCulture))
        .ToArray();

    int dims = target.Length;

    var buttonMatches = Regex.Matches(line, @"\(([0-9,]+)\)");
    var columns = new List<double[]>();

    foreach (Match m in buttonMatches)
    {
        var col = new double[dims];
        var indices = m.Groups[1].Value
            .Split(',', StringSplitOptions.RemoveEmptyEntries);

        foreach (var p in indices)
        {
            if (!int.TryParse(p, out var idx))
            {
                continue;
            }

            if (idx >= 0 && idx < dims)
            {
                col[idx] = 1.0;
            }
        }

        columns.Add(col);
    }

    int numButtons = columns.Count;
    if (numButtons == 0)
    {
        return 0;
    }

    var matrix = new double[dims, numButtons + 1];
    for (int r = 0; r < dims; r++)
    {
        for (int c = 0; c < numButtons; c++)
        {
            matrix[r, c] = columns[c][r];
        }

        matrix[r, numButtons] = target[r];
    }

    int pivotRow = 0;
    var pivotCols = new List<int>();
    var colToPivotRow = Enumerable.Repeat(-1, numButtons).ToArray();

    for (int c = 0; c < numButtons && pivotRow < dims; c++)
    {
        int selected = -1;
        for (int r = pivotRow; r < dims; r++)
        {
            if (Math.Abs(matrix[r, c]) > 1e-9)
            {
                selected = r;
                break;
            }
        }

        if (selected == -1)
        {
            continue;
        }

        for (int k = c; k <= numButtons; k++)
        {
            (matrix[pivotRow, k], matrix[selected, k]) = (matrix[selected, k], matrix[pivotRow, k]);
        }

        double pivotVal = matrix[pivotRow, c];
        for (int k = c; k <= numButtons; k++)
        {
            matrix[pivotRow, k] /= pivotVal;
        }

        for (int r = 0; r < dims; r++)
        {
            if (r == pivotRow)
            {
                continue;
            }

            if (Math.Abs(matrix[r, c]) <= 1e-9)
            {
                continue;
            }

            double factor = matrix[r, c];
            for (int k = c; k <= numButtons; k++)
            {
                matrix[r, k] -= factor * matrix[pivotRow, k];
            }
        }

        pivotCols.Add(c);
        colToPivotRow[c] = pivotRow;
        pivotRow++;
    }

    for (int r = pivotRow; r < dims; r++)
    {
        if (Math.Abs(matrix[r, numButtons]) > 1e-9)
        {
            return 0;
        }
    }

    var freeCols = new List<int>();
    for (int c = 0; c < numButtons; c++)
    {
        if (!pivotCols.Contains(c))
        {
            freeCols.Add(c);
        }
    }

    var upperBounds = new long[numButtons];
    for (int c = 0; c < numButtons; c++)
    {
        long minUb = long.MaxValue;
        bool bounded = false;

        for (int r = 0; r < dims; r++)
        {
            if (columns[c][r] > 0.5)
            {
                long val = (long)(target[r] / columns[c][r]);
                if (val < minUb)
                {
                    minUb = val;
                }

                bounded = true;
            }
        }

        upperBounds[c] = bounded ? minUb : 0;
    }

    long minTotalPresses = long.MaxValue;
    bool found = false;

    void Search(int freeIdx, long[] currentFree)
    {
        if (freeIdx == freeCols.Count)
        {
            long currentPresses = 0;
            foreach (var v in currentFree)
            {
                currentPresses += v;
            }

            bool possible = true;

            foreach (var pCol in pivotCols)
            {
                int r = colToPivotRow[pCol];
                double val = matrix[r, numButtons];
                for (int j = 0; j < freeCols.Count; j++)
                {
                    int fCol = freeCols[j];
                    val -= matrix[r, fCol] * currentFree[j];
                }

                if (val < -1e-9)
                {
                    possible = false;
                    break;
                }

                long longVal = (long)Math.Round(val);
                if (Math.Abs(val - longVal) > 1e-9)
                {
                    possible = false;
                    break;
                }

                currentPresses += longVal;
            }

            if (possible && currentPresses < minTotalPresses)
            {
                minTotalPresses = currentPresses;
                found = true;
            }

            return;
        }

        int freeColIndex = freeCols[freeIdx];
        long limit = upperBounds[freeColIndex];

        for (long val = 0; val <= limit; val++)
        {
            currentFree[freeIdx] = val;
            Search(freeIdx + 1, currentFree);
        }
    }

    Search(0, new long[freeCols.Count]);

    return found ? minTotalPresses : 0;
}
