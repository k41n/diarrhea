class Command < ActiveRecord::Base
  belongs_to :node

  def execute
    self.result = node.execute(self.cmdline)
    self.save
  end
end
