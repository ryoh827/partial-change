# frozen_string_literal: true

require "rspec/partial_change"

RSpec.describe "partial_change matcher" do
  it "only changes the specified nested object attribute and leaves others unchanged" do
    object = {
      user: {
        name: "Alice",
        address: {
          city: "New York",
          zip: "10001"
        }
      }
    }

    expect do
      object[:user][:address][:city] = "San Francisco"
    end.to partial_change(object, [%i[user address city]])
      .from({ user: { address: { city: "New York" } } })
      .to({ user: { address: { city: "San Francisco" } } })
  end

  # zip も変更されている場合
  it "only changes the specified nested object attribute and leaves others unchanged" do
    object = {
      user: {
        name: "Alice",
        address: {
          city: "New York",
          zip: "10001"
        }
      }
    }

    expect do
      object[:user][:address][:city] = "San Francisco"
      object[:user][:address][:zip] = "10008"
    end.to partial_change(object, [%i[user address city], %i[user address zip]])
      .from({ user: { address: { city: "New York", zip: "10001" } } })
      .to({ user: { address: { city: "San Francisco", zip: "10008" } } })
  end
end
