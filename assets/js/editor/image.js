import { mergeAttributes, Node, nodeInputRule } from "@tiptap/core";

import Image from "@tiptap/extension-image";

export const CustomImage = Image.extend({
  addOptions() {
    return {
      ...this.parent?.(),
      previewEndpoint: null,
    };
  },
  renderHTML({ HTMLAttributes }) {
    const previewUrl =
      this.options.previewEndpoint + "?path=" + HTMLAttributes.src;
    HTMLAttributes.src = previewUrl;
    return [
      "img",
      mergeAttributes(this.options.HTMLAttributes, HTMLAttributes),
    ];
  },
});
