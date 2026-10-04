module Mail
  # Extends each field parser with utility methods.
  module ParserTools #:nodoc:
    # Slice bytes from ASCII-8BIT data and mark as UTF-8.
    if 'string'.respond_to?(:force_encoding)
      def chars(data, from_bytes, to_bytes)
        data.slice(from_bytes..to_bytes).force_encoding(Encoding::UTF_8)
      end
    else
      def chars(data, from_bytes, to_bytes)
        data.slice(from_bytes..to_bytes)
      end
    end

    private

    TABLE_ENTRY_BYTES = { 'C*' => 1, 'v*' => 2, 'V*' => 4 }.freeze
    private_constant :TABLE_ENTRY_BYTES

    # Decode a Ragel state table packed by tools/pack_ragel_tables.rb into
    # the parser's data file.
    # Filling a presized Array keeps peak memory down: building it with a
    # plain unpack grows (and over-allocates) a second copy of the table.
    def unpack_table(data, offset, length, directive)
      bytes = data.byteslice(offset, length)
      table = Array.new(length / TABLE_ENTRY_BYTES.fetch(directive))
      index = 0
      bytes.unpack(directive) do |value|
        table[index] = value
        index += 1
      end
      table.freeze
    end
  end
end
