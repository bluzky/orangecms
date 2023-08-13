// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import Sortable from "sortablejs";
import { initEditor } from "./editor";
import { toMarkdown } from "./to_markdown";
import { debounce } from "./utils";
import { FileUpload } from "./fileUpload";
import componentHooks from "./componentHooks";
import initLad from "./lad";
import { createMdEditor } from "./md_editor";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

// phoenix hooks
const Hooks = {
  ...componentHooks,
  MdEditor: {
    mounted() {
      const editor = createMdEditor({
        element: document.getElementById("editor"),
        content: this.el.value,
      });
    },
  },
  WritterEditor: {
    mounted() {
      const autoSave = debounce((editor, textarea) => {
        textarea.value = toMarkdown(editor.getJSON());
        // trigger change so phx-change will be triggered
        const e = new Event("input", {
          bubbles: true,
          cancelable: true,
        });
        textarea.dispatchEvent(e);
      }, 1000);

      const editor = initEditor({
        element: document.getElementById("editor"),
        content: this.el.value,
        previewEndpoint: this.el.getAttribute("data-preview-path"),
        uploadEndpoint: this.el.getAttribute("data-upload-path"),
        csrf_token: csrfToken,
        classes:
          "prose prose-sm sm:prose-base lg:prose-lg xl:prose-xl m-5 focus:outline-none pb-32",
        tiptapOptions: {
          onUpdate: ({ editor }) => {
            autoSave(editor, this.el);
          },
        },
      });

      // Synchronise the form's textarea with the editor on submit
      this.el.form.addEventListener("submit", (_event) => {
        this.el.value = toMarkdown(editor.getJSON());
      });
      window.editor = editor;
    },
  },
  FileUpload: {
    mounted() {
      new FileUpload(this.el, { csrf_token: csrfToken });
    },
  },
  Sortable: {
    mounted() {
      new Sortable(this.el, {
        animation: 150,
        ghostClass: "bg-yellow-100",
        dragClass: "shadow-2xl",
        onEnd: (evt) => {
          // each sortable item must have a data-id attribute which is used to identify the item
          const elements = Array.from(this.el.children);
          const ids = elements.map((elm) => elm.getAttribute("data-id"));
          this.pushEvent(
            this.el.getAttribute("phx-event") || "update-sorting",
            { ids: ids },
          );
        },
      });
    },
  },
};

const socketOptions = {
  hooks: Hooks,
  params: {
    _csrf_token: csrfToken,
  },
};

let liveSocket = new LiveSocket("/live", Socket, socketOptions);
// init Lad's functionalities
initLad(liveSocket);

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
