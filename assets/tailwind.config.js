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
      background: "var(--background)",
      foreground: "var(--foreground)",
      card: "var(--card)",
      "card-foreground": "var(--card-foreground)",
      popover: "var(--popover)",
      "popover-foreground": "var(--popover-foreground)",
      muted: "var(--muted)",
      "muted-foreground": "var(--muted-foreground)",
      primary: "var(--primary)",
      "primary-foreground": "var(--primary-foreground)",
      secondary: "var(--secondary)",
      "secondary-foreground": "var(--secondary-foreground)",
      accent: "var(--accent)",
      "accent-foreground": "var(--accent-foreground)",
      destructive: "var(--destructive)",
      "destructive-foreground": "var(--destructive-foreground)",
      ring: "var(--ring)",
      input: "var(--input)",
      border: "var(--border)",
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
