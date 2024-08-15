# frozen_string_literal: true

require_relative "partial_change/version"

module Rspec
  # This RSpec matcher partial_change is designed to test if specific keys in a hash-like object have changed as expected.
  # It supports from and to chaining for asserting the exact values before and after the change,
  # but does not support usage with not_to.
  module PartialChange
    extend RSpec::Matchers::DSL

    RSpec::Matchers.define :partial_change do |object, changed_keys|
      supports_block_expectations

      match do |block|
        @before = object.dup
        block.call
        @after = object

        @from_subset = @before.slice(*changed_keys)
        @to_subset = @after.slice(*changed_keys)

        unchanged_keys = @before.keys - changed_keys

        # Check that unchanged keys have not been modified
        unchanged_keys_still_same = unchanged_keys.all? { |key| @before[key] == @after[key] }

        # Check that the specified "from" subset matches the before state
        from_matches = @from.nil? || @from_subset == @from

        # Check that the specified "to" subset matches the after state
        to_matches = @to.nil? || @to_subset == @to

        unchanged_keys_still_same && from_matches && to_matches
      end

      match_when_negated do |_block|
        raise NotImplementedError,
              "The `partial_change` matcher does not support `not_to` usage. Please use it with `to`."
      end

      chain :from do |before|
        @from = before
      end

      chain :to do |after|
        @to = after
      end

      failure_message do
        messages = []
        messages << "from #{@from}" if @from
        messages << "to #{@to}" if @to
        expected_change = messages.empty? ? "for keys #{changed_keys}" : messages.join(" ")

        "expected #{object} to change #{expected_change}, but got #{@from_subset} to #{@to_subset}"
      end

      failure_message_when_negated do
        "expected #{object} not to change for keys #{changed_keys}, but changes were detected."
      end

      def unchanged_keys
        @before.keys
      end
    end
  end
end
