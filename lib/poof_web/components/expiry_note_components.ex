defmodule PoofWeb.ExpiryNoteComponents do
  use PoofWeb, :component

  alias Poof.ExpiryNotes.ExpiryNote

  # ================================================================================================
  # Public Components
  # ================================================================================================

  attr :id, :string
  attr :expiry_note, ExpiryNote
  attr :editing?, :boolean

  def expiry_note(%{editing?: true} = assigns) do
    ~H"""
    <div
      id={@id}
      class="card border-base-200 border-2 rounded-md shadow-xl"
    >
      <form
        id="expiry_note-form"
        class="card-body p-4"
        phx-submit="edit-save"
        phx-hook="CtrlEnterSubmit"
      >
        <.input
          id="#{id}-textarea"
          type="textarea"
          name="body"
          value={@expiry_note.body}
          rows={5}
          autofocus={true}
          autofocus_to={:end}
        />

        <div class="card-actions justify-end">
          <button type="button" class="btn" phx-click="edit-cancel">Cancel</button>
          <button class="btn btn-primary">Save</button>
        </div>
      </form>
    </div>
    """
  end

  def expiry_note(assigns) do
    ~H"""
    <div
      id={@id}
      class="card border-base-200 border-2 rounded-md shadow-xl"
    >
      <div class="card-body p-4">
        <p class="text-lg">{@expiry_note.body}</p>
        <div class="card-actions justify-end">
          <.humanized_expiration expiry_note={@expiry_note} />

          <div>
            <button
              phx-click="edit"
              phx-value-expiry_note_id={@expiry_note.id}
              phx-value-dom_id={@id}
              class="btn btn-circle btn-ghost btn-sm"
            >
              <.icon name="hero-pencil-square" />
            </button>
            <div class="dropdown">
              <div tabindex="0" role="button" class="btn btn-circle btn-ghost btn-sm">
                <.icon name="hero-ellipsis-vertical" />
              </div>
              <ul
                tabindex="-1"
                class="dropdown-content menu bg-base-200 rounded-box z-1 w-52 p-2 shadow-sm"
              >
                <li class="text-red-500">
                  <.link
                    phx-click={JS.push("delete", value: %{id: @expiry_note.id}) |> hide("##{@id}")}
                    data-confirm="Are you sure?"
                  >
                    <.icon name="hero-trash" /> Delete
                  </.link>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # ================================================================================================
  # Private Components
  # ================================================================================================

  # ------------------------------------------------------------------------------------------------
  # Humanized Expiration
  # ------------------------------------------------------------------------------------------------

  attr :expiry_note, ExpiryNote

  defp humanized_expiration(%{expiry_note: expiry_note} = assigns) do
    {hours, minutes, seconds, _} =
      DateTime.diff(expiry_note.expiration, DateTime.utc_now())
      |> Timex.Duration.from_seconds()
      |> Timex.Duration.to_clock()

    assigns =
      assigns
      |> assign_new(:hours, fn -> hours end)
      |> assign_new(:minutes, fn -> minutes end)
      |> assign_new(:seconds, fn -> seconds end)

    ~H"""
    <p class="text-gray-500">
      <span class="font-bold text-gray-400">{@hours}</span>{"h"}
      <span class="font-bold text-gray-400">{@minutes}</span>{"m"}
      <span class="font-bold text-gray-400">{@seconds}</span>{"s"}
    </p>
    """
  end
end
