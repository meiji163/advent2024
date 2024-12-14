
def main
  input = File.read('./input/14.txt')
  robots = parse(input)
  p part1(robots, 101, 103)
  p part2(robots)
end

def parse(input)
  input.each_line.map { |l| l.scan(/-?\d+/).map(&:to_i) }
end

def has_line?(robots, width, height, min=10)
  poss = robots.map{ |r| r[0] + height * r[1] }.to_set

  (0..height).each do |i|
    len = 1
    (0..width).each do |j|
      if poss.include?(i + height * j)
        len += 1
      else
        return true if len > min
        len = 1
      end
    end
  end
  false
end

def print_tiles(robots, width, height)
  pos = robots.map { |r| r[0..1] }
  (0..width).each do |j|
    (0..height).each do |i|
      char = if pos.include?([i, j]) then '^' else '.' end
      print char
    end
    print "\n"
  end
  print "\n"
  $stdout.flush
end

def step!(robot, width, height)
  robot[0] = (robot[0] + robot[2]) % width
  robot[1] = (robot[1] + robot[3]) % height
end

def part1(robots, width, height)
  poss = robots.map do |r|
    [(r[0] + 100 * r[2]) % width,
     (r[1] + 100 * r[3]) % height ]
  end
  x_mid = width / 2
  y_mid = height / 2
  q1 = poss.select { |c| c[0] < x_mid && c[1] < y_mid }
  q2 = poss.select { |c| c[0] > x_mid && c[1] < y_mid }
  q3 = poss.select { |c| c[0] > x_mid && c[1] > y_mid }
  q4 = poss.select { |c| c[0] < x_mid && c[1] > y_mid }
  q1.length * q2.length * q3.length * q4.length
end


def part2(robots)
  width = 101
  height = 103
  max_itrs = width * height
  (1..max_itrs).each do |i|
    robots.each do |r|
      r[0] = (r[0] + r[2]) % width
      r[1] = (r[1] + r[3]) % height
    end
    if has_line?(robots, width, height)
      print_tiles(robots, width, height)
      return i
    end
  end
end

def test
  input = <<~EOS
p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3
EOS
  robots = parse(input)
  part1(robots, 11, 7)
end

test
main
