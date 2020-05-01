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
    Regex.scan(~r/[ ^\/](r\/[a-zA-Z0-9-_]+)\b/i, text)
    |> Enum.reduce(MapSet.new(), fn [_, match | _], acc -> MapSet.put(acc, "/#{match}") end)
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
