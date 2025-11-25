defmodule PoofWeb.ExpiryNoteLive.Form do
  use PoofWeb, :live_view

  alias Poof.ExpiryNotes
  alias Poof.ExpiryNotes.ExpiryNote

  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage expiry_note records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="expiry_note-form" phx-change="validate" phx-submit="save">
        <input id="timezone" type="hidden" phx-hook="LocalTimezone" name="timezone" />
        
        <.input field={@form[:body]} type="textarea" label="Body" />
        <.input field={@form[:expiration]} type="datetime-local" label="Expiration" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Expiry note</.button>
          <.button navigate={return_path(@current_scope, @return_to, @expiry_note)}>Cancel</.button>
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
    expiry_note = ExpiryNotes.get_expiry_note!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Expiry note")
    |> assign(:expiry_note, expiry_note)
    |> assign(:form, to_form(ExpiryNotes.change_expiry_note(socket.assigns.current_scope, expiry_note)))
  end

  defp apply_action(socket, :new, _params) do
    expiry_note = %ExpiryNote{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Expiry note")
    |> assign(:expiry_note, expiry_note)
    |> assign(:form, to_form(ExpiryNotes.change_expiry_note(socket.assigns.current_scope, expiry_note)))
  end

  @impl true
  def handle_event("validate", %{"expiry_note" => expiry_note_params}, socket) do
    changeset = ExpiryNotes.change_expiry_note(socket.assigns.current_scope, socket.assigns.expiry_note, expiry_note_params)
    
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"expiry_note" => expiry_note_params, "timezone" => timezone}, socket) do
    expiration = expiry_note_params["expiration"] <> ":00"

    with {:ok, naive} <- NaiveDateTime.from_iso8601(expiration),
         {:ok, datetime} <- DateTime.from_naive(naive, timezone) do
      
      save_expiry_note(
        socket,
        socket.assigns.live_action,
        Map.replace(expiry_note_params, "expiration", datetime)
      )
    else
      other ->
        Logger.error(inspect(other))
        {:noreply, put_flash(socket, :error, "Could not calculate datetime")}
    end
  end

  defp save_expiry_note(socket, :edit, expiry_note_params) do
    case ExpiryNotes.update_expiry_note(socket.assigns.current_scope, socket.assigns.expiry_note, expiry_note_params) do
      {:ok, expiry_note} ->
        {:noreply,
         socket
         |> put_flash(:info, "Expiry note updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, expiry_note)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_expiry_note(socket, :new, expiry_note_params) do
    case ExpiryNotes.create_expiry_note(socket.assigns.current_scope, expiry_note_params) do
      {:ok, expiry_note} ->
        {:noreply,
         socket
         |> put_flash(:info, "Expiry note created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, expiry_note)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _expiry_note), do: ~p"/expiry_notes"
  defp return_path(_scope, "show", expiry_note), do: ~p"/expiry_notes/#{expiry_note}"
end
