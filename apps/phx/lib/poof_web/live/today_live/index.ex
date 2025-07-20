defmodule PoofWeb.TodayLive.Index do
  use PoofWeb, :live_view

  alias Poof.ExpiryNotes
  alias PoofWeb.TodayLive.EditNoteComponent

  # ----------------------------------------------------------------------------
  # Mount
  # ----------------------------------------------------------------------------

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:form, to_form(ExpiryNotes.change_expiry_note(%ExpiryNotes.ExpiryNote{})))
     |> stream(:expiry_notes, ExpiryNotes.list_expiry_notes())
     |> stream(:new_expiry_notes, [])}
  end

  # ----------------------------------------------------------------------------
  # Params
  # ----------------------------------------------------------------------------

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:expiry_note, ExpiryNotes.get_expiry_note!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:expiry_note, nil)
  end

  # ----------------------------------------------------------------------------
  # Events
  # ----------------------------------------------------------------------------

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    expiry_note = ExpiryNotes.get_expiry_note!(id)
    {:ok, _} = ExpiryNotes.delete_expiry_note(expiry_note)

    {:noreply,
     socket
     |> stream_delete(:expiry_notes, expiry_note)
     |> stream_delete(:new_expiry_notes, expiry_note)}
  end

  # ----------------------------------------------------------------------------

  @impl true
  def handle_event("validate", %{"expiry_note" => expiry_note_params}, socket) do
    changeset =
      ExpiryNotes.change_expiry_note(%ExpiryNotes.ExpiryNote{}, expiry_note_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  # ----------------------------------------------------------------------------

  def handle_event("submit", %{"expiry_note" => expiry_note_params}, socket) do
    create_expiry_note(socket, expiry_note_params)
  end

  # ----------------------------------------------------------------------------
  # Handle Info Callbacks
  # ----------------------------------------------------------------------------

  @impl true
  def handle_info(
        {PoofWeb.TodayLive.EditNoteComponent, {:saved, expiry_note}},
        socket
      ) do
    {:noreply,
     socket
     |> stream_insert(:expiry_notes, expiry_note)}
  end

  # ----------------------------------------------------------------------------
  # JS Helper Functions
  # ----------------------------------------------------------------------------

  def hide_modal(js \\ %JS{}) do
    js
    |> JS.patch(~p"/today")
  end

  # ----------------------------------------------------------------------------
  # Helper Functions
  # ----------------------------------------------------------------------------

  defp create_expiry_note(socket, expiry_note_params) do
    expiry_note_params =
      Map.put(
        expiry_note_params,
        "expiration",
        DateTime.utc_now() |> DateTime.add(24 * 60 * 60, :second)
      )

    case ExpiryNotes.create_expiry_note(expiry_note_params) do
      {:ok, expiry_note} ->
        {:noreply,
         socket
         |> put_flash(:info, "Note created successfully.")
         |> assign(:form, to_form(ExpiryNotes.change_expiry_note(%ExpiryNotes.ExpiryNote{})))
         |> stream_insert(:new_expiry_notes, expiry_note, at: 0)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  # ----------------------------------------------------------------------------
  # Render
  # ----------------------------------------------------------------------------

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="flex items-center gap-2">
        <.form
          for={@form}
          id="expiry_note-form"
          phx-change="validate"
          phx-submit="submit"
          class="flex flex-1 items-center gap-2"
        >
          <div class="flex-1">
            <.input
              placeholder="What do you want to remember? It will disappear in 24 hours :)"
              field={@form[:body]}
              value=""
              ignore_errors={true}
            />
          </div>
          <.button variant={
            case @form[:body].value do
              nil -> nil
              "" -> nil
              _ -> "primary"
            end
          }>
            Submit
          </.button>
        </.form>
      </div>

      <div class="flex flex-col gap-2" id="new_expiry_notes_cards" phx-update="stream">
        <Ecosystems.ExpiryNotes.card
          :for={{dom_id, expiry_note} <- @streams.new_expiry_notes}
          id={"new_expiry_notes_card-#{dom_id}"}
          expiry_note={expiry_note}
          class="border-secondary"
        />
      </div>

      <div class="flex flex-col gap-2" id="expiry_notes_cards" phx-update="stream">
        <Ecosystems.ExpiryNotes.card
          :for={{dom_id, expiry_note} <- @streams.expiry_notes}
          id={"expiry_notes_card-#{dom_id}"}
          expiry_note={expiry_note}
        />
      </div>
    </Layouts.app>

    <dialog
      :if={@live_action in [:edit]}
      id="modal_expiry_note_edit"
      class="modal modal-open"
      phx-window-keydown={hide_modal()}
      phx-key="Escape"
    >
      <div class="modal-box">
        <.live_component
          module={EditNoteComponent}
          id="modal_expiry_note_edit__live"
          expiry_note={@expiry_note}
        />
      </div>

      <form method="dialog" class="modal-backdrop">
        <button phx-click={hide_modal()}>close</button>
      </form>
    </dialog>
    """
  end
end
