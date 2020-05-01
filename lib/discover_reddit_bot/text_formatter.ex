defmodule DiscoverRedditBot.TextFormatter do
  alias ExGram.Model.{InlineQueryResultArticle, InputTextMessageContent}

  @type url_subreddits :: DiscoverRedditBot.Parser.url_subreddits()

  def reddit_base_url(), do: "https://www.reddit.com"

  @spec format_subreddits(url_subreddits) :: String.t()
  def format_subreddits(url_subreddits) do
    url_subreddits
    |> Enum.map(fn {url, subreddits} ->
      subredits_message =
        subreddits
        |> Stream.map(&format_subreddit/1)
        |> Enum.join("\n")

      "Subreddits detected [#{url}](#{url}):\n#{subredits_message}"
    end)
    |> Enum.join("\n\n")
  end

  @spec get_inline_articles(url_subreddits) :: [InlineQueryResultArticle.t()]
  def get_inline_articles(url_subreddits) do
    articles =
      url_subreddits
      |> merge_subreddits()
      |> Enum.map(fn {name, n, urls} = data ->
        n_urls = Enum.count(urls)
        title = "#{name} (#{n} in #{n_urls} urls)"

        %InlineQueryResultArticle{
          type: "article",
          id: name,
          title: title,
          input_message_content: %InputTextMessageContent{
            message_text: format_subreddit(data, :for_inline),
            parse_mode: "Markdown"
          }
        }
      end)

    all_article = %InlineQueryResultArticle{
      type: "article",
      id: "all",
      title: "Share all subreddits found",
      input_message_content: %InputTextMessageContent{
        message_text: format_subreddits(url_subreddits),
        parse_mode: "Markdown"
      }
    }

    [all_article] ++ articles
  end

  @spec no_subreddits_text :: String.t()
  def no_subreddits_text() do
    "No subreddits detected"
  end

  @spec get_no_subreddits_inline :: [InlineQueryResultArticle.t()]
  def get_no_subreddits_inline() do
    text = no_subreddits_text()

    [
      %InlineQueryResultArticle{
        type: "article",
        id: "nosubs",
        title: text,
        input_message_content: %InputTextMessageContent{
          message_text: text
        }
      }
    ]
  end

  defp merge_subreddits(all) do
    all
    |> Enum.reduce(%{}, fn {url, subreddits}, merged ->
      Enum.reduce(subreddits, merged, fn {sub, n}, merged ->
        {current, urls} = Map.get(merged, sub, {0, []})

        data = {current + n, urls ++ [url]}
        Map.put(merged, sub, data)
      end)
    end)
    |> Enum.map(fn {sub, {n, urls}} -> {sub, n, urls} end)
  end

  defp format_subreddit({sub, n}), do: "  - [#{sub}](#{reddit_base_url()}#{sub}) (#{n})"

  defp format_subreddit({sub, n, urls}, :for_inline) do
    urls_text =
      urls
      |> Stream.map(fn url ->
        "[#{url}](#{url})"
      end)
      |> Enum.join("\n\n")

    "[#{sub}](#{reddit_base_url()}#{sub}) (#{n}) detected on URLs: \n\n#{urls_text}"
  end
end
