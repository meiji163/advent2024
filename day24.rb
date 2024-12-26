require 'test/unit'
include Test::Unit::Assertions

def main
  input = File.read('./input/24.txt')
  gate, inputs = parse(input)
  puts part1(gate, inputs)

  input = File.read('./input/24.txt')
  circuit, = parse(input)
  puts part2(circuit)
end

Gate = Struct.new(:id, :arg1, :op, :arg2, :out)
Circuit = Struct.new(:gates, :wired_to)
Adder = Struct.new(:id, :gates, :carry_in, :carry_out, :out)

def gate_to_s(gate)
  format('id=%.3d %s %s %s -> %s', gate.id, gate.arg1, gate.op, gate.arg2, gate.out)
end

def adder_to_s(adder)
  format('id=%.2d carry=[%s %s] out=%s gates=%s',
         adder.id, adder.carry_in, adder.carry_out, adder.out, adder.gates)
end

def parse_gates(input)
  input.each_line.with_index.map do |l, id|
    gate = l.gsub(/\n/, '').split(' ')
    arg1 = [gate[0], gate[2]].min
    arg2 = [gate[0], gate[2]].max
    Gate.new(id: id, arg1: arg1, arg2: arg2, op: gate[1], out: gate.last)
  end
end

def parse(input)
  s1, s2 = input.split(/\n\n/)
  gates = parse_gates(s2)
  inputs = s1.each_line.map do |l|
    wire, bit = l.gsub(/\n/, '').split(': ')
    [wire, bit.to_i]
  end
  wired_to = Hash.new { [] }
  gates.each_with_index do |gate, id|
    wired_to[gate.arg1] <<= id
    wired_to[gate.arg2] <<= id
  end
  circuit = Circuit.new(gates: gates, wired_to: wired_to)
  [circuit, inputs]
end

def bool_op(op, arg1, arg2)
  case op
  when 'XOR'
    arg1 ^ arg2
  when 'OR'
    arg1 | arg2
  when 'AND'
    arg1 & arg2
  end
end

def run(circuit, inputs)
  value = {}
  inputs.each do |wire_val|
    wire, val = wire_val
    value[wire] = val
  end
  # keep propagating signals until all wires have values
  done = Set.new
  q = inputs.map(&:first)
  i = 0
  while i < q.length
    wire = q[i]
    circuit.wired_to[wire].each do |id|
      next if done.include?(id)

      bool = value[wire]
      gate = circuit.gates[id]
      wire2 = wire != gate.arg1 ? gate.arg1 : gate.arg2
      next unless value.include?(wire2)

      bool2 = value[wire2]
      value[gate.out] = bool_op(gate.op, bool, bool2)
      i = 0
      done << id
      q.push(gate.out)
    end
    i += 1
  end
  value
end

def part1(circuit, input)
  values = run(circuit, input)
  values
    .select { |k, _| k.start_with?('z') }
    .sort.reverse.map(&:last)
    .join('')
    .to_i(2)
end

class AdderParseError < StandardError
  attr_reader :partial, :type
  def initialize(partial, type, msg = 'Error parsing adder')
    @partial = partial
    @type = type
    super(msg)
  end
end

# A 1-bit adder computes (xn + yn + carry_in) and outputs (out, carry_out).
# We parse the adder starting from the inputs (xn, yn).
#
#              xn  yn
#               v  v
#         ------+  |
#         | ----|--+
#         | |   |  |
# (gate0) AND    XOR (gate1)
#          |      |
#          |  ----|---+-< (carry_in)
#          |  |   |   |
#          |  | --+-- |
#          |  | |   | |
#  (gate2) |  AND   XOR (gate3)
#          |   |     |
#  (gate4) OR---     |
#          |         |
#          V         V
#    (carry_out)  (out)
#
def parse_adder(circuit, n)
  adder = Adder.new(gates: [], id: n)
  x_in = format('x%.2d', n)
  y_in = format('y%.2d', n)
  g01 = circuit.wired_to[x_in] & circuit.wired_to[y_in]
  g0 = g01.select { |i| circuit.gates[i].op == 'AND' }.first
  g1 = g01.select { |i| circuit.gates[i].op == 'XOR' }.first
  raise AdderParseError.new(adder, :gate1) if g1.nil?
  raise AdderParseError.new(adder, :gate0) if g0.nil?

  adder.gates <<= g0
  adder.gates <<= g1
  gate0 = circuit.gates[g0]
  gate1 = circuit.gates[g1]
  g23 = circuit.wired_to[gate1.out]
  g2 = g23.select { |i| circuit.gates[i].op == 'AND' }.first
  g3 = g23.select { |i| circuit.gates[i].op == 'XOR' }.first
  raise AdderParseError.new(adder, :gate2) if g2.nil?
  raise AdderParseError.new(adder, :gate3) if g3.nil?

  adder.gates <<= g2
  adder.gates <<= g3
  gate2 = circuit.gates[g2]
  gate3 = circuit.gates[g3]

  adder.out = circuit.gates[g3].out
  adder.carry_in = gate3.arg1 == gate1.out ? gate3.arg2 : gate3.arg1
  g4 = (circuit.wired_to[gate0.out] &
        circuit.wired_to[gate2.out]).first
  raise AdderParseError.new(adder, :gate4) if g4.nil?

  adder.gates <<= g4
  gate4 = circuit.gates[g4]
  adder.carry_out = gate4.out
  adder
end

def swap_output!(circuit, w1, w2)
  gate1 = circuit.gates.select { |g| g.out == w1 }.first
  gate2 = circuit.gates.select { |g| g.out == w2 }.first
  gate1.out = w2
  gate2.out = w1
end

# The circuit is a 45-bit ripple adder, made by chaining 1-bit adders.
# We try to parse each 1-bit adder and inspect invalid ones to find
# the gates whose outputs are swapped.
def part2(circuit)
  swaps = [%w[z16 hmk],
           %w[z20 fhp],
           %w[tpc rvf],
           %w[z33 fcd]]
  swaps.each do |ww|
    swap_output!(circuit, *ww)
  end

  (1..44).each do |id|
    adder = parse_adder(circuit, id)
    puts adder_to_s(adder)
  rescue AdderParseError => e
    adder = e.partial
    puts "## INVALID ADDER #{id}"
    adder.gates.each_with_index do |g, i|
      gate = circuit.gates[g]
      puts " gate#{i}:  #{gate_to_s(gate)}"
    end
  end
  # binding.irb

  swaps.flatten.sort.join(',')
end

def test
  input = File.read('./input/24-test.txt')
  circuit, inputs = parse(input)
  assert_equal(2024, part1(circuit, inputs))
end

test
main
