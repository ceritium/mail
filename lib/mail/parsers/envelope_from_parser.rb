# frozen_string_literal: true
require "mail/utilities"
require "mail/parser_tools"

begin
  original_verbose, $VERBOSE = $VERBOSE, nil

  module Mail::Parsers
    module EnvelopeFromParser
      extend Mail::ParserTools
      tables = File.binread(File.join(__dir__, "envelope_from_parser.dat"))

      EnvelopeFromStruct = Struct.new(:address, :ctime_date, :error)

      class << self
        attr_accessor :_trans_keys
        private :_trans_keys, :_trans_keys=
      end
      self._trans_keys = unpack_table(tables, 0, 619, "C*")

      class << self
        attr_accessor :_key_spans
        private :_key_spans, :_key_spans=
      end
      self._key_spans = unpack_table(tables, 619, 309, "C*")

      class << self
        attr_accessor :_index_offsets
        private :_index_offsets, :_index_offsets=
      end
      self._index_offsets = unpack_table(tables, 928, 618, "v*")

      class << self
        attr_accessor :_indicies
        private :_indicies, :_indicies=
      end
      self._indicies = unpack_table(tables, 1546, 44212, "v*")

      class << self
        attr_accessor :_trans_targs
        private :_trans_targs, :_trans_targs=
      end
      self._trans_targs = unpack_table(tables, 45758, 1074, "v*")

      class << self
        attr_accessor :_trans_actions
        private :_trans_actions, :_trans_actions=
      end
      self._trans_actions = unpack_table(tables, 46832, 537, "C*")

      class << self
        attr_accessor :_eof_actions
        private :_eof_actions, :_eof_actions=
      end
      self._eof_actions = unpack_table(tables, 47369, 309, "C*")

      class << self
        attr_accessor :start
      end
      self.start = 1
      class << self
        attr_accessor :first_final
      end
      self.first_final = 257
      class << self
        attr_accessor :error
      end
      self.error = 0

      class << self
        attr_accessor :en_comment_tail
      end
      self.en_comment_tail = 245
      class << self
        attr_accessor :en_main
      end
      self.en_main = 1

      def self.parse(data)
        data = data.dup.force_encoding(Encoding::ASCII_8BIT) if data.respond_to?(:force_encoding)

        envelope_from = EnvelopeFromStruct.new
        return envelope_from if Mail::Utilities.blank?(data)

        # Parser state
        address_s = ctime_date_s = nil

        # 5.1 Variables Used by Ragel
        p = 0
        eof = pe = data.length
        stack = []

        begin
          p ||= 0
          pe ||= data.length
          cs = start
          top = 0
        end

        begin
          testEof = false
          _slen, _trans, _keys, _inds, _acts, _nacts = nil
          _goto_level = 0
          _resume = 10
          _eof_trans = 15
          _again = 20
          _test_eof = 30
          _out = 40
          while true
            if _goto_level <= 0
              if p == pe
                _goto_level = _test_eof
                next
              end
              if cs == 0
                _goto_level = _out
                next
              end
            end
            if _goto_level <= _resume
              _keys = cs << 1
              _inds = _index_offsets[cs]
              _slen = _key_spans[cs]
              _wide = data[p].ord
              _trans = if (_slen > 0 &&
                           _trans_keys[_keys] <= _wide &&
                           _wide <= _trans_keys[_keys + 1])
                  _indicies[_inds + _wide - _trans_keys[_keys]]
                else
                  _indicies[_inds + _slen]
                end
              cs = _trans_targs[_trans]
              if _trans_actions[_trans] != 0
                case _trans_actions[_trans]
                when 3
                  begin
                    address_s = p
                  end
                when 27
                  begin
                    envelope_from.address = chars(data, address_s, p - 1).rstrip
                  end
                when 14
                  begin
                    ctime_date_s = p
                  end
                when 8
                  begin
                  end
                when 15
                  begin
                  end
                when 6
                  begin
                  end
                when 24
                  begin
                  end
                when 20
                  begin
                  end
                when 4
                  begin
                  end
                when 12
                  begin
                  end
                when 10
                  begin
                  end
                when 40
                  begin
                  end
                when 5
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 245
                      _goto_level = _again
                      next
                    end
                  end
                when 18
                  begin
                    begin
                      top -= 1
                      cs = stack[top]
                      _goto_level = _again
                      next
                    end
                  end
                when 1
                  begin
                    address_s = p
                  end
                  begin
                  end
                when 28
                  begin
                  end
                  begin
                    envelope_from.address = chars(data, address_s, p - 1).rstrip
                  end
                when 26
                  begin
                  end
                  begin
                  end
                when 13
                  begin
                  end
                  begin
                  end
                when 42
                  begin
                  end
                  begin
                  end
                when 9
                  begin
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 245
                      _goto_level = _again
                      next
                    end
                  end
                when 16
                  begin
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 245
                      _goto_level = _again
                      next
                    end
                  end
                when 17
                  begin
                  end
                  begin
                    begin
                      top -= 1
                      cs = stack[top]
                      _goto_level = _again
                      next
                    end
                  end
                when 29
                  begin
                  end
                  begin
                    envelope_from.address = chars(data, address_s, p - 1).rstrip
                  end
                when 7
                  begin
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 245
                      _goto_level = _again
                      next
                    end
                  end
                when 23
                  begin
                  end
                  begin
                    envelope_from.address = chars(data, address_s, p - 1).rstrip
                  end
                when 36
                  begin
                  end
                  begin
                  end
                when 22
                  begin
                  end
                  begin
                  end
                when 21
                  begin
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 245
                      _goto_level = _again
                      next
                    end
                  end
                when 11
                  begin
                  end
                  begin
                  end
                when 39
                  begin
                  end
                  begin
                    envelope_from.address = chars(data, address_s, p - 1).rstrip
                  end
                when 2
                  begin
                    address_s = p
                  end
                  begin
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 245
                      _goto_level = _again
                      next
                    end
                  end
                when 30
                  begin
                  end
                  begin
                  end
                  begin
                    envelope_from.address = chars(data, address_s, p - 1).rstrip
                  end
                when 25
                  begin
                  end
                  begin
                  end
                  begin
                    envelope_from.address = chars(data, address_s, p - 1).rstrip
                  end
                when 38
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 41
                  begin
                  end
                  begin
                  end
                  begin
                    envelope_from.address = chars(data, address_s, p - 1).rstrip
                  end
                when 35
                  begin
                  end
                  begin
                  end
                  begin
                    envelope_from.address = chars(data, address_s, p - 1).rstrip
                  end
                when 19
                  begin
                  end
                  begin
                  end
                  begin
                    envelope_from.address = chars(data, address_s, p - 1).rstrip
                  end
                when 34
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 37
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                    envelope_from.address = chars(data, address_s, p - 1).rstrip
                  end
                when 33
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                    envelope_from.address = chars(data, address_s, p - 1).rstrip
                  end
                end
              end
            end
            if _goto_level <= _again
              if cs == 0
                _goto_level = _out
                next
              end
              p += 1
              if p != pe
                _goto_level = _resume
                next
              end
            end
            if _goto_level <= _test_eof
              if p == eof
                case _eof_actions[cs]
                when 27
                  begin
                    envelope_from.address = chars(data, address_s, p - 1).rstrip
                  end
                when 31
                  begin
                    envelope_from.ctime_date = chars(data, ctime_date_s, p - 1)
                  end
                when 28
                  begin
                  end
                  begin
                    envelope_from.address = chars(data, address_s, p - 1).rstrip
                  end
                when 32
                  begin
                  end
                  begin
                    envelope_from.ctime_date = chars(data, ctime_date_s, p - 1)
                  end
                when 29
                  begin
                  end
                  begin
                    envelope_from.address = chars(data, address_s, p - 1).rstrip
                  end
                when 23
                  begin
                  end
                  begin
                    envelope_from.address = chars(data, address_s, p - 1).rstrip
                  end
                when 39
                  begin
                  end
                  begin
                    envelope_from.address = chars(data, address_s, p - 1).rstrip
                  end
                when 30
                  begin
                  end
                  begin
                  end
                  begin
                    envelope_from.address = chars(data, address_s, p - 1).rstrip
                  end
                when 25
                  begin
                  end
                  begin
                  end
                  begin
                    envelope_from.address = chars(data, address_s, p - 1).rstrip
                  end
                when 41
                  begin
                  end
                  begin
                  end
                  begin
                    envelope_from.address = chars(data, address_s, p - 1).rstrip
                  end
                when 35
                  begin
                  end
                  begin
                  end
                  begin
                    envelope_from.address = chars(data, address_s, p - 1).rstrip
                  end
                when 19
                  begin
                  end
                  begin
                  end
                  begin
                    envelope_from.address = chars(data, address_s, p - 1).rstrip
                  end
                when 37
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                    envelope_from.address = chars(data, address_s, p - 1).rstrip
                  end
                when 33
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                    envelope_from.address = chars(data, address_s, p - 1).rstrip
                  end
                end
              end
            end
            if _goto_level <= _out
              break
            end
          end
        end

        if false
          testEof
        end

        if p != eof || cs < 257
          raise Mail::Field::IncompleteParseError.new(Mail::EnvelopeFromElement, data, p)
        end

        envelope_from
      end
    end
  end
ensure
  $VERBOSE = original_verbose
end
