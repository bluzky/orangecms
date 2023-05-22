const esbuild = require("esbuild");
const sveltePlugin = require("esbuild-svelte");

const args = process.argv.slice(2);
const watch = args.includes("--watch");
const deploy = args.includes("--deploy");

const loader = {
  // Add loaders for images/fonts/etc, e.g. { '.svg': 'file' }
};

const plugins = [
  // Add and configure plugins here
  sveltePlugin({ filterWarnings: (_warning) => false }),
  // ... other plugins such as postCss, etc.
];

let opts = {
  entryPoints: ["js/app.js"],
  // mainFields: ["svelte", "browser", "module", "main"],
  bundle: true,
  minify: false,
  target: "es2017",
  outdir: "../priv/static/assets",
  logLevel: "info",
  loader,
  plugins,
};

if (watch) {
  opts = {
    ...opts,
    sourcemap: "inline",
  };

  esbuild.context(opts).then((context) => {
    context.watch();
    console.log("Watching ....");
  });
}

if (deploy) {
  opts = {
    ...opts,
    minify: true,
  };

  console.log("Building release ...");
  esbuild.build(opts);
}
