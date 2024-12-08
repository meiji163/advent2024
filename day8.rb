require 'test/unit'
include Test::Unit::Assertions

def main
  input = File.read('./input/8.txt')
  grid = parse(input)
  p part1(grid)
  p part2(grid)
end

def parse(input)
  g = []
  input.each_line do |l|
    g << l.gsub(/\n/,'').chars
  end
  g
end

def antenna_pos(grid)
  pos = Hash.new { [] }
  h = grid.length
  w = grid[0].length
  pos = Hash.new { [] }

  (0..(h - 1)).each do |i|
    (0..(w - 1)).each do |j|
      c = grid[i][j]
      if c != '.'
        pos[c] <<= [i,j]
      end
    end
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
    }
              .filter { |coord|
      i, j = coord
      i < h && j < w && i >= 0 && j >= 0
    }
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
      if all_nodes.include?(c1) && all_nodes.include?(c2)
        next
      end
      dx, dy = c2[0] - c1[0], c2[1] - c1[1]
      i, j = c1[0], c1[1]
      while (i < h && j < w && i >= 0 && j >= 0)
        all_nodes << i + h*j
        i += dx
        j += dy
      end

      i, j = c1[0], c1[1]
      while (i < h && j < w && i >= 0 && j >= 0)
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
  grid = parse(input)
  assert_equal(14, part1(grid))
  assert_equal(34, part2(grid))
end

test
main
