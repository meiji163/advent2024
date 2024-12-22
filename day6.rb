require './lib/grid.rb'
require 'test/unit'
include Test::Unit::Assertions

def main
  input = File.read("./input/6.txt")
  grid = Grid.from_string(input)
  p part1(grid)
  p part2(grid)
end

def start(grid)
  Grid.each_index(grid.size, grid[0].size) do |i, j|
    return [i, j] if grid[i][j] == '^'
  end
end

def part1(grid)
  c = start(grid)
  seen = run(grid, c)
  w = grid[0].length - 1
  h = grid.length - 1
  seen.to_a.map { |n|
    z = (n / (w * h))
    n - (z*w*h)
  }
    .uniq
    .length
end

# directions
def run(grid, start)
  w = grid[0].length - 1
  h = grid.length - 1
  c = start[0..1]
  dir = Direction::North
  seen = Set.new
  seen << c[0] + h*(c[1] + w*dir)
  loop do
    i, j = Direction.go(dir, c)
    if i > h or i < 0 or j > w or j < 0
      break
    end

    if grid[i][j] == '#'
      dir = Direction.rturn(dir)
      next
    end
    c[0], c[1] = i, j
    c_num = i + h*(j + w*dir)
    if seen.include?(c_num)
      throw :loop
    end
    seen << c_num
  end
  seen
end

def part2(grid)
  w = grid[0].length - 1
  h = grid.length - 1
  c = start(grid)
  count = 0
  (0..h).each do |i|
    (0..w).each do |j|
      if grid[i][j] != '.'
        next
      end
      grid[i][j] = '#'

      is_loop = true
      catch(:loop) do
        run(grid, c)
        is_loop = false
      end
      if is_loop
        count += 1
      end

      grid[i][j] = '.'
    end
  end
  count
end

def test
  input = <<-EOS
....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
EOS
  grid = Grid.from_string(input)
  assert_equal(41, part1(grid))
  assert_equal(6, part2(grid))
end

test
main
