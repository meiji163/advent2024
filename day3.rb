#!/usr/bin/env ruby

MUL_REGEX = /mul\((?<first>\d{1,3}),(?<second>\d{1,3})\)/

def main
  file_path = "./input/3.txt"
  input = File.read(file_path)
  p eval_muls(input)
  p eval_muls2(input)
end

def eval_muls(s)
  ans = 0
  s.scan(MUL_REGEX).each do |a, b|
    ans += (a.to_i) * (b.to_i)
  end
  ans
end

def eval_muls2(s)
  start = 0
  ans = 0
  loop do
    stop = s.index("don't()", start)
    if stop.nil?
      stop = s.length-1
    end
    ans += eval_muls(s[start..stop])

    start = s.index("do()", stop+7)
    if start.nil?
      break
    end
  end

  ans
end

main
