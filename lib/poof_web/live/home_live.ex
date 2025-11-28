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
      <form class="join flex" phx-change="validate" phx-submit="save">
        <input
          name="expiry_note[body]"
          value=""
          placeholder="What would you like to down later?"
          class="input flex-1 join-item"
        />

        <button
          class="btn btn-primary join-item"
          navigate={~p"/expiry_notes/new"}
          disabled={!@expiry_note_valid?}
        >
          <.icon name="hero-plus" /> Add
        </button>
      </form>

      <div id="expiry_notes" class="space-y-2">
        <ExpiryNoteComponents.expiry_note
          :for={expiry_note <- @new_expiry_notes}
          id={"expiry_note-#{expiry_note.id}"}
          expiry_note={expiry_note}
          editing?={expiry_note.id == @editing_id}
          fresh?={true}
        />
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
  def mount(_params, _session, socket) do
    if socket.assigns.current_scope do
      if connected?(socket) do
        ExpiryNotes.subscribe_expiry_notes(socket.assigns.current_scope)
      end

      {:ok,
       socket
       |> assign(
         editing_id: nil,
         expiry_notes: ExpiryNotes.list_expiry_notes(socket.assigns.current_scope),
         new_expiry_notes: [],
         expiry_note_valid?: false
       )}
    else
      {:ok, redirect(socket, to: ~p"/users/log-in")}
    end
  end

  # ------------------------------------------------------------------------------------------------
  # Events
  # ------------------------------------------------------------------------------------------------

  @impl true
  def handle_event("validate", %{"expiry_note" => %{"body" => body}}, socket) do
    IO.inspect(body)

    {:noreply, assign(socket, expiry_note_valid?: !is_nil(body) and body != "")}
  end

  @impl true
  def handle_event("save", %{"expiry_note" => expiry_note_params}, socket) do
    expiry_note_params =
      Map.put(expiry_note_params, "expiration", DateTime.add(DateTime.utc_now(), 1, :day))

    case ExpiryNotes.create_expiry_note(socket.assigns.current_scope, expiry_note_params) do
      {:ok, expiry_note} ->
        {:noreply,
         assign(socket,
           new_expiry_notes: [expiry_note | socket.assigns.new_expiry_notes],
           expiry_note_valid?: false
         )}

      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply, put_flash(socket, :error, "Error adding reminder")}
    end
  end

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
