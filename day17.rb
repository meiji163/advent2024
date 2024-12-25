require 'test/unit'
include Test::Unit::Assertions

def main
  input = File.read('./input/17.txt')
  reg, insts = parse(input)
  out = run!(reg, insts)
  puts out.join(',')
  puts part2(insts)
end

def parse(input)
  s1, s2 = input.split(/\n\n/)
  registers = s1.each_line.flat_map { |l| l.scan(/\d+/).map(&:to_i) }
  ops = s2.scan(/\d/).map(&:to_i)
  [registers, ops]
end

OP_ADV = 0
OP_BXL = 1
OP_BST = 2
OP_JNZ = 3
OP_BXC = 4
OP_OUT = 5
OP_BDV = 6
OP_CDV = 7

def run!(reg, insts, halt_early: false)
  out = []
  i = 0
  while i < insts.length
    op = insts[i]
    arg = insts[i + 1]
    val = case arg
          when 0, 1, 2, 3
            arg
          when 4
            reg[0]
          when 5
            reg[1]
          when 6
            reg[2]
          end

    case op
    when OP_ADV
      reg[0] = reg[0] / (2 ** val)
    when OP_BDV
      reg[1] = reg[0] / (2 ** val)
    when OP_CDV
      reg[2] = reg[0] / (2 ** val)
    when OP_BXL
      reg[1] ^= arg
    when OP_BST
      reg[1] = val % 8
    when OP_JNZ
      if reg[0] != 0
        i = arg
        next
      end
    when OP_BXC
      reg[1] ^= reg[2]
    when OP_OUT
      out << (val % 8)

      return out if halt_early && out != insts[0..(out.size - 1)]
    end
    i += 2
  end
  out
end


# Program: 2,4,1,3,7,5,4,7,0,3,1,5,5,5,3,0
# -------------------------
# B = 0
# C = 0
# LOOP:
# B <- A % 8      # bst 4
# B <- B ^ 3      # bxl 3
# C <- A / 2**B   # cdv 5
# B <- B ^ C      # bxc 7
# A <- A / 2**3   # adv 3
# B <- B ^ 5      # bxl 5
# output(B % 8)   # out 5
# IF A == 0 HALT  # jnz 0
# GOTO LOOP
# -------------------------
#
# output(B % 8) depends only on the lowest 8 bits of A.
# A is then shifted left 3 bits. We recursively search for
# candidate inputs by matching 1st output with lowest 8 bits of A,
# 2nd output with lowest 11 bits of A, etc...
def part2(ops)
  cands = (0..0xff).to_a
  (0..(ops.size - 1)).each do |i|
    new_cands = []
    cands.each do |x|
      (0..7).each do |y|
        a = (y << 3 * i + 8) | x
        r = [a, 0, 0]
        out = run!(r, ops, halt_early: true)
        new_cands << a if out[0..i] == ops[0..i]
      end
    end
    cands = new_cands
  end
  cands.min
end

def test
  input = <<~EOS
  Register A: 729
  Register B: 0
  Register C: 0

  Program: 0,1,5,4,3,0
  EOS
  reg, ops = parse(input)
  out = run!(reg, ops)
  assert_equal('4,6,3,5,6,3,5,2,1,0', out.join(','))
end

test
main
