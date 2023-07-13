defmodule AlgoThink.ChatMessagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `AlgoThink.ChatMessages` context.
  """

  @doc """
  Generate a chat_message.
  """
  def chat_message_fixture(attrs \\ %{}) do
    {:ok, chat_message} =
      attrs
      |> Enum.into(%{

      })
      |> AlgoThink.ChatMessages.create_chat_message()

    chat_message
  end
end
