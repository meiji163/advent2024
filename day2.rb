#!/usr/bin/env ruby

def main
  file_path = "./input/2.txt"
  reports = []
  begin
    File.foreach(file_path) do |line|
      reports << line.split(" ").map { |s| s.to_i }
    end
  end
  p reports.count { |r| is_safe(r) }
  p reports.count { |r| is_safe(r, tolerance: true) }
end

def del_at(arr, idx)
  new = arr.clone
  new.delete_at(idx)
  new
end

def is_safe(report, tolerance: false)
  if report.length() < 2
    return true
  end
  is_inc = report[1] > report[0]
  idx = 0
  report.each_cons(2) do |a, b|
    d = b-a
    if (d.abs() > 3) or (d.abs() < 1) or ((d>0) != is_inc)
      break
    end
    idx += 1
  end

  if idx == report.length() - 1
    true
  elsif not tolerance
    false
  else
    is_safe(del_at(report, idx-1)) or
    is_safe(del_at(report, idx)) or
    is_safe(del_at(report, idx+1))
  end
end

main
