require './lib/grid.rb'

require 'algorithms'
require 'test/unit'
include Test::Unit::Assertions

def main
  input = File.read('./input/20.txt')
  grid = Grid.from_string(input)

  deltas = solve(grid, max_dist: 2, min_delta: 100)
  p deltas.size

  deltas = solve(grid, max_dist: 20, min_delta: 100)
  p deltas.size
end

# map coord => [ empty squares <= max_dist away from coord ]
def cheat_candidates(grid, max_dist: 2)
  empty = Grid.select(grid.size, grid[0].size) { |i, j| grid[i][j] != '#' }
  cheats = {}
  empty.each do |start|
    i, j = start[0..1]
    ends = []
    (-max_dist..max_dist).each do |di|
      dj_lo = -max_dist + di.abs
      dj_hi = max_dist - di.abs
      (dj_lo..dj_hi).each do |dj|
        c = [i + di, j + dj]
        ends << c unless Grid.oob?(grid, c) || grid[c[0]][c[1]] == '#'
      end
    end
    cheats[start] = ends
  end
  cheats
end

# Consider shortest path that contains vertices "s" and "e" and cheats from s-->e.
# The length of that path is:
#   (len of shortest path E-->e) + (len of shortest path S-->s) + dist(s, e)
# which can be found by running Djisktra from S and E.
def solve(grid, max_dist: 2, min_delta: 0)
  start = Grid.find(grid, 'S').first
  targ = Grid.find(grid, 'E').first

  cheats = cheat_candidates(grid, max_dist: max_dist)
  nocheat_dists, = search_with_cheats(grid, [*start, 0])
  nocheat_dist = nocheat_dists[[*targ, 0]]
  fwd_dist, = search_with_cheats(grid, [*start, 0], cheats: cheats)
  rev_dist, = search_with_cheats(grid, [*targ, 0], cheats: cheats)

  deltas = []
  cheats.each do |s, ends|
    ends.each do |e|
      d = fwd_dist[[*s, 0]] + rev_dist[[*e, 0]] + taxicab(e, s)
      delta = nocheat_dist - d
      deltas << delta if delta >= min_delta
    end
  end
  deltas
end

# Djikstra's algorithm AGAIN, but it takes a block argument
# with the current vertex "v" as input and returns
# a list of pairs [u, weight(v, u)], where "u" is adjacent to "v".
def search(start)
  q = Containers::PriorityQueue.new
  q.push(start, 0)
  done = Set.new
  seen = Set.new
  dist = { start => 0 }
  prev = {}

  until q.empty?
    c = q.pop
    d = dist[c]

    nbr_weights = yield(c)
    nbr_weights.reject! { |p| done.include?(p.first) }
    nbr_weights.each do |n, weight|
      new_dist = d + weight
      if dist[n].nil? || new_dist < dist[n]
        dist[n] = new_dist
        prev[n] = c
        q.push(n, -new_dist) unless seen.include?(n)
      end
      seen << n
    end
    done << c
  end
  [dist, prev]
end

def taxicab(c1, c2)
  (c1[0] - c2[0]).abs + (c1[1] - c2[1]).abs
end

# the last component of the vertex == 0 if we haven't
# cheated on this path yet, and 1 otherwise.
def search_with_cheats(grid, start, cheats: nil)
  search(start) do |c|
    cheated = c[2]
    nbrs = Grid.neighbors(grid, c[0..1])
             .reject { |n| grid[n[0]][n[1]] == '#' }
             .map { |n| [*n, cheated] }
    # YOCO (You Only Cheat Once)
    if !cheats.nil? && cheated.zero?
      cheats[c[0..1]].each do |n|
        nbrs << [*n, 1]
      end
    end
    nbrs.map { |n| [n, taxicab(c, n)] }
  end
end

def test
  input = <<~EOS
  ###############
  #...#...#.....#
  #.#.#.#.#.###.#
  #S#...#.#.#...#
  #######.#.#.###
  #######.#.#...#
  #######.#.###.#
  ###..E#...#...#
  ###.#######.###
  #...###...#...#
  #.#####.#.###.#
  #.#...#.#.#...#
  #.#.#.#.#.#.###
  #...#...#...###
  ###############
  EOS
  grid = Grid.from_string(input)
  scores = solve(grid)
  counts = scores.tally
  assert_equal(1, counts[64])
  assert_equal(1, counts[40])
  assert_equal(3, counts[12])
  assert_equal(2, counts[10])

  scores = solve(grid, max_dist: 20, min_delta: 50)
  counts = scores.tally
  assert_equal(3, counts[76])
  assert_equal(4, counts[74])
  assert_equal(22, counts[72])
  assert_equal(12, counts[70])
end

test
main
