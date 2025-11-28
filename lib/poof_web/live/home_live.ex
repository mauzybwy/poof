defmodule PoofWeb.HomeLive do
  use PoofWeb, :live_view

  alias Poof.ExpiryNotes
  alias PoofWeb.ExpiryNoteComponents

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

      <div id="expiry_notes" class="space-y-2">
        <ExpiryNoteComponents.expiry_note
          :for={expiry_note <- @expiry_notes}
          id={"expiry_note-#{expiry_note.id}"}
          expiry_note={expiry_note}
          editing?={expiry_note.id == @editing_id}
        />
      </div>
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
      if connected?(socket) do
        ExpiryNotes.subscribe_expiry_notes(socket.assigns.current_scope)
      end

      {:ok,
       socket
       |> assign(
         editing_id: nil,
         expiry_notes: ExpiryNotes.list_expiry_notes(socket.assigns.current_scope)
       )}
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

    {:noreply,
     assign(socket,
       expiry_notes: ExpiryNotes.list_expiry_notes(socket.assigns.current_scope)
     )}
  end

  @impl true
  def handle_event("edit", %{"expiry_note_id" => expiry_note_id}, socket) do
    {:noreply, assign(socket, editing_id: String.to_integer(expiry_note_id))}
  end

  @impl true
  def handle_event("edit-cancel", _params, socket) do
    {:noreply, assign(socket, editing_id: nil)}
  end

  @impl true
  def handle_event("edit-save", _params, socket) do
    {:noreply, assign(socket, editing_id: nil)}
  end
end
