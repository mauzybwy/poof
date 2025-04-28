defmodule PoofWeb.ExpiryNoteLive.Index do
  use PoofWeb, :live_view

  alias Poof.ExpiryNotes

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Expiry notes
        <:actions>
          <.button variant="primary" navigate={~p"/expiry_notes/new"}>
            <.icon name="hero-plus" /> New Expiry note
          </.button>
        </:actions>
      </.header>

      <.table
        id="expiry_notes"
        rows={@streams.expiry_notes}
        row_click={fn {_id, expiry_note} -> JS.navigate(~p"/expiry_notes/#{expiry_note}") end}
      >
        <:col :let={{_id, expiry_note}} label="Body">{expiry_note.body}</:col>
        <:col :let={{_id, expiry_note}} label="Expiration">{expiry_note.expiration}</:col>
        <:action :let={{_id, expiry_note}}>
          <div class="sr-only">
            <.link navigate={~p"/expiry_notes/#{expiry_note}"}>Show</.link>
          </div>
          <.link navigate={~p"/expiry_notes/#{expiry_note}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, expiry_note}}>
          <.link
            phx-click={JS.push("delete", value: %{id: expiry_note.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Expiry notes")
     |> stream(:expiry_notes, ExpiryNotes.list_expiry_notes())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    expiry_note = ExpiryNotes.get_expiry_note!(id)
    {:ok, _} = ExpiryNotes.delete_expiry_note(expiry_note)

    {:noreply, stream_delete(socket, :expiry_notes, expiry_note)}
  end
end
