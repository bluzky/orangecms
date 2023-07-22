const Serializer = {
  blockquote(node, nested) {
    nested = nested || 1;
    const prefix = new Array(nested).fill("> ").join("");
    return node.content
      .map((node) => {
        if (node.type === "blockquote") {
          return Serializer.blockquote(node, nested + 1);
        } else {
          return prefix + Serializer.renderNode(node);
        }
      })
      .join("\n");
  },
  bulletList(node, level) {
    level = level || 0;

    const children = node.content || [];
    return children
      .map((child) => {
        return Serializer.listItem(child, node, level);
      })
      .join("\n");
  },
  codeBlock(node) {
    const children = node.content || [];
    const text = children.map((node) => Serializer.renderNode(node)).join(" ");
    return "```" + (node.attrs.language || "") + "\n" + text + "\n```";
  },
  doc(node) {
    return node.content.map((node) => Serializer.renderNode(node)).join("\n\n");
  },
  hardBreak(node) {},
  heading(node) {
    const prefix = new Array(node.attrs.level).fill("#").join("");
    const children = node.content || [];
    const text = children.map((node) => Serializer.renderNode(node)).join(" ");
    return `${prefix} ${text}`;
  },
  horizontalRule(node) {
    return "---";
  },
  image(node) {
    const title = node.attrs.title ? ` "${node.attrs.title}"` : "";
    return `![${node.attrs.alt}](${node.attrs.src}${title})`;
  },
  listItem(node, parent, level) {
    return node.content
      .map((child) => {
        if (child.type == "bulletList" || child.type == "orderedList") {
          return Serializer[child.type](child, level + 1);
        } else {
          let prefix = new Array(level).fill("  ").join("");
          if (parent.type == "orderedList") {
            prefix += parent.attrs.start + parent.content.indexOf(node) + ". ";
          } else {
            prefix += "- ";
          }
          return prefix + Serializer.renderNode(child);
        }
      })
      .join("\n");
  },
  orderedList(node, level) {
    level = level || 0;

    const children = node.content || [];
    return children
      .map((child) => {
        return Serializer.listItem(child, node, level);
      })
      .join("\n");
  },
  paragraph(node) {
    if (node.content) {
      return node.content.map((node) => Serializer.renderNode(node)).join("");
    } else {
      return "";
    }
  },
  table(node) {},
  tableRow(node) {},
  tableCell(node) {},
  tableHeader(node) {},
  taskList(node) {},
  taskItem(node) {},
  text(node) {
    if (!node.marks) {
      return node.text;
    } else {
      return node.marks.reduce((acc, mark) => {
        switch (mark.type) {
          case "bold":
            return `**${acc}**`;

          case "italic":
            return `*${acc}*`;

          case "strike":
            return `~~${acc}~~`;
          case "code":
            return `\`${acc}\``;

          case "link":
            return `[${acc}](${mark.attrs.href})`;

          default:
            return acc;
        }
      }, node.text);
    }
  },
  renderNode(node) {
    const serializer = Serializer[node.type];

    if (serializer) {
      const rs = serializer(node);
      if (rs) {
        return rs;
      }
    } else {
      throw "not supported node";
    }
  },
};

function renderNode(node) {
  const serializer = Serializer[node.type];

  if (serializer) {
    return serializer(node);
  } else {
    throw "not supported node";
  }
}

export { renderNode as toMarkdown };
