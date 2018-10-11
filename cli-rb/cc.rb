# command node group
class CGroup
  attr_reader :command, :cnode

  def initialize(command)
    @command = command
    @sub_group_hash = {}
    @cnode = nil
  end

  def get_sub_group(group_command)
    @sub_group_hash[group_command]
  end

  def add_node(node_command, &node_action)
    @cnode = CNode.new(node_command, &node_action)
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
    @action.call(*arguments)
  end
end

# command tree
class CTree
  def initialize
    @root_group = CGroup.new('')
  end

  def define(group_commands, node_command, &node_action)
    if group_commands.is_a?(Array)
      sg = @root_group.add_sub_group(group_commands.pop)
      sg = sg.add_sub_group(group_commands.pop) while group_commands.any?
      sg.add_node(node_command, &node_action)
    elsif group_commands && !group_commands.empty?
      sg = @root_group.add_sub_group(group_commands)
      sg.add_node(node_command, &node_action)
    else
      @root_group.add_node(node_command, &node_action)
    end
  end

  def exec(inputs)
    call_stack = parse(inputs)
    call_stack.each(&:call)
  end

  private

  def parse(inputs, pg = @root_group, call_stack = [])
    if inputs.empty?
      call_stack << proc { pg.cnode.apply } if pg.cnode
      return call_stack
    end

    sg = pg.get_sub_group(inputs.first)
    arguments = [] << inputs.pop while inputs.any? && !pg.get_sub_group(inputs.first)

    # found sub group, continue searching node
    if sg
      inputs.pop
      parse(arguments, sg, call_stack)
    end

    # not found sub group, invoking node of current group
    call_stack << proc { pg.cnode.apply(arguments) } if pg.cnode
    parse(inputs, pg, call_stack) if inputs.any?

    call_stack
  end
end
