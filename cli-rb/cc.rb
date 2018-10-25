# command node node
class CNode
  attr_reader :command, :sub_node_hash, :action

  def initialize(command = nil)
    @command = command
    @sub_node_hash = {}
  end

  def get_sub_node(node_command)
    @sub_node_hash[node_command]
  end

  def add_sub_node(sub_node_command)
    @sub_node_hash[sub_node_command] = CNode.new(sub_node_command) unless @sub_node_hash.key?(sub_node_command)
    @sub_node_hash[sub_node_command]
  end

  def add_action(&action)
    @action = action
  end

  def apply_action(arguments)
    @action.call(*arguments)
  end
end

# command tree
class CTree
  def initialize
    @root_node = CNode.new
  end

  def define(node_command, &action)
    if node_command.is_a?(Array)
      sn = @root_node.add_sub_node(node_command.shift)
      sn = sn.add_sub_node(node_command.shift) while node_command.any?
      sn.add_action(&action)
    elsif node_command && !node_command.empty?
      sn = @root_node.add_sub_node(node_command)
      sn.add_action(&action)
    else
      @root_node.add_action(&action)
    end
  end

  def traversal(output = '', indent = ' ', node = @root_node)
    output += indent * 1 + node.command + "\n" if node.command
    while node.sub_node_hash.any?
      _, sn = node.sub_node_hash.shift
      output = traversal(output, indent * 2, sn)
    end
    output
  end

  def exec(inputs)
    call_stack = parse(inputs)
    call_stack.each(&:call)
  end

  private

  def parse(inputs, node = @root_node, call_stack = [])
        
  end
end
