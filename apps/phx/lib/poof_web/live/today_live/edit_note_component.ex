defmodule PoofWeb.TodayLive.EditNoteComponent do
  use PoofWeb, :live_component

  alias Poof.ExpiryNotes

  # ----------------------------------------------------------------------------
  # Mount
  # ----------------------------------------------------------------------------

  @impl true
  def update(%{expiry_note: expiry_note} = assigns, socket) do
    IO.inspect(expiry_note, label: "aDFASDFASDFADF")

    {
      :ok,
      socket
      |> assign(assigns)
      |> assign_new(:form, fn ->
        to_form(ExpiryNotes.change_expiry_note(expiry_note))
      end)
    }
  end

  # ----------------------------------------------------------------------------
  # Events
  # ----------------------------------------------------------------------------

  @impl true
  def handle_event(
        "validate",
        %{"expiry_note" => expiry_note_params},
        socket
      ) do
    changeset =
      ExpiryNotes.change_expiry_note(
        socket.assigns.expiry_note,
        expiry_note_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"expiry_note" => expiry_note_params}, socket) do
    case ExpiryNotes.update_expiry_note(
           socket.assigns.expiry_note,
           expiry_note_params
         ) do
      {:ok, expiry_note} ->
        notify_parent({:saved, expiry_note})

        {:noreply,
         socket
         |> put_flash(:info, "Note updated successfully")
         |> push_patch(to: ~p"/today")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  # ----------------------------------------------------------------------------
  # Render
  # ----------------------------------------------------------------------------

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        id="expiry_note-form"
        phx-change="validate"
        phx-submit="save"
        phx-target={@myself}
      >
        <.input field={@form[:body]} type="textarea" label="Body" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save</.button>
          <.button navigate={~p"/today"}>Cancel</.button>
        </footer>
      </.form>
    </div>
    """
  end
end
