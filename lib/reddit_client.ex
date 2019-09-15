defmodule DiscoverRedditBot.RedditClient do
  use Tesla

  require Logger

  def client(user) do
    middlewares = [
      {Tesla.Middleware.BaseUrl, "https://www.reddit.com/api/v1"},
      {Tesla.Middleware.BasicAuth, user},
      Tesla.Middleware.FormUrlencoded
    ]

    Tesla.client(middlewares)
  end

  # def authorized_client(token) do
  # end

  def get_access_token(credentials) do
    result =
      credentials
      |> client()
      |> post("/access_token", %{grant_type: "client_credentials"})

    with {:ok, %{body: response}} <- result,
         {:ok, %{"access_token" => access_token}} <- Jason.decode(response) do
      {:ok, access_token}
    else
      err -> err |> inspect |> Logger.debug()
    end
  end
end
