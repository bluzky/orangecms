export default function initLad(liveSocket) {
  const _liveSocket = liveSocket;

  // Query all elements matching selector
  // Supports scope:
  //       - closest(selector): query the closest parent matching the selector
  //       - children(selector): query the children matching the selector
  //       - selector: query the document for element matching selector
  // Returns an array of elements
  // Example:
  //       queryDom(el, "closest(.post .post-body)")
  //       queryDom(el, "children(.post .post-body)")
  //       queryDom(el, ".post-body")
  function queryDom(el, ladSelector, callback) {
    let elements = [];
    if (!ladSelector) {
      elements = [el];
    } else {
      const [scope, selector] = parseSelector(ladSelector);
      switch (scope) {
        case "closest":
          const found = el.closest(selector);
          elements = found ? [found] : [];
          break;
        case "children":
          elements = el.querySelectorAll(selector);
          break;
        default:
          elements = document.querySelectorAll(selector);
      }
    }
    if (callback) {
      Array.from(elements).forEach(callback);
    } else {
      return Array.from(elements);
    }
  }

  // check selector to detect query scope
  // returns [scope, selector]
  // scope can be document, closest, children
  // - closest: query the closest parent matching the selector
  // - children: query the children matching the selector
  // - document: query the document for element matching selector
  function parseSelector(selector) {
    const re = /(?<scope>closest|children)\((?<selector>.*) \)/;
    const result = re.exec(selector);
    if (result) {
      return [result.groups.scope, result.groups.selector];
    } else {
      return ["document", selector];
    }
  }

  const commands = {
    // toggle attribute value on assigned target
    // values must be an array of length 2
    // caveats: if the attribute is not present in values list, it will be set to the first value
    toggle_attribute(target, { attr, values, to }) {
      if (!values || values.length != 2)
        throw "values must be an array of length 2";

      queryDom(target, to, (node) => {
        const current = node.getAttribute(attr);

        const nextValue = values.find((v) => v != current);
        node.setAttribute(attr, nextValue);
      });
    },

    // execute Liveview.JS command store in given attribute on assigned target
    exec(target, { attr, to }) {
      queryDom(target, to, (node) => {
        let encodedJS = node.getAttribute(attr);
        if (!encodedJS) {
          throw new Error(`expected ${attr} to contain JS command on "${to}"`);
        }
        _liveSocket.execJS(node, encodedJS, "exec");
      });
    },

    // toggle class
    toggle_class(target, { class: className, to }) {
      queryDom(target, to, (node) => {
        node.classList.toggle(className);
      });
    },
  };

  function execCommand([command, args], currentTarget) {
    commands[command](currentTarget, args);
  }

  window.addEventListener("lad:exec", (event) => {
    if (Array.isArray(event.detail)) {
      event.detail.map((command) => {
        execCommand(command, event.target);
      });
    } else {
      throw "lad:exec expects an array of commands";
    }
  });
}
