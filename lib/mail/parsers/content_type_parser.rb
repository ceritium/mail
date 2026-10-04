# frozen_string_literal: true
require "mail/utilities"
require "mail/parser_tools"

begin
  original_verbose, $VERBOSE = $VERBOSE, nil

  module Mail::Parsers
    module ContentTypeParser
      extend Mail::ParserTools
      tables = File.binread(File.join(__dir__, "content_type_parser.dat"))

      ContentTypeStruct = Struct.new(:main_type, :sub_type, :parameters, :error)

      class << self
        attr_accessor :_trans_keys
        private :_trans_keys, :_trans_keys=
      end
      self._trans_keys = unpack_table(tables, 0, 111, "C*")

      class << self
        attr_accessor :_key_spans
        private :_key_spans, :_key_spans=
      end
      self._key_spans = unpack_table(tables, 111, 55, "C*")

      class << self
        attr_accessor :_index_offsets
        private :_index_offsets, :_index_offsets=
      end
      self._index_offsets = unpack_table(tables, 166, 110, "v*")

      class << self
        attr_accessor :_indicies
        private :_indicies, :_indicies=
      end
      self._indicies = unpack_table(tables, 276, 4243, "C*")

      class << self
        attr_accessor :_trans_targs
        private :_trans_targs, :_trans_targs=
      end
      self._trans_targs = unpack_table(tables, 4519, 113, "C*")

      class << self
        attr_accessor :_trans_actions
        private :_trans_actions, :_trans_actions=
      end
      self._trans_actions = unpack_table(tables, 4632, 113, "C*")

      class << self
        attr_accessor :_eof_actions
        private :_eof_actions, :_eof_actions=
      end
      self._eof_actions = unpack_table(tables, 4745, 55, "C*")

      class << self
        attr_accessor :start
      end
      self.start = 1
      class << self
        attr_accessor :first_final
      end
      self.first_final = 47
      class << self
        attr_accessor :error
      end
      self.error = 0

      class << self
        attr_accessor :en_comment_tail
      end
      self.en_comment_tail = 35
      class << self
        attr_accessor :en_main
      end
      self.en_main = 1

      def self.parse(data)
        data = data.dup.force_encoding(Encoding::ASCII_8BIT) if data.respond_to?(:force_encoding)

        return ContentTypeStruct.new("text", "plain", []) if Mail::Utilities.blank?(data)
        content_type = ContentTypeStruct.new(nil, nil, [])

        # Parser state
        main_type_s = sub_type_s = param_attr_s = param_attr = nil
        qstr_s = qstr = param_val_s = nil

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
                when 1
                  begin
                    main_type_s = p
                  end
                when 2
                  begin
                    content_type.main_type = chars(data, main_type_s, p - 1).downcase
                  end
                when 3
                  begin
                    sub_type_s = p
                  end
                when 19
                  begin
                    content_type.sub_type = chars(data, sub_type_s, p - 1).downcase
                  end
                when 4
                  begin
                    param_attr_s = p
                  end
                when 6
                  begin
                    param_attr = chars(data, param_attr_s, p - 1)
                  end
                when 9
                  begin
                    qstr_s = p
                  end
                when 11
                  begin
                    qstr = chars(data, qstr_s, p - 1)
                  end
                when 7
                  begin
                    param_val_s = p
                  end
                when 21
                  begin
                    if param_attr.nil?
                      raise Mail::Field::ParseError.new(Mail::ContentTypeElement, data, "no attribute for value")
                    end

                    # Use quoted s value if one exists, otherwise use parameter value
                    value = qstr || chars(data, param_val_s, p - 1)

                    content_type.parameters << { param_attr => value }
                    param_attr = nil
                    qstr = nil
                  end
                when 12
                  begin
                  end
                when 15
                  begin
                  end
                when 5
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 35
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
                when 20
                  begin
                    content_type.sub_type = chars(data, sub_type_s, p - 1).downcase
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 35
                      _goto_level = _again
                      next
                    end
                  end
                when 10
                  begin
                    qstr_s = p
                  end
                  begin
                    qstr = chars(data, qstr_s, p - 1)
                  end
                when 8
                  begin
                    param_val_s = p
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 35
                      _goto_level = _again
                      next
                    end
                  end
                when 25
                  begin
                    if param_attr.nil?
                      raise Mail::Field::ParseError.new(Mail::ContentTypeElement, data, "no attribute for value")
                    end

                    # Use quoted s value if one exists, otherwise use parameter value
                    value = qstr || chars(data, param_val_s, p - 1)

                    content_type.parameters << { param_attr => value }
                    param_attr = nil
                    qstr = nil
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 35
                      _goto_level = _again
                      next
                    end
                  end
                when 13
                  begin
                  end
                  begin
                    param_attr_s = p
                  end
                when 23
                  begin
                  end
                  begin
                    if param_attr.nil?
                      raise Mail::Field::ParseError.new(Mail::ContentTypeElement, data, "no attribute for value")
                    end

                    # Use quoted s value if one exists, otherwise use parameter value
                    value = qstr || chars(data, param_val_s, p - 1)

                    content_type.parameters << { param_attr => value }
                    param_attr = nil
                    qstr = nil
                  end
                when 14
                  begin
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 35
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
                      cs = 35
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
                when 22
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 35
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                    if param_attr.nil?
                      raise Mail::Field::ParseError.new(Mail::ContentTypeElement, data, "no attribute for value")
                    end

                    # Use quoted s value if one exists, otherwise use parameter value
                    value = qstr || chars(data, param_val_s, p - 1)

                    content_type.parameters << { param_attr => value }
                    param_attr = nil
                    qstr = nil
                  end
                when 24
                  begin
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 35
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                    if param_attr.nil?
                      raise Mail::Field::ParseError.new(Mail::ContentTypeElement, data, "no attribute for value")
                    end

                    # Use quoted s value if one exists, otherwise use parameter value
                    value = qstr || chars(data, param_val_s, p - 1)

                    content_type.parameters << { param_attr => value }
                    param_attr = nil
                    qstr = nil
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
                when 19
                  begin
                    content_type.sub_type = chars(data, sub_type_s, p - 1).downcase
                  end
                when 21
                  begin
                    if param_attr.nil?
                      raise Mail::Field::ParseError.new(Mail::ContentTypeElement, data, "no attribute for value")
                    end

                    # Use quoted s value if one exists, otherwise use parameter value
                    value = qstr || chars(data, param_val_s, p - 1)

                    content_type.parameters << { param_attr => value }
                    param_attr = nil
                    qstr = nil
                  end
                when 12
                  begin
                  end
                when 23
                  begin
                  end
                  begin
                    if param_attr.nil?
                      raise Mail::Field::ParseError.new(Mail::ContentTypeElement, data, "no attribute for value")
                    end

                    # Use quoted s value if one exists, otherwise use parameter value
                    value = qstr || chars(data, param_val_s, p - 1)

                    content_type.parameters << { param_attr => value }
                    param_attr = nil
                    qstr = nil
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

        if p != eof || cs < 47
          raise Mail::Field::IncompleteParseError.new(Mail::ContentTypeElement, data, p)
        end

        content_type
      end
    end
  end
ensure
  $VERBOSE = original_verbose
end
