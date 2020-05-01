defmodule DiscoverRedditBot.Parser do
  alias DiscoverRedditBot.RedditClient

  def extract_urls(text) do
    text
    |> String.split(~r/(\s|\n)/, trim: true)
    |> Enum.filter(&String.match?(&1, ~r/^(http|https):\/\/(www\.|old\.|)reddit.com/))
  end

  @doc """
  This function expects the full json from reddit as a string
  """
  @spec extract_subrredits(String.t()) :: {:ok, [String.t()]}
  def extract_subrredits(text) do
    Regex.scan(~r/\/?r\/[a-z0-9]*(\s|\\")/i, text)
    |> Enum.map(fn [match, rest | _] ->
      subreddit = String.replace(match, rest, "")

      case String.starts_with?(subreddit, "r/") do
        true -> "/#{subreddit}"
        _ -> subreddit
      end
    end)
    |> MapSet.new()
    |> MapSet.to_list()
  end

  def get_subreddits(text) do
    text
    |> extract_urls()
    |> Enum.map(fn url ->
      case RedditClient.get_comments(url) do
        {:ok, comments} -> extract_subrredits(comments)
        _ -> []
      end
    end)
    |> List.flatten()
  end
end
