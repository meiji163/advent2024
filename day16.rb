require './lib/grid.rb'

require 'test/unit'
include Test::Unit::Assertions

def main
  input = File.read('./input/16.txt')
  grid = Grid.from_string(input)
  p solve(grid)
end

def paths(grid, prev, goal)
  nodes = Set.new
  q = [goal]
  until q.empty?
    c = q.pop
    nodes << [c[0], c[1]]
    prev[c].each { |pc| q << pc }
  end
  nodes
end

def solve(grid)
  h = grid.length
  w = grid[0].length
  start = [h-2, 1, Direction::East]
  goal = [1, w-2]
  scores, prev = search(grid, start)
  goal_key = Direction::All
           .map { |dir| [*goal, dir] }
           .select { |k| scores.include?(k) }
           .min_by { |k| scores[k] }

  score = scores[goal_key]
  visited = paths(grid, prev, goal_key)

  # print solutions
  # visited.each do |c|
  #   grid[c[0]][c[1]] = 'O'
  # end
  # Grid.pprint(grid)
  [score, visited.length]
end

# Djikstra search on grid, but we include the direction.
def search(grid, start)
  done = Set.new
  score = Hash.new
  prev = Hash.new { [] }
  score[start] = 0
  q = [start]

  until q.empty?
    min_idx = q.each_index.min_by { |i| score[q[i]] }
    key = q[min_idx]
    q.delete_at(min_idx)
    i, j, dir = key

    next if done.include?(key)

    this_score = score[key]

    # go in same direction for cost 1
    ni, nj = Direction.go(dir, [i, j])
    next_key = [ni, nj, dir]

    unless done.include?(next_key) || Grid.oob?(grid, [ni, nj]) || grid[ni][nj] == '#'
      next_score = score[next_key]
      if next_score.nil? || this_score + 1 < next_score
        score[next_key] = this_score + 1
        prev[next_key] = [key]
      elsif this_score + 1 == next_score
        prev[next_key] <<= key
      end
      q << next_key
    end

    # turn directions for cost 1000
    [-1, 1].each do |del|
      ndir = (dir + del)%4
      next_key = [i, j, (dir + del)%4]

      # don't turn if we will face a wall
      nc = Direction.go(ndir, [i, j])
      next if grid[nc[0]][nc[1]] == '#'

      next if done.include?(next_key)

      next_score = score[next_key]
      if next_score.nil? || this_score + 1000 < next_score
        score[next_key] = this_score + 1000
        prev[next_key] = [key]
      elsif this_score + 1000 == next_score
        prev[next_key] <<= key
      end
      q << next_key
    end
    done << key
  end
  [score, prev]
end

def test
  input1 = <<~EOS
  ###############
  #.......#....E#
  #.#.###.#.###.#
  #.....#.#...#.#
  #.###.#####.#.#
  #.#.#.......#.#
  #.#.#####.###.#
  #...........#.#
  ###.#.#####.#.#
  #...#.....#.#.#
  #.#.#.###.#.#.#
  #.....#...#.#.#
  #.###.#.#.#.#.#
  #S..#.....#...#
  ###############
  EOS
  grid = Grid.from_string(input1)
  score, tiles = solve(grid)
  assert_equal(7036, score)
  assert_equal(45, tiles)

  input2 = <<~EOS
  #################
  #...#...#...#..E#
  #.#.#.#.#.#.#.#.#
  #.#.#.#...#...#.#
  #.#.#.#.###.#.#.#
  #...#.#.#.....#.#
  #.#.#.#.#.#####.#
  #.#...#.#.#.....#
  #.#.#####.#.###.#
  #.#.#.......#...#
  #.#.###.#####.###
  #.#.#...#.....#.#
  #.#.#.#####.###.#
  #.#.#.........#.#
  #.#.#.#########.#
  #S#.............#
  #################
  EOS
  grid = Grid.from_string(input2)
  score, tiles = solve(grid)
  assert_equal(11048, score)
  assert_equal(64, tiles)
end

test
main
