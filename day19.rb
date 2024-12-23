require 'test/unit'
include Test::Unit::Assertions

def main
  input = File.read('./input/19.txt')
  towels, designs = parse(input)
  p solve(towels, designs)
end

def parse(input)
  s1, s2 = input.split(/\n\n/)
  designs = s2.each_line.map { |l| l.gsub(/\n/,'') }
  [ s1.split(/, /), designs ]
end

def solve(towels, designs)
  cache = Hash.new
  ns = designs.map { |d| possible?(towels, d, cache) }
  n_possible = ns.select(&:positive?).length
  [ n_possible, ns.sum ]
end

def possible?(towels, design, cache)
  return 1 if design.empty?

  return cache[design] if cache.include?(design)

  sum = 0
  towels.each do |t|
    if design.start_with?(t)
      sum += possible?(towels, design[t.size..], cache)
    end
  end
  cache[design] = sum
  sum
end

def test
  input = <<~EOS
  r, wr, b, g, bwu, rb, gb, br

  brwrr
  bggr
  gbbr
  rrbgbr
  ubwu
  bwurrg
  brgr
  bbrgwb
  EOS
  ts, ds = parse(input)
  ans1, ans2 = solve(ts, ds)
  assert_equal(6, ans1)
  assert_equal(16, ans2)
end

test
main
