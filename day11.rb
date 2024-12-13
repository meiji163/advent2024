require "test/unit"
include Test::Unit::Assertions

def main
  input = File.read('./input/11.txt')
  stones = parse(input)
  p part1(stones, 25)

  stones = parse(input)
  p part2(stones, 75)
end

def parse(input)
  input.split(' ').map(&:to_i)
end

def digits_to_num(dig)
  out = 0
  dig.reverse.each do |d|
    out *= 10
    out += d
  end
  out
end

def blink!(stones)
  len = stones.length
  (0..(len - 1)).each do |i|
    if stones[i].zero?
      stones[i] = 1
      next
    end
    digs = stones[i].digits
    if digs.length.even?
      l = (digs.length/2) - 1
      n1 = digits_to_num(digs[0..l])
      n2 = digits_to_num(digs[(l+1)..])
      stones[i] = n1
      stones << n2
    else
      stones[i] *= 2024
    end
  end
  stones
end

MULTIPLIER = 2024
$cache = {}
def count(n, m)
  return 1 if m.zero?

  return $cache[[n, m]] if $cache.key?([n, m])

  return count(1, m - 1) if n.zero?

  digs = n.digits
  out = if digs.length.even?
    l = (digs.length / 2) - 1
    n1 = digits_to_num(digs[0..l])
    n2 = digits_to_num(digs[(l + 1)..])
    count(n1, m - 1) + count(n2, m - 1)
  else
    count(MULTIPLIER * n, m - 1)
  end
  $cache[[n, m]] = out
  out
end

def part1(stones, m)
  m.times do
    blink!(stones)
  end
  stones.length
end

def part2(stones, m)
  stones.map { |n| count(n, m) }.sum
end

def test
  assert_equal(55312, part1([125, 17], 25))
end

# We see the ratio of the sequence converges to
# 1.518925 +/- 4e-6
#
# (0..1000).each do |n|
#   puts "#{n}\t#{ratios(n)}"
# end
def ratios(n)
  tol = 0.000001
  ratios = []
  vars = []
  (10..1600).each do |m|
    ratios << count(n, m + 1).to_f / count(n, m)
    next if ratios.length < 2

    var = (ratios[-1] - ratios[-2]).abs / ratios[-2].to_f
    break if !vars.empty? && vars[-1] < tol && var < tol

    vars << var
  end
  ratios[-1]
end

test
main
