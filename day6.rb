require "set"
require "test/unit"
include Test::Unit::Assertions

def main
  input = File.read("./input/6.txt")
  grid = parse(input)
  p part1(grid)
  p part2(grid)
end

def parse(s)
  g = []
  s.each_line do |l|
    g << l.gsub(/\n/, '').chars
  end
  g
end

def start(grid)
  grid
    .map{ |row| row.find_index('^') }
    .filter_map.with_index{ |j, i| [i, j] if not j.nil? }
    .first
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
# 0 => [-1, 0]
# 1 => [0, 1]
# 2 => [1, 0]
# 3 => [0, -1]
def run(grid, start)
  w = grid[0].length - 1
  h = grid.length - 1
  c = start[0..1]
  dir = 0
  seen = Set.new
  seen << c[0] + h*(c[1] + w*dir)
  loop do
    i, j = c[0], c[1]
    case dir
    when 0
      i -= 1
    when 1
      j += 1
    when 2
      i += 1
    when 3
      j -= 1
    end
    if i > h or i < 0 or j > w or j < 0
      break
    end

    if grid[i][j] == '#'
      dir = (dir + 1)%4
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
  grid = parse(input)
  assert_equal(41, part1(grid))
  assert_equal(6, part2(grid))
end

test
main
