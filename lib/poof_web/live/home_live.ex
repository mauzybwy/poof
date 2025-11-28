defmodule PoofWeb.HomeLive do
  use PoofWeb, :live_view

  alias Poof.ExpiryNotes

  # ================================================================================================
  # Render
  # ================================================================================================

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Your Reminders
        <:actions>
          <.button variant="primary" navigate={~p"/expiry_notes/new"}>
            <.icon name="hero-plus" /> Add
          </.button>
        </:actions>
      </.header>

      <.table
        id="expiry_notes"
        rows={@streams.expiry_notes}
        row_click={fn {_id, expiry_note} -> JS.navigate(~p"/expiry_notes/#{expiry_note}") end}
      >
        <:col :let={{_id, expiry_note}} label={~H"<.icon name=\"hero-clock\" />"} class="w-36">
          {Timex.format!(expiry_note.expiration, "{relative}", :relative)}
        </:col>
        <:col :let={{_id, expiry_note}} label="Body">{expiry_note.body}</:col>
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

  # ================================================================================================
  # Lifecycle
  # ================================================================================================

  # ------------------------------------------------------------------------------------------------
  # Mount
  # ------------------------------------------------------------------------------------------------

  @impl true
  def mount(_params, session, socket) do
    if socket.assigns.current_scope do
      timezone =
        case Phoenix.LiveView.get_connect_params(socket) do
          %{"timezone" => tz} -> tz
          # Fallback to a default or session value
          _ -> session["timezone"] || "UTC"
        end

      if connected?(socket) do
        ExpiryNotes.subscribe_expiry_notes(socket.assigns.current_scope)
      end

      {:ok,
       socket
       |> assign(timezone: timezone)
       |> stream(:expiry_notes, ExpiryNotes.list_expiry_notes(socket.assigns.current_scope))}
    else
      {:ok, redirect(socket, to: ~p"/users/log-in")}
    end
  end

  # ------------------------------------------------------------------------------------------------
  # Events
  # ------------------------------------------------------------------------------------------------

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    expiry_note = ExpiryNotes.get_expiry_note!(socket.assigns.current_scope, id)
    {:ok, _} = ExpiryNotes.delete_expiry_note(socket.assigns.current_scope, expiry_note)

    {:noreply, stream_delete(socket, :expiry_notes, expiry_note)}
  end
end
