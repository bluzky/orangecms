# OrangeCMS - CMS admin for your static site 

# ⚠️ Warning: This project is under heavy construction and refactoring

> **OrangeCMS is a admin app for static site on github. Instead of creating/editing file on your local and push to git repo. You are now can manage your content with Web UI and your editors don't have to know anything about git**

## DEMO
- [Admin page](http://demo-orangecms.pawtools.org/app) username: demo, password: 123123
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


## This project is impossible without these excellenct works:

- [Phoenix framework](https://phoenixframework.org/)
- [Ash framework](https://ash-hq.org/)
- [Tailwind css](https://tailwindcss.com/)
- [Daisy UI](https://daisyui.com/)
- [Lucide icons](https://lucide.dev/)
- And lots of other libraries
