'''
A k x k magic square is a k x k grid filled with integers such that every row sum, every column sum, and both diagonal sums are all equal. The integers in the magic square do not have to be distinct. Every 1 x 1 grid is trivially a magic square.

Given an m x n integer grid, return the size (i.e., the side length k) of the largest magic square that can be found within this grid.

 

Example 1:


Input: grid = [[7,1,4,5,6],[2,5,1,6,4],[1,5,4,3,2],[1,2,7,3,4]]
Output: 3
Explanation: The largest magic square has a size of 3.
Every row sum, column sum, and diagonal sum of this magic square is equal to 12.
- Row sums: 5+1+6 = 5+4+3 = 2+7+3 = 12
- Column sums: 5+5+2 = 1+4+7 = 6+3+3 = 12
- Diagonal sums: 5+4+3 = 6+4+2 = 12
Example 2:


Input: grid = [[5,1,3,1],[9,3,3,1],[1,3,3,8]]
Output: 2
 

Constraints:

m == grid.length
n == grid[i].length
1 <= m, n <= 50
1 <= grid[i][j] <= 106



'''



from typing import List

class Solution:
    def largestMagicSquare(self, grid: List[List[int]]) -> int:
        m, n = len(grid), len(grid[0])

        # Precompute prefix sums for rows and columns
        row_prefix = [[0] * (n + 1) for _ in range(m)]
        col_prefix = [[0] * (m + 1) for _ in range(n)]

        for i in range(m):
            for j in range(n):
                row_prefix[i][j + 1] = row_prefix[i][j] + grid[i][j]
                col_prefix[j][i + 1] = col_prefix[j][i] + grid[i][j]

        def check(i: int, j: int, k: int) -> bool:
            target = None
            # Check rows
            for r in range(i, i + k):
                s = row_prefix[r][j + k] - row_prefix[r][j]
                if target is None:
                    target = s
                elif target != s:
                    return False
            # Check columns
            for c in range(j, j + k):
                s = col_prefix[c][i + k] - col_prefix[c][i]
                if target != s:
                    return False
            # Check diagonals
            d1 = sum(grid[i + x][j + x] for x in range(k))
            d2 = sum(grid[i + x][j + k - 1 - x] for x in range(k))
            return target == d1 == d2

        # Try sizes from largest to smallest
        for size in range(min(m, n), 1, -1):
            for i in range(m - size + 1):
                for j in range(n - size + 1):
                    if check(i, j, size):
                        return size
        return 1
