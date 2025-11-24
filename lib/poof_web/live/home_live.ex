defmodule PoofWeb.HomeLive do
  use PoofWeb, :live_view

  alias Poof.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-sm space-y-4">
        <div class="text-center">
          <.header>
            <p>Poof</p>
            <:subtitle>
              <%= if @current_scope do %>
                Logged in
              <% else %>
                Not Logged in
              <% end %>
            </:subtitle>
          </.header>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:email)])

    {:ok, assign(socket, email: email)}
  end
end
