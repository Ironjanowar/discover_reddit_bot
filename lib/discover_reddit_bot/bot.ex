defmodule DiscoverRedditBot.Bot do
  @bot :discover_reddit_bot

  require Logger

  alias DiscoverRedditBot.{Parser, RedditClient}

  use ExGram.Bot,
    name: @bot,
    setup_commands: true

  command("start")
  command("help", description: "Print the bot's help")

  middleware(ExGram.Middleware.IgnoreUsername)

  def bot(), do: @bot

  def handle({:command, :start, _msg}, context) do
    answer(context, "Hi!")
  end

  def handle({:command, :help, _msg}, context) do
    answer(context, "Here is your help:")
  end

  def handle({:text, text, _msg}, context) do
    [url | _] = Parser.extract_urls(text)
    {:ok, comments} = RedditClient.get_comments(url)

    message =
      Parser.extract_subrredits(comments)
      |> DiscoverRedditBot.TextFormatter.format_subreddits()

    answer(context, message, parse_mode: "Markdown")
  end

  def handle({:inline_query, %{query: text}}, context) do
    [url | _] = Parser.extract_urls(text)
    {:ok, comments} = RedditClient.get_comments(url)

    message =
      Parser.extract_subrredits(comments)
      |> DiscoverRedditBot.TextFormatter.format_subreddits()

    # TODO: generate articles
    # answer_inline_query(context, message, parse_mode: "Markdown")
  end
end
