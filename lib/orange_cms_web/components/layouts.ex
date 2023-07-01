defmodule OrangeCmsWeb.Layouts do
  @moduledoc false
  use OrangeCmsWeb, :html
  import OrangeCmsWeb.Components.Sidebar

  embed_templates "layouts/*"
end
