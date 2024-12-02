def main
  file_path = "./input/1.txt"
  arr1 = []
  arr2 = []
  begin
    File.foreach(file_path) do |line|
      a, b = line.split(/\s+/, 2).map{ |s| s.to_i }
      arr1 << a
      arr2 << b
    end
  end
  puts part1(arr1, arr2)
  puts part2(arr1, arr2)
end

def part1(arr1, arr2)
  arr1_s = arr1.sort
  arr2_s = arr2.sort
  dists = arr1_s.zip(arr2_s).map { |a, b| (a-b).abs() }
  dists.sum()
end

def part2(arr1, arr2)
  freqs = arr2.tally
  ans = 0
  arr1.each do |n|
    f = freqs.fetch(n, 0)
    ans += f * n
  end
  ans
end

main
