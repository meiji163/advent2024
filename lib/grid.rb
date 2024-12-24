# lib/grid.rb

module Grid
  class << self
    def oob?(grid, c)
      h = grid.length
      w = grid[0].length
      c[0] >= h || c[0] < 0 || c[1] >= w || c[1] < 0
    end

    def neighbors(grid, c)
      i, j = c[0], c[1]
      [[i - 1, j], [i, j + 1], [i + 1, j], [i, j - 1]]
        .reject { |n| oob?(grid, n) }
    end

    def each_index(height, width)
      if block_given?
        (0..(height - 1)).each do |i|
          (0..(width - 1)).each do |j|
            yield(i, j)
          end
        end
      end
    end

    def find(grid, val)
      h = grid.size
      w = grid[0].size
      out = []
      (0..(h - 1)).each do |i|
        (0..(w - 1)).each do |j|
          out << [i, j] if grid[i][j] == val
        end
      end
      out
    end

    def select(height, width)
      out = []
      (0..(height - 1)).each do |i|
        (0..(width - 1)).each do |j|
          out << [i, j] if yield(i, j)
        end
      end
      out
    end

    def pprint(grid)
      grid.each do |row|
        print row.join('')
        print "\n"
      end
      print "\n"
      $stdout.flush
    end

    def from_string(s)
      s.each_line.map { |l| l.gsub(/\n/, '').chars }
    end
  end
end

module Direction
  North = 0
  East  = 1
  South = 2
  West  = 3

  All = [North, East, South, West].freeze

  class << self
    def vec(dir)
      case (dir % 4)
      when North
        [-1, 0]
      when East
        [0, 1]
      when South
        [1, 0]
      when West
        [0, -1]
      end
    end

    def sub(dir1, dir2)
      out = (dir1 - dir2) % 4
      if out < 3
        out
      else
        4 - out
      end
    end

    def opp(dir)
      4 - dir
    end

    def rturn(dir)
      (dir + 1) % 4
    end

    def lturn(dir)
      (dir - 1) % 4
    end

    def go(dir, coord, steps: 1)
      v = vec(dir)
      [coord[0] + steps * v[0], coord[1] + steps * v[1]]
    end

    def string(dir)
      case (dir % 4)
      when 0
        "North"
      when 1
        "East"
      when 2
        "South"
      when 3
        "West"
      end
    end
  end
end
