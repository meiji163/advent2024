require 'test/unit'
include Test::Unit::Assertions

def main
  input = File.read('./input/12.txt')
  grid = parse(input)
  p solve(grid)
end

def parse(input)
  input.split(/\n/).map(&:chars)
end

def neighbors(grid, c)
  i, j = c
  val = grid[c[0]][c[1]]
  [[i + 1, j], [i - 1, j], [i, j + 1], [i, j - 1]]
    .reject { |n| n[0] >= grid.size || n[0].negative? || n[1] >= grid[0].size || n[1].negative? }
    .select { |n| grid[n[0]][n[1]] == val }
end

def fill(grid, coord)
  q = [coord]
  vis = Set.new
  perim = Set.new
  until q.empty?
    c = q.pop
    next if vis.include?(c)

    nbrs = neighbors(grid, c)
    nbrs.each do |n|
      q.unshift(n) unless vis.include?(n)
    end
    perim << c if nbrs.length < 4
    vis << c
  end
  [vis, perim]
end

def turn_right(dir)
  case dir
  when [-1, 0]
    [0, 1]
  when [0, 1]
    [1, 0]
  when [1, 0]
    [0, -1]
  when [0, -1]
    [-1, 0]
  end
end

def turn_left(dir)
  case dir
  when [0, 1]
    [-1, 0]
  when [1, 0]
    [0, 1]
  when [0, -1]
    [1, 0]
  when [-1, 0]
    [0, -1]
  end
end

def count_sides(set)
  total = 0
  done = Set.new
  max_i = set.map(&:first).max
  min_i = set.map(&:first).min
  max_j = set.map(&:last).max

  # scan the whole set to ensure we traverse every
  # component of the boundary
  (min_i..max_i).each do |i|
    j = max_j + 1
    while j >= -1
      if done.include?([i, j]) || set.include?([i, j])
        j -= 1
        next
      end
      if set.include?([i, j - 1])
        # boundary to the right of the set
        bdry, sides = traverse_boundary(set, [i, j], [1, 0])
        total += sides
        done.merge(bdry)
      elsif set.include?([i, j + 1])
        # boundary to the left of the set
        bdry, sides = traverse_boundary(set, [i, j], [-1, 0])
        total += sides
        done.merge(bdry)
      end
      j -= 1
    end
  end
  total
end

# Traverse around the boundary of the set starting at c.
# The dir must be chosen so that the count-clockwise perpendicular
# vector points outward from the set e.g.
#   ...        ↑...
#   ...c→     ←c...
#   ...↓        ...
def traverse_boundary(set, c, dir)
  i, j = c
  perp = turn_left(dir)
  start = [i, j]
  start_dir = [dir[0], dir[1]]
  seen = Set.new
  sides = 0
  loop do
    ni = i + dir[0]
    nj = j + dir[1]
    seen << [i, j]
    if set.include?([ni, nj])
      # turn left
      dir = turn_left(dir)
      perp = turn_left(perp)
      sides += 1
    elsif set.include?([ni - perp[0], nj - perp[1]])
      # go straight
      i = ni
      j = nj
    else
      # turn right
      i = ni - perp[0]
      j = nj - perp[1]
      dir = turn_right(dir)
      perp = turn_right(perp)
      sides += 1
    end
    break if start == [i, j] && dir == start_dir
  end
  [seen, sides]
end

def solve(grid)
  h = grid.length
  w = grid[0].length
  done = []
  h.times do
    done << [false] * w
  end

  ans1 = 0
  ans2 = 0
  (0..(h - 1)).each do |i|
    (0..(w - 1)).each do |j|
      next if done[i][j]

      vis, perim = fill(grid, [i, j])
      perim_len = perim.map { |c| 4 - neighbors(grid, c).length }.sum
      sides = count_sides(vis)
      ans1 += perim_len * vis.length
      ans2 += sides * vis.length

      vis.each do |c|
        done[c[0]][c[1]] = true
      end
    end
  end
  [ans1, ans2]
end

def test
  input1 = <<~EOS
  RRRRIICCFF
  RRRRIICCCF
  VVRRRCCFFF
  VVRCCCJFFF
  VVVVCJJCFE
  VVIVCCJJEE
  VVIIICJJEE
  MIIIIIJJEE
  MIIISIJEEE
  MMMISSJEEE
EOS
  grid = parse(input1)
  p1, p2 = solve(grid)
  assert_equal(1930, p1)
  assert_equal(1206, p2)

  input2 = <<~EOS
  AAAAAA
  AAABBA
  AAABBA
  ABBAAA
  ABBAAA
  AAAAAA
EOS
  grid = parse(input2)
  _, p2 = solve(grid)
  assert_equal(368, p2)
end

test
main
