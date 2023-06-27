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
#     image_settings: %{},
#     field_defs: [],
#     anchor_field: :title,
#     project_id: project.id
#   },
#   %{
#     name: "Post",
#     key: "post",
#     image_settings: %{},
#     project_id: project.id,
#     field_defs: [
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
# OrangeCms.Accounts.User
# |> Ash.Changeset.for_create(:register_with_password, %{
#   # first_name: "Supper",
#   # last_name: "admin",
#   email: "admin@example.com",
#   password: "123123123",
#   password_confirmation: "123123123"
# })
# |> Ash.Changeset.force_change_attribute(:is_admin, true)
# |> OrangeCms.Accounts.create!(authorize?: false)

Enum.map(1..10, fn i ->
  OrangeCms.Accounts.register_user(%{
    first_name: "Demo #{i}",
    last_name: "User",
    email: "demo#{i}@example.com",
    password: "123123123"
  })
end)
