# -*- encoding : utf-8 -*-
module WriteDown
  module Adapter
    module_function

    # Show current adapter.
    # @return [Symbol] Names of current adapter.
    def current
      self.constants[0]
    end
  end
end
