defmodule LiveviewChatWeb.MessageLive do
  # this file is the LiveView file (or liveview), and replaces a controller
  # mount() must be present.  render() only needed if an associated .html.heex is not in the same folder
  # handle events from templages in here
  use LiveviewChatWeb, :live_view
  alias LiveviewChat.Message

  # add 'if_connected' to check socket connection and subscibe
  def mount(_params, _session, socket) do
    if connected?(socket), do: Message.subscribe()

    messages = Message.list_messages() |> Enum.reverse()
    changeset = Message.changeset(%Message{}, %{})

    {:ok, assign(socket, messages: messages, changeset: changeset)}
  end

  def handle_event("new_message", %{"message" => params}, socket) do
    # IO.inspect(params, label: "&&&&&&&&&&  params in handle_event")

    case Message.create_message(params) do
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      # the changeset below is provided to the form to show the users hame
      # broadcast returns :ok if there are no errors
      :ok ->
        changeset = Message.changeset(%Message{}, %{"name" => params["name"]})
        # IO.inspect(changeset, label: "&&&&&&&&&&  changeset in handle_event")
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_info({:message_created, message}, socket) do
    messages = socket.assigns.messages ++ [message]
    {:noreply, assign(socket, messages: messages)}
  end
end
