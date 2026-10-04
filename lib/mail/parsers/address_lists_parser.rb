# frozen_string_literal: true
require "mail/utilities"
require "mail/parser_tools"

begin
  original_verbose, $VERBOSE = $VERBOSE, nil

  module Mail::Parsers
    module AddressListsParser
      extend Mail::ParserTools
      tables = File.binread(File.join(__dir__, "address_lists_parser.dat"))

      AddressListStruct = Struct.new(:addresses, :group_names, :error)
      AddressStruct = Struct.new(:raw, :domain, :comments, :local,
                                 :obs_domain_list, :display_name, :group, :error)

      class << self
        attr_accessor :_trans_keys
        private :_trans_keys, :_trans_keys=
      end
      self._trans_keys = unpack_table(tables, 0, 5071, "C*")

      class << self
        attr_accessor :_key_spans
        private :_key_spans, :_key_spans=
      end
      self._key_spans = unpack_table(tables, 5071, 2535, "C*")

      class << self
        attr_accessor :_index_offsets
        private :_index_offsets, :_index_offsets=
      end
      self._index_offsets = unpack_table(tables, 7606, 10140, "V*")

      class << self
        attr_accessor :_indicies
        private :_indicies, :_indicies=
      end
      self._indicies = unpack_table(tables, 17746, 459532, "v*")

      class << self
        attr_accessor :_trans_targs
        private :_trans_targs, :_trans_targs=
      end
      self._trans_targs = unpack_table(tables, 477278, 9976, "v*")

      class << self
        attr_accessor :_trans_actions
        private :_trans_actions, :_trans_actions=
      end
      self._trans_actions = unpack_table(tables, 487254, 4988, "C*")

      class << self
        attr_accessor :_eof_actions
        private :_eof_actions, :_eof_actions=
      end
      self._eof_actions = unpack_table(tables, 492242, 2535, "C*")

      class << self
        attr_accessor :start
      end
      self.start = 2461
      class << self
        attr_accessor :first_final
      end
      self.first_final = 2461
      class << self
        attr_accessor :error
      end
      self.error = 0

      class << self
        attr_accessor :en_comment_tail
      end
      self.en_comment_tail = 2449
      class << self
        attr_accessor :en_main
      end
      self.en_main = 2461

      def self.parse(data)
        data = data.dup.force_encoding(Encoding::ASCII_8BIT) if data.respond_to?(:force_encoding)

        address_list = AddressListStruct.new([], [])
        return address_list if Mail::Utilities.blank?(data)

        phrase_s = phrase_e = qstr_s = qstr = comment_s = nil
        group_name_s = domain_s = group_name = nil
        local_dot_atom_s = local_dot_atom_e = nil
        local_dot_atom_pre_comment_e = nil
        obs_domain_list_s = nil

        address_s = 0
        address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)

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
                when 4
                  begin
                    phrase_e = p - 1
                  end
                when 8
                  begin
                    qstr_s = p
                  end
                when 10
                  begin
                    qstr = chars(data, qstr_s, p - 1)
                  end
                when 59
                  begin
                    comment_s = p unless comment_s
                  end
                when 12
                  begin
                    if address
                      address.comments << chars(data, comment_s, p - 2)
                    end
                    comment_s = nil
                  end
                when 34
                  begin
                    if address_s
                      if address.local.nil? && local_dot_atom_pre_comment_e && local_dot_atom_s && local_dot_atom_e
                        if address.domain
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_e)
                        else
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_pre_comment_e)
                        end
                      end
                      address.raw = chars(data, address_s, p - 1)
                      address_list.addresses << address if address

                      # Start next address
                      address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
                      address.group = group_name
                      address_s = nil
                    end
                  end
                when 3
                  begin
                    if qstr
                      address.display_name = Mail::Utilities.unescape(qstr)
                      qstr = nil
                    elsif phrase_e
                      address.display_name = chars(data, phrase_s, phrase_e).strip
                      phrase_e = phrase_s = nil
                    end
                  end
                when 43
                  begin
                    domain_s = p
                  end
                when 54
                  begin
                    address.domain = chars(data, domain_s, p - 1).rstrip if address
                  end
                when 1
                  begin
                    local_dot_atom_s = p
                  end
                when 24
                  begin
                    local_dot_atom_e = p - 1
                  end
                when 21
                  begin
                    local_dot_atom_pre_comment_e = p - 1
                  end
                when 50
                  begin
                    address.local = '"' + qstr + '"' if address
                  end
                when 20
                  begin
                    obs_domain_list_s = p
                  end
                when 2
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 2449
                      _goto_level = _again
                      next
                    end
                  end
                when 62
                  begin
                    begin
                      top -= 1
                      cs = stack[top]
                      _goto_level = _again
                      next
                    end
                  end
                when 6
                  begin
                    phrase_e = p - 1
                  end
                  begin
                    if qstr
                      group = qstr
                      qstr = nil
                    else
                      group = chars(data, group_name_s, p - 1)
                      group_name_s = nil
                    end
                    address_list.group_names << group
                    group_name = group

                    # Start next address
                    address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
                    address_s = p
                    address.group = group_name
                  end
                when 7
                  begin
                    phrase_e = p - 1
                  end
                  begin
                    if qstr
                      address.display_name = Mail::Utilities.unescape(qstr)
                      qstr = nil
                    elsif phrase_e
                      address.display_name = chars(data, phrase_s, phrase_e).strip
                      phrase_e = phrase_s = nil
                    end
                  end
                when 42
                  begin
                    phrase_e = p - 1
                  end
                  begin
                    domain_s = p
                  end
                when 30
                  begin
                    phrase_e = p - 1
                  end
                  begin
                    local_dot_atom_pre_comment_e = p - 1
                  end
                when 9
                  begin
                    qstr_s = p
                  end
                  begin
                    qstr = chars(data, qstr_s, p - 1)
                  end
                when 60
                  begin
                    comment_s = p unless comment_s
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 2449
                      _goto_level = _again
                      next
                    end
                  end
                when 61
                  begin
                    comment_s = p unless comment_s
                  end
                  begin
                    begin
                      top -= 1
                      cs = stack[top]
                      _goto_level = _again
                      next
                    end
                  end
                when 11
                  begin
                    if address
                      address.comments << chars(data, comment_s, p - 2)
                    end
                    comment_s = nil
                  end
                  begin
                    phrase_e = p - 1
                  end
                when 35
                  begin
                    if address
                      address.comments << chars(data, comment_s, p - 2)
                    end
                    comment_s = nil
                  end
                  begin
                    if address_s
                      if address.local.nil? && local_dot_atom_pre_comment_e && local_dot_atom_s && local_dot_atom_e
                        if address.domain
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_e)
                        else
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_pre_comment_e)
                        end
                      end
                      address.raw = chars(data, address_s, p - 1)
                      address_list.addresses << address if address

                      # Start next address
                      address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
                      address.group = group_name
                      address_s = nil
                    end
                  end
                when 17
                  begin
                    if address
                      address.comments << chars(data, comment_s, p - 2)
                    end
                    comment_s = nil
                  end
                  begin
                    if qstr
                      address.display_name = Mail::Utilities.unescape(qstr)
                      qstr = nil
                    elsif phrase_e
                      address.display_name = chars(data, phrase_s, phrase_e).strip
                      phrase_e = phrase_s = nil
                    end
                  end
                when 55
                  begin
                    if address
                      address.comments << chars(data, comment_s, p - 2)
                    end
                    comment_s = nil
                  end
                  begin
                    address.domain = chars(data, domain_s, p - 1).rstrip if address
                  end
                when 53
                  begin
                    if address
                      address.comments << chars(data, comment_s, p - 2)
                    end
                    comment_s = nil
                  end
                  begin
                    local_dot_atom_s = p
                  end
                when 25
                  begin
                    if address
                      address.comments << chars(data, comment_s, p - 2)
                    end
                    comment_s = nil
                  end
                  begin
                    local_dot_atom_e = p - 1
                  end
                when 52
                  begin
                    if address
                      address.comments << chars(data, comment_s, p - 2)
                    end
                    comment_s = nil
                  end
                  begin
                    address.local = '"' + qstr + '"' if address
                  end
                when 16
                  begin
                    if address
                      address.comments << chars(data, comment_s, p - 2)
                    end
                    comment_s = nil
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 2449
                      _goto_level = _again
                      next
                    end
                  end
                when 29
                  begin
                    address_s = p
                  end
                  begin
                    phrase_s = p
                  end
                when 28
                  begin
                    address_s = p
                  end
                  begin
                    if qstr
                      address.display_name = Mail::Utilities.unescape(qstr)
                      qstr = nil
                    elsif phrase_e
                      address.display_name = chars(data, phrase_s, phrase_e).strip
                      phrase_e = phrase_s = nil
                    end
                  end
                when 48
                  begin
                    domain_s = p
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 2449
                      _goto_level = _again
                      next
                    end
                  end
                when 45
                  begin
                    address.domain = chars(data, domain_s, p - 1).rstrip if address
                  end
                  begin
                    if address_s
                      if address.local.nil? && local_dot_atom_pre_comment_e && local_dot_atom_s && local_dot_atom_e
                        if address.domain
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_e)
                        else
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_pre_comment_e)
                        end
                      end
                      address.raw = chars(data, address_s, p - 1)
                      address_list.addresses << address if address

                      # Start next address
                      address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
                      address.group = group_name
                      address_s = nil
                    end
                  end
                when 18
                  begin
                    local_dot_atom_s = p
                  end
                  begin
                    obs_domain_list_s = p
                  end
                when 33
                  begin
                    local_dot_atom_e = p - 1
                  end
                  begin
                    if address_s
                      if address.local.nil? && local_dot_atom_pre_comment_e && local_dot_atom_s && local_dot_atom_e
                        if address.domain
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_e)
                        else
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_pre_comment_e)
                        end
                      end
                      address.raw = chars(data, address_s, p - 1)
                      address_list.addresses << address if address

                      # Start next address
                      address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
                      address.group = group_name
                      address_s = nil
                    end
                  end
                when 39
                  begin
                    local_dot_atom_e = p - 1
                  end
                  begin
                    address.local = '"' + qstr + '"' if address
                  end
                when 23
                  begin
                    local_dot_atom_pre_comment_e = p - 1
                  end
                  begin
                    local_dot_atom_e = p - 1
                  end
                when 22
                  begin
                    local_dot_atom_pre_comment_e = p - 1
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 2449
                      _goto_level = _again
                      next
                    end
                  end
                when 49
                  begin
                    address.local = '"' + qstr + '"' if address
                  end
                  begin
                    if address_s
                      if address.local.nil? && local_dot_atom_pre_comment_e && local_dot_atom_s && local_dot_atom_e
                        if address.domain
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_e)
                        else
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_pre_comment_e)
                        end
                      end
                      address.raw = chars(data, address_s, p - 1)
                      address_list.addresses << address if address

                      # Start next address
                      address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
                      address.group = group_name
                      address_s = nil
                    end
                  end
                when 56
                  begin
                    address.obs_domain_list = chars(data, obs_domain_list_s, p - 1)
                  end
                  begin
                    local_dot_atom_s = p
                  end
                when 5
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 2449
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                    phrase_e = p - 1
                  end
                when 14
                  begin
                    if address
                      address.comments << chars(data, comment_s, p - 2)
                    end
                    comment_s = nil
                  end
                  begin
                    phrase_e = p - 1
                  end
                  begin
                    if qstr
                      group = qstr
                      qstr = nil
                    else
                      group = chars(data, group_name_s, p - 1)
                      group_name_s = nil
                    end
                    address_list.group_names << group
                    group_name = group

                    # Start next address
                    address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
                    address_s = p
                    address.group = group_name
                  end
                when 15
                  begin
                    if address
                      address.comments << chars(data, comment_s, p - 2)
                    end
                    comment_s = nil
                  end
                  begin
                    phrase_e = p - 1
                  end
                  begin
                    if qstr
                      address.display_name = Mail::Utilities.unescape(qstr)
                      qstr = nil
                    elsif phrase_e
                      address.display_name = chars(data, phrase_s, phrase_e).strip
                      phrase_e = phrase_s = nil
                    end
                  end
                when 46
                  begin
                    if address
                      address.comments << chars(data, comment_s, p - 2)
                    end
                    comment_s = nil
                  end
                  begin
                    address.domain = chars(data, domain_s, p - 1).rstrip if address
                  end
                  begin
                    if address_s
                      if address.local.nil? && local_dot_atom_pre_comment_e && local_dot_atom_s && local_dot_atom_e
                        if address.domain
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_e)
                        else
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_pre_comment_e)
                        end
                      end
                      address.raw = chars(data, address_s, p - 1)
                      address_list.addresses << address if address

                      # Start next address
                      address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
                      address.group = group_name
                      address_s = nil
                    end
                  end
                when 47
                  begin
                    if address
                      address.comments << chars(data, comment_s, p - 2)
                    end
                    comment_s = nil
                  end
                  begin
                    local_dot_atom_e = p - 1
                  end
                  begin
                    if address_s
                      if address.local.nil? && local_dot_atom_pre_comment_e && local_dot_atom_s && local_dot_atom_e
                        if address.domain
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_e)
                        else
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_pre_comment_e)
                        end
                      end
                      address.raw = chars(data, address_s, p - 1)
                      address_list.addresses << address if address

                      # Start next address
                      address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
                      address.group = group_name
                      address_s = nil
                    end
                  end
                when 41
                  begin
                    if address
                      address.comments << chars(data, comment_s, p - 2)
                    end
                    comment_s = nil
                  end
                  begin
                    local_dot_atom_e = p - 1
                  end
                  begin
                    address.local = '"' + qstr + '"' if address
                  end
                when 51
                  begin
                    if address
                      address.comments << chars(data, comment_s, p - 2)
                    end
                    comment_s = nil
                  end
                  begin
                    address.local = '"' + qstr + '"' if address
                  end
                  begin
                    if address_s
                      if address.local.nil? && local_dot_atom_pre_comment_e && local_dot_atom_s && local_dot_atom_e
                        if address.domain
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_e)
                        else
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_pre_comment_e)
                        end
                      end
                      address.raw = chars(data, address_s, p - 1)
                      address_list.addresses << address if address

                      # Start next address
                      address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
                      address.group = group_name
                      address_s = nil
                    end
                  end
                when 13
                  begin
                    if address
                      address.comments << chars(data, comment_s, p - 2)
                    end
                    comment_s = nil
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 2449
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                    phrase_e = p - 1
                  end
                when 65
                  begin
                    group_name_s = p
                  end
                  begin
                    phrase_s = p
                  end
                  begin
                    address_s = p
                  end
                when 26
                  begin
                    address_s = p
                  end
                  begin
                    phrase_s = p
                  end
                  begin
                    local_dot_atom_s = p
                  end
                when 19
                  begin
                    local_dot_atom_s = p
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 2449
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                    obs_domain_list_s = p
                  end
                when 38
                  begin
                    local_dot_atom_e = p - 1
                  end
                  begin
                    address.local = '"' + qstr + '"' if address
                  end
                  begin
                    if address_s
                      if address.local.nil? && local_dot_atom_pre_comment_e && local_dot_atom_s && local_dot_atom_e
                        if address.domain
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_e)
                        else
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_pre_comment_e)
                        end
                      end
                      address.raw = chars(data, address_s, p - 1)
                      address_list.addresses << address if address

                      # Start next address
                      address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
                      address.group = group_name
                      address_s = nil
                    end
                  end
                when 32
                  begin
                    local_dot_atom_pre_comment_e = p - 1
                  end
                  begin
                    local_dot_atom_e = p - 1
                  end
                  begin
                    if address_s
                      if address.local.nil? && local_dot_atom_pre_comment_e && local_dot_atom_s && local_dot_atom_e
                        if address.domain
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_e)
                        else
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_pre_comment_e)
                        end
                      end
                      address.raw = chars(data, address_s, p - 1)
                      address_list.addresses << address if address

                      # Start next address
                      address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
                      address.group = group_name
                      address_s = nil
                    end
                  end
                when 37
                  begin
                    local_dot_atom_pre_comment_e = p - 1
                  end
                  begin
                    local_dot_atom_e = p - 1
                  end
                  begin
                    address.local = '"' + qstr + '"' if address
                  end
                when 57
                  begin
                    address.obs_domain_list = chars(data, obs_domain_list_s, p - 1)
                  end
                  begin
                    local_dot_atom_s = p
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 2449
                      _goto_level = _again
                      next
                    end
                  end
                when 44
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 2449
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                    phrase_e = p - 1
                  end
                  begin
                    domain_s = p
                  end
                when 31
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 2449
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                    phrase_e = p - 1
                  end
                  begin
                    local_dot_atom_pre_comment_e = p - 1
                  end
                when 40
                  begin
                    if address
                      address.comments << chars(data, comment_s, p - 2)
                    end
                    comment_s = nil
                  end
                  begin
                    local_dot_atom_e = p - 1
                  end
                  begin
                    address.local = '"' + qstr + '"' if address
                  end
                  begin
                    if address_s
                      if address.local.nil? && local_dot_atom_pre_comment_e && local_dot_atom_s && local_dot_atom_e
                        if address.domain
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_e)
                        else
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_pre_comment_e)
                        end
                      end
                      address.raw = chars(data, address_s, p - 1)
                      address_list.addresses << address if address

                      # Start next address
                      address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
                      address.group = group_name
                      address_s = nil
                    end
                  end
                when 63
                  begin
                    group_name_s = p
                  end
                  begin
                    phrase_s = p
                  end
                  begin
                    address_s = p
                  end
                  begin
                    local_dot_atom_s = p
                  end
                when 27
                  begin
                    address_s = p
                  end
                  begin
                    phrase_s = p
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 2449
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                    local_dot_atom_s = p
                  end
                when 36
                  begin
                    local_dot_atom_pre_comment_e = p - 1
                  end
                  begin
                    local_dot_atom_e = p - 1
                  end
                  begin
                    address.local = '"' + qstr + '"' if address
                  end
                  begin
                    if address_s
                      if address.local.nil? && local_dot_atom_pre_comment_e && local_dot_atom_s && local_dot_atom_e
                        if address.domain
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_e)
                        else
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_pre_comment_e)
                        end
                      end
                      address.raw = chars(data, address_s, p - 1)
                      address_list.addresses << address if address

                      # Start next address
                      address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
                      address.group = group_name
                      address_s = nil
                    end
                  end
                when 58
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 2449
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                    address_s = p
                  end
                  begin
                    phrase_s = p
                  end
                  begin
                    local_dot_atom_s = p
                  end
                when 64
                  begin
                    group_name_s = p
                  end
                  begin
                    phrase_s = p
                  end
                  begin
                    begin
                      stack[top] = cs
                      top += 1
                      cs = 2449
                      _goto_level = _again
                      next
                    end
                  end
                  begin
                    address_s = p
                  end
                  begin
                    local_dot_atom_s = p
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
                when 12
                  begin
                    if address
                      address.comments << chars(data, comment_s, p - 2)
                    end
                    comment_s = nil
                  end
                when 34
                  begin
                    if address_s
                      if address.local.nil? && local_dot_atom_pre_comment_e && local_dot_atom_s && local_dot_atom_e
                        if address.domain
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_e)
                        else
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_pre_comment_e)
                        end
                      end
                      address.raw = chars(data, address_s, p - 1)
                      address_list.addresses << address if address

                      # Start next address
                      address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
                      address.group = group_name
                      address_s = nil
                    end
                  end
                when 35
                  begin
                    if address
                      address.comments << chars(data, comment_s, p - 2)
                    end
                    comment_s = nil
                  end
                  begin
                    if address_s
                      if address.local.nil? && local_dot_atom_pre_comment_e && local_dot_atom_s && local_dot_atom_e
                        if address.domain
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_e)
                        else
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_pre_comment_e)
                        end
                      end
                      address.raw = chars(data, address_s, p - 1)
                      address_list.addresses << address if address

                      # Start next address
                      address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
                      address.group = group_name
                      address_s = nil
                    end
                  end
                when 45
                  begin
                    address.domain = chars(data, domain_s, p - 1).rstrip if address
                  end
                  begin
                    if address_s
                      if address.local.nil? && local_dot_atom_pre_comment_e && local_dot_atom_s && local_dot_atom_e
                        if address.domain
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_e)
                        else
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_pre_comment_e)
                        end
                      end
                      address.raw = chars(data, address_s, p - 1)
                      address_list.addresses << address if address

                      # Start next address
                      address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
                      address.group = group_name
                      address_s = nil
                    end
                  end
                when 33
                  begin
                    local_dot_atom_e = p - 1
                  end
                  begin
                    if address_s
                      if address.local.nil? && local_dot_atom_pre_comment_e && local_dot_atom_s && local_dot_atom_e
                        if address.domain
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_e)
                        else
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_pre_comment_e)
                        end
                      end
                      address.raw = chars(data, address_s, p - 1)
                      address_list.addresses << address if address

                      # Start next address
                      address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
                      address.group = group_name
                      address_s = nil
                    end
                  end
                when 49
                  begin
                    address.local = '"' + qstr + '"' if address
                  end
                  begin
                    if address_s
                      if address.local.nil? && local_dot_atom_pre_comment_e && local_dot_atom_s && local_dot_atom_e
                        if address.domain
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_e)
                        else
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_pre_comment_e)
                        end
                      end
                      address.raw = chars(data, address_s, p - 1)
                      address_list.addresses << address if address

                      # Start next address
                      address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
                      address.group = group_name
                      address_s = nil
                    end
                  end
                when 46
                  begin
                    if address
                      address.comments << chars(data, comment_s, p - 2)
                    end
                    comment_s = nil
                  end
                  begin
                    address.domain = chars(data, domain_s, p - 1).rstrip if address
                  end
                  begin
                    if address_s
                      if address.local.nil? && local_dot_atom_pre_comment_e && local_dot_atom_s && local_dot_atom_e
                        if address.domain
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_e)
                        else
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_pre_comment_e)
                        end
                      end
                      address.raw = chars(data, address_s, p - 1)
                      address_list.addresses << address if address

                      # Start next address
                      address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
                      address.group = group_name
                      address_s = nil
                    end
                  end
                when 47
                  begin
                    if address
                      address.comments << chars(data, comment_s, p - 2)
                    end
                    comment_s = nil
                  end
                  begin
                    local_dot_atom_e = p - 1
                  end
                  begin
                    if address_s
                      if address.local.nil? && local_dot_atom_pre_comment_e && local_dot_atom_s && local_dot_atom_e
                        if address.domain
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_e)
                        else
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_pre_comment_e)
                        end
                      end
                      address.raw = chars(data, address_s, p - 1)
                      address_list.addresses << address if address

                      # Start next address
                      address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
                      address.group = group_name
                      address_s = nil
                    end
                  end
                when 51
                  begin
                    if address
                      address.comments << chars(data, comment_s, p - 2)
                    end
                    comment_s = nil
                  end
                  begin
                    address.local = '"' + qstr + '"' if address
                  end
                  begin
                    if address_s
                      if address.local.nil? && local_dot_atom_pre_comment_e && local_dot_atom_s && local_dot_atom_e
                        if address.domain
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_e)
                        else
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_pre_comment_e)
                        end
                      end
                      address.raw = chars(data, address_s, p - 1)
                      address_list.addresses << address if address

                      # Start next address
                      address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
                      address.group = group_name
                      address_s = nil
                    end
                  end
                when 38
                  begin
                    local_dot_atom_e = p - 1
                  end
                  begin
                    address.local = '"' + qstr + '"' if address
                  end
                  begin
                    if address_s
                      if address.local.nil? && local_dot_atom_pre_comment_e && local_dot_atom_s && local_dot_atom_e
                        if address.domain
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_e)
                        else
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_pre_comment_e)
                        end
                      end
                      address.raw = chars(data, address_s, p - 1)
                      address_list.addresses << address if address

                      # Start next address
                      address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
                      address.group = group_name
                      address_s = nil
                    end
                  end
                when 32
                  begin
                    local_dot_atom_pre_comment_e = p - 1
                  end
                  begin
                    local_dot_atom_e = p - 1
                  end
                  begin
                    if address_s
                      if address.local.nil? && local_dot_atom_pre_comment_e && local_dot_atom_s && local_dot_atom_e
                        if address.domain
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_e)
                        else
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_pre_comment_e)
                        end
                      end
                      address.raw = chars(data, address_s, p - 1)
                      address_list.addresses << address if address

                      # Start next address
                      address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
                      address.group = group_name
                      address_s = nil
                    end
                  end
                when 40
                  begin
                    if address
                      address.comments << chars(data, comment_s, p - 2)
                    end
                    comment_s = nil
                  end
                  begin
                    local_dot_atom_e = p - 1
                  end
                  begin
                    address.local = '"' + qstr + '"' if address
                  end
                  begin
                    if address_s
                      if address.local.nil? && local_dot_atom_pre_comment_e && local_dot_atom_s && local_dot_atom_e
                        if address.domain
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_e)
                        else
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_pre_comment_e)
                        end
                      end
                      address.raw = chars(data, address_s, p - 1)
                      address_list.addresses << address if address

                      # Start next address
                      address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
                      address.group = group_name
                      address_s = nil
                    end
                  end
                when 36
                  begin
                    local_dot_atom_pre_comment_e = p - 1
                  end
                  begin
                    local_dot_atom_e = p - 1
                  end
                  begin
                    address.local = '"' + qstr + '"' if address
                  end
                  begin
                    if address_s
                      if address.local.nil? && local_dot_atom_pre_comment_e && local_dot_atom_s && local_dot_atom_e
                        if address.domain
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_e)
                        else
                          address.local = chars(data, local_dot_atom_s, local_dot_atom_pre_comment_e)
                        end
                      end
                      address.raw = chars(data, address_s, p - 1)
                      address_list.addresses << address if address

                      # Start next address
                      address = AddressStruct.new(nil, nil, [], nil, nil, nil, nil)
                      address.group = group_name
                      address_s = nil
                    end
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

        if p != eof || cs < 2461
          raise Mail::Field::IncompleteParseError.new(Mail::AddressList, data, p)
        end

        address_list
      end
    end
  end
ensure
  $VERBOSE = original_verbose
end
