require './lib/grid.rb'

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
  Grid.each_index(grid.size, grid[0].size) do |i, j|
    out << [i, j] if grid[i][j] == val
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
  prev = Hash.new { [] }
  q = [start]

  while !q.empty?
    c = q.pop
    nbrs = Grid.neighbors(grid, c)
             .select { |n| grid[n[0]][n[1]] == grid[c[0]][c[1]] + 1}
    nbrs.each do |n|
      prev[n] <<= c unless prev[n].include?(c)
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
    n_paths += ends.map { |e| count_paths(prev, e, start)}.sum
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
