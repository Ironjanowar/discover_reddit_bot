defmodule DiscoverRedditBot.TextFormatter do
  alias ExGram.Model.{InlineQueryResultArticle, InputTextMessageContent}

  def reddit_base_url(), do: "https://www.reddit.com"

  def format_subreddits(subreddits) do
    subredits_message =
      subreddits
      |> Enum.map(&format_subreddit/1)
      |> Enum.join("\n")

    "Subreddits detected:\n#{subredits_message}"
  end

  def format_subreddit(sub), do: "  - [#{sub}](#{reddit_base_url()}#{sub})"
  def format_subreddit(sub, :for_inline), do: "[#{sub}](#{reddit_base_url()}#{sub})"

  def get_inline_articles(subreddits) do
    articles =
      Enum.map(subreddits, fn sub ->
        %InlineQueryResultArticle{
          type: "article",
          id: sub,
          title: sub,
          input_message_content: %InputTextMessageContent{
            message_text: format_subreddit(sub, :for_inline),
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

  def get_no_subreddits_inline() do
    [
      %InlineQueryResultArticle{
        type: "article",
        id: "nosubs",
        title: "No subreddits detected",
        input_message_content: %InputTextMessageContent{
          message_text: "No subreddits detected"
        }
      }
    ]
  end
end
