# frozen_string_literal: true
require "mail/utilities"
require "mail/parser_tools"

begin
  original_verbose, $VERBOSE = $VERBOSE, nil

  module Mail::Parsers
    module ReceivedParser
      extend Mail::ParserTools
      tables = File.binread(File.join(__dir__, "received_parser.dat"))

      ReceivedStruct = Struct.new(:date, :time, :info, :error)

      class << self
        attr_accessor :_trans_keys
        private :_trans_keys, :_trans_keys=
      end
      self._trans_keys = unpack_table(tables, 0, 1311, "C*")

      class << self
        attr_accessor :_key_spans
        private :_key_spans, :_key_spans=
      end
      self._key_spans = unpack_table(tables, 1311, 655, "C*")

      class << self
        attr_accessor :_index_offsets
        private :_index_offsets, :_index_offsets=
      end
      self._index_offsets = unpack_table(tables, 1966, 1310, "v*")

      class << self
        attr_accessor :_indicies
        private :_indicies, :_indicies=
      end
      self._indicies = unpack_table(tables, 3276, 104978, "v*")

      class << self
        attr_accessor :_trans_targs
        private :_trans_targs, :_trans_targs=
      end
      self._trans_targs = unpack_table(tables, 108254, 2808, "v*")

      class << self
        attr_accessor :_trans_actions
        private :_trans_actions, :_trans_actions=
      end
      self._trans_actions = unpack_table(tables, 111062, 1404, "C*")

      class << self
        attr_accessor :_eof_actions
        private :_eof_actions, :_eof_actions=
      end
      self._eof_actions = unpack_table(tables, 112466, 655, "C*")

      class << self
        attr_accessor :start
      end
      self.start = 1
      class << self
        attr_accessor :first_final
      end
      self.first_final = 648
      class << self
        attr_accessor :error
      end
      self.error = 0

      class << self
        attr_accessor :en_comment_tail
      end
      self.en_comment_tail = 636
      class << self
        attr_accessor :en_main
      end
      self.en_main = 1

      def self.parse(data)
        data = data.dup.force_encoding(Encoding::ASCII_8BIT) if data.respond_to?(:force_encoding)

        raise Mail::Field::NilParseError.new(Mail::ReceivedElement) if data.nil?

        # Parser state
        received = ReceivedStruct.new
        received_tokens_s = date_s = time_s = nil

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
                when 8
                  begin
                    received.info = chars(data, received_tokens_s, p - 1)
                  end
                when 54
                  begin
                    date_s = p
                  end
                when 131
                  begin
                    received.time = chars(data, time_s, p - 1)
                  end
                when 9
                  begin
                  end
                when 52
                  begin
                  end
                when 127
                  begin
                  end
                when 68
                  begin
                  end
                when 10
                  begin
                  end
                when 22
                  begin
                  end
                when 64
                  begin
                  end
                when 61
                  begin
                  end
                when 26
                  begin
                  end
                when 24
                  begin
                  end
                when 70
                  begin
                  end
                when 63
                  begin
                  end
                when 47
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
                  end
                when 130
                  begin
                    begin
                      top -= 1
                      cs = stack[top]
                      _goto_level = _again
                      next
                    end
                  end
                when 3
                  begin
                    received_tokens_s = p
                  end
                  begin
                    received.info = chars(data, received_tokens_s, p - 1)
                  end
                when 4
                  begin
                    received_tokens_s = p
                  end
                  begin
                  end
                when 5
                  begin
                    received_tokens_s = p
                  end
                  begin
                  end
                when 59
                  begin
                    date_s = p
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
                  end
                when 57
                  begin
                    received.date = chars(data, date_s, p - 1).strip
                  end
                  begin
                    time_s = p
                  end
                when 132
                  begin
                    received.time = chars(data, time_s, p - 1)
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
                  end
                when 81
                  begin
                  end
                  begin
                  end
                when 105
                  begin
                  end
                  begin
                  end
                when 120
                  begin
                  end
                  begin
                  end
                when 50
                  begin
                  end
                  begin
                    received.info = chars(data, received_tokens_s, p - 1)
                  end
                when 51
                  begin
                  end
                  begin
                  end
                when 69
                  begin
                  end
                  begin
                  end
                when 53
                  begin
                  end
                  begin
                  end
                when 66
                  begin
                  end
                  begin
                  end
                when 72
                  begin
                  end
                  begin
                  end
                when 71
                  begin
                  end
                  begin
                  end
                when 56
                  begin
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
                  end
                when 128
                  begin
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
                  end
                when 129
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
                when 77
                  begin
                  end
                  begin
                    received.info = chars(data, received_tokens_s, p - 1)
                  end
                when 78
                  begin
                  end
                  begin
                  end
                when 79
                  begin
                  end
                  begin
                  end
                when 67
                  begin
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
                  end
                when 104
                  begin
                  end
                  begin
                    received.info = chars(data, received_tokens_s, p - 1)
                  end
                when 106
                  begin
                  end
                  begin
                  end
                when 38
                  begin
                  end
                  begin
                  end
                when 15
                  begin
                  end
                  begin
                  end
                when 65
                  begin
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
                  end
                when 6
                  begin
                  end
                  begin
                  end
                when 60
                  begin
                  end
                  begin
                  end
                when 25
                  begin
                  end
                  begin
                  end
                when 116
                  begin
                  end
                  begin
                    received.info = chars(data, received_tokens_s, p - 1)
                  end
                when 117
                  begin
                  end
                  begin
                  end
                when 118
                  begin
                  end
                  begin
                  end
                when 73
                  begin
                  end
                  begin
                  end
                when 55
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                    date_s = p
                  end
                when 1
                  begin
                    received_tokens_s = p
                  end
                  begin
                  end
                  begin
                  end
                when 21
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 58
                  begin
                  end
                  begin
                    received.date = chars(data, date_s, p - 1).strip
                  end
                  begin
                    time_s = p
                  end
                when 86
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 111
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 125
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 85
                  begin
                  end
                  begin
                  end
                  begin
                    received.info = chars(data, received_tokens_s, p - 1)
                  end
                when 87
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 110
                  begin
                  end
                  begin
                  end
                  begin
                    received.info = chars(data, received_tokens_s, p - 1)
                  end
                when 112
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 45
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 48
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 124
                  begin
                  end
                  begin
                  end
                  begin
                    received.info = chars(data, received_tokens_s, p - 1)
                  end
                when 126
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 75
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 20
                  begin
                  end
                  begin
                  end
                  begin
                    received.info = chars(data, received_tokens_s, p - 1)
                  end
                when 23
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 101
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 98
                  begin
                  end
                  begin
                  end
                  begin
                    received.info = chars(data, received_tokens_s, p - 1)
                  end
                when 99
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 100
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 31
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 80
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 102
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 119
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 62
                  begin
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                  end
                when 114
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 74
                  begin
                  end
                  begin
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
                  end
                when 7
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                  end
                  begin
                  end
                when 2
                  begin
                    received_tokens_s = p
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
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
                  end
                when 94
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 82
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 93
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                    received.info = chars(data, received_tokens_s, p - 1)
                  end
                when 95
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 107
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 83
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 108
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 122
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 121
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 49
                  begin
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                  end
                  begin
                  end
                when 88
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                    received.info = chars(data, received_tokens_s, p - 1)
                  end
                when 17
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 36
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                    received.info = chars(data, received_tokens_s, p - 1)
                  end
                when 39
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 13
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                    received.info = chars(data, received_tokens_s, p - 1)
                  end
                when 14
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 16
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 96
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 18
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 76
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 103
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 115
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 44
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 90
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 43
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                    received.info = chars(data, received_tokens_s, p - 1)
                  end
                when 46
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 91
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 84
                  begin
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 109
                  begin
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 123
                  begin
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 113
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                    received.info = chars(data, received_tokens_s, p - 1)
                  end
                when 33
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 11
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 29
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                    received.info = chars(data, received_tokens_s, p - 1)
                  end
                when 30
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 32
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 97
                  begin
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 34
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 19
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 40
                  begin
                  end
                  begin
                  end
                  begin
                  end
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
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 92
                  begin
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 27
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 89
                  begin
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 35
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 12
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 42
                  begin
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                when 28
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 636
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
                  end
                  begin
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
                when 131
                  begin
                    received.time = chars(data, time_s, p - 1)
                  end
                when 52
                  begin
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

        if p != eof || cs < 648
          raise Mail::Field::IncompleteParseError.new(Mail::ReceivedElement, data, p)
        end

        received
      end
    end
  end
ensure
  $VERBOSE = original_verbose
end
