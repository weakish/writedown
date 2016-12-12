# -*- encoding : utf-8 -*-
module WriteDown
  module Adapter
    module Example
      module_function

      # Search notes.
      # @param regex [String]
      # @return [Array<Fixnum>] matched notes' id
      def search(regex)
        'Nothing found!'
      end

      # Edit notes
      # @param id [Fixnum]
      # @param edit_options [Hash] additional options for editing
      # @return [String] success message
      def edit(id, edit_options)
        'Edited.'
      end

      # List notes
      # @param options [Hash] filter options
      # @param f [Proc, Method] filter function
      # @return [void] print result to screen
      def list(options, f)
        puts 'print result to screen'
      end

      # Add notes
      # Not implemented.
      def add(content)
        raise NotImplementedError
      end

      # Archive a note.
      # @param id [Fixnum, String]
      # @return [String] success message
      #
      def archive(id)
        '123 archived.'
      end

      # Remove a note.
      # @param id [Fixnum, String]
      # @param trash [Bool]
      # @return [void]
      def remove(id, trash='true')
        '321 trashed'
      end
    end
  end
end
