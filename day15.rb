require './lib/grid.rb'

require 'io/console'
require 'test/unit'
include Test::Unit::Assertions

def main
  input = File.read('./input/15.txt')
  grid, moves = parse(input)
  p part1(grid, moves)

  grid, moves = parse(input)
  big_grid = double(grid)
  p part2(big_grid, moves)
end

def to_dir(move)
  case move
  when '^', 'w'
    Direction::North
  when 'v', 's'
    Direction::South
  when '>', 'd'
    Direction::East
  when '<', 'a'
    Direction::West
  end
end

def parse(input)
  gs, ms = input.split(/\n\n/)
  moves = ms.gsub(/\n/, '').chars.map { |m| to_dir(m) }
  [Grid.from_string(gs), moves]
end

def step!(grid, c, dir)
  nc = Direction.go(dir, c)
  return c if Grid.oob?(grid, nc) || grid[nc[0]][nc[1]] == '#'

  if grid[nc[0]][nc[1]] == '.'
    grid[nc[0]][nc[1]] = '@'
    grid[c[0]][c[1]] = '.'
    return nc
  end

  i, j = nc[0..]
  i, j = Direction.go(dir, [i, j]) while grid[i][j] == 'O'

  if Grid.oob?(grid, [i, j]) || grid[i][j] != '.'
    c
  else
    grid[nc[0]][nc[1]] = '@'
    grid[c[0]][c[1]] = '.'
    grid[i][j] = 'O'
    nc
  end
end

def step1!(grid, c, dir)
  nc = Direction.go(dir, c)
  return c if Grid.oob?(grid, nc) || grid[nc[0]][nc[1]] == '#'

  if grid[nc[0]][nc[1]] == '.'
    # empty space
    grid[nc[0]][nc[1]] = '@'
    grid[c[0]][c[1]] = '.'
    return nc
  end

  other_half = lambda { |coord|
    case grid[coord[0]][coord[1]]
    when ']'
      Direction.go(Direction::West, coord)
    when '['
      Direction.go(Direction::East, coord)
    end
  }

  i, j = nc[0..]

  case dir
  when Direction::East, Direction::West
    i, j = Direction.go(dir, [i, j]) while grid[i][j] == '[' || grid[i][j] == ']'

    return c if Grid.oob?(grid, [i, j]) || grid[i][j] != '.'

    opp = Direction.opp(dir)
    while nc != [i, j]
      ni, nj = Direction.go(opp, [i, j])
      grid[i][j] = grid[ni][nj]
      i, j = ni, nj
    end
    grid[nc[0]][nc[1]] = '@'
    grid[c[0]][c[1]] = '.'

    nc
  when Direction::North, Direction::South
    is_blocked = false
    levels = [[c]]

    loop do
      level = []
      levels.last.each do |b|
        next if b == '.'

        nb = Direction.go(dir, b)
        case grid[nb[0]][nb[1]]
        when '#'
          is_blocked = true
          break
        when '.'
          next
        when ']', '['
          level << nb unless level.include?(nb)
          oh = other_half.call(nb)
          level << oh unless level.include?(oh)
        end
        break if is_blocked
      end

      break if is_blocked || level.all? { |c| grid[c[0]][c[1]] == '.' }

      levels << level unless level.empty?
    end
    return c if is_blocked

    # shift the levels
    until levels.empty?
      level = levels.pop
      level.each do |b|
        nb = Direction.go(dir, b)
        grid[nb[0]][nb[1]] = grid[b[0]][b[1]]
        grid[b[0]][b[1]] = '.'
      end
    end

    nc
  end
end

def double(grid)
  h = grid.length
  w = grid[0].length
  g = Array.new(h) { Array.new(2 * w) }
  Grid.each_index(h, w) do |i, j|
    case grid[i][j]
    when '#', '.'
      g[i][2 * j] = grid[i][j]
      g[i][2 * j + 1] = grid[i][j]
    when '@'
      g[i][2 * j] = '@'
      g[i][2 * j + 1] = '.'
    when 'O'
      g[i][2 * j] = '['
      g[i][2 * j + 1] = ']'
    end
  end
  g
end

def part1(grid, moves)
  c = Grid.find(grid, '@').first
  moves.each do |m|
    c = step!(grid, c, m)
  end

  sum = 0
  h = grid.length
  w = grid[0].length
  Grid.each_index(h, w) do |i, j|
    sum += 100 * i + j if grid[i][j] == 'O'
  end
  sum
end

def part2(grid, moves)
  c = Grid.find(grid, '@').first
  moves.each do |m|
    c = step1!(grid, c, m)
  end

  Grid.pprint(grid)

  sum = 0
  h = grid.length
  w = grid[0].length
  Grid.each_index(h, w) do |i, j|
    sum += 100 * i + j if grid[i][j] == '['
  end
  sum
end

def test
  input = <<~EOS
    ##########
    #..O..O.O#
    #......O.#
    #.OO..O.O#
    #..O@..O.#
    #O#..O...#
    #O..O..O.#
    #.OO.O.OO#
    #....O...#
    ##########

    <vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
    vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
    ><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
    <<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
    ^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
    ^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
    >^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
    <><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
    ^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
    v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
  EOS
  grid, moves = parse(input)
  assert_equal(10092, part1(grid, moves))

  grid, moves = parse(input)
  dgrid = double(grid)

  assert_equal(9021, part2(dgrid, moves))
  interactive(dgrid)
end

def interactive(grid)
  Grid.pprint(grid)

  cur = Grid.find(grid, '@').first
  loop do
    char = $stdin.getch
    exit(1) if char == "\x03"

    move = to_dir(char)
    next if move.nil?

    cur = step1!(grid, cur, move)
    Grid.pprint(grid)
    $stdout.flush
  end
end

test
main
