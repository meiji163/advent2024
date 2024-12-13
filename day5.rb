require "test/unit"
include Test::Unit::Assertions

def main
  input = File.read("./input/5.txt")
  rules, updates = parse(input)
  puts part1(rules, updates)
  puts part2(rules, updates)
end

def parse(s)
  s1, s2 = s.split(/\n\n/)
  rules = Hash.new{ [] }
  updates = []
  s1.each_line do |l|
    a, b = l.split('|').map(&:to_i)
    rules[a] <<= b
  end
  s2.each_line do |l|
    updates << l.split(',').map(&:to_i)
  end
  return [ rules, updates ]
end

def valid?(rules, pages)
  pages.each_with_index do |p, i|
    rules[p].each do |m|
      seen = i > 0 ? pages[0..(i-1)] : []
      if seen.include?(m)
        return false
      end
    end
  end
  true
end

def sort_pages!(rules, pages)
  passes = 0
  loop do
    modified = sort_pages_pass(rules, pages)
    break unless modified

    passes += 1
  end
  passes
end

def sort_pages_pass(rules, pages)
  modified = false
  i = 0
  while i < pages.length
    seen = i > 0 ? pages[0..(i-1)] : []

    rules[pages[i]].each do |a|
      j = seen.find_index(a)
      next if j.nil?

      pages[i], pages[j] = pages[j], pages[i]
      modified = true
    end
    i += 1
  end
  modified
end

def part1(rules, updates)
  updates.select { |pgs| valid?(rules, pgs) }
    .map { |pgs| pgs[pgs.length / 2] }
    .sum
end

def part2(rules, updates)
  sum = 0
  updates.each do |pages|
    passes = sort_pages!(rules, pages)
    if passes > 0
      sum += pages[pages.length / 2]
    end
  end
  sum
end

def test
  input = <<-EOS
47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47
EOS
  rules, updates = parse(input)
  assert_equal(143, part1(rules, updates))
  assert_equal(123, part2(rules, updates))
end

test
main
