defmodule DiscoverRedditBot.TextFormatter do
  def reddit_base_url(), do: "https://www.reddit.com"

  def format_subreddits(subreddits) do
    subredits_message =
      subreddits
      |> Enum.map(fn sub -> "  - [#{sub}](#{reddit_base_url()}#{sub})" end)
      |> Enum.join("\n")

    "Subreddits detected:\n#{subredits_message}"
  end
end
