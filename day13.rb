require "test/unit"
include Test::Unit::Assertions

def main
  input = File.read('input/13.txt')
  machines = parse(input)
  p part1(machines)
  p part2(machines)

end

def parse(input)
  machines = []
  blocks = input.split(/\n\n/)
  blocks.each do |block|
    machines << block.scan(/\d+/).map(&:to_i).to_a
  end
  machines
end

def part1(machines)
  machines.map { |m| solve1(m) }
    .reject(&:nil?)
    .map { |xy| 3 * xy.first + xy.last }
    .sum
end

def solve1(machine)
  a1, b1, a2, b2, t1, t2 = machine
  (0..100).each do |x|
    (0..100).each do |y|
      if a1 * x + a2 * y == t1 &&
         b1 * x + b2 * y == t2
        return [x, y]
      end
    end
  end
  nil
end

def solve2(machine)
  a1, b1, a2, b2, t1, t2 = machine
  det = a1 * b2 - b1 * a2
  if det != 0
    inv = [[b2, -a2], [-b1, a1]]
    vx = t1 * inv[0][0] + t2 * inv[0][1]
    vy = t1 * inv[1][0] + t2 * inv[1][1]
    if vx % det == 0 && vy % det == 0
      [vx / det, vy / det]
    else
      nil
    end
  else
    # not handling rank 1
    raise
  end
end

def part2(machines)
  ans = 0
  machines.each do |m|
    m[4] += 10000000000000
    m[5] += 10000000000000
  end
  machines.map { |m| solve2(m) }
    .reject(&:nil?)
    .map { |xy| 3 * xy.first + xy.last }
    .sum
end

def test
  input = <<~EOS
Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279
EOS
  machines = parse(input)
  assert_equal(480, part1(machines))
end

test
main
