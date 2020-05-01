defmodule DiscoverRedditBot.Bot do
  @bot :discover_reddit_bot

  require Logger

  alias DiscoverRedditBot.{Parser, TextFormatter}

  use ExGram.Bot,
    name: @bot,
    setup_commands: true

  command("start", description: "Starts the bot")
  command("help", description: "Print the bot's help")

  middleware(ExGram.Middleware.IgnoreUsername)

  def bot(), do: @bot

  def handle({:command, :start, _msg}, context) do
    answer(context, "Hi!")
  end

  def handle({:command, :help, _msg}, context) do
    answer(
      context,
      "Send me any reddit comments url and I'll show you what subrredits are mentioned there!"
    )
  end

  def handle({:text, text, _msg}, context) do
    %{subreddits: subreddits_detected, urls: urls} = Parser.get_subreddits(text)
    message = TextFormatter.format_subreddits(subreddits_detected, urls)

    if subreddits_detected != [] do
      answer(context, message, parse_mode: "Markdown")
    end
  end

  def handle({:inline_query, %{query: text}}, context) do
    %{subreddits: subreddits_detected, urls: urls} = Parser.get_subreddits(text)
    articles = TextFormatter.get_inline_articles(subreddits_detected, urls)

    if subreddits_detected == [] do
      answer_inline_query(context, TextFormatter.get_no_subreddits_inline())
    else
      answer_inline_query(context, articles)
    end
  end
end
