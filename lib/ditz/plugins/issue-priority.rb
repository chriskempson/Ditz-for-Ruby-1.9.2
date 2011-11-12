## issue-priority ditz plugin
## 
## This plugin allows issues to have priorities. Priorities are numbers
## P1-P5 where P1 is the highest priority and P5 is the lowest. Internally
## the priorities are sorted lexicographically.
##
## Commands added:
##   ditz set-priority <issue> <priority>: Set the priority of an issue
##
## Usage:
##   1. add a line "- issue-priority" to the .ditz-plugins file in the project
##      root
##   2. use the above commands to abandon


module Ditz

class Issue
  class << self
    def get_allowed_priorities
      return ["P1", "P2", "P3", "P4", "P5"]
    end
  end 

  field :priority, :multi => false, :default => "P3", :prompt => "Specify a priority (#{Issue.get_allowed_priorities * ","})"

  def priority=(priority)
    if !Issue.get_allowed_priorities.include? priority
      raise Error, "Priority #{priority} is not in the list of allowed priorities (#{Issue.get_allowed_priorities * ","})"
    end
    # Note that note setting @priority because I've overriden the 
    # assignment method for priority to do validation of the values.
    # This requires me to copy the code from the generic definition of 
    # #{name}= from model.rb. If someone knows of a better way to do this,
    # please change it.
    changed!
    @serialized_values.delete :priority
    @values[:priority] = priority
  end

  def set_priority new_priority, who, comment
    self.priority = new_priority
    if priority != new_priority
      # error setting priority
      return
    end
    log "set issue priority", who, comment
  end

  def sort_order
    if priority.nil?
      # make very low priority 
      ["P9", STATUS_SORT_ORDER[status], creation_time] 
    else
      [priority, STATUS_SORT_ORDER[status], creation_time] 
    end
  end

end

class ScreenView
  add_to_view :issue_summary do |issue, config|
    "   Priority: #{issue.priority}\n"
  end
end

class HtmlView
  add_to_view :issue_summary do |issue, config|
    next if issue.priority.nil?
    [<<EOS, { :issue => issue }]
<tr>
  <td class='attrname'>Priority:</td>
  <td class='attrval'><%= h(issue.priority) %></td>
</tr>
EOS
  end
end

class Operator

  operation :set_priority, "Set priority of an issue", :issue, :priority
  def set_priority project, config, issue, priority
    puts "Set priority of issue #{issue.name} to #{priority}."
    comment = ask_multiline_or_editor "Comments" unless $opts[:no_comment]
    begin
      issue.set_priority priority, config.user, comment
    rescue Ditz::ModelError => e
      puts "Error: Issue #{e}"
      return
    end
  end

  class <<self
    alias_method :_priority_orig_die_with_completions, :die_with_completions
    def die_with_completions project, method, spec
      case spec
      when :priority
	puts Issue.get_allowed_priorities()
	exit 0
      else
	_priority_orig_die_with_completions(project, method, spec)
      end
    end
  end

end

end
