import MdEditor from "./MdEditor.svelte";

export function createMdEditor({ element, content }) {
  return new MdEditor({
    target: element,
    props: {
      content: content,
    },
  });
}
