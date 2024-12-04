require "test/unit"
include Test::Unit::Assertions

def main
  input = File.read("./input/4.txt")
  m = parse(input)
  p part1(m)
  p part2(m)
end

def parse(s)
  m = []
  s.each_line do |l|
    m << l.gsub(/\n/, '').chars
  end
  m
end

def part1(m)
  horizontal(m) + vertical(m) + diag(m) + antidiag(m)
end

def part2(m)
  w = m[0].length - 1
  h = m.length - 1
  count = 0
  (0..(w-2)).each do |j|
    (0..(h-2)).each do |i|
      s1 = m[i][j] + m[i+1][j+1] + m[i+2][j+2]
      s2 = m[i+2][j] + m[i+1][j+1] + m[i][j+2]
      if (s1 == "MAS" or s1 == "SAM") and (s2 == "MAS" or s2 == "SAM")
        count += 1
      end
    end
  end
  count
end

def horizontal(m)
  w = m[0].length - 1
  h = m.length - 1
  count = 0
  (0..h).each do |i|
    (0..(w-3)).each do |j|
      s = m[i][j..(j+3)].join
      if s == "XMAS" or s == "SAMX"
        count += 1
      end
    end
  end
  count
end

def vertical(m)
  horizontal(m.transpose)
end

def diag(m)
  w = m[0].length - 1
  h = m.length - 1
  count = 0
  (0..(w-3)).each do |j|
    (0..(h-3)).each do |i|
      s = m[i][j] + m[i+1][j+1] + m[i+2][j+2] + m[i+3][j+3]
      if s == "XMAS" or s == "SAMX"
        count += 1
      end
    end
  end
  count
end

def antidiag(m)
  diag(m.transpose.map(&:reverse))
end

def test
  s = <<-EOS
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
EOS
  m = parse(s)
  assert_equal(part1(m), 18)
  assert_equal(part2(m), 9)
end

test
main
