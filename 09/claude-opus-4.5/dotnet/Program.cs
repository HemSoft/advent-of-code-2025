var lines = File.ReadAllLines("input.txt").Where(l => !string.IsNullOrWhiteSpace(l)).ToArray();

var tiles = lines.Select(line =>
{
    var parts = line.Split(',');
    return (x: long.Parse(parts[0]), y: long.Parse(parts[1]));
}).ToList();

// Part 1: Find largest rectangle with two red tiles as opposite corners
long maxArea = 0;

for (int i = 0; i < tiles.Count; i++)
{
    for (int j = i + 1; j < tiles.Count; j++)
    {
        long width = Math.Abs(tiles[j].x - tiles[i].x) + 1;
        long height = Math.Abs(tiles[j].y - tiles[i].y) + 1;
        long area = width * height;
        if (area > maxArea)
            maxArea = area;
    }
}

Console.WriteLine($"Day 09 Part 1: {maxArea}");

// Part 2: Find largest rectangle using only red and green tiles
// The polygon is formed by red tiles connected by straight green lines
// A rectangle is valid if all 4 of its corners are inside or on the boundary

// Build polygon edges
var edges = new List<((long x, long y) p1, (long x, long y) p2)>();
for (int i = 0; i < tiles.Count; i++)
{
    var curr = tiles[i];
    var next = tiles[(i + 1) % tiles.Count];
    edges.Add((curr, next));
}

// For a rectangle with red corners at (x1,y1) and (x2,y2), all 4 corners must be valid
// A point is valid if it's inside the polygon OR on an edge
long maxArea2 = 0;

for (int i = 0; i < tiles.Count; i++)
{
    for (int j = i + 1; j < tiles.Count; j++)
    {
        var t1 = tiles[i];
        var t2 = tiles[j];
        
        long minX = Math.Min(t1.x, t2.x);
        long maxX = Math.Max(t1.x, t2.x);
        long minY = Math.Min(t1.y, t2.y);
        long maxY = Math.Max(t1.y, t2.y);
        
        // The 4 corners
        var corners = new[] { (minX, minY), (minX, maxY), (maxX, minY), (maxX, maxY) };
        
        // Check all 4 corners are valid (inside or on boundary)
        bool allValid = corners.All(c => IsValidPoint(c.Item1, c.Item2, edges, tiles));
        
        // Also need to check the 4 edges of the rectangle stay within valid region
        if (allValid)
        {
            allValid = IsRectangleValid(minX, maxX, minY, maxY, edges, tiles);
        }
        
        if (allValid)
        {
            long area = (maxX - minX + 1) * (maxY - minY + 1);
            if (area > maxArea2)
                maxArea2 = area;
        }
    }
}

Console.WriteLine($"Day 09 Part 2: {maxArea2}");

static bool IsValidPoint(long px, long py, List<((long x, long y) p1, (long x, long y) p2)> edges, List<(long x, long y)> redTiles)
{
    // Check if on a red tile
    if (redTiles.Contains((px, py))) return true;
    
    // Check if on an edge (green tile on boundary)
    foreach (var (p1, p2) in edges)
    {
        if (IsOnSegment(px, py, p1.x, p1.y, p2.x, p2.y))
            return true;
    }
    
    // Check if inside polygon
    return IsInsidePolygon(px, py, edges);
}

static bool IsOnSegment(long px, long py, long x1, long y1, long x2, long y2)
{
    // Check if point (px,py) is on segment from (x1,y1) to (x2,y2)
    if (x1 == x2) // vertical
    {
        return px == x1 && py >= Math.Min(y1, y2) && py <= Math.Max(y1, y2);
    }
    if (y1 == y2) // horizontal
    {
        return py == y1 && px >= Math.Min(x1, x2) && px <= Math.Max(x1, x2);
    }
    return false; // diagonal segments not expected per problem
}

static bool IsInsidePolygon(long px, long py, List<((long x, long y) p1, (long x, long y) p2)> edges)
{
    int crossings = 0;
    foreach (var (p1, p2) in edges)
    {
        long y1 = p1.y, y2 = p2.y;
        long x1 = p1.x, x2 = p2.x;
        
        if ((y1 <= py && y2 > py) || (y2 <= py && y1 > py))
        {
            double xIntersect = x1 + (double)(py - y1) / (y2 - y1) * (x2 - x1);
            if (px < xIntersect)
                crossings++;
        }
    }
    return crossings % 2 == 1;
}

static bool IsRectangleValid(long minX, long maxX, long minY, long maxY, 
    List<((long x, long y) p1, (long x, long y) p2)> edges, List<(long x, long y)> redTiles)
{
    // Check all 4 edges of rectangle don't cross outside the polygon
    // Each edge of the rectangle must either be entirely inside or on the boundary
    
    // We check by sampling points along each edge and ensuring they're valid
    // But for large coordinates, we need a smarter approach
    
    // Actually, we check if any polygon edge crosses into our rectangle in a way
    // that would exclude some interior points
    
    // Simpler approach: check if the rectangle edges cross any polygon edge 
    // that would put part of the rectangle outside
    
    // For now, verify corners are inside/on-boundary and no polygon edge
    // enters the rectangle interior from outside
    
    foreach (var (p1, p2) in edges)
    {
        // Check if this polygon edge passes through our rectangle
        // If it does, it might exclude some points
        
        // A polygon edge going through our rectangle is ok if it's either:
        // 1. Entirely within our rectangle (meaning our rectangle contains this path)
        // 2. Only touching the boundary
        
        // If the edge crosses the interior from one external side to another, that's bad
        if (EdgeCrossesRectangleInterior(p1.x, p1.y, p2.x, p2.y, minX, maxX, minY, maxY))
            return false;
    }
    
    return true;
}

static bool EdgeCrossesRectangleInterior(long x1, long y1, long x2, long y2, 
    long minX, long maxX, long minY, long maxY)
{
    // Check if the line segment from (x1,y1) to (x2,y2) crosses through 
    // the rectangle's interior (meaning some part of rectangle is excluded)
    
    // The edge is part of the polygon boundary. If this edge cuts through
    // our rectangle, it means some portion of the rectangle is outside the polygon.
    
    // We need to check if the edge intersects any of the 4 edges of the rectangle
    // (other than at the rectangle's corners which are already validated)
    
    // If both endpoints are inside or on the rectangle boundary, that's fine
    bool p1Inside = x1 >= minX && x1 <= maxX && y1 >= minY && y1 <= maxY;
    bool p2Inside = x2 >= minX && x2 <= maxX && y2 >= minY && y2 <= maxY;
    
    if (p1Inside && p2Inside) return false;
    
    // Check for intersection with rectangle edges
    // Top edge (minY)
    if (SegmentsIntersect(x1, y1, x2, y2, minX, minY, maxX, minY))
    {
        // Find intersection point
        var intersect = GetIntersection(x1, y1, x2, y2, minX, minY, maxX, minY);
        if (intersect.HasValue && intersect.Value.x > minX && intersect.Value.x < maxX)
            return true;
    }
    // Bottom edge (maxY)  
    if (SegmentsIntersect(x1, y1, x2, y2, minX, maxY, maxX, maxY))
    {
        var intersect = GetIntersection(x1, y1, x2, y2, minX, maxY, maxX, maxY);
        if (intersect.HasValue && intersect.Value.x > minX && intersect.Value.x < maxX)
            return true;
    }
    // Left edge (minX)
    if (SegmentsIntersect(x1, y1, x2, y2, minX, minY, minX, maxY))
    {
        var intersect = GetIntersection(x1, y1, x2, y2, minX, minY, minX, maxY);
        if (intersect.HasValue && intersect.Value.y > minY && intersect.Value.y < maxY)
            return true;
    }
    // Right edge (maxX)
    if (SegmentsIntersect(x1, y1, x2, y2, maxX, minY, maxX, maxY))
    {
        var intersect = GetIntersection(x1, y1, x2, y2, maxX, minY, maxX, maxY);
        if (intersect.HasValue && intersect.Value.y > minY && intersect.Value.y < maxY)
            return true;
    }
    
    return false;
}

static bool SegmentsIntersect(long ax1, long ay1, long ax2, long ay2, 
    long bx1, long by1, long bx2, long by2)
{
    // Check if segments A and B intersect
    double d1 = Direction(bx1, by1, bx2, by2, ax1, ay1);
    double d2 = Direction(bx1, by1, bx2, by2, ax2, ay2);
    double d3 = Direction(ax1, ay1, ax2, ay2, bx1, by1);
    double d4 = Direction(ax1, ay1, ax2, ay2, bx2, by2);
    
    if (((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
        ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0)))
        return true;
    
    return false;
}

static double Direction(long x1, long y1, long x2, long y2, long x3, long y3)
{
    return (double)(x3 - x1) * (y2 - y1) - (double)(x2 - x1) * (y3 - y1);
}

static (double x, double y)? GetIntersection(long ax1, long ay1, long ax2, long ay2,
    long bx1, long by1, long bx2, long by2)
{
    double d = (double)(ax2 - ax1) * (by2 - by1) - (double)(ay2 - ay1) * (bx2 - bx1);
    if (Math.Abs(d) < 1e-10) return null;
    
    double t = ((double)(bx1 - ax1) * (by2 - by1) - (double)(by1 - ay1) * (bx2 - bx1)) / d;
    
    return (ax1 + t * (ax2 - ax1), ay1 + t * (ay2 - ay1));
}