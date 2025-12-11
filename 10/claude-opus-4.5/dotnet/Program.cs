using System.Globalization;
using System.Text.RegularExpressions;

var input = File.ReadAllText("input.txt").Trim();
var lines = input.Split('\n', StringSplitOptions.RemoveEmptyEntries);

long part1 = 0;

foreach (var line in lines)
{
    part1 += SolveMachine(line.Trim());
}

Console.WriteLine($"Day 10 Part 1: {part1.ToString(CultureInfo.InvariantCulture)}");

// Part 2
long part2 = 0;
foreach (var line in lines)
{
    var result = SolveMachinePart2(line.Trim());
    // Console.WriteLine($"Machine: {result}");
    part2 += result;
}
Console.WriteLine($"Day 10 Part 2: {part2.ToString(CultureInfo.InvariantCulture)}");

static int SolveMachine(string line)
{
    // Parse the indicator lights pattern
    var lightMatch = Regex.Match(line, @"\[([.#]+)\]");
    var pattern = lightMatch.Groups[1].Value;
    int n = pattern.Length;
    
    // Target: 1 where '#', 0 where '.'
    var target = new int[n];
    for (int i = 0; i < n; i++)
        target[i] = pattern[i] == '#' ? 1 : 0;
    
    // Parse buttons - each (x,y,z) toggles lights at positions x, y, z
    var buttonMatches = Regex.Matches(line, @"\(([0-9,]+)\)");
    var buttons = new List<int[]>();
    
    foreach (Match m in buttonMatches)
    {
        var indices = m.Groups[1].Value.Split(',').Select(int.Parse).ToArray();
        buttons.Add(indices);
    }
    
    int numButtons = buttons.Count;
    
    // Build the matrix: each column is a button, each row is a light
    // We solve: A * x = target (mod 2)
    // Using Gaussian elimination over GF(2)
    
    // Augmented matrix: [A | target]
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
    
    // Gaussian elimination over GF(2) with column tracking
    var pivotCol = new int[n];
    Array.Fill(pivotCol, -1);
    int rank = 0;
    
    for (int col = 0; col < numButtons && rank < n; col++)
    {
        // Find pivot
        int pivotRow = -1;
        for (int row = rank; row < n; row++)
        {
            if (matrix[row, col] == 1)
            {
                pivotRow = row;
                break;
            }
        }
        
        if (pivotRow == -1) continue;
        
        // Swap rows
        for (int k = 0; k <= numButtons; k++)
        {
            (matrix[rank, k], matrix[pivotRow, k]) = (matrix[pivotRow, k], matrix[rank, k]);
        }
        
        pivotCol[rank] = col;
        
        // Eliminate
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
    
    // Check for inconsistency
    for (int row = rank; row < n; row++)
    {
        if (matrix[row, numButtons] == 1)
            return int.MaxValue; // No solution
    }
    
    // Find free variables (columns not used as pivots)
    var freeVars = new List<int>();
    var pivotCols = new HashSet<int>(pivotCol.Where(x => x >= 0));
    for (int j = 0; j < numButtons; j++)
    {
        if (!pivotCols.Contains(j))
            freeVars.Add(j);
    }
    
    // Try all combinations of free variables to find minimum solution
    int minPresses = int.MaxValue;
    int numFree = freeVars.Count;
    
    for (int mask = 0; mask < (1 << numFree); mask++)
    {
        var solution = new int[numButtons];
        
        // Set free variables based on mask
        for (int i = 0; i < numFree; i++)
        {
            solution[freeVars[i]] = (mask >> i) & 1;
        }
        
        // Back-substitute to find pivot variable values
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
            minPresses = presses;
    }
    
    return minPresses;
}

static long SolveMachinePart2(string line)
{
    // Parse joltage requirements from {x,y,z,...}
    var reqMatch = Regex.Match(line, @"\{([0-9,]+)\}");
    var requirements = reqMatch.Groups[1].Value.Split(',').Select(long.Parse).ToArray();
    int n = requirements.Length;
    
    // Parse buttons - each (x,y,z) increments counters at positions x, y, z
    var buttonMatches = Regex.Matches(line, @"\(([0-9,]+)\)");
    var buttons = new List<int[]>();
    
    foreach (Match m in buttonMatches)
    {
        var indices = m.Groups[1].Value.Split(',').Select(int.Parse).ToArray();
        buttons.Add(indices);
    }
    
    int numButtons = buttons.Count;
    
    // Build augmented matrix [A | requirements]
    var matrix = new double[n, numButtons + 1];
    for (int i = 0; i < n; i++)
    {
        matrix[i, numButtons] = requirements[i];
    }
    for (int j = 0; j < numButtons; j++)
    {
        foreach (var idx in buttons[j])
        {
            if (idx < n)
                matrix[idx, j] = 1;
        }
    }
    
    // Gaussian elimination
    var pivotCol = new int[n];
    Array.Fill(pivotCol, -1);
    int rank = 0;
    
    for (int col = 0; col < numButtons && rank < n; col++)
    {
        int pivotRow = -1;
        double maxVal = 0;
        for (int row = rank; row < n; row++)
        {
            if (Math.Abs(matrix[row, col]) > maxVal)
            {
                maxVal = Math.Abs(matrix[row, col]);
                pivotRow = row;
            }
        }
        
        if (maxVal < 1e-10) continue;
        
        for (int k = 0; k <= numButtons; k++)
        {
            (matrix[rank, k], matrix[pivotRow, k]) = (matrix[pivotRow, k], matrix[rank, k]);
        }
        
        pivotCol[rank] = col;
        double pivot = matrix[rank, col];
        for (int k = 0; k <= numButtons; k++)
        {
            matrix[rank, k] /= pivot;
        }
        
        for (int row = 0; row < n; row++)
        {
            if (row != rank)
            {
                double factor = matrix[row, col];
                for (int k = 0; k <= numButtons; k++)
                {
                    matrix[row, k] -= factor * matrix[rank, k];
                }
            }
        }
        rank++;
    }
    
    // Find free variables
    var freeVars = new List<int>();
    var pivotCols = new HashSet<int>(pivotCol.Where(x => x >= 0));
    for (int j = 0; j < numButtons; j++)
    {
        if (!pivotCols.Contains(j))
            freeVars.Add(j);
    }
    
    long minPresses = long.MaxValue;
    
    long[] TryFreeVars(long[] freeValues)
    {
        var solution = new double[numButtons];
        for (int i = 0; i < freeVars.Count; i++)
        {
            solution[freeVars[i]] = freeValues[i];
        }
        
        for (int row = 0; row < rank; row++)
        {
            int col = pivotCol[row];
            double val = matrix[row, numButtons];
            for (int j = col + 1; j < numButtons; j++)
            {
                val -= matrix[row, j] * solution[j];
            }
            solution[col] = val;
        }
        
        var intSolution = solution.Select(v => (long)Math.Round(v)).ToArray();
        
        // Verify
        var result = new long[n];
        for (int j = 0; j < numButtons; j++)
        {
            foreach (var idx in buttons[j])
            {
                if (idx < n)
                    result[idx] += intSolution[j];
            }
        }
        
        bool valid = intSolution.All(x => x >= 0) && result.SequenceEqual(requirements);
        return valid ? intSolution : null;
    }
    
    // For no free variables, just try the unique solution
    if (freeVars.Count == 0)
    {
        var sol = TryFreeVars([]);
        if (sol != null)
            return sol.Sum();
        return 0;
    }
    
    // For systems with free variables, search systematically
    int limit = 200;  // Reasonable limit for exhaustive search
    
    void SearchRecursive(int depth, long[] values)
    {
        if (depth == freeVars.Count)
        {
            var sol = TryFreeVars(values);
            if (sol != null)
            {
                long total = sol.Sum();
                if (total < minPresses)
                    minPresses = total;
            }
            return;
        }
        
        for (long v = 0; v <= limit; v++)
        {
            values[depth] = v;
            SearchRecursive(depth + 1, values);
        }
    }
    
    if (freeVars.Count > 0 && freeVars.Count <= 2)
    {
        SearchRecursive(0, new long[freeVars.Count]);
    }
    else
    {
        // Too many free variables - just try basic solution
        var sol = TryFreeVars(new long[freeVars.Count]);
        if (sol != null)
            return sol.Sum();
        return 0;
    }
    
    return minPresses == long.MaxValue ? 0 : minPresses;
}