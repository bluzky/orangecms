// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin");
const colors = require("tailwindcss/colors");

module.exports = {
  content: [
    "./js/**/*.js",
    "./js/**/*.svelte",
    "../lib/*_web.ex",
    "../lib/*_web/**/*.*ex",
    "../lib/*_web/components/**/*.ex",
  ],
  theme: {
    colors: {
      background: "hsl(0, 0%, 100%)",
      foreground: "hsl(222.2 47.4% 11.2%)",
      card: "hsl(0, 0%, 100%)",
      "card-foreground": "hsl(222.2 47.4% 11.2%)",
      popover: "hsl(0, 0%, 100%)",
      "popover-foreground": "hsl(222.2 47.4% 11.2%)",
      muted: "hsl(210, 40%, 96.1%)",
      "muted-foreground": "hsl(215.4, 16.3%, 46.9%)",
      primary: "hsl(222.2, 47.4%, 11.2%)",
      "primary-foreground": "hsl(210, 40%, 98%)",
      secondary: "hsl(210, 40%, 96.1%)",
      "secondary-foreground": "hsl(222.2, 47.4%, 11.2%)",
      accent: "hsl(210, 40%, 96.1%)",
      "accent-foreground": "hsl(222.2, 47.4%, 11.2%)",
      destructive: "hsl(0, 84.2%, 60.2%)",
      "destructive-foreground": "hsl(0, 0%, 98%)",
      ring: "hsl(215, 20.2%, 65.1%)",
      input: "hsl(214.3, 31.8%, 91.4%)",
      border: "hsl(214.3, 31.8%, 91.4%)",
      transparent: "transparent",
      current: "currentColor",
      black: colors.black,
      white: colors.white,
      gray: colors.gray,
      yellow: colors.yellow,
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/typography"),
    // require("daisyui"),
    plugin(({ addVariant }) =>
      addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-click-loading", [
        ".phx-click-loading&",
        ".phx-click-loading &",
      ])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-submit-loading", [
        ".phx-submit-loading&",
        ".phx-submit-loading &",
      ])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-change-loading", [
        ".phx-change-loading&",
        ".phx-change-loading &",
      ])
    ),
  ],
  // daisyui: {
  //   styled: true,
  //   themes: ["light", "dark", "winter"],
  //   base: true,
  //   utils: true,
  //   logs: true,
  //   rtl: false,
  //   prefix: "",
  //   darkTheme: "dark",
  // },
};
