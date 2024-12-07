require 'test/unit'
include Test::Unit::Assertions

def main
  input = File.read('./input/7.txt')
  eqs = parse(input)
  p part1(eqs)
  p part2(eqs)
end

def parse(input)
  out = []
  input.each_line do |l|
    t, rest = l.split(': ')
    ns = rest.split(' ').map(&:to_i)
    out << [t.to_i, ns]
  end
  out
end

def cat(n, m)
  res = n
  n_digits = Math.log10(m + 1).ceil
  res *= 10**n_digits
  res += m
  res
end

def eval_muls(operands, mul_idxs)
  res = operands[0]
  operands[1..].each_with_index do |x, i|
    if mul_idxs.include?(i)
      res *= x
    else
      res += x
    end
  end
  res
end

# satisfiable using +, *
def satisfiable?(target, operands)
  n = operands.length - 1
  idxs = (0..(n - 1)).to_a
  operand_min = operands.min
  (0..n).each do |n_muls|
    results = idxs
              .combination(n_muls)
              .map { |combo| eval_muls(operands, combo) }
    if results.include?(target)
      return true
    elsif operand_min > 1 && results.min > target
      # replacing another + by * can't decrease the result
      # so we can end the search here
      return false
    end
  end
  false
end

# satisfiable using +, *, ||
def satisfiable1?(target, operands)
  n = operands.length - 1
  ops = [0] * n
  (3**n).times do
    res = operands[0]
    ops.each_with_index do |op, i|
      case op
      when 0
        res += operands[i + 1]
      when 1
        res *= operands[i + 1]
      when 2
        res = cat(res, operands[i + 1])
      else
        throw :unknown
      end
    end
    return true if res == target

    next_tuple!(ops, 3)
  end
  false
end

# generate the next base b tuple
def next_tuple!(tuple, b)
  n = tuple.length
  j = n - 1
  while j.positive? && tuple[j] == b - 1
    tuple[j] = 0
    j -= 1
  end
  return if j.negative?

  tuple[j] += 1
end

def part1(eqs)
  sum = 0
  eqs.each do |eq|
    target, operands = eq
    sum += target if satisfiable?(target, operands)
  end
  sum
end

def part2(eqs)
  sum = 0
  eqs.each do |eq|
    target, operands = eq
    sum += target if satisfiable1?(target, operands)
  end
  sum
end

def test
  input = <<~EOS
  190: 10 19
  3267: 81 40 27
  83: 17 5
  156: 15 6
  7290: 6 8 6 15
  161011: 16 10 13
  192: 17 8 14
  21037: 9 7 18 13
  292: 11 6 16 20
  EOS
  eqs = parse(input)
  assert_equal(3749, part1(eqs))
  assert_equal(11_387, part2(eqs))
end

test
main
