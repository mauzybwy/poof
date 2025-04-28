defmodule PoofWeb.ExpiryNoteLive.Form do
  use PoofWeb, :live_view

  alias Poof.ExpiryNotes
  alias Poof.ExpiryNotes.ExpiryNote

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage expiry_note records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="expiry_note-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:body]} type="textarea" label="Body" />
        <.input field={@form[:expiration]} type="text" label="Expiration" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Expiry note</.button>
          <.button navigate={return_path(@return_to, @expiry_note)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    expiry_note = ExpiryNotes.get_expiry_note!(id)

    socket
    |> assign(:page_title, "Edit Expiry note")
    |> assign(:expiry_note, expiry_note)
    |> assign(:form, to_form(ExpiryNotes.change_expiry_note(expiry_note)))
  end

  defp apply_action(socket, :new, _params) do
    expiry_note = %ExpiryNote{}

    socket
    |> assign(:page_title, "New Expiry note")
    |> assign(:expiry_note, expiry_note)
    |> assign(:form, to_form(ExpiryNotes.change_expiry_note(expiry_note)))
  end

  @impl true
  def handle_event("validate", %{"expiry_note" => expiry_note_params}, socket) do
    changeset = ExpiryNotes.change_expiry_note(socket.assigns.expiry_note, expiry_note_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"expiry_note" => expiry_note_params}, socket) do
    save_expiry_note(socket, socket.assigns.live_action, expiry_note_params)
  end

  defp save_expiry_note(socket, :edit, expiry_note_params) do
    case ExpiryNotes.update_expiry_note(socket.assigns.expiry_note, expiry_note_params) do
      {:ok, expiry_note} ->
        {:noreply,
         socket
         |> put_flash(:info, "Expiry note updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, expiry_note))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_expiry_note(socket, :new, expiry_note_params) do
    case ExpiryNotes.create_expiry_note(expiry_note_params) do
      {:ok, expiry_note} ->
        {:noreply,
         socket
         |> put_flash(:info, "Expiry note created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, expiry_note))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _expiry_note), do: ~p"/expiry_notes"
  defp return_path("show", expiry_note), do: ~p"/expiry_notes/#{expiry_note}"
end
