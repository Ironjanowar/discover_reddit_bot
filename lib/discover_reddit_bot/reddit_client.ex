defmodule DiscoverRedditBot.RedditClient do
  use Tesla

  require Logger

  plug(Tesla.Middleware.JSON)

  def get_comments(url) do
    [url_without_params | _] = String.split(url, "?")

    case get("#{url_without_params}.json") do
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
