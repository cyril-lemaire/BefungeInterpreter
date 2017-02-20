def interpret code
  b = Befunge.new(code.split("\n"))
  return b.execute
end

class Befunge
  # Class constants
  DIRECTIONS = {'^' => {l: -1, c: 0}, '>' => {l: 0, c: 1}, 'v' => {l: 1, c: 0}, '<' => {l: 0, c: -1} }
  EVAL_OPS = ['+', '-', '*', '/', '%']
  FUNC_OPS = {
    '!' => :ft_not,
    '`' => :ft_gt,
    '?' => :ft_rnd,
    '_' => :ft_lr,
    '|' => :ft_ud,
    '"' => :ft_str_toggle,
    ':' => :ft_dup,
    '\\' => :ft_swap,
    '$' => :ft_pop,
    '.' => :ft_print_int,
    ',' => :ft_print_char,
    '#' => :ft_skip,
    'p' => :ft_put,
    'g' => :ft_get,
    ' ' => :ft_wait
  }
  
  def initialize codemap
    @map = codemap
    @stack = []
    @pos = {l: 0, c: 0}
    @dir = DIRECTIONS['>']
    @str_mode = false
  end
  
  def execute
    @prompt = ''
    while (instruction = @map[@pos[:l]][@pos[:c]]) != '@'
      if (@str_mode and instruction != '"')
        @stack << instruction.ord
      elsif ('0'..'9').include? instruction
        @stack << instruction.to_i
      elsif DIRECTIONS.include? instruction
        @dir = DIRECTIONS[instruction]
      elsif EVAL_OPS.include? instruction
        b = popstack
        a = popstack
        @stack << eval(a.to_s + instruction + b.to_s)
      elsif FUNC_OPS.include? instruction
        send(FUNC_OPS[instruction])
      end
      move
    end
    @prompt
  end
  
  def popstack
    return @stack.size > 0 ? @stack.pop : 0
  end
  
  def move
    @pos[:l] = (@pos[:l] + @dir[:l]) % @map.size
    @pos[:c] = (@pos[:c] + @dir[:c]) % @map[@pos[:l]].size
  end
  
  def ft_not
    @stack << (popstack == 0 ? 1 : 0)
  end
  
  def ft_gt
    b = popstack
    a = popstack
    @stack << (a > b ? 1 : 0)
  end
  
  def ft_rnd
    @dir = DIRECTIONS[DIRECTIONS.keys.sample]
  end
  
  def ft_lr
    @dir = DIRECTIONS[popstack == 0 ? '>' : '<']
  end
  
  def ft_ud
    @dir = DIRECTIONS[popstack == 0 ? 'v' : '^']
  end
  
  def ft_str_toggle
    @str_mode = !@str_mode
  end
  
  def ft_dup
    @stack << (@stack.size > 0 ? @stack[-1] : 0)
  end
  
  def ft_swap
    b = popstack
    a = popstack
    @stack << b << a
  end
  
  def ft_pop
    popstack
  end
  
  def ft_print_int
    @prompt += popstack.to_s
  end
  
  def ft_print_char
    @prompt += popstack.chr
  end
  
  def ft_skip
    move
  end
  
  def ft_put
    l = popstack
    c = popstack
    v = popstack.chr
    @map[l][c] = v
  end
  
  def ft_get
    l = popstack
    c = popstack
    @stack << ((l < @map.size and c < @map[l].size) ? @map[l][c].ord : 0)
  end
  
  def ft_wait
  end
end
