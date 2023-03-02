defmodule OrangeCmsWeb.ContentEntryLive.Index do
  use OrangeCmsWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       type: nil
     )}
  end
end
