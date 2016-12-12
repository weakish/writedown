# -*- encoding : utf-8 -*-
require 'lib/writedown'
# pry-rescue works on terminal but not in sublime
require 'pry-rescue/minitest'

open('lib/writedown.rb') do |f|
  module_lines = f.find_all { |line| line[0..5] == 'module' }
  modules = module_lines.map { |s| s.strip.tr(' ', '')[6..-1] }
  modules.each do |mod|
    mod = Object.const_get(mod)
    include mod
    YARD::Doctest.configure do |doctest|
      # Avoid duplicating tests results of module functions.
      #
      # Module functions are copied from instance methods. After copying,
      # instance methods will be turned into private. So there are two
      # functions with the same name. So we need to avoid duplicating tests of them
      # and we can get a list of module functions from
      # `private_instance_methods`.
      mod.private_instance_methods.each do |m|
        # Since module functions are copies, so we can 1) skip all of them or
        # 2) skip all of these original instance methods. For the following reason,
        # we choose option 1: skip testing all module functions.
        # Actually private instance methods without a corresponding module
        # function are also listed. Since they can not be accessed via
        # `M.p`, So we use `.` not `#` to avoid skip them. yard-doctest will simply
        # ignore all non existent skip methods.
        doctest.skip "#{mod}.#{m.to_s}"
      end
    end
  end
end
