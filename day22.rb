require 'test/unit'
include Test::Unit::Assertions

def main
  input = File.read('./input/22.txt')
  nums = parse(input)
  p part1(nums)
  p part2(nums)
end

def next_num(n)
  m = ((n * 64) ^ n) % 2**24
  m = ((m / 32) ^ m) % 2**24
  ((2048 * m) ^ m) % 2**24
end

def parse(input)
  input.split(/\n/).map(&:to_i)
end

def iter_times(n, arg)
  arr = [arg]
  if block_given?
    n.times do
      arr << yield(arr.last)
    end
  end
  arr
end

def part1(nums)
  nums
    .map { |x| iter_times(2000, x) { |y| next_num(y) } }
    .map(&:last)
    .sum
end

def deltas(seq)
  # this is a dummy value so that
  # deltas[i] corresponds to seq[i]
  deltas = [9999]
  (1..(seq.length - 1)).each do |i|
    deltas << (seq[i] - seq[i - 1])
  end
  deltas
end

# A delta is in [-9..9] for 19 possible values so we can
# represent a sequence of deltas as a base 20 number (the "code").
#
# d1, d2, d3, d4 <---> 20^3(d1+9) + 20^2(d2+9) + 20(d3+9) + (d4+9)
#
# This lets us efficiently compute a rolling code
BASE = 20
MODULUS = BASE**4

def to_code(dels)
  dels.reduce(0) { |sum, n| BASE * sum + (n + 9) }
end

def from_code(code)
  out = []
  while code.positive?
    out << (code % BASE) - 9
    code /= BASE
  end
  out.reverse
end

def tally4(dels, codes, id)
  key = to_code(dels[0..3])
  codes[key] <<= [id, 3]
  (4..(dels.size - 1)).each do |i|
    key = (BASE * key + dels[i] + 9) % MODULUS
    codes[key] <<= [id, i]
  end
  codes
end

def part2(nums)
  seqs = nums.map do |x|
    seq = iter_times(2000, x) { |y| next_num(y) }
    seq.map { |y| y % 10 }
  end
  delta_seqs = seqs.map { |seq| deltas(seq) }

  # code_to_loc[code] is a list of pairs [id, idx]
  # such that delta_seqs[id][(idx-3)..idx] is the
  # delta sequence corresponding to "code"
  code_to_loc = Hash.new { [] }
  delta_seqs.each_with_index do |dels, i|
    tally4(dels, code_to_loc, i)
  end

  # find the max sum over all delta codes.
  max = -1
  max_code = nil
  min_len = 0
  code_to_loc.each do |code, pairs|
    next if pairs.length < min_len

    # sort [id, index] pairs by id asc, index asc
    # then take the first pair for each id, i.e.
    # take the first one that appears in each sequence
    id_idxs = pairs.sort.reduce([]) do |acc, pair|
      if acc.last.nil? || acc.last[0] != pair[0]
        acc.append(pair)
      else
        acc
      end
    end
    sum = id_idxs.map { |pr| seqs[pr[0]][pr[1]] }.sum
    next if sum < max

    max = sum
    max_code = code

    # optimization: the max possible sum is < 9 * n where
    # n = (number of sequences the code appears in)
    # so we can skip any codes with < this number of appearances.
    loop do
      break if 9 * min_len >= max

      min_len += 1
    end
  end
  [from_code(max_code), max]
end

def test
  nums = [1, 10, 100, 2024]
  assert_equal(37327623, part1(nums))

  nums = [1, 2, 3, 2024]
  deltas, max = part2(nums)
  assert_equal([-2, 1, -1, 3], deltas)
  assert_equal(23, max)
end

test
main
