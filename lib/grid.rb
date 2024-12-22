# lib/grid.rb

module Grid
  class << self
    def oob?(grid, c)
      h = grid.length
      w = grid[0].length
      c[0] >= h || c[0] < 0 || c[1] >= w || c[1] < 0
    end

    def neighbors(grid, c)
      i, j = c
      [[i - 1, 0], [i, j + 1], [i + 1, j], [i, j - 1]]
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
      s.each_line.map { |l| l.gsub(/\n/,'').chars }
    end
  end
end

module Direction
  North = 0
  East  = 1
  South = 2
  West  = 3

  All = [North, East, South, West]

  class << self
    def vec(dir)
      case dir % 4
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

    def rturn(dir)
      (dir + 1) % 4
    end

    def lturn(dir)
      (dir - 1) % 4
    end

    def go(dir, coord)
      v = vec(dir)
      [v[0] + coord[0], v[1] + coord[1]]
    end
  end
end
