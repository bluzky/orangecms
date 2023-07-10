defmodule OrangeCmsWeb.Components.Form do
  @moduledoc """
  Implement of form component

  Reuse `.form` from live view Component, so we don't have to duplicate it

  # Examples:

      <div>
        <.form
          class="space-y-6"
          for={@form}
          id="project-form"
          phx-target={@myself}
          phx-change="validate"
          phx-submit="save"
        >
          <.form_item>
          <.form_label>What is your project's name?</.form_label>
          <.form_control>
              <Input.input field={@form[:name]} type="text" phx-debounce="500" />
            </.form_control>
            <.form_description>
                This is your public display name.
          </.form_description>
          <.form_message field={@form[:name]} />
          </.form_item>
          <div class="w-full flex flex-row-reverse">
            <.button
              class="btn btn-secondary btn-md"
              icon="inbox_arrow_down"
              phx-disable-with="Saving..."
            >
              Save project
              </.button>
          </div>
            </.form>
      </div>
  """
  use Phoenix.Component

  attr :label, :string, default: nil
  attr :description, :string, default: nil
  attr :class, :string, default: nil
  attr :field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form, for example: @form[:email]"
  slot :inner_block, required: true
  attr :rest, :global

  def form_item(%{field: %Phoenix.HTML.FormField{}} = assigns) do
    ~H"""
    <.form_item class={@class} {@rest} phx-feedback-for={@field.name}>
      <.form_label :if={@label}><%= @label %></.form_label>
      <.form_description :if={@description}><%= @description %></.form_description>
      <.form_control>
        <%= render_slot(@inner_block) %>
      </.form_control>
      <.form_message field={@field} />
    </.form_item>
    """
  end

  def form_item(assigns) do
    ~H"""
    <div class={["space-y-2", @class]} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true
  attr :rest, :global

  def form_label(assigns) do
    ~H"""
    <label
      class={[
        "text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  # attr :class, :string, default: nil
  slot :inner_block, required: true
  # attr :rest, :global

  def form_control(assigns) do
    ~H"""
    <%= render_slot(@inner_block) %>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true
  attr :rest, :global

  def form_description(assigns) do
    ~H"""
    <p class={["text-sm text-muted-foreground", @class]} {@rest}>
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  attr :field, Phoenix.HTML.FormField, doc: "a form field struct retrieved from the form, for example: @form[:email]"
  attr :class, :string, default: nil
  attr :errors, :list, default: []
  slot :inner_block, required: false
  attr :rest, :global

  def form_message(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign(:field, nil)
    |> form_message()
  end

  def form_message(assigns) do
    ~H"""
    <p
      :if={msg = render_slot(@inner_block) || not Enum.empty?(@errors)}
      class={["text-sm font-medium text-destructive", @class]}
      {@rest}
    >
      <span :for={msg <- @errors} class="block"><%= msg %></span>
      <%= if @errors == [] do %>
        <%= msg %>
      <% end %>
    </p>
    """
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
