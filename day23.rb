require 'test/unit'
include Test::Unit::Assertions

def main
  input = File.read('./input/23.txt')
  adj = parse(input)
  puts part1(adj)
  puts part2(adj)
end

def parse(input)
  adj = Hash.new { [] }
  input.each_line do |l|
    u, v = l.gsub(/\n/, '').split('-')
    adj[u] <<= v
    adj[v] <<= u
  end
  adj
end

# State holds sets of vertices during search for maximal cliques
# clique:  vertices in the current clique
# propose: vertices propsed to add to the clique
# exclude: vertices to exclude from the clique
State = Struct.new(:clique, :propose, :exclude)

# Find maximal cliques with backtracking ("Bron-Kerbosch algorithm").
# We recursively add neighbors to a clique until it's maximal.
# We exclude vertices from consideration after finding their maximal clique.
def maximal(adj, state, &block)
  yield state.clique if state.propose.empty? && state.exclude.empty?

  until state.propose.empty?
    v = state.propose.first
    nbrs = adj[v].to_set

    new_state = State.new(
      clique: state.clique + [v],
      propose: state.propose & nbrs,
      exclude: state.exclude & nbrs
    )
    maximal(adj, new_state, &block)

    state.propose.delete(v)
    state.exclude <<= v
  end
end

def part1(adj)
  count = 0
  adj.each do |n, nbrs|
    next unless n.start_with?('t')

    nbrs.combination(2).each do |pair|
      n1, n2 = pair
      next unless adj[n1].include?(n2)

      ts = [n, n1, n2].select { |s| s.start_with?('t') }
      count += 1 if ts.min == n
    end
  end
  count
end

def part2(adj)
  state = State.new(
    clique: Set.new,
    propose: adj.keys.to_set,
    exclude: Set.new
  )

  cliques = []
  maximal(adj, state) do |c|
    cliques << c
  end
  cliques.max_by(&:size).sort.join(',')
end

def test
  input = <<~EOS
    kh-tc
    qp-kh
    de-cg
    ka-co
    yn-aq
    qp-ub
    cg-tb
    vc-aq
    tb-ka
    wh-tc
    yn-cg
    kh-ub
    ta-co
    de-co
    tc-td
    tb-wq
    wh-td
    ta-ka
    td-qp
    aq-cg
    wq-ub
    ub-vc
    de-ta
    wq-aq
    wq-vc
    wh-yn
    ka-de
    kh-ta
    co-tc
    wh-qp
    tb-vc
    td-yn
  EOS
  adj = parse(input)
  assert_equal(7, part1(adj))
  assert_equal('co,de,ka,ta', part2(adj))
end

test
main
