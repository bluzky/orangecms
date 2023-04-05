# OrangeCMS - CMS admin for your static site 

# ⚠️ Warning: This project is under heavy construction and refactoring

> **OrangeCMS is a admin app for static site on github. Instead of creating/editing file on your local and push to git repo. You are now can manage your content with Web UI and your editors don't have to know anything about git**

## DEMO
- [Admin page](http://demo-orangecms.pawtools.org/app) username: admin, password: 123123
- [Content page](http://orange-demo-site.pawtools.org/)
- [Github repo](https://github.com/bluzky/orange-demo-site)


## Start dev server

- Requirement: elixir, nodejs installed on your machine

- Install dependencies
`mix deps.get`

- Install node packages
`cd assets && npm install`

- Run migration
`mix ash_postgres.migrate`

- Start project
`mix phx.server`


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
  - [ ] Cofig image upload, use relative image path
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
  - [ ] Manage user
  - [ ] Assign user to project
  - [ ] RBAC
  - [ ] Update User profile and password
  - [ ] Login / logout

- Integration
  - [ ] Cloudinary image upload
  - [ ] Manage API token

- API
  - [ ] API load collection
  - [ ] API load single content entry
  - [ ] Token authentication

## This project is impossible without these excellenct works:

- [Phoenix framework](https://phoenixframework.org/)
- [Ash framework](https://ash-hq.org/)
- [Tailwind css](https://tailwindcss.com/)
- [Daisy UI](https://daisyui.com/)
- [Lucide icons](https://lucide.dev/)
- And lots of other libraries
