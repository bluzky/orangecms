defmodule OrangeCmsWeb.ContentEntryLive.Edit do
  use OrangeCmsWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       input: ""
     )}
  end
end
