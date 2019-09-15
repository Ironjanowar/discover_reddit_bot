defmodule DiscoverRedditBotTest do
  use ExUnit.Case
  doctest DiscoverRedditBot

  test "greets the world" do
    assert DiscoverRedditBot.hello() == :world
  end
end
