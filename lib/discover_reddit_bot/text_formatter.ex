defmodule DiscoverRedditBot.TextFormatter do
  alias ExGram.Model.{InlineQueryResultArticle, InputTextMessageContent}

  @type subreddits :: DiscoverRedditBot.Parser.subreddits()

  def reddit_base_url(), do: "https://www.reddit.com"

  @spec format_subreddits(subreddits) :: String.t()
  def format_subreddits(subreddits) do
    subredits_message =
      subreddits
      |> Stream.map(&format_subreddit/1)
      |> Enum.join("\n")

    "Subreddits detected:\n#{subredits_message}"
  end

  @spec get_inline_articles(subreddits) :: [InlineQueryResultArticle.t()]
  def get_inline_articles(subreddits) do
    articles =
      Enum.map(subreddits, fn {name, n} = data ->
        title = "#{name} (#{n})"

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
        message_text: format_subreddits(subreddits),
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

  defp format_subreddit({sub, n}), do: "  - [#{sub}](#{reddit_base_url()}#{sub}) (#{n})"
  defp format_subreddit({sub, n}, :for_inline), do: "[#{sub}](#{reddit_base_url()}#{sub}) (#{n})"
end
