defmodule DiscoverRedditBot.TokenRefresh do
  use GenServer

  require Logger
  alias DiscoverRedditBot.RedditClient

  # Erlang diffs time in microseconds (for whatever reason)
  @token_age 60 * 60 * 1000 * 1000
  @credentials File.read!("reddit.auth") |> Jason.decode!()

  # Child specification
  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    }
  end

  # Client API
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def get_token() do
    GenServer.call(__MODULE__, :get_token)
  end

  # Server callbacks
  def init(_) do
    {:ok, token} = obtain_token()
    {:ok, %{token: token, token_time: :os.timestamp()}}
  end

  def handle_call(:get_token, _from, %{token: token, token_time: token_time} = state) do
    now = :os.timestamp()
    # Refresh token if it has expired
    if(:timer.now_diff(now, token_time) > @token_age) do
      Logger.debug("Refreshing token...")
      {:ok, new_token} = obtain_token()
      {:reply, {:ok, new_token}, %{token: new_token, token_time: now}}
    else
      {:reply, {:ok, token}, state}
    end
  end

  # Private
  defp obtain_token() do
    user = %{
      username: @credentials["username"],
      password: @credentials["password"],
      client_id: @credentials["client_id"],
      client_secret: @credentials["client_secret"]
    }

    Logger.info("Getting access token...")

    case RedditClient.get_access_token(user) do
      {:ok, %{"error" => _} = error} ->
        Logger.error("Error received: #{inspect(error)}")
        Logger.error("Trying again...")
        obtain_token()

      {:ok, token} ->
        Logger.info("Token obtained")
        {:ok, token}

      _ ->
        Logger.error("Error getting the token, trying again...")
        obtain_token()
    end
  end
end
