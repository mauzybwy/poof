defmodule PoofWeb.HomeLive do
  use PoofWeb, :live_view

  # ================================================================================================
  # Render
  # ================================================================================================

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <p>shrug</p>
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
    if !socket.assigns.current_scope do
      {:ok, redirect(socket, to: ~p"/users/log-in")}
    else
      {:ok, redirect(socket, to: ~p"/expiry_notes")}
    end
  end
end
