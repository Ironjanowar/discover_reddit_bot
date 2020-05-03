defmodule DiscoverRedditBot.Parser do
  alias DiscoverRedditBot.RedditClient

  @type subreddits :: [{String.t(), non_neg_integer()}]
  @type url_subreddits :: %{String.t() => subreddits}

  @doc """
  This function expects the full json from reddit as a string
  and returns a map with key the subreddit name and value number
  of occurrences
  """
  @spec get_subreddits(String.t()) :: url_subreddits
  def get_subreddits(text) do
    text
    |> extract_urls()
    |> Stream.map(fn url ->
      case RedditClient.get_comments(url) do
        {:ok, body} ->
          subreddits = body |> extract_comments() |> extract_subrredits() |> sort_subreddits()
          {url, subreddits}

        _ ->
          {url, []}
      end
    end)
    |> Stream.filter(fn
      {_, []} -> false
      _ -> true
    end)
    |> Enum.into(%{})
  end

  defp extract_urls(text) do
    text
    |> String.split(~r/(\s|\n)/, trim: true)
    |> Enum.filter(&String.match?(&1, ~r/^(http|https):\/\/(www\.|old\.|)reddit.com/))
  end

  defp extract_comments([_post, comments | _rest]) do
    extract_comments(comments)
  end

  defp extract_comments(%{"data" => data}) do
    children_comments =
      data
      |> extract_children()
      |> Enum.flat_map(&extract_comments/1)

    case data["body"] do
      nil -> children_comments
      body -> [body | children_comments]
    end
  end

  defp extract_comments(_) do
    []
  end

  defp extract_children(data) do
    case {data["children"], data["replies"]} do
      {c, r} when is_list(c) and is_map(r) -> [r | c]
      {c, _} when is_list(c) -> c
      {_, r} when is_map(r) -> [r]
      _ -> []
    end
  end

  defp extract_subrredits(comments) do
    text = comments |> Enum.join("\n")

    Regex.scan(~r/[ ^\/](r\/[a-zA-Z0-9-_]+)\b/i, text)
    |> Enum.reduce(%{}, fn [_, match | _], acc ->
      name = "/" <> match
      current = Map.get(acc, name, 0)

      Map.put(acc, name, current + 1)
    end)
  end

  defp sort_subreddits(subreddits) do
    Enum.sort_by(subreddits, fn {_k, v} -> v end, &(&1 > &2))
  end
end
