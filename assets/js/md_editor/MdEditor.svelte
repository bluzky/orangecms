<script>
  import breaks from "@bytemd/plugin-breaks";
  import gfm from "@bytemd/plugin-gfm";
  import highlight from "@bytemd/plugin-highlight";

  import { Editor } from "bytemd";

  import "highlight.js/styles/vs.css";

  export let content;
  let mode = "tab";
  const plugins = [breaks(), gfm(), highlight()];
  console.log(content);
</script>

<div class="container">
  <Editor
    value={content}
    {mode}
    {plugins}
    placeholder={"Start writing with ByteMD"}
    uploadImages={(files) => {
      return Promise.all(
        files.map((file) => {
          // TODO:
          return {
            url: "https://picsum.photos/300",
          };
        }),
      );
    }}
    on:change={(e) => {
      value = e.detail.value;
    }}
  />
</div>

<style>
  .container {
    max-width: 1200px;
    margin: 0 auto;
  }
  .line {
    margin: 10px 0;
    text-align: center;
  }
  :global(body) {
    margin: 0 10px;
    font-size: 14px;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial,
      sans-serif, "Apple Color Emoji", "Segoe UI Emoji";
  }
  :global(.bytemd) {
    height: calc(100vh - 100px);
  }
  :global(.medium-zoom-overlay) {
    z-index: 100;
  }
  :global(.medium-zoom-image--opened) {
    z-index: 101;
  }
</style>
