defmodule PoofWeb.TodayLive.Index do
  use PoofWeb, :live_view

  alias Poof.ExpiryNotes

  # ----------------------------------------------------------------------------
  # Mount
  # ----------------------------------------------------------------------------

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Expiry notes")
     |> assign(:form, to_form(ExpiryNotes.change_expiry_note(%ExpiryNotes.ExpiryNote{})))
     |> stream(:expiry_notes, ExpiryNotes.list_expiry_notes())}
  end

  # ----------------------------------------------------------------------------
  # Events
  # ----------------------------------------------------------------------------

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    expiry_note = ExpiryNotes.get_expiry_note!(id)
    {:ok, _} = ExpiryNotes.delete_expiry_note(expiry_note)

    {:noreply, stream_delete(socket, :expiry_notes, expiry_note)}
  end

  # ----------------------------------------------------------------------------

  @impl true
  def handle_event("validate", %{"expiry_note" => expiry_note_params}, socket) do
    changeset =
      ExpiryNotes.change_expiry_note(%ExpiryNotes.ExpiryNote{}, expiry_note_params)

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  # ----------------------------------------------------------------------------

  def handle_event("save", %{"expiry_note" => expiry_note_params}, socket) do
    create_expiry_note(socket, expiry_note_params)
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
         |> put_flash(:info, "Poof!")
         |> assign(:form, to_form(ExpiryNotes.change_expiry_note(%ExpiryNotes.ExpiryNote{})))
         |> stream_insert(:expiry_notes, expiry_note)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def calc_time_string(expiry_note) do
    Timex.diff(expiry_note.expiration, Timex.now(), :duration)
    |> Timex.format_duration(:humanized)
  end

  # ----------------------------------------------------------------------------
  # Render
  # ----------------------------------------------------------------------------

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Today
      </.header>

      <div class="flex items-center gap-2">
        <.form
          for={@form}
          id="expiry_note-form"
          phx-change="validate"
          phx-submit="save"
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

      <.table
        id="expiry_notes"
        rows={@streams.expiry_notes}
        row_click={fn {_id, expiry_note} -> JS.navigate(~p"/admin/expiry_notes/#{expiry_note}") end}
      >
        <:col :let={{_id, expiry_note}} label="Note">{expiry_note.body}</:col>
        <:col :let={{_id, expiry_note}} label="Expires">
          {calc_time_string(expiry_note)}
        </:col>
        <:action :let={{_id, expiry_note}}>
          <div class="sr-only">
            <.link navigate={~p"/admin/expiry_notes/#{expiry_note}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/expiry_notes/#{expiry_note}/edit"}>
            <.icon name="hero-pencil-square" class="h-4 w-4" />
          </.link>
        </:action>
        <:action :let={{id, expiry_note}}>
          <.link phx-click={JS.push("delete", value: %{id: expiry_note.id}) |> hide("##{id}")}>
            <.icon name="hero-trash" class="h-4 w-4" />
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end
end
