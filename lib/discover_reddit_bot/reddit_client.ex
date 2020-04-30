defmodule DiscoverRedditBot.RedditClient do
  use Tesla

  require Logger

  defp parse_comments(childs) do
    Enum.filter(childs, fn child -> child["kind"] == "t1" end)
    |> Enum.map(fn c -> %{author: c["data"]["author"], text: c["data"]["body"]} end)
  end

  defp get_children_comments(childs) do
    Enum.map(childs, fn child ->
      case child do
        %{"kind" => "Listing"} ->
          get_children_comments(child["data"]["children"])

        %{"data" => %{"children" => children}} ->
          parse_comments(child) ++ get_children_comments(children)

        _ ->
          parse_comments(child)
      end
    end)
  end

  # API requests
  def raw_get_comments(url) do
    with {:ok, %{body: body}} <- get("#{url}.json"),
         {:ok, decoded_body} <- Jason.decode(body) do
      {:ok, decoded_body}
    else
      err ->
        Logger.error("""
        Error while getting comments from: #{url}
        Error: #{inspect(err)}
        """)

        {:error, "Error while getting comments from: #{url}"}
    end
  end

  def get_comments(url) do
    case get("#{url}.json") do
      {:ok, %{body: body}} ->
        {:ok, body}

      err ->
        Logger.error("""
        Error while getting comments from: #{url}
        Error: #{inspect(err)}
        """)
    end
  end

  # def get_comments(url) do
  #   with {:ok, %{body: body}} <- get("#{url}.json"),
  #        {:ok, decoded_body} <- Jason.decode(body),
  #        childs =
  #          Enum.map(decoded_body, fn entity -> entity["data"]["children"] end) |> List.flatten(),
  #        comments = Enum.filter(childs, fn child -> child["kind"] == "t1" end),
  #        parsed_comments =
  #          Enum.map(comments, fn c -> %{author: c["data"]["author"], text: c["data"]["body"]} end) do
  #     {:ok, parsed_comments}
  #   else
  #     err ->
  #       Logger.error("""
  #       Error while getting comments from: #{url}
  #       Error: #{inspect(err)}
  #       """)

  #       {:error, "Error while getting comments from: #{url}"}
  #   end
  # end
end
