defmodule DiscoverRedditBot.RedditClient do
  use Tesla

  require Logger

  def get_comments(url) do
    case get("#{url}.json") do
      {:ok, %{body: body}} ->
        {:ok, body}

      err ->
        Logger.error("""
        Error while getting comments from: #{url}
        Error: #{inspect(err)}
        """)

        :error
    end
  end
end
