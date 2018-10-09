# command node group
class CGroup
  attr_reader :command, :cnode

  def initialize(command)
    @command = command
    @sub_group_hash = {}
    @cnode = nil
  end

  def get_group(group_command)
    @sub_group_hash[group_command]
  end

  def add_node(node_command, &node_action)
    @cnode = CNode.new(node_command, node_action)
  end

  def add_sub_group(sub_group_command)
    @sub_group_hash[sub_group_command] = CGroup.new(sub_group_command) unless @sub_group_hash.key?(sub_group_command)
    @sub_group_hash[sub_group_command]
  end
end

# command node
class CNode
  attr_reader :command

  def initialize(command, &action)
    @command = command
    @action = action
  end

  def apply(arguments)
    @action.call(arguments)
  end
end

# command tree
class CTree
  def initialize
    @call_stack = []
    @root_group = CGroup.new('')
  end

  def define(group_commands, node_command, &node_action)
    if group_commands.is_a?(Array)
      g = @root_group.add_sub_group(group_commands.pop)
      g = g.add_sub_group(group_commands.pop) while group_commands.any?
      g.add_node(node_command, node_action)
    elsif group_commands
      g = @root_group.add_sub_group(group_commands)
      g.add_node(node_command, node_action)
    else
      @root_group.add_node(node_command, node_action)
    end
  end

  def parse(inputs)
    next_group = @root_group
    while inputs.any?
        
    end
  end
end
