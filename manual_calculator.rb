class ManualCalculator
  attr_accessor :statement, :operands, :operators, :tokens, :ast, :result, :debug_mode

  def initialize(statement)
    @statement = statement
    @operands = []
    @operators = []
    @tokens = statement.split
    @debug_mode = debug_mode || false
  end

  def call
    tokens.each_with_index do |current_token, pointer|
      log "Pointer: #{pointer}"
      log "Current token: #{current_token}"

      token_type = case current_token
                   when /[0-9]+/
                     :operand
                   when *Operator::PRECEDENCE
                     :operator
                   end
      log "Token type: #{token_type}"


      if token_type == :operand
        self.operands << current_token
      elsif token_type == :operator
        raise "Syntax error" if pointer == 0 || pointer == tokens.count - 1
        process_operator(current_token)
      else
        raise "Not implemented"
      end

      debug
    end
    make_ast
    debug

    self.result = ast.parse
    log "Result: #{result}"
    result
  end

  def log(msg)
    return unless debug_mode
    STDOUT.puts msg
  end

  def debug
    log "Operands: #{operands}"
    log "Operators: #{operators}"
    log "AST Tree: #{ast.inspect}"
  end

  def process_operator(op)
    if operators.empty?
      self.operators << op
    else
      previous_op = Operator.new(operators.last)
      current_op = Operator.new(op)

      if current_op < previous_op
        make_ast
      end

      log "Push op #{op}"
      self.operators << op
    end
  end

 def make_ast
    log "Make AST"
    while operators.count > 0
      node = ASTNode.new
      node.op = self.operators.pop
      node.right = self.operands.pop
      node.left = self.operands.pop

      self.operands.push(node)
    end
    self.ast = operands.first
  end
end

  # E.g. 1 + 2
  #       op (+)
  #      /  \
  #     /    \
  #    /      \
  # left    right
  #  (1)     (2)
 class ASTNode
  attr_accessor :op, :left, :right

  def parse
    left_val = parse_leaf(left)
    right_val = parse_leaf(right)
    left_val.send(op.to_sym, right_val)
  end

  def parse_leaf(leaf)
    leaf.is_a?(ASTNode) ? leaf.parse : leaf.to_i
  end

  def val
    [op, left.to_s, right.to_s]
  end

  def ==(other)
    to_s == other
  end

  def to_s
    val
  end

  def inspect
    val
  end
end

class Operator
  include Comparable
  attr_reader :op

  PRECEDENCE = ['+', '*'].freeze
  def initialize(o)
    @op = o
  end

  def <=>(other_op)
    PRECEDENCE.index(op) <=> PRECEDENCE.index(other_op.op)
  end

  def inspect
    op
  end
end


