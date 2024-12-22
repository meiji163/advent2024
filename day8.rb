require './lib/grid.rb'
require 'test/unit'
include Test::Unit::Assertions

def main
  input = File.read('./input/8.txt')
  grid = Grid.from_string(input)
  p part1(grid)
  p part2(grid)
end

def antenna_pos(grid)
  pos = Hash.new { [] }

  h = grid.length
  w = grid[0].length
  Grid.each_index(h, w) do |i, j|
    c = grid[i][j]
    pos[c] <<= [i,j] if c != '.'
  end
  pos
end

def part1(grid)
  h = grid.length
  w = grid[0].length

  pos = antenna_pos(grid)
  all_nodes = Set.new
  pos.each do |ant, coords|
    nodes = coords
              .combination(2).to_a
              .flat_map { |pair|
      c1, c2 = pair
      dx, dy = c2[0] - c1[0], c2[1] - c1[1]
      [[c1[0] - dx, c1[1] - dy],
       [c2[0] + dx, c2[1] + dy]]
    }.reject { |coord| Grid.oob?(grid, coord) }

    nodes.each do |n|
      all_nodes << n
    end
  end
  all_nodes.length
end

def part2(grid)
  h = grid.length
  w = grid[0].length

  pos = antenna_pos(grid)
  all_nodes = Set.new
  pos.each do |ant, coords|
    pairs = coords.combination(2).to_a
    pairs.each do |pair|
      c1, c2 = pair
      next if all_nodes.include?(c1) && all_nodes.include?(c2)

      dx, dy = c2[0] - c1[0], c2[1] - c1[1]
      i, j = c1[0], c1[1]
      until Grid.oob?(grid, [i, j])
        all_nodes << i + h*j
        i += dx
        j += dy
      end

      i, j = c1[0], c1[1]
      until Grid.oob?(grid, [i, j])
        all_nodes << i + h*j
        i -= dx
        j -= dy
      end
    end
  end
  all_nodes.length
end

def test
  input = <<~EOS
  ............
  ........0...
  .....0......
  .......0....
  ....0.......
  ......A.....
  ............
  ............
  ........A...
  .........A..
  ............
  ............
EOS
  grid = Grid.from_string(input)
  assert_equal(14, part1(grid))
  assert_equal(34, part2(grid))
end

test
main
