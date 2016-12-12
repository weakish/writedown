# -*- encoding : utf-8 -*-
require_relative 'writedown/version'
require_relative 'writedown/adapter'
require 'json'
# We use `constantize` in ActiveSupport because in Ruby 1.9
# `Object.const_get` does not accept `::`.
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/itself'

module WriteDown

  # Adapter and its options. (see #init_adapter)
  Options = {}

  module_function

  # Initial adapter.
  # @param options [Hash] including 'backend' (adapter name) and other
  #   options for that adapter.
  # @return [void] initialize WriteDown::Options which remembering options,
  #   and WriteDown.notes which returns adapter module.
  #
  # @example Initial Example adapter.
  #   init_adapter(backend: 'Example', json_path: 'example.json')
  #   WriteDown::Options[:backend] #=> 'Example'
  #   WriteDown::Options[:json_path] #=> 'example.json'
  #   WriteDown.notes #=> WriteDown::Adapter::Example
  def init_adapter(options={})
    WriteDown::Options.clear
    WriteDown::Options.merge! options

    adapter_name = WriteDown::Options[:backend] || 'Example'
    # `adapter_name` is a String, but we still use `to_s` in case it
    # was provided as a Symbol.
    require_relative "writedown/adapter/#{adapter_name.to_s.downcase}"
    WriteDown.send(:define_method, :notes,
      ->{ "WriteDown::Adapter::#{adapter_name}".constantize })
    WriteDown.send(:module_function, :notes)
  end

  # Receive input from stdin, file or arguments.
  # @param frontend [Module] which provides the following function.
  #   If this param is given, then the following function will use
  #   frontend.add, frontend.add, frontend.attack, frontend.list
  #   automatically. If you want to provide your own versions of
  #   following functions, you MUST provide `nil` for this `frontend` param.
  # @param stdin_f [Proc, Method, Symbol, String] function for standard input
  # @param file_f [Proc, Method, Symbol, String] function for file
  # @param args_f [Proc, Method, Symbol, String] function for arguments
  # @param default_f [Proc, Method, Symbol, string] default function
  #
  def receive_input(frontend=nil,
    stdin_f=WriteDown.method(:id),
    file_f=WriteDown.method(:id),
    args_f=WriteDown.method(:id),
    default_f=nil)
    if frontend
      stdin_f = frontend.method(:add)
      file_f = frontend.method(:add)
      args_f = frontend.method(:attack)
      default_f = frontend.method(:list)
    end
    if ARGV.first
      if File.exist? ARGV.first
        apply file_f, ARGF.read
      else
        apply args_f, ARGV.first
      end
    elsif not STDIN.tty? and not STDIN.closed?
      apply stdin_f, STDIN.read
    else
      apply default_f
    end
  end

  # Parse user input.
  # @param pattern [String] of user input
  # @param prefix [String] characters of prefix for tags
  # @param function [Proc, Method, Symbol, String] to call back if all matches fail
  # @return [String] if regex matched
  # @return [Array(String, String, String>)] if substitute regex, replace text
  #   matched and id
  # @return [Hash{String => String}] if tags starting with prefix matched
  # @return [void] if all matches fail and the callback function is triggered
  #
  # @example Parse regex.
  #   parse_input('/hello/') #=> 'hello'
  #
  # @example Pares substitute command.
  #   parse_input('s/foo/bar/3') #=> ['foo', 'bar', '3']
  #
  # @example Parse a single hash tag.
  #   parse_input('#tag') #=> {'#' => ['#tag']}
  #
  # @example Parse multiple tags.
  #   parse_input('@office @home @moon')
  #   #=> {'@' => ['@office', '@home', '@moon']}
  #
  # @example Customize tags.
  #   parse_input('+project', '+') #=> {'+' => ['+project']}
  #
  # @example Parse multiple tags with mixed type and customization.
  #   parse_input('@office ~Bob ~Alice #book !CriticalNow', '#@~!')
  #   #=> {'@' => ['@office'], '#' => ['#book'], '~' => ['~Bob', '~Alice'], '!' => ['!CriticalNow']}
  #
  # @example Mixing tags with regex is invalid.
  #   parse_input('@home /music/') #=> '@home /music/'
  #
  # @example Normal text.
  #   parse_input('normal text') #=> 'normal text'
  #
  # @example Disable tag detection.
  #   parse_input('#tag', '') #=> '#tag'
  #
  # @example Call back function (Proc).
  #   parse_input('1', '', ->(x) { x.to_i + 1 }) #=> 2
  #
  # @example Call back method.
  #   def add_one(x)
  #     x.to_i + 1
  #   end
  #   parse_input('1', '', :add_one) #=> 2
  def parse_input(pattern, prefix='#@', function=WriteDown.method(:id))
    regex = pattern.match(/^\/(.*[^\\]+)\/$/)
    if regex
      regex[1]
    else
      substitute_command = pattern.match(/^s\/(.*[^\\]+)\/(.*)\/([-0-9a-z]+)$/)
      if substitute_command
        regex = substitute_command[1]
        replace_text = substitute_command[2]
        id = substitute_command[3]
        [regex, replace_text, id]
      else
        tokens = pattern.split
        if tokens.all? do |t|
            prefix.each_char.to_a.any? do |c|
              t.start_with? c
            end
          end
          tokens.group_by { |t| t[0] }
        else
          apply function, pattern
        end
      end
    end
  end

  # Search notes.
  # @param regex [String]
  # @return [void] whatever the adapter returns.
  #
  # @example Search via Example adapter.
  #   init_adapter()
  #   search('descri[bp]') # => 'Nothing found!'
  def search(regex)
    notes.search regex
  end


  # Edit notes.
  # @param id [Fixnum, String] of note
  # @param options [Hash] command, editor, etc
  # @return [void]
  #
  # @example Edit via Example adapter.
  #   init_adapter()
  #   edit(1234, backup: true) #=> 'Edited.'
  def edit(id, options={})
    notes.edit id, options
  end

  # List notes meeting certain conditions.
  # @param options [Hash] filter options
  # @param f [Proc, Method] filter function
  # @return [void] whatever the adapter returns.
  #
  # @example Listing notes via Example adapter returns nil since the adapter print out notes on screen.
  #   init_adapter()
  #   list() #=> nil
  def list(options={}, f=nil)
    notes.list options, f
  end

  # Add a note.
  # @param content [String] of note
  # @return [void] whatever the adapter returns.
  #
  # @example Add a note via Example adapter.
  #   init_adapter()
  #   assert_raise(NotImplementedError) { add('hello world') } #=> true
  def add(content)
    notes.add content
  end

  # Archive a note.
  #
  # @param id [Fixnum, String]
  # @return [void]
  #
  # @example Archive a note via Example adapter.
  #   init_adapter()
  #   archive(123) #=> '123 archived.'
  def archive(id)
    notes.archive id
  end

  # Remove a note.
  #
  # @param id [Fixnum, String]
  # @param trash [Bool]
  # @return [void]
  #
  # @example Remove a note via Example adapter.
  #   init_adapter()
  #   remove(321) #=> '321 trashed'
  def remove(id, trash='true')
    notes.remove id, trash
  end

  # Identity function.
  # @param x [Object] any object
  # @return [Object] object itself
  #
  #   @example id
  #     id(1) #=> 1
  def id(x)
    x.itself
  end

  # Apply a Proc or Method.
  # @param f [Proc, Method, Symbol, String] Proc or method name.
  # @param args [List] List of arguments
  # @return [void] applies function
  #
  # @example Apply a Proc.
  #   apply ->(x) { x + 1 }, 1 #=> 2
  # @example Apply a Proc with multiple arguments.
  #   apply ->(x, y) { x + y }, 1, 1 #=> 2
  # @example Apply a Method.
  #   def add_one(x) x + 1 end
  #   apply method(:add_one), 1 #=> 2
  #   apply :add_one, 1 #=> 2
  #   apply 'add_one', 1 #=> 2
  def apply(f, *args)
    if f.is_a? Proc or f.is_a? Method
      f.call *args
    elsif f.is_a? Symbol or f.is_a? String
      method(f).call *args
    else
      raise ArgumentError, 'Argument is not a Proc/Method or method name.'
    end
  end

end


