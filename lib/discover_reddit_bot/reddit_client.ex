defmodule DiscoverRedditBot.RedditClient do
  use Tesla

  require Logger

  alias DiscoverRedditBot.TokenRefresh

  def client(user) do
    Logger.debug("user: #{inspect(user)}")

    middlewares = [
      {Tesla.Middleware.BaseUrl, "https://www.reddit.com/api/v1"},
      {Tesla.Middleware.BasicAuth, %{username: user[:client_id], password: user[:client_secret]}},
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
      |> post("/access_token", %{
        grant_type: "password",
        username: credentials[:username],
        password: credentials[:password]
      })

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

  def get_json(url) do
    with {:ok, %{body: body}} <- get("#{url}.json"),
         {:ok, decoded_body} <- Jason.decode(body),
         childs =
           Enum.map(decoded_body, fn entity -> entity["data"]["children"] end) |> List.flatten(),
         comments = Enum.filter(childs, fn child -> child["kind"] == "t1" end),
         parsed_comments =
           Enum.map(comments, fn c -> %{author: c["data"]["author"], text: c["data"]["body"]} end) do
      {:ok, parsed_comments}
    else
      err ->
        Logger.error("""
        Error while getting: #{url}
        Error: #{inspect(err)}
        """)

        {:error, "Error while getting: #{url}"}
    end
  end
end
