defmodule OrangeCmsWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.

  The components in this module use Tailwind CSS, a utility-first CSS framework.
  See the [Tailwind CSS documentation](https://tailwindcss.com) to learn how to
  customize the generated components in this module.

  Icons are provided by [heroicons](https://heroicons.com), using the
  [heroicons_elixir](https://github.com/mveytsman/heroicons_elixir) project.
  """
  use Phoenix.Component
  use OrangeCmsWeb, :verified_routes

  import OrangeCmsWeb.Gettext

  alias Phoenix.LiveView.JS

  @doc """
  Renders a modal.

  ## Examples

      <.modal id="confirm-modal">
        Are you sure?
        <:confirm>OK</:confirm>
        <:cancel>Cancel</:cancel>
      </.modal>

  JS commands may be passed to the `:on_cancel` and `on_confirm` attributes
  for the caller to react to each button press, for example:

      <.modal id="confirm" on_confirm={JS.push("delete")} on_cancel={JS.navigate(~p"/posts")}>
        Are you sure you?
        <:confirm>OK</:confirm>
        <:cancel>Cancel</:cancel>
      </.modal>
  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  attr :on_confirm, JS, default: %JS{}

  slot :inner_block, required: true
  slot :title
  slot :subtitle
  slot :confirm
  slot :cancel

  def modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_modal(@id)}
      phx-remove={hide_modal(@id)}
      class="relative z-50 hidden"
    >
      <div id={"#{@id}-bg"} class="fixed inset-0 bg-zinc-50/90 transition-opacity" aria-hidden="true" />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex min-h-full items-center justify-center">
          <div class="w-full max-w-3xl p-4 sm:p-6 lg:py-8">
            <.focus_wrap
              id={"#{@id}-container"}
              phx-mounted={@show && show_modal(@id)}
              phx-window-keydown={hide_modal(@on_cancel, @id)}
              phx-key="escape"
              phx-click-away={hide_modal(@on_cancel, @id)}
              class="hidden relative rounded-2xl bg-white p-14 shadow-lg shadow-zinc-700/10 ring-1 ring-zinc-700/10 transition"
            >
              <div class="absolute top-6 right-5">
                <button
                  phx-click={hide_modal(@on_cancel, @id)}
                  type="button"
                  class="-m-3 flex-none p-3 opacity-20 hover:opacity-40"
                  aria-label={gettext("close")}
                >
                  <.icon name="x-mark" solid class="h-5 w-5 stroke-current" />
                </button>
              </div>
              <div id={"#{@id}-content"}>
                <header :if={@title != []}>
                  <h1 id={"#{@id}-title"} class="text-lg font-semibold leading-8 text-zinc-800">
                    <%= render_slot(@title) %>
                  </h1>
                  <p
                    :if={@subtitle != []}
                    id={"#{@id}-description"}
                    class="mt-2 text-sm leading-6 text-zinc-600"
                  >
                    <%= render_slot(@subtitle) %>
                  </p>
                </header>
                <%= render_slot(@inner_block) %>
                <div :if={@confirm != [] or @cancel != []} class="ml-6 mb-4 flex items-center gap-5">
                  <.button
                    :for={confirm <- @confirm}
                    id={"#{@id}-confirm"}
                    phx-click={@on_confirm}
                    phx-disable-with
                    class="py-2 px-3"
                  >
                    <%= render_slot(confirm) %>
                  </.button>
                  <.link
                    :for={cancel <- @cancel}
                    phx-click={hide_modal(@on_cancel, @id)}
                    class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
                  >
                    <%= render_slot(cancel) %>
                  </.link>
                </div>
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders Heroicons
  """

  attr :name, :string, required: true
  attr :class, :string, default: "w-5 h-5"
  attr :solid, :boolean, default: false
  attr :rest, :global

  def icon(assigns) do
    apply(Heroicons, :"#{String.replace(assigns.name, "-", "_")}", [
      %{__changed__: nil, __given__: nil, class: assigns.class, solid: assigns.solid}
    ])
  end

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, default: "flash", doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :autoshow, :boolean, default: true, doc: "whether to auto show the flash on mount"
  attr :close, :boolean, default: true, doc: "whether the flash can be closed"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-mounted={@autoshow && show("##{@id}")}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class="fixed hidden top-2 right-2 w-80 sm:w-96 z-50"
      style="user-select: none; touch-action: none;"
      {@rest}
    >
      <div class={[
        "group pointer-events-auto relative flex w-full items-center justify-between space-x-2 overflow-hidden rounded-md border p-4 pr-6 shadow-lg transition-all group ",
        (@kind == :error &&
           "border-destructive bg-destructive text-destructive-foreground destructive") ||
          "border bg-background"
      ]}>
        <div class="grid gap-1">
          <div :if={@title} class="text-sm font-semibold [&+div]:text-xs"><%= @title %></div>
          <div class="text-sm opacity-90"><%= msg %></div>
        </div>

        <button
          type="button"
          class="absolute right-1 top-1 rounded-md p-1 text-foreground/50 opacity-0 transition-opacity hover:text-foreground focus:opacity-100 focus:outline-none focus:ring-1 group-hover:opacity-100 group-[.destructive]:text-red-300 group-[.destructive]:hover:text-red-50 group-[.destructive]:focus:ring-red-400 group-[.destructive]:focus:ring-offset-red-600"
        >
          <.icon name="x-mark" />
        </button>
      </div>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  def flash_group(assigns) do
    ~H"""
    <.flash kind={:info} title="Success!" flash={@flash} />
    <.flash kind={:error} title="Error!" flash={@flash} />
    <.flash
      id="disconnected"
      kind={:error}
      title="We can't find the internet"
      close={false}
      autoshow={false}
      phx-disconnected={show("#disconnected")}
      phx-connected={hide("#disconnected")}
    >
      Attempting to reconnect <.icon name="arrow-path" class="ml-1 w-3 h-3 inline animate-spin" />
    </.flash>
    """
  end

  @doc """
  Renders a simple form.

  ## Examples

      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} label="Email"/>
        <.input field={@form[:username]} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr :for, :any, required: true, doc: "the datastructure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class="space-y-4">
        <%= render_slot(@inner_block, f) %>
        <div :for={action <- @actions} class="mt-2 flex items-center justify-between gap-6">
          <%= render_slot(action, f) %>
        </div>
      </div>
    </.form>
    """
  end

  @doc """
  Renders a button.

  ## Examples

      <.button>Send!</.button>
      <.button phx-click="go" class="ml-2">Send!</.button>
  """
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :variant, :string, default: "primary"
  attr :icon, :string, default: nil
  attr :icon_right, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  @button_variants %{
    "primary" => "bg-primary text-primary-foreground hover:bg-primary/90",
    "secondary" => "bg-secondary text-secondary-foreground hover:bg-secondary/80",
    "destructive" => "bg-destructive text-destructive-foreground hover:bg-destructive/90",
    "outline" => "border border-input bg-background shadow-sm hover:bg-accent hover:text-accent-foreground",
    "ghost" => "hover:bg-accent hover:text-accent-foreground",
    "link" => "text-primary underline-offset-4 hover:underline"
  }
  def button(assigns) do
    assigns = assign(assigns, :variant_class, @button_variants[assigns.variant])

    ~H"""
    <button
      type={@type}
      class={[
        "inline-flex items-center justify-center rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 shadow h-9 px-4 py-2 #{@variant_class}",
        "gap-1",
        "phx-submit-loading:opacity-75 btn",
        @class
      ]}
      {@rest}
    >
      <.icon :if={not is_nil(@icon)} name={@icon} class="w-5 h-5" />
      <%= render_slot(@inner_block) %>
      <.icon :if={not is_nil(@icon_right)} name={@icon_right} class="w-5 h-5" />
    </button>
    """
  end

  @doc """
  Renders an input with label and error messages.

  A `%Phoenix.HTML.Form{}` and field name may be passed to the input
  to build input names and error messages, or all the attributes and
  errors may be passed explicitly.

  ## Examples

      <.input field={@form[:email]} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file hidden month number password
               range radio search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"
  attr :rest, :global, include: ~w(autocomplete cols disabled form max maxlength min minlength
                                   pattern placeholder readonly required rows size step)

  slot :helper
  slot :inner_block

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox", value: value} = assigns) do
    assigns = assign_new(assigns, :checked, fn -> Phoenix.HTML.Form.normalize_value("checkbox", value) end)

    ~H"""
    <div phx-feedback-for={@name} class="form-control">
      <div class="flex gap-2 items-center">
        <input type="hidden" name={@name} value="false" />
        <input
          type="checkbox"
          class="peer h-4 w-4 shrink-0 rounded-sm border border-primary shadow focus:ring-0 focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50 text-primary"
          id={@id || @name}
          name={@name}
          value="true"
          checked={@checked}
          {@rest}
        />
        <.label for={@id || @name} helper={@helper}><%= @label %></.label>
      </div>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name} class="form-control">
      <.label for={@id} helper={@helper}><%= @label %></.label>
      <select
        id={@id}
        name={@name}
        class={["select select-bordered", @errors != [] && "select-error"]}
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value=""><%= @prompt %></option>
        <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div phx-feedback-for={@name} class="form-control">
      <.label for={@id} helper={@helper}><%= @label %></.label>
      <textarea
        id={@id || @name}
        name={@name}
        class={[
          "textarea textarea-bordered",
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 phx-no-feedback:focus:ring-zinc-800/5",
          @errors != [] && "textarea-error"
        ]}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(assigns) do
    ~H"""
    <div phx-feedback-for={@name} class="form-control">
      <.label for={@id} helper={@helper}><%= @label %></.label>
      <input
        type={@type}
        name={@name}
        id={@id || @name}
        value={Phoenix.HTML.Form.normalize_value(@type, @value)}
        class={[
          "flex h-9 w-full rounded-md border border-input bg-background px-3 py-1 text-sm shadow-sm transition-colors file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50",
          "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 phx-no-feedback:focus:ring-zinc-800/5",
          @errors != [] && "input-error"
        ]}
        {@rest}
      />
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  @doc """
  Renders a label.
  """
  attr :for, :string, default: nil
  attr :helper, :any, default: []
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label
      for={@for}
      class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
    >
      <%= render_slot(@inner_block) %>

      <div :if={@helper != []} class="dropdown">
        <label tabindex="0" class="btn btn-circle btn-ghost btn-xs text-info">
          <.icon name="question-mark-circle" class="w-4 h-4" />
        </label>
        <div tabindex="0" class="card compact dropdown-content shadow-lg bg-base-300 rounded-box w-80">
          <div class="card-body font-normal">
            <%= render_slot(@helper) %>
          </div>
        </div>
      </div>
    </label>
    """
  end

  @doc """
  Generates a generic error message.
  """
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class="phx-no-feedback:hidden mt-3 flex gap-3 text-sm leading-6 text-error">
      <.icon name="exclamation-circle" class="mt-0.5 h-5 w-5 flex-none fill-error" />
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  @doc """
  Renders a header with title.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header class={[@actions != [] && "flex items-center justify-between gap-6", @class]}>
      <div>
        <h1 class="text-lg font-semibold leading-8 text-zinc-800">
          <%= render_slot(@inner_block) %>
        </h1>
        <p :if={@subtitle != []} class="mt-2 text-sm leading-6 text-zinc-600">
          <%= render_slot(@subtitle) %>
        </p>
      </div>
      <div class="flex-none"><%= render_slot(@actions) %></div>
    </header>
    """
  end

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id"><%= user.id %></:col>
        <:col :let={user} label="username"><%= user.username %></:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :label, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class="overflow-y-auto px-4 sm:overflow-visible sm:px-0">
      <table class="table mt-11 w-[40rem] sm:w-full">
        <thead class="">
          <tr>
            <th :for={col <- @col}><%= col[:label] %></th>
            <th><span class="sr-only"><%= gettext("Actions") %></span></th>
          </tr>
        </thead>
        <tbody id={@id} phx-update={match?(%Phoenix.LiveView.LiveStream{}, @rows) && "stream"}>
          <tr :for={row <- @rows} id={@row_id && @row_id.(row)} class={[@row_click && "hover"]}>
            <td
              :for={{col, _i} <- Enum.with_index(@col)}
              phx-click={@row_click && @row_click.(row)}
              class={[@row_click && "hover:cursor-pointer"]}
            >
              <%= render_slot(col, @row_item.(row)) %>
            </td>
            <td :if={@action != []} class="">
              <div class="flex flex-wrap justify-end gap-2">
                <span :for={action <- @action}>
                  <%= render_slot(action, @row_item.(row)) %>
                </span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc """
  Renders a data list.

  ## Examples

      <.list>
        <:item title="Title"><%= @post.title %></:item>
        <:item title="Views"><%= @post.views %></:item>
      </.list>
  """
  slot :item, required: true do
    attr :title, :string, required: true
  end

  def list(assigns) do
    ~H"""
    <div class="mt-14">
      <dl class="-my-4 divide-y divide-zinc-100">
        <div :for={item <- @item} class="flex gap-4 py-4 sm:gap-8">
          <dt class="w-1/4 flex-none text-[0.8125rem] leading-6 text-zinc-500"><%= item.title %></dt>
          <dd class="text-sm leading-6 text-zinc-700"><%= render_slot(item) %></dd>
        </div>
      </dl>
    </div>
    """
  end

  @doc """
  Renders a back navigation link.

  ## Examples

      <.back navigate={~p"/posts"}>Back to posts</.back>
  """
  attr :navigate, :any, required: true
  slot :inner_block, required: true

  def back(assigns) do
    ~H"""
    <div class="mt-16">
      <.link
        navigate={@navigate}
        class="text-sm font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
      >
        <.icon name="arrow-left" solid class="w-3 h-3 stroke-current inline" />
        <%= render_slot(@inner_block) %>
      </.link>
    </div>
    """
  end

  @doc """
  Render alert
  """

  attr :kind, :any, default: nil
  attr :icon, :string
  attr :class, :string
  slot :inner_block, required: true
  attr :rest, :global, default: %{}

  def alert(assigns) do
    assigns = assign(assigns, kind: to_string(assigns.kind))

    assigns =
      if is_nil(assigns[:icon]) do
        icon =
          case to_string(assigns.kind) do
            "success" -> "check-circle"
            "info" -> "information_circle"
            "error" -> "exclamation_triangle"
            _ -> nil
          end

        assign(assigns, :icon, icon)
      else
        assigns
      end

    # We have to specify full class name for tailwind to extract class name
    ~H"""
    <div
      class={[
        "rounded-lg border px-4 py-3 text-sm bg-background text-foreground",
        @class,
        @kind == "error" && "border-destructive/50 text-destructive dark:border-destructive"
      ]}
      {@rest}
    >
      <div class="w-full flex gap-2">
        <.icon :if={not is_nil(@icon)} name={@icon} />
        <div>
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Render avatar
  """

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def avatar(assigns) do
    ~H"""
    <div class={["relative flex h-10 w-10 shrink-0 overflow-hidden rounded-full", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :class, :string, default: nil
  attr :src, :string, required: true
  attr :rest, :global

  def avatar_image(assigns) do
    ~H"""
    <img class={["aspect-square h-full w-full", @class]} src={@src} {@rest} />
    """
  end

  @doc """
  Render badge
  """
  attr :class, :string, default: "bg-primary text-primary-foreground hover:bg-primary/80"
  slot :inner_block, required: true
  attr :rest, :global

  def badge(assigns) do
    ~H"""
    <div
      class={[
        "inline-flex items-center rounded-md border px-2.5 py-0.5 text-xs font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 shadow border-transparent",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      transition:
        {"transition-all transform ease-out duration-300", "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200", "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(OrangeCmsWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(OrangeCmsWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
