require './lib/grid.rb'
require 'algorithms'

def main
  input = File.read('./input/18.txt')
  coords = parse(input)
  puts part1(coords.take(1024))
  puts part2(coords)
end

def parse(input)
  input.each_line.map { |l| l.scan(/\d+/).map(&:to_i) }
end

def part1(coords)
  g = Array.new(71) { Array.new(71) }
  set!(g, coords)
  search(g)
end

def set!(grid, coords)
  Grid.each_index(71, 71) do |i, j|
    grid[i][j] = '.'
  end
  coords.each do |c|
    grid[c[0]][c[1]] = '#'
  end
end

def part2(coords)
  g = Array.new(71) { Array.new(71) }
  lo = 1024
  hi = coords.length

  while hi - lo > 1
    i = (hi + lo) / 2
    set!(g, coords.take(i))
    if search(g).nil?
      hi = i
    else
      lo = i
    end
  end
  coords[hi - 1].join(',')
end

def weight(c)
  (70 - c[0]).abs + (70 - c[1]).abs
end

def search(grid)
  start = [0, 0]
  targ = [70, 70]

  q = Containers::PriorityQueue.new
  q.push(start, 0)

  done = Set.new
  seen = Set.new
  dist = Hash.new
  dist[start] = weight(start)

  until q.length == 0
    c = q.pop
    d = dist[c]
    if c == targ
      return d
    end

    nbrs = Grid.neighbors(grid, c)
             .reject { |n| grid[n[0]][n[1]] == '#' }
             .reject { |n| done.include?(n) }
    nbrs.each do |n|
      new_dist = d + 1 + weight(n) - weight(c)
      if !dist.include?(n) || new_dist < dist[n]
        dist[n] = new_dist
        q.push(n, -new_dist) if !seen.include?(n)
      end
      seen << n
    end
    done << c
  end
end

main
