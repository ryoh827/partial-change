# frozen_string_literal: true

require "rspec/partial_change"

RSpec.describe "partial_change matcher" do
  let(:object) { { a: 1, b: 2, c: 3 } }

  it "matches when specified keys change as expected" do
    expect do
      object[:b] = 99
    end.to partial_change(object, [:b]).from(b: 2).to(b: 99)
  end

  it "matches when only changed keys are specified and no from/to is provided" do
    expect do
      object[:b] = 99
    end.to partial_change(object, [:b])
  end

  it "matches when multiple keys change as expected" do
    expect do
      object[:a] = 10
      object[:b] = 99
    end.to partial_change(object, %i[a b]).from(a: 1, b: 2).to(a: 10, b: 99)
  end

  it "raises an error when used with `not_to`" do
    expect do
      expect do
        object[:b] = 99
      end.not_to partial_change(object, [:b])
    end.to raise_error(NotImplementedError,
                       "The `partial_change` matcher does not support `not_to` usage. Please use it with `to`.")
  end

  it "fails when the 'from' value does not match the actual initial value" do
    expect do
      expect do
        object[:b] = 99
      end.to partial_change(object, [:b]).from(b: 3).to(b: 99)
    end.to raise_error(RSpec::Expectations::ExpectationNotMetError,
                       /expected \{:a=>1, :b=>99, :c=>3\} to change from \{:b=>3\} to \{:b=>99\}, but got \{:b=>2\} to \{:b=>99\}/)
  end

  it "fails when the 'to' value does not match the actual final value" do
    expect do
      expect do
        object[:b] = 98
      end.to partial_change(object, [:b]).from(b: 2).to(b: 99)
    end.to raise_error(RSpec::Expectations::ExpectationNotMetError,
                       /expected \{:a=>1, :b=>98, :c=>3\} to change from \{:b=>2\} to \{:b=>99\}, but got \{:b=>2\} to \{:b=>98\}/)
  end

  it "fails when an unchanged key is modified" do
    expect do
      expect do
        object[:a] = 100
        object[:b] = 99
      end.to partial_change(object, [:b])
    end.to raise_error(RSpec::Expectations::ExpectationNotMetError,
                       /expected \{:a=>100, :b=>99, :c=>3\} to change for keys \[:b\], but got \{:b=>2\} to \{:b=>99\}/)
  end
end
