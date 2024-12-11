require "test/unit"
include Test::Unit::Assertions

def main
  input = File.read('./input/10.txt')
  grid = parse(input)
  p part1(grid)
  p part2(grid)
end

def parse(input)
  g = []
  input.each_line do |l|
    g << l.gsub(/\n/,'').chars.map(&:to_i)
  end
  g
end

def find_coords(grid, val)
  out = []
  h = grid.length - 1
  w = grid[0].length - 1
  (0..h).each do |i|
    (0..w).each do |j|
      out << [i, j] if grid[i][j] == val
    end
  end
  out
end

def part1(grid)
  starts = find_coords(grid, 0)
  score = 0
  starts.each do |start|
    prev = bfs(grid, start)
    score += prev.select { |c, _| grid[c[0]][c[1]] == 9}.length
  end
  score
end

def count_paths(prev, start, target)
  if start == target
    1
  else
    prev[start].map { |c| count_paths(prev, c, target)}.sum
  end
end

def bfs(grid, start)
  h = grid.length
  w = grid[0].length
  prev = Hash.new { [] }
  q = [start]

  while !q.empty?
    i, j = q.pop
    nbrs = [[i+1, j], [i-1, j], [i, j+1], [i, j-1]]
             .reject { |n| n[0] >= h || n[0] < 0 || n[1] >= w || n[1] < 0 }
             .select { |n| grid[n[0]][n[1]] == grid[i][j] + 1}
    nbrs.each do |n|
      if !prev[n].include?([i, j])
        prev[n] <<= [i, j]
      end
      q.unshift(n)
    end
  end
  prev
end

# CURSED ARRAY???
# irb> a = [[0] * 2] * 3
# => [[0, 0], [0, 0], [0, 0]]
# irb> a[0][1] = 1
# irb> a
# => [[0, 1], [0, 1], [0, 1]]

def part2(grid)
  starts = find_coords(grid, 0)
  ends = find_coords(grid, 9)
  n_paths = 0
  starts.each do |start|
    prev = bfs(grid, start)
    # count_paths traverses from 9 -> 0
    n_paths += ends.map { |e| count_paths(prev, e, start)}
  end
  n_paths
end

def test
  input = <<~EOS
89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732
EOS
  grid = parse(input)
  assert_equal(36, part1(grid))
  assert_equal(81, part2(grid))
end

test
main
