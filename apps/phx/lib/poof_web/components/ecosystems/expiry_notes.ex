defmodule PoofWeb.Ecosystems.ExpiryNotes do
  use PoofWeb, :live_component
  alias Poof.ExpiryNotes.ExpiryNote

  @doc """
  Renders an expiry note card
  """
  attr :id, :string, required: true
  attr :expiry_note, ExpiryNote, required: true

  attr :class, :string, default: nil

  def card(assigns) do
    time_remaining_seconds =
      DateTime.diff(assigns.expiry_note.expiration, DateTime.utc_now(), :second)

    hours = div(time_remaining_seconds, 3600)
    minutes = div(rem(time_remaining_seconds, 3600), 60)
    seconds = rem(time_remaining_seconds, 60)

    assigns =
      assigns
      |> assign(:minutes, minutes)
      |> assign(:hours, hours)
      |> assign(:seconds, seconds)

    ~H"""
    <div
      class={["flex w-full card card-sm bg-base-100 shadow-xl border-base-200 border-2", @class]}
      id={@id}
    >
      <div class="card-body">
        <p class="text-lg">
          {@expiry_note.body}
        </p>
        <div class="card-actions justify-between items-center">
          <p class="text-sm text-gray-500">
            <b class="text-gray-400">{assigns.hours}</b>h<b class="text-gray-400">{assigns.minutes}</b>m<b class="text-gray-400">{assigns.seconds}</b>s
          </p>
          <div class="dropdown dropdown-left">
            <div tabindex="0" role="button" class="btn btn-ghost btn-circle btn-xs">
              <.icon name="hero-ellipsis-vertical" class="h-4 w-4" />
            </div>
            <ul
              tabindex="0"
              class="dropdown-content menu bg-base-100 rounded-box z-1 w-24 p-2 shadow-sm"
            >
              <li>
                <.link navigate={~p"/admin/expiry_notes/#{@expiry_note}/edit"}>
                  <.icon name="hero-pencil-square" class="h-4 w-4" /> Edit
                </.link>
              </li>
              <li>
                <.link phx-click={JS.push("delete", value: %{id: @expiry_note.id}) |> hide("##{@id}")}>
                  <.icon name="hero-trash" class="h-4 w-4" /> Delete
                </.link>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
