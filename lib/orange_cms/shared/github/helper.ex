defmodule OrangeCms.Shared.Github.Helper do
  @doc """
  Decode file content return by github and parse frontmatter and content 
  """
  def parse_markdown_content(content) do
    {frontmatter_str, body} =
      content
      |> Base.decode64!(ignore: :whitespace)
      |> String.split("---", parts: 3)
      |> case do
        ["", frontmatter, content] -> {frontmatter, content}
        [frontmatter, content] -> {frontmatter, content}
        [content] -> {"", content}
      end

    # read frontmatter in order
    :yamerl_app.set_param(:node_mods, [YamlElixir.Node.KeywordList])

    frontmatter =
      case YamlElixir.read_from_string(frontmatter_str, maps_as_keywords: true) do
        {:ok, data} -> Enum.reverse(data)
        _ -> []
      end

    {frontmatter, body}
  end

  @doc """
  Build frontmatter string in yaml format
  Keep order as in frontmatter schema
  """
  def build_frontmatter_yaml(content_type, content_entry) do
    content_type.field_defs
    |> Enum.map(fn field ->
      {field.key, content_entry.frontmatter[field.key]}
    end)
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> OrangeCms.Shared.Yaml.document!()
  end
end
