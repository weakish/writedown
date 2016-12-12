# -*- encoding : utf-8 -*-
require 'facets/array/collapse'
require 'open3'

module WriteDown
  module Adapter
    module T
      module_function

      # Build t.py command.
      # @param args [Array<String>] additional arguments for t.py.
      # @return [Array<String>] command line
      def _t_cmd(*args)
        task_dir = WriteDown::Options[:task_dir] || "#{ENV['HOME']}/tasks"
        list = WriteDown::Options[:list] || 'tasks'
        ['t.py', '--task-dir', task_dir, '--list', list] + args
      end

      # Add.
      # @param content [String]
      # @return [void]
      def add(content)
        Open3.popen2 *_t_cmd do | stdin |
          stdin.write content
          stdin.close
        end
      end

      # Archive.
      # @param id_or_text [String] for task
      # @return [void]
      def archive(id_or_text)
        system *_t_cmd, id_or_text
      end

      # Edit
      # @param id [String] for task
      # @param options [Hash{String => String}] regex and replacement
      def edit(id, options)
        system *_t_cmd, '-e', id, "/#{options[:regex]}/#{options[:replacement]}/"
      end

      # Search
      # @param regex [String]
      # @return [Array<String>] matched lines
      def _search(regex, ignore_case=false)
        IO.popen(_t_cmd) do |f|
          f.select { |line| line =~ /#{regex}/u  }
        end
      end

      # Search
      # Call _search and print out result.
      # @param regex [String]
      # @return [void]
      def search(regex)
        puts _search(regex).join("\n")
      end

      # List
      # @param options [Hash{String => String}] additional listing options.
      # @param f [Proc, Method] filter function NOT IMPLEMENTED
      def list(options, f)
        if f
          raise NotImplementedError, 'Filter function is not implemented.'
        end
        IO.popen(_t_cmd) do |file|
          tags = options.values.collapse
          if tags.any? { |tag| tag.start_with? '?' }
            if tags.length == 1
              id = tags[0][1..-1]
              task = file.detect do |line|
                line.strip =~ /^#{id}\s+-\s+/
              end
              puts task.gsub ' ⏎ ', "\n"
            else
              puts 'Usage: t ?id'
              exit(false)
            end
          else
            if tags.empty?
              tasks = file
            else
              tasks = file.select do |line|
                tags.all? { |tag| line =~ /#{tag}/iu }
              end
            end
            tasks.each do |line|
              # Since `list` tends to list a lot of tasks, so we truncate
              # long tasks to save screen space.
              if line.length <= 80
                print_line line
              else
                print_line "#{line[0..76]} ..."
              end
            end
          end
        end
      end

      # Remove
      # Not Implemented.
      def remove(id, trash)
        raise NotImplementedError
      end

      # Print lines ready for head.
      # @param line [String]
      # @return [void] print to stdout
      def print_line(line)
        begin
          $stdout.puts line
        rescue Errno::EPIPE
          exit(74)
        end
      end
    end
  end
end
