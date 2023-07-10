# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     OrangeCms.Repo.insert!(%Orangecms.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# project = OrangeCms.Projects.Project.create!(%{name: "test project"})

# Ash.set_tenant(project.id)

# content_types = [
#   %{
#     name: "Page",
#     key: "page",
#     github_config: %{},
#     frontmatter_schema: [],
#     anchor_field: :title,
#     project_id: project.id
#   },
#   %{
#     name: "Post",
#     key: "post",
#     github_config: %{},
#     project_id: project.id,
#     frontmatter_schema: [
#       %{
#         name: "title",
#         key: "title",
#         type: "string"
#       },
#       %{
#         name: "description",
#         key: "description",
#         type: "text"
#       },
#       %{
#         name: "category",
#         key: "category",
#         type: "checkbox",
#         options: ["category 1", "category 2", "category 3"]
#       },
#       %{
#         name: "tag",
#         key: "tag",
#         type: "array"
#       },
#       %{
#         name: "author",
#         key: "author",
#         type: "select",
#         options: ["Ta La Soi", "Viet Anh", "author 3"]
#       },
#       %{
#         name: "cover image",
#         key: "cover_img",
#         type: "upload"
#       },
#       %{
#         name: "Is draft?",
#         key: "draft",
#         type: "boolean"
#       },
#       %{
#         name: "Point",
#         key: "point",
#         type: "number"
#       },
#       %{
#         name: "published date",
#         key: "published_at",
#         type: "datetime"
#       }
#     ],
#     anchor_field: :title
#   }
# ]

# Enum.each(content_types, fn item ->
#   OrangeCms.Content.ContentType
#   |> Ash.Changeset.for_create(:create, item)
#   |> OrangeCms.Content.create!()
# end)

# create admin
alias OrangeCms.Accounts.User

%User{}
|> OrangeCms.Accounts.change_user(%{
  first_name: "Supper",
  last_name: "admin",
  email: "admin@example.com",
  password: "123123123"
})
|> Ecto.Changeset.change(%{is_admin: true})
|> OrangeCms.Repo.insert!()

Enum.map(1..10, fn i ->
  OrangeCms.Accounts.register_user(%{
    first_name: "Demo #{i}",
    last_name: "User",
    email: "demo#{i}@example.com",
    password: "123123123"
  })
end)
