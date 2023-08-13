const esbuild = require("esbuild");
const sveltePlugin = require("esbuild-svelte");

const args = process.argv.slice(2);
const watch = args.includes("--watch");
const deploy = args.includes("--deploy");

const loader = {
  // Add loaders for images/fonts/etc, e.g. { '.svg': 'file' }
};

const plugins = [
  sveltePlugin({
    filterWarnings: (_warning) => false,
    compilerOptions: { css: "external" },
  }),
];

let opts = {
  entryPoints: ["js/app.js"],
  mainFields: ["svelte", "module", "main"],
  conditions: ["svelte"],
  nodePaths: ["./vendor"],
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
  console.log(opts);

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
