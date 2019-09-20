defmodule DiscoverRedditBot.RedditClient do
  use Tesla

  require Logger

  alias DiscoverRedditBot.TokenRefresh

  def client(user) do
    middlewares = [
      {Tesla.Middleware.BaseUrl, "https://www.reddit.com/api/v1"},
      {Tesla.Middleware.BasicAuth, user},
      Tesla.Middleware.FormUrlencoded
    ]

    Tesla.client(middlewares)
  end

  def authorized_client(token) do
    middlewares = [
      {Tesla.Middleware.BaseUrl, "https://oauth.reddit.com/api"},
      {Tesla.Middleware.Headers,
       [
         {"Authorization", "Bearer #{token}"},
         {"User-Agent", "DiscoverRedditBot/0.1.0 by Ironjanowar"}
       ]}
    ]

    Tesla.client(middlewares)
  end

  def get_access_token(credentials) do
    result =
      credentials
      |> client()
      |> post("/access_token", %{grant_type: "client_credentials"})

    with {:ok, %{body: response}} <- result,
         {:ok, %{"access_token" => access_token}} <- Jason.decode(response) do
      {:ok, access_token}
    else
      err ->
        err |> inspect |> Logger.debug()
        err
    end
  end

  # API requests
  def get_comments(article) do
    {:ok, token} = TokenRefresh.get_token()

    token
    |> authorized_client()
    |> get("/comments/#{article}",
      query: [
        context: 0,
        showedits: false,
        showmore: false,
        sort: "top",
        threaded: false,
        truncate: 0
      ]
    )
  end

  def get_me() do
    {:ok, token} = TokenRefresh.get_token()

    token
    |> authorized_client()
    |> get("/v1/me")
  end

  def raw(endpoint, query) do
    {:ok, token} = TokenRefresh.get_token()

    token
    |> authorized_client()
    |> get(endpoint, query)
  end
end
