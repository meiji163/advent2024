require 'test/unit'
include Test::Unit::Assertions

def main
  input = File.read('./input/9.txt')
  used, free = parse(input)
  root = to_linked_list(used, free)
  p part1(used, free)
  p part2(root)
end

ID_FREE = -1
Node = Struct.new(:id, :start, :blocks, :next, :prev)

#   n1--n2   n1   n2
#              \  /
#     n3        n3
def insert_after!(n1, id, start, blocks)
  n3 = Node.new(id: id, start: start, blocks: blocks)
  n2 = n1.next
  n2.prev = n3
  n3.next = n2
  n3.prev = n1
  n1.next = n3
  n3
end

#   n1--node--n3   n1--n3
def delete!(node)
  prev = node.prev
  nxt = node.next
  prev.next = nxt unless prev.nil?
  nxt.prev = prev unless nxt.nil?
  prev
end

def merge_free!(node)
  prev = node.prev
  if !prev.nil? && prev.id == ID_FREE
    node.start = prev.start
    node.blocks += prev.blocks
    delete!(node.prev)
  end

  nxt = node.next
  if !nxt.nil? && nxt.id == ID_FREE
    node.blocks += nxt.blocks
    delete!(nxt)
  end
end

def insert_file!(free, file)
  new = insert_after!(free.prev, file.id, free.start, file.blocks)
  free.blocks -= file.blocks
  free.start += file.blocks
  if free.blocks.zero?
    delete!(free)
  else
    merge_free!(free)
  end
  file.id = ID_FREE
  new
end

def find_free(root, file_id, blocks)
  node = root
  until node.nil?
    return node if node.id == ID_FREE && node.blocks >= blocks

    return nil if node.id == file_id

    node = node.next
  end
end

def to_linked_list(used, free)
  root = Node.new(id: -1)
  n = root
  i = 0
  (0..(used.size - 1)).each do |id|
    next_n = Node.new(id: id, start: i, blocks: used[id])
    next_n.prev = n
    n.next = next_n
    n = next_n
    i += used[id]
    next if free[id].zero?

    free_n = Node.new(id: ID_FREE, start: i, blocks: free[id])
    free_n.prev = n
    n.next = free_n
    n = free_n
    i += free[id]
  end
  root = root.next
  root.prev = nil
  root
end

def parse(input)
  used = []
  free = []
  input.chars.map(&:to_i).each_with_index do |n, i|
    if i.even?
      used << n
    else
      free << n
    end
  end
  free << 0 if free.length < used.length
  [used, free]
end

def part1(used, free)
  hi_id = used.length - 1
  lo_id = 0
  disk = []
  while hi_id > lo_id
    used[lo_id].times do
      disk << lo_id
    end
    while free[lo_id].positive?
      disk << hi_id
      used[hi_id] -= 1
      free[lo_id] -= 1
      hi_id -= 1 if used[hi_id].zero?
    end
    lo_id += 1
  end
  used[lo_id].times do
    disk << lo_id
  end
  disk.each_with_index.map{ |n, idx| n * idx }.sum
end

def checksum(root)
  sum = 0
  i = 0
  n = root
  until n.nil?
    unless n.id == ID_FREE
      sum += n.id * (i..(i + n.blocks - 1)).sum
    end
    i += n.blocks
    n = n.next
  end
  sum
end

def part2(root)
  file = root
  file = file.next until file.next.nil?
  until file.nil?
    if file.id == ID_FREE
      file = file.prev
      next
    end
    free = find_free(root, file.id, file.blocks)
    if free.nil?
      file = file.prev
      next
    end
    insert_file!(free, file)
    file = file.prev
  end
  checksum(root)
end

def test
  input = '2333133121414131402'
  used, free = parse(input)
  root = to_linked_list(used, free)
  assert_equal(1928, part1(used, free))
  assert_equal(2858, part2(root))
end

test
main
