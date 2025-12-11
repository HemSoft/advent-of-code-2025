using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;

class Program
{
    static void Main()
    {
        string input = File.ReadAllText("input.txt");
        long totalPressesPart1 = 0;
        long totalPressesPart2 = 0;

        foreach (var line in input.Split('\n', StringSplitOptions.RemoveEmptyEntries))
        {
            if (string.IsNullOrWhiteSpace(line)) continue;
            totalPressesPart1 += SolvePart1(line);
            totalPressesPart2 += SolvePart2(line);
        }

        Console.WriteLine($"Day 10 Part 1: {totalPressesPart1}");
        Console.WriteLine($"Day 10 Part 2: {totalPressesPart2}");
    }

    static long SolvePart1(string line)
    {
        var match = Regex.Match(line, @"\[([.#]+)\]");
        if (!match.Success) return 0;
        string targetStr = match.Groups[1].Value;
        int L = targetStr.Length;
        
        int[] target = new int[L];
        for (int i = 0; i < L; i++) target[i] = targetStr[i] == '#' ? 1 : 0;

        var buttonMatches = Regex.Matches(line, @"\(([\d,]+)\)");
        List<int[]> buttons = new List<int[]>();
        foreach (Match bm in buttonMatches)
        {
            int[] b = new int[L];
            var parts = bm.Groups[1].Value.Split(',');
            foreach (var p in parts)
            {
                if (int.TryParse(p, out int idx))
                {
                    if (idx < L) b[idx] = 1;
                }
            }
            buttons.Add(b);
        }

        int B = buttons.Count;
        
        // Matrix M of size L x (B + 1)
        int[,] M = new int[L, B + 1];
        for (int r = 0; r < L; r++)
        {
            for (int c = 0; c < B; c++)
            {
                M[r, c] = buttons[c][r];
            }
            M[r, B] = target[r];
        }

        int pivotRow = 0;
        List<int> pivotCols = new List<int>();
        int[] colToPivotRow = new int[B];
        for(int i=0; i<B; i++) colToPivotRow[i] = -1;

        for (int c = 0; c < B && pivotRow < L; c++)
        {
            int sel = -1;
            for (int r = pivotRow; r < L; r++)
            {
                if (M[r, c] == 1)
                {
                    sel = r;
                    break;
                }
            }

            if (sel == -1) continue;

            // Swap
            for (int k = 0; k <= B; k++)
            {
                int temp = M[pivotRow, k];
                M[pivotRow, k] = M[sel, k];
                M[sel, k] = temp;
            }

            // Eliminate
            for (int r = 0; r < L; r++)
            {
                if (r != pivotRow && M[r, c] == 1)
                {
                    for (int k = c; k <= B; k++)
                    {
                        M[r, k] ^= M[pivotRow, k];
                    }
                }
            }

            pivotCols.Add(c);
            colToPivotRow[c] = pivotRow;
            pivotRow++;
        }

        for (int r = pivotRow; r < L; r++)
        {
            if (M[r, B] == 1) return 0; // Should not happen
        }

        List<int> freeCols = new List<int>();
        for (int c = 0; c < B; c++)
        {
            if (!pivotCols.Contains(c)) freeCols.Add(c);
        }

        long minPresses = long.MaxValue;
        int numFree = freeCols.Count;
        long combinations = 1L << numFree;

        for (long i = 0; i < combinations; i++)
        {
            int[] x = new int[B];
            long currentPresses = 0;

            for (int k = 0; k < numFree; k++)
            {
                if ((i & (1L << k)) != 0)
                {
                    x[freeCols[k]] = 1;
                    currentPresses++;
                }
            }

            foreach (int pCol in pivotCols)
            {
                int r = colToPivotRow[pCol];
                int val = M[r, B];
                foreach (int fCol in freeCols)
                {
                    if (M[r, fCol] == 1 && x[fCol] == 1)
                    {
                        val ^= 1;
                    }
                }
                x[pCol] = val;
                if (val == 1) currentPresses++;
            }

            if (currentPresses < minPresses)
            {
                minPresses = currentPresses;
            }
        }

        return minPresses;
    }

    static long SolvePart2(string line)
    {
        var matchTarget = Regex.Match(line, @"\{([\d,]+)\}");
        if (!matchTarget.Success) return 0;
        var targetParts = matchTarget.Groups[1].Value.Split(',').Select(long.Parse).ToArray();
        int L = targetParts.Length;
        double[] b = targetParts.Select(x => (double)x).ToArray();

        var buttonMatches = Regex.Matches(line, @"\(([\d,]+)\)");
        List<double[]> A_cols = new List<double[]>();
        foreach (Match bm in buttonMatches)
        {
            double[] col = new double[L];
            var parts = bm.Groups[1].Value.Split(',');
            foreach (var p in parts)
            {
                if (int.TryParse(p, out int idx))
                {
                    if (idx < L) col[idx] = 1.0;
                }
            }
            A_cols.Add(col);
        }

        int B = A_cols.Count;
        double[,] matrix = new double[L, B + 1];
        for (int r = 0; r < L; r++)
        {
            for (int c = 0; c < B; c++)
            {
                matrix[r, c] = A_cols[c][r];
            }
            matrix[r, B] = b[r];
        }

        int pivotRow = 0;
        List<int> pivotCols = new List<int>();
        int[] colToPivotRow = Enumerable.Repeat(-1, B).ToArray();

        for (int c = 0; c < B && pivotRow < L; c++)
        {
            int sel = -1;
            for (int r = pivotRow; r < L; r++)
            {
                if (Math.Abs(matrix[r, c]) > 1e-9)
                {
                    sel = r;
                    break;
                }
            }

            if (sel == -1) continue;

            for (int k = c; k <= B; k++)
            {
                double temp = matrix[pivotRow, k];
                matrix[pivotRow, k] = matrix[sel, k];
                matrix[sel, k] = temp;
            }

            double pivotVal = matrix[pivotRow, c];
            for (int k = c; k <= B; k++) matrix[pivotRow, k] /= pivotVal;

            for (int r = 0; r < L; r++)
            {
                if (r != pivotRow && Math.Abs(matrix[r, c]) > 1e-9)
                {
                    double factor = matrix[r, c];
                    for (int k = c; k <= B; k++) matrix[r, k] -= factor * matrix[pivotRow, k];
                }
            }

            pivotCols.Add(c);
            colToPivotRow[c] = pivotRow;
            pivotRow++;
        }

        for (int r = pivotRow; r < L; r++)
        {
            if (Math.Abs(matrix[r, B]) > 1e-9) return 0;
        }

        List<int> freeCols = new List<int>();
        for (int c = 0; c < B; c++)
        {
            if (!pivotCols.Contains(c)) freeCols.Add(c);
        }

        long[] UBs = new long[B];
        for (int c = 0; c < B; c++)
        {
            long minUb = long.MaxValue;
            bool bounded = false;
            for (int r = 0; r < L; r++)
            {
                if (A_cols[c][r] > 0.5)
                {
                    long val = (long)(targetParts[r] / A_cols[c][r]);
                    if (val < minUb) minUb = val;
                    bounded = true;
                }
            }
            UBs[c] = bounded ? minUb : 0;
        }

        long minTotalPresses = long.MaxValue;
        bool found = false;

        void Search(int freeIdx, long[] currentFreeVals)
        {
            if (freeIdx == freeCols.Count)
            {
                long currentPresses = 0;
                foreach(var v in currentFreeVals) currentPresses += v;
                
                bool possible = true;
                
                for (int i = 0; i < pivotCols.Count; i++)
                {
                    int pCol = pivotCols[i];
                    int r = colToPivotRow[pCol];
                    double val = matrix[r, B];
                    for (int j = 0; j < freeCols.Count; j++)
                    {
                        int fCol = freeCols[j];
                        val -= matrix[r, fCol] * currentFreeVals[j];
                    }

                    if (val < -1e-9) { possible = false; break; }
                    long longVal = (long)Math.Round(val);
                    if (Math.Abs(val - longVal) > 1e-9) { possible = false; break; }
                    
                    currentPresses += longVal;
                }

                if (possible)
                {
                    if (currentPresses < minTotalPresses)
                    {
                        minTotalPresses = currentPresses;
                        found = true;
                    }
                }
                return;
            }

            int fColIdx = freeCols[freeIdx];
            long limit = UBs[fColIdx];
            
            for (long val = 0; val <= limit; val++)
            {
                currentFreeVals[freeIdx] = val;
                Search(freeIdx + 1, currentFreeVals);
            }
        }

        Search(0, new long[freeCols.Count]);

        return found ? minTotalPresses : 0;
    }
}
