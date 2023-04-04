import { Editor } from "@tiptap/core";
import StarterKit from "@tiptap/starter-kit";
import Image from "@tiptap/extension-image";
import Link from "@tiptap/extension-link";
import BubbleMenu from "@tiptap/extension-bubble-menu";
import MarkdownIt from "markdown-it";
// import { toMarkdown } from "./to_markdown";

// Override function

function initMenu(editor, element) {
  bindMenuCommand(editor, element);
  bindLinkForm(editor, element);

  // handle menu state on selection update
  editor.on("selectionUpdate", ({ editor }) => {
    const marks = editor.view.state.selection.$head.marks();

    // set active for applied marks
    ["bold", "italic", "strike"].forEach((mark) => {
      const appliedMark = marks.find((item) => item.type.name == mark);

      if (appliedMark) {
        element
          .querySelector(`[data-command=${mark}]`)
          .classList.add("btn-active");
      } else {
        element
          .querySelector(`[data-command=${mark}]`)
          .classList.remove("btn-active");
      }
    });

    // show/hide link/unlink
    const linkMark = marks.find((item) => item.type.name == "link");
    if (linkMark) {
      element.querySelector(`[data-command=link]`).classList.add("hidden");
      element.querySelector(`[data-command=unlink]`).classList.remove("hidden");
    } else {
      element.querySelector(`[data-command=link]`).classList.remove("hidden");
      element.querySelector(`[data-command=unlink]`).classList.add("hidden");
    }
    element.querySelector(".link-form").classList.add("hidden");
  });
}

function bindMenuCommand(editor, element) {
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
    unlink() {
      editor.chain().focus().unsetLink().run();
    },
    link(e) {
      element.querySelector(".link-form").classList.toggle("hidden");
      // const marks = editor.view.state.selection.$head.marks();
      // const linkMark = marks.find((item) => item.type.name == "link");
      // if (linkMark) {
      //   element.querySelector(".link-form input").value = linkMark.attrs.href;
      // }
    },
    bulletList() {
      editor.chain().focus().toggleBulletList().run();
    },
    orderedList() {
      editor.chain().focus().toggleOrderedList().run();
    },
    paragraph() {
      editor.chain().focus().setParagraph().run();
    },
    blockquote() {
      editor.chain().focus().toggleBlockquote().run();
    },
    codeBlock() {
      editor.chain().focus().toggleCodeBlock().run();
    },
    h1() {
      editor.chain().focus().toggleHeading({ level: 1 }).run();
    },
    h2() {
      editor.chain().focus().toggleHeading({ level: 2 }).run();
    },
    h3() {
      editor.chain().focus().toggleHeading({ level: 3 }).run();
    },
    h4() {
      editor.chain().focus().toggleHeading({ level: 4 }).run();
    },
  };

  element.querySelectorAll("[role=menu-item]").forEach((item) => {
    item.addEventListener("click", (e) => {
      const command = item.getAttribute("data-command");
      if (command && commands[command]) {
        commands[command](e);
      }
    });
  });
}

function bindLinkForm(editor, element) {
  element.querySelector(".link-form input").addEventListener("keydown", (e) => {
    if (e.key === "Enter") {
      if (e.target.value) {
        editor
          .chain()
          .focus()
          .setLink({ href: e.target.value, target: "_blank" })
          .run();
      } else {
        editor.chain().focus().unsetLink().run();
      }

      element.querySelector(".link-form").classList.toggle("hidden");
      e.target.value = "";
      e.stopPropagation();
      e.preventDefault();
    }
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
      Link.configure({
        openOnClick: false,
      }),
      BubbleMenu.configure({
        element: menuElement,
        tippyOptions: {
          maxWidth: "none",
        },
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
