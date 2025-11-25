defmodule PoofWeb.ExpiryNoteLive.Show do
  use PoofWeb, :live_view

  alias Poof.ExpiryNotes

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Expiry note {@expiry_note.id}
        <:subtitle>This is a expiry_note record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/expiry_notes"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/expiry_notes/#{@expiry_note}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit expiry_note
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Body">{@expiry_note.body}</:item>
        <:item title="Expiration">
          <time id="expiry_note-#{@expiry_note.id}-expiration" phx-hook="LocalTime">
            {DateTime.to_iso8601(@expiry_note.expiration)}
          </time>
        </:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      ExpiryNotes.subscribe_expiry_notes(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Expiry note")
     |> assign(:expiry_note, ExpiryNotes.get_expiry_note!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Poof.ExpiryNotes.ExpiryNote{id: id} = expiry_note},
        %{assigns: %{expiry_note: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :expiry_note, expiry_note)}
  end

  def handle_info(
        {:deleted, %Poof.ExpiryNotes.ExpiryNote{id: id}},
        %{assigns: %{expiry_note: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current expiry_note was deleted.")
     |> push_navigate(to: ~p"/expiry_notes")}
  end

  def handle_info({type, %Poof.ExpiryNotes.ExpiryNote{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
