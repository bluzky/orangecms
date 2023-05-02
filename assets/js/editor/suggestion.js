import tippy from "tippy.js";
import CommandPalette from "./commands.svelte";
import IconH1 from "@tabler/icons-svelte/dist/svelte/icons/IconH1.svelte";
import IconH2 from "@tabler/icons-svelte/dist/svelte/icons/IconH2.svelte";
import IconH3 from "@tabler/icons-svelte/dist/svelte/icons/IconH3.svelte";
import IconQuote from "@tabler/icons-svelte/dist/svelte/icons/IconQuote.svelte";
import IconList from "@tabler/icons-svelte/dist/svelte/icons/IconList.svelte";
import IconListNumbers from "@tabler/icons-svelte/dist/svelte/icons/IconListNumbers.svelte";
import IconPhoto from "@tabler/icons-svelte/dist/svelte/icons/IconPhoto.svelte";

export default {
  items: ({ query }) => {
    return [
      {
        title: "Header 1",
        icon: IconH1,
        command: ({ editor, range }) => {
          console.log(editor);
          editor
            .chain()
            .focus()
            .deleteRange(range)
            .setNode("heading", { level: 1 })
            .run();
        },
      },
      {
        title: "Header 2",
        icon: IconH2,
        command: ({ editor, range }) => {
          editor
            .chain()
            .focus()
            .deleteRange(range)
            .setNode("heading", { level: 2 })
            .run();
        },
      },
      {
        title: "Header 3",
        icon: IconH3,
        command: ({ editor, range }) => {
          editor
            .chain()
            .focus()
            .deleteRange(range)
            .setNode("heading", { level: 3 })
            .run();
        },
      },

      {
        title: "Blockquote",
        icon: IconQuote,
        command: ({ editor, range }) => {
          editor.chain().focus().deleteRange(range).toggleBlockquote().run();
        },
      },

      {
        title: "Bullet list",
        icon: IconList,
        command: ({ editor, range }) => {
          editor.chain().focus().deleteRange(range).toggleBulletList().run();
        },
      },

      {
        title: "Ordered list",
        icon: IconListNumbers,
        command: ({ editor, range }) => {
          editor.chain().focus().deleteRange(range).toggleOrderedList().run();
        },
      },

      {
        title: "Upload image",
        icon: IconPhoto,
        command: ({ editor, range }) => {
          let input = document.createElement("input");
          input.type = "file";
          input.onchange = (_) => {
            let files = Array.from(input.files);
            editor.options.uploadFunc(files[0]).then((result) => {
              console.log(result);
              editor
                .chain()
                .focus()
                .deleteRange(range)
                .setNode("paragraph")
                .setImage({ src: result.data.access_path })
                .run();
            });
          };
          input.click();
        },
      },
    ]
      .filter((item) => item.title.toLowerCase().includes(query.toLowerCase()))
      .slice(0, 10);
  },

  render: () => {
    let ref;
    let component;
    let popup;

    return {
      onStart: (props) => {
        const element = document.createElement("div");
        component = new CommandPalette({
          target: element,
          hydrate: false,
          props: {
            items: props.items,
            command: props.command,
            "bind:this": ref,
          },
        });

        if (!props.clientRect) {
          return;
        }

        popup = tippy("body", {
          getReferenceClientRect: props.clientRect,
          appendTo: () => document.body,
          content: element,
          showOnCreate: true,
          interactive: true,
          trigger: "manual",
          placement: "bottom-start",
        });
      },

      onUpdate(props) {
        component.$set(props);

        if (!props.clientRect) {
          return;
        }

        popup[0].setProps({
          getReferenceClientRect: props.clientRect,
        });
      },

      onKeyDown(props) {
        if (props.event.key === "Escape") {
          popup[0].hide();

          return true;
        }

        return component.handleKeyEvent(props.event.key);
      },

      onExit() {
        if (popup) {
          popup[0].destroy();
          component.$destroy();
        }
      },
    };
  },
};
