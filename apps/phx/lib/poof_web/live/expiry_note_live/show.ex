defmodule PoofWeb.ExpiryNoteLive.Show do
  use PoofWeb, :live_view

  alias Poof.ExpiryNotes

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Expiry note {@expiry_note.id}
        <:subtitle>This is a expiry_note record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/admin/expiry_notes"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/admin/expiry_notes/#{@expiry_note}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit expiry_note
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Body">{@expiry_note.body}</:item>
        <:item title="Expiration">{@expiry_note.expiration}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Expiry note")
     |> assign(:expiry_note, ExpiryNotes.get_expiry_note!(id))}
  end
end
