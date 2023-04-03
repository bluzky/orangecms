import { Editor } from "@tiptap/core";
import StarterKit from "@tiptap/starter-kit";
import Image from "@tiptap/extension-image";
import BubbleMenu from "@tiptap/extension-bubble-menu";
import MarkdownIt from "markdown-it";
// import { toMarkdown } from "./to_markdown";

// Override function

function initMenu(editor, element) {
  const commands = {
    bold() {
      editor.chain().focus().toggleMark("bold").run();
    },

    italic() {
      editor.chain().focus().toggleMark("italic").run();
    },
    strike() {
      editor.chain().focus().toggleMark("strike").run();
    },
    h1() {
      editor.chain().focus().toggleHeading({ level: 1 }).run();
    },
  };

  element.querySelectorAll("[role=menu-item]").forEach((item) => {
    item.addEventListener("click", (e) => {
      const command = item.getAttribute("data-command");
      if (command && commands[command]) {
        commands[command]();
      }
    });
  });
}

export function initEditor(options) {
  const html = new MarkdownIt().render(options.content);
  const menuElement = document.querySelector(".editor-menu");

  const editor = new Editor({
    element: options.element,
    extensions: [
      StarterKit,
      Image.configure({ inline: true }),
      BubbleMenu.configure({
        element: menuElement,
      }),
    ],
    editorProps: {
      attributes: {
        class: options.classes,
        spellcheck: "false",
      },
    },
    content: html,
    ...options.tiptapOptions,
  });

  initMenu(editor, menuElement);
  return editor;
}

// const editor = initEditor({
//   el: document.querySelector(".tt-editor"),
//   content: document.getElementById("editor").value,
//   classes:
//     "prose prose-sm sm:prose-base lg:prose-lg xl:prose-xl m-5 focus:outline-none",
//   tiptapOptions: {
//     onUpdate({ editor }) {
//       console.log(toMarkdown(editor.getJSON()));
//     },
//   },
// });
