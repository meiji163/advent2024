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
  i = 0
  to_add = []
  len = stones.length
  (0..(len - 1)).each do |i|
    if stones[i] == 0
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

# F[n][m] := number of stones after blinking m times for single stone n.
# We get a recurrence for n < 10 from the sequences:
# [0] > [1]
# [1] > [2024] > [20, 24] > [2, 0, 2, 4]
# [2] > [4048] > [40, 48] > [4, 0, 4, 8]
# [3] > [6072] > [60, 72] > [6, 0, 7, 2]
# [4] > [8096] > [80, 96] > [8, 0, 9, 6]
# [5] > [10120] > [20482880] > [2048, 2880] > [20, 48, 28, 80] > [2, 0, 4, 8, 2, 8, 8, 0]
# [6] > [12144] > [24579456] > [2457, 9456] > [24, 57, 94, 56] > [2, 4, 5, 7, 9, 4, 5, 6]
# [7] > [14168] > [28676032] > [2867, 6032] > [28, 67, 60, 32] > [2, 8, 6, 7, 6, 0, 3, 2]
# [8] > [16192] > [32772608] > [3277, 2608] > [32, 77, 26, 8 ] > [3, 2, 7, 7, 2, 6, 16192]
# [9] > [18216] > [36869184] > [3686, 9184] > [36, 86, 91, 84] > [3, 6, 8, 6, 9, 1, 8, 4]
F = []
def init_table!(size)
  (0..9).each do |n|
    F << [0] * (size + 5)
  end
  (0..9).each do |n|
    F[n][0] = 1
    F[n][1] = 1
  end
  [1,2,3,4].each do |n|
    F[n][2] = 2
  end
  [0,5,6,7,8,9].each do |n|
    F[n][2] = 1
    F[n][3] = 2
    F[n][4] = 4
  end

  (0..size).each do |m|
    F[0][m+1] = F[1][m]
    F[1][m+3] = 2 * F[2][m] + F[0][m] + F[4][m]
    F[2][m+3] = 2 * F[4][m] + F[0][m] + F[8][m]
    F[3][m+3] = F[6][m] + F[0][m] + F[7][m] + F[2][m]
    F[4][m+3] = F[8][m] + F[0][m] + F[9][m] + F[6][m]
    F[5][m+5] = 2 * F[2][m] + 2 * F[0][m] + 3 * F[8][m] + F[4][m]
    F[6][m+5] = F[2][m] + 2 * F[4][m] + 2 * F[5][m] + F[7][m] + F[9][m] + F[6][m]
    F[7][m+5] = 2 * F[2][m] + F[8][m] + 2 * F[6][m] + F[7][m] + F[0][m] + F[3][m]
    F[9][m+5] =  F[3][m] + 2*F[6][m] + 2*F[8][m] + F[9][m] + F[1][m] + F[4][m]
    if m > 0
      F[8][m+4] = F[3][m-1] + 2 * F[2][m-1] + 2 * F[7][m-1] + F[6][m-1] + F[8][m]
    end
  end
end

def part1(stones, m)
  m.times do
    blink!(stones)
  end
  stones.length
end

def part2(stones, m)
  init_table!(75)
  sum = 0
  while m > 0 && !stones.empty?
    small = stones.select{ |n| n < 10 }
    small.each do |n|
      sum += F[n][m]
    end
    stones.reject!{ |n| n < 10 }
    blink!(stones)
    m -= 1
  end
  sum += stones.length
  sum
end

def test
  assert_equal(55312, part1([125, 17], 25))
end

test
main
