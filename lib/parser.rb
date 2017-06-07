module Parser
  def self.parse(source)
    Grammar.parse(source, :actions => Builder.new)
  end
end

require 'parser/grammar'
require 'parser/builder'
