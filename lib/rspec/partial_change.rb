# frozen_string_literal: true

require_relative "partial_change/version"

module Rspec
  # This RSpec matcher is designed to test if specific keys in a hash-like object have changed as expected.
  # It supports from and to chaining for asserting the exact values before and after the change,
  # but does not support usage with not_to.
  module PartialChange
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :partial_change do |object, keys|
      supports_block_expectations

      match do |block|
        all_keys = extract_all_keys(object)
        # オブジェクト全体の前の状態をディープコピーして保持
        @before_state = deep_clone(object)

        # 実行して変更を適用
        block.call

        # オブジェクト全体の後の状態をディープコピーして保持
        @after_state = deep_clone(object)

        # 差分がでているキーを探す
        changed_keys = []
        all_keys.each do |key|
          before_value = @before_state.dig(*key)
          next if !keys.include?(key) && before_value.is_a?(Hash)

          changed_keys << key if @before_state.dig(*key) != @after_state.dig(*key)
        end

        # 差分がでているキーが指定されたキーと一致しているか
        return false unless keys.sort == changed_keys.sort

        # from と to が指定されている場合はそれに一致しているか
        return false unless @expected_from && expected_from?
        return false unless @expected_to && expected_to?

        true
      end

      match_when_negated do |_block|
        keys.none? do |key|
          @before_state.dig(*key) != @after_state.dig(*key)
        end
      end

      chain :from do |expected|
        @expected_from = expected
      end

      chain :to do |expected|
        @expected_to = expected
      end

      def expected_from?
        keys = extract_all_keys(@expected_from)

        keys.all? do |key|
          @before_state.dig(*key) == @expected_from.dig(*key)
        end
      end

      def expected_to?
        keys = extract_all_keys(@expected_to)

        keys.all? do |key|
          @after_state.dig(*key) == @expected_to.dig(*key)
        end
      end

      def extract_all_keys(hash, prefix = [])
        keys = []
        hash.each do |k, v|
          full_key = prefix + [k]
          keys << full_key
          keys.concat(extract_all_keys(v, full_key)) if v.is_a?(Hash)
        end

        # 各配列を文字列として表現し、それをキーにしてグループ化
        grouped_by_key = keys.group_by(&:itself)

        # 最も深いネストを持つものを選ぶ
        grouped_by_key.keys.reject do |key|
          grouped_by_key.keys.any? { |other| other != key && other[0...key.size] == key }
        end
      end

      def deep_clone(obj)
        Marshal.load(Marshal.dump(obj))
      end
    end
  end
end
