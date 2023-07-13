# OrangeCMS - CMS admin for your static site

> **OrangeCMS is a admin app for static site on github. Instead of creating/editing file on your local and push to git repo. You are now can manage your content with Web UI and your content editors don't have to know anything about git**

## DEMO

- [Admin page](http://demo-orangecms.pawtools.org/) username: demo1@example.com, password: 123123123
- [Content page](http://orange-demo-site.pawtools.org/)
- [Github repo](https://github.com/bluzky/orange-demo-site)

## Start dev server

- Requirement: elixir, nodejs installed on your machine. Nodejs is used to build assets only

- Install dependencies
  `mix setup`

- Start project
  `mix phx.server`

## Build release

- Manual build `mix assets.deploy && mix release`
- Build docker `docker build -t orangecms .`

## Deploy with Fly.io

`fly` cli installation guide here [https://fly.io/docs/flyctl/](https://fly.io/docs/flyctl/)

Then run `fly launch`

## Roadmap

- Project
  - [x] Creat project
  - [x] Setup project flow
  - [x] Project scope query
  - [ ] Encrypt github secret
- Content type
  - [x] Extract content type from markdown frontmatter
  - [x] Add/edit/remove field from frontmatter schema
  - [ ] Add new content type and sync from github
  - [x] Cofig image upload, use relative image path
  - [ ] Add default field for github file: `file_name` and `file_dir`
  - [ ] Reorder content type's field
  - [ ] Resync button to force sync latest data from github
- Content entry
  - [x] Import content from github
  - [x] Create/edit/delete content entry
  - [x] Publish (update/create) content to github
  - [x] Markdown editor
  - [x] Block editors
  - [x] improve frontmatter form
  - [ ] Delete content both in database and on repo
  - [ ] Search, filter post
- User

  - [ ] first time setup create user
  - [x] Manage user
  - [x] Assign user to project
  - [x] RBAC
  - [ ] Update User profile and password
  - [x] Login / logout

- Integration

  - [ ] Cloudinary image upload
  - [ ] Manage API token

- API
  - [ ] API load collection
  - [ ] API load single content entry
  - [ ] Token authentication

## This project is impossible without these excellenct works:

- [Phoenix framework](https://phoenixframework.org/)
- [Tailwind css](https://tailwindcss.com/)
- [Daisy UI](https://daisyui.com/)
- [Lucide icons](https://lucide.dev/)
- And lots of other libraries
