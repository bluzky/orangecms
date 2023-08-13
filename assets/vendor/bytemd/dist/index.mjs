import factory from "codemirror-ssr";
import usePlaceholder from "codemirror-ssr/addon/display/placeholder.js";
import useContinuelist from "codemirror-ssr/addon/edit/continuelist.js";
import useOverlay from "codemirror-ssr/addon/mode/overlay.js";
import useGfm from "codemirror-ssr/mode/gfm/gfm.js";
import useMarkdown from "codemirror-ssr/mode/markdown/markdown.js";
import useXml from "codemirror-ssr/mode/xml/xml.js";
import useYamlFrontmatter from "codemirror-ssr/mode/yaml-frontmatter/yaml-frontmatter.js";
import useYaml from "codemirror-ssr/mode/yaml/yaml.js";
import selectFiles from "select-files";
import wordCount from "word-count";
import { visit } from "unist-util-visit";
import { delegate } from "tippy.js";
import { defaultSchema } from "hast-util-sanitize";
import rehypeRaw from "rehype-raw";
import rehypeSanitize from "rehype-sanitize";
import rehypeStringify from "rehype-stringify";
import remarkParse from "remark-parse";
import remarkRehype from "remark-rehype";
import { unified } from "unified";
import { debounce, throttle } from "lodash-es";
const index = "";
function noop() {
}
function run(fn) {
  return fn();
}
function blank_object() {
  return /* @__PURE__ */ Object.create(null);
}
function run_all(fns) {
  fns.forEach(run);
}
function is_function(thing) {
  return typeof thing === "function";
}
function safe_not_equal(a, b) {
  return a != a ? b == b : a !== b || (a && typeof a === "object" || typeof a === "function");
}
function not_equal(a, b) {
  return a != a ? b == b : a !== b;
}
function is_empty(obj) {
  return Object.keys(obj).length === 0;
}
function append(target, node) {
  target.appendChild(node);
}
function insert(target, node, anchor) {
  target.insertBefore(node, anchor || null);
}
function detach(node) {
  if (node.parentNode) {
    node.parentNode.removeChild(node);
  }
}
function destroy_each(iterations, detaching) {
  for (let i = 0; i < iterations.length; i += 1) {
    if (iterations[i])
      iterations[i].d(detaching);
  }
}
function element(name) {
  return document.createElement(name);
}
function text(data) {
  return document.createTextNode(data);
}
function empty() {
  return text("");
}
function listen(node, event, handler, options) {
  node.addEventListener(event, handler, options);
  return () => node.removeEventListener(event, handler, options);
}
function self(fn) {
  return function(event) {
    if (event.target === this)
      fn.call(this, event);
  };
}
function attr(node, attribute, value) {
  if (value == null)
    node.removeAttribute(attribute);
  else if (node.getAttribute(attribute) !== value)
    node.setAttribute(attribute, value);
}
function children(element2) {
  return Array.from(element2.childNodes);
}
function set_data(text2, data) {
  data = "" + data;
  if (text2.wholeText !== data)
    text2.data = data;
}
function toggle_class(element2, name, toggle) {
  element2.classList[toggle ? "add" : "remove"](name);
}
function custom_event(type, detail, { bubbles = false, cancelable = false } = {}) {
  const e = document.createEvent("CustomEvent");
  e.initCustomEvent(type, bubbles, cancelable, detail);
  return e;
}
let current_component;
function set_current_component(component) {
  current_component = component;
}
function get_current_component() {
  if (!current_component)
    throw new Error("Function called outside component initialization");
  return current_component;
}
function onMount(fn) {
  get_current_component().$$.on_mount.push(fn);
}
function afterUpdate(fn) {
  get_current_component().$$.after_update.push(fn);
}
function onDestroy(fn) {
  get_current_component().$$.on_destroy.push(fn);
}
function createEventDispatcher() {
  const component = get_current_component();
  return (type, detail, { cancelable = false } = {}) => {
    const callbacks = component.$$.callbacks[type];
    if (callbacks) {
      const event = custom_event(type, detail, { cancelable });
      callbacks.slice().forEach((fn) => {
        fn.call(component, event);
      });
      return !event.defaultPrevented;
    }
    return true;
  };
}
const dirty_components = [];
const binding_callbacks = [];
let render_callbacks = [];
const flush_callbacks = [];
const resolved_promise = /* @__PURE__ */ Promise.resolve();
let update_scheduled = false;
function schedule_update() {
  if (!update_scheduled) {
    update_scheduled = true;
    resolved_promise.then(flush);
  }
}
function tick() {
  schedule_update();
  return resolved_promise;
}
function add_render_callback(fn) {
  render_callbacks.push(fn);
}
const seen_callbacks = /* @__PURE__ */ new Set();
let flushidx = 0;
function flush() {
  if (flushidx !== 0) {
    return;
  }
  const saved_component = current_component;
  do {
    try {
      while (flushidx < dirty_components.length) {
        const component = dirty_components[flushidx];
        flushidx++;
        set_current_component(component);
        update(component.$$);
      }
    } catch (e) {
      dirty_components.length = 0;
      flushidx = 0;
      throw e;
    }
    set_current_component(null);
    dirty_components.length = 0;
    flushidx = 0;
    while (binding_callbacks.length)
      binding_callbacks.pop()();
    for (let i = 0; i < render_callbacks.length; i += 1) {
      const callback = render_callbacks[i];
      if (!seen_callbacks.has(callback)) {
        seen_callbacks.add(callback);
        callback();
      }
    }
    render_callbacks.length = 0;
  } while (dirty_components.length);
  while (flush_callbacks.length) {
    flush_callbacks.pop()();
  }
  update_scheduled = false;
  seen_callbacks.clear();
  set_current_component(saved_component);
}
function update($$) {
  if ($$.fragment !== null) {
    $$.update();
    run_all($$.before_update);
    const dirty = $$.dirty;
    $$.dirty = [-1];
    $$.fragment && $$.fragment.p($$.ctx, dirty);
    $$.after_update.forEach(add_render_callback);
  }
}
function flush_render_callbacks(fns) {
  const filtered = [];
  const targets = [];
  render_callbacks.forEach((c) => fns.indexOf(c) === -1 ? filtered.push(c) : targets.push(c));
  targets.forEach((c) => c());
  render_callbacks = filtered;
}
const outroing = /* @__PURE__ */ new Set();
let outros;
function group_outros() {
  outros = {
    r: 0,
    c: [],
    p: outros
    // parent group
  };
}
function check_outros() {
  if (!outros.r) {
    run_all(outros.c);
  }
  outros = outros.p;
}
function transition_in(block, local) {
  if (block && block.i) {
    outroing.delete(block);
    block.i(local);
  }
}
function transition_out(block, local, detach2, callback) {
  if (block && block.o) {
    if (outroing.has(block))
      return;
    outroing.add(block);
    outros.c.push(() => {
      outroing.delete(block);
      if (callback) {
        if (detach2)
          block.d(1);
        callback();
      }
    });
    block.o(local);
  } else if (callback) {
    callback();
  }
}
function create_component(block) {
  block && block.c();
}
function mount_component(component, target, anchor, customElement) {
  const { fragment, after_update } = component.$$;
  fragment && fragment.m(target, anchor);
  if (!customElement) {
    add_render_callback(() => {
      const new_on_destroy = component.$$.on_mount.map(run).filter(is_function);
      if (component.$$.on_destroy) {
        component.$$.on_destroy.push(...new_on_destroy);
      } else {
        run_all(new_on_destroy);
      }
      component.$$.on_mount = [];
    });
  }
  after_update.forEach(add_render_callback);
}
function destroy_component(component, detaching) {
  const $$ = component.$$;
  if ($$.fragment !== null) {
    flush_render_callbacks($$.after_update);
    run_all($$.on_destroy);
    $$.fragment && $$.fragment.d(detaching);
    $$.on_destroy = $$.fragment = null;
    $$.ctx = [];
  }
}
function make_dirty(component, i) {
  if (component.$$.dirty[0] === -1) {
    dirty_components.push(component);
    schedule_update();
    component.$$.dirty.fill(0);
  }
  component.$$.dirty[i / 31 | 0] |= 1 << i % 31;
}
function init(component, options, instance2, create_fragment2, not_equal2, props, append_styles, dirty = [-1]) {
  const parent_component = current_component;
  set_current_component(component);
  const $$ = component.$$ = {
    fragment: null,
    ctx: [],
    // state
    props,
    update: noop,
    not_equal: not_equal2,
    bound: blank_object(),
    // lifecycle
    on_mount: [],
    on_destroy: [],
    on_disconnect: [],
    before_update: [],
    after_update: [],
    context: new Map(options.context || (parent_component ? parent_component.$$.context : [])),
    // everything else
    callbacks: blank_object(),
    dirty,
    skip_bound: false,
    root: options.target || parent_component.$$.root
  };
  append_styles && append_styles($$.root);
  let ready = false;
  $$.ctx = instance2 ? instance2(component, options.props || {}, (i, ret, ...rest) => {
    const value = rest.length ? rest[0] : ret;
    if ($$.ctx && not_equal2($$.ctx[i], $$.ctx[i] = value)) {
      if (!$$.skip_bound && $$.bound[i])
        $$.bound[i](value);
      if (ready)
        make_dirty(component, i);
    }
    return ret;
  }) : [];
  $$.update();
  ready = true;
  run_all($$.before_update);
  $$.fragment = create_fragment2 ? create_fragment2($$.ctx) : false;
  if (options.target) {
    if (options.hydrate) {
      const nodes = children(options.target);
      $$.fragment && $$.fragment.l(nodes);
      nodes.forEach(detach);
    } else {
      $$.fragment && $$.fragment.c();
    }
    if (options.intro)
      transition_in(component.$$.fragment);
    mount_component(component, options.target, options.anchor, options.customElement);
    flush();
  }
  set_current_component(parent_component);
}
class SvelteComponent {
  $destroy() {
    destroy_component(this, 1);
    this.$destroy = noop;
  }
  $on(type, callback) {
    if (!is_function(callback)) {
      return noop;
    }
    const callbacks = this.$$.callbacks[type] || (this.$$.callbacks[type] = []);
    callbacks.push(callback);
    return () => {
      const index2 = callbacks.indexOf(callback);
      if (index2 !== -1)
        callbacks.splice(index2, 1);
    };
  }
  $set($$props) {
    if (this.$$set && !is_empty($$props)) {
      this.$$.skip_bound = true;
      this.$$set($$props);
      this.$$.skip_bound = false;
    }
  }
}
const bold = "Bold";
const boldText = "bold text";
const cheatsheet = "Markdown Cheatsheet";
const closeHelp = "Close help";
const closeToc = "Close table of contents";
const code = "Code";
const codeBlock = "Code block";
const codeLang = "lang";
const codeText = "code";
const exitFullscreen = "Exit fullscreen";
const exitPreviewOnly = "Exit preview only";
const exitWriteOnly = "Exit write only";
const fullscreen = "Fullscreen";
const h1 = "Heading 1";
const h2 = "Heading 2";
const h3 = "Heading 3";
const h4 = "Heading 4";
const h5 = "Heading 5";
const h6 = "Heading 6";
const headingText = "heading";
const help = "Help";
const hr = "Horizontal rule";
const image = "Image";
const imageAlt = "alt";
const imageTitle = "title";
const italic = "Italic";
const italicText = "italic text";
const limited = "The maximum character limit has been reached";
const lines = "Lines";
const link = "Link";
const linkText = "link text";
const ol = "Ordered list";
const olItem = "item";
const preview = "Preview";
const previewOnly = "Preview only";
const quote = "Quote";
const quotedText = "quoted text";
const shortcuts = "Shortcuts";
const source = "Source code";
const sync = "Scroll sync";
const toc = "Table of contents";
const top = "Scroll to top";
const ul = "Unordered list";
const ulItem = "item";
const words = "Words";
const write = "Write";
const writeOnly = "Write only";
const en = {
  bold,
  boldText,
  cheatsheet,
  closeHelp,
  closeToc,
  code,
  codeBlock,
  codeLang,
  codeText,
  exitFullscreen,
  exitPreviewOnly,
  exitWriteOnly,
  fullscreen,
  h1,
  h2,
  h3,
  h4,
  h5,
  h6,
  headingText,
  help,
  hr,
  image,
  imageAlt,
  imageTitle,
  italic,
  italicText,
  limited,
  lines,
  link,
  linkText,
  ol,
  olItem,
  preview,
  previewOnly,
  quote,
  quotedText,
  shortcuts,
  source,
  sync,
  toc,
  top,
  ul,
  ulItem,
  words,
  write,
  writeOnly
};
const icons = {
  Close: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 48 48"><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="m8 8 32 32M8 40 40 8"/></svg>',
  H: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 48 48"><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="M12 5v38M36 5v38M12 24h24"/></svg>',
  H1: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 48 48"><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="M6 8v32M25 8v32M6 24h19M34.226 24 39 19.017V40"/></svg>',
  H2: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 48 48"><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="M6 8v32M24 8v32M7 24h16M32 25c0-3.167 2.667-5 5-5s5 1.833 5 5c0 5.7-10 9.933-10 15h10"/></svg>',
  H3: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 48 48"><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="M6 8v32M24 8v32M7 24h16M32 20h10l-7 9c4 0 7 2 7 6s-3 5-5 5c-2.381 0-4-1-5-2.1"/></svg>',
  LevelFourTitle: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 48 48"><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="M6 8v32M24 8v32M7 24h16M39.977 40V20L31 32.997v2.023h12"/></svg>',
  LevelFiveTitle: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 48 48"><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="M6 8v32M24 8v32M7 24h16M40 21.01h-8v7.024C32 28 34 27 37 27s4 2.534 4 6.5-1 6.5-5 6.5c-3 0-4-2-4-3.992"/></svg>',
  LevelSixTitle: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 48 48"><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="M6 8v32M24 8v32M7 24h16"/><path stroke="currentColor" stroke-width="4" d="M36.5 40a5.5 5.5 0 1 0 0-11 5.5 5.5 0 0 0 0 11Z"/><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="M41.596 24.74C40.778 22.545 38.804 21 36.5 21c-3.038 0-5.5 2.686-5.5 6v7"/></svg>',
  TextBold: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 48 48"><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="M24 24c5.506 0 9.969-4.477 9.969-10S29.506 4 24 4H11v20h13ZM28.031 44C33.537 44 38 39.523 38 34s-4.463-10-9.969-10H11v20h17.031Z" clip-rule="evenodd"/></svg>',
  TextItalic: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 48 48"><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="M20 6h16M12 42h16M29 5.952 19 42"/></svg>',
  Quote: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 48 48"><path fill="currentColor" fill-rule="evenodd" d="M18.853 9.116C11.323 13.952 7.14 19.58 6.303 26.003 5 36 13.94 40.893 18.47 36.497 23 32.1 20.285 26.52 17.005 24.994c-3.28-1.525-5.286-.994-4.936-3.033.35-2.038 5.016-7.69 9.116-10.322a.749.749 0 0 0 .114-1.02L20.285 9.3c-.44-.572-.862-.55-1.432-.185ZM38.679 9.116c-7.53 4.836-11.714 10.465-12.55 16.887-1.303 9.997 7.637 14.89 12.167 10.494 4.53-4.397 1.815-9.977-1.466-11.503-3.28-1.525-5.286-.994-4.936-3.033.35-2.038 5.017-7.69 9.117-10.322a.749.749 0 0 0 .113-1.02L40.11 9.3c-.44-.572-.862-.55-1.431-.185Z" clip-rule="evenodd"/></svg>',
  LinkOne: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 48 48"><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="m26.24 16.373-9.14-9.14c-2.661-2.661-7.035-2.603-9.768.131-2.734 2.734-2.793 7.107-.131 9.768l7.935 7.936M32.903 23.003l7.935 7.935c2.661 2.662 2.603 7.035-.13 9.769-2.735 2.734-7.108 2.792-9.77.13l-9.14-9.14"/><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="M26.11 26.142c2.733-2.734 2.792-7.108.13-9.769M21.799 21.798c-2.734 2.734-2.792 7.108-.131 9.769"/></svg>',
  Pic: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 48 48"><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="M5 10a2 2 0 0 1 2-2h34a2 2 0 0 1 2 2v28a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V10Z" clip-rule="evenodd"/><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="M14.5 18a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3Z" clip-rule="evenodd"/><path stroke="currentColor" stroke-linejoin="round" stroke-width="4" d="m15 24 5 4 6-7 17 13v4a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2v-4l10-10Z"/></svg>',
  Code: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 48 48"><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="M16 13 4 25.432 16 37M32 13l12 12.432L32 37"/><path stroke="currentColor" stroke-linecap="round" stroke-width="4" d="m28 4-7 40"/></svg>',
  CodeBrackets: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 48 48"><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="M16 4c-2 0-5 1-5 5v9c0 3-5 5-5 5s5 2 5 5v11c0 4 3 5 5 5M32 4c2 0 5 1 5 5v9c0 3 5 5 5 5s-5 2-5 5v11c0 4-3 5-5 5"/></svg>',
  ListTwo: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 48 48"><path stroke="currentColor" stroke-linejoin="round" stroke-width="4" d="M9 42a4 4 0 1 0 0-8 4 4 0 0 0 0 8ZM9 14a4 4 0 1 0 0-8 4 4 0 0 0 0 8ZM9 28a4 4 0 1 0 0-8 4 4 0 0 0 0 8Z"/><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="M21 24h22M21 38h22M21 10h22"/></svg>',
  OrderedList: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 48 48"><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="M9 4v9M12 13H6M12 27H6M6 20s3-3 5 0-5 7-5 7M6 34.5s2-3 5-1 0 4.5 0 4.5 3 2.5 0 4.5-5-1-5-1M11 38H9M9 4 6 6M21 24h22M21 38h22M21 10h22"/></svg>',
  DividingLine: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 48 48"><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="M5 24h38M21 38h6M37 38h6M21 10h6M5 38h6M5 10h6M37 10h6"/></svg>',
  AlignTextLeftOne: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 48 48"><path stroke="currentColor" stroke-linejoin="round" stroke-width="4" d="M39 6H9a3 3 0 0 0-3 3v30a3 3 0 0 0 3 3h30a3 3 0 0 0 3-3V9a3 3 0 0 0-3-3Z"/><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="M26 24H14M34 15H14M32 33H14"/></svg>',
  Helpcenter: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 48 48"><path stroke="currentColor" stroke-linejoin="round" stroke-width="4" d="M39 6H9a3 3 0 0 0-3 3v30a3 3 0 0 0 3 3h30a3 3 0 0 0 3-3V9a3 3 0 0 0-3-3Z"/><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="M24 28.625v-4a6 6 0 1 0-6-6"/><path fill="currentColor" fill-rule="evenodd" d="M24 37.625a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5Z" clip-rule="evenodd"/></svg>',
  LeftExpand: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 48 48"><rect width="28" height="36" x="6" y="6" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" rx="2"/><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="M42 6v36"/></svg>',
  RightExpand: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 48 48"><rect width="28" height="36" x="14" y="6" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" rx="2"/><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="M6 6v36"/></svg>',
  OffScreen: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 48 48"><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="M33 6v9h9M15 6v9H6M15 42v-9H6M33 42v-9h8.9"/></svg>',
  FullScreen: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 48 48"><path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="4" d="M33 6h9v9M42 33v9h-9M15 42H6v-9M6 15V6h9"/></svg>',
  GithubOne: '<svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="none" viewBox="0 0 48 48"><path stroke="currentColor" stroke-linecap="round" stroke-width="4" d="M29.344 30.477c2.404-.5 4.585-1.366 6.28-2.638C38.52 25.668 40 22.314 40 19c0-2.324-.881-4.494-2.407-6.332-.85-1.024 1.636-8.667-.573-7.638-2.21 1.03-5.45 3.308-7.147 2.805A20.712 20.712 0 0 0 24 7c-1.8 0-3.532.223-5.147.634C16.505 8.232 14.259 6 12 5.03c-2.26-.97-1.026 6.934-1.697 7.765C8.84 14.605 8 16.73 8 19c0 3.314 1.79 6.668 4.686 8.84 1.93 1.446 4.348 2.368 7.054 2.822M19.74 30.662c-1.159 1.275-1.738 2.486-1.738 3.632v8.717M29.345 30.477c1.097 1.44 1.646 2.734 1.646 3.88v8.654M6 31.215c.899.11 1.566.524 2 1.24.652 1.075 3.074 5.063 5.825 5.063h4.177"/></svg>'
};
function createCodeMirror() {
  const codemirror = factory();
  usePlaceholder(codemirror);
  useOverlay(codemirror);
  useXml(codemirror);
  useMarkdown(codemirror);
  useGfm(codemirror);
  useYaml(codemirror);
  useYamlFrontmatter(codemirror);
  useContinuelist(codemirror);
  return codemirror;
}
function createEditorUtils(codemirror, editor) {
  return {
    /**
     * Wrap text with decorators, for example:
     *
     * `text -> *text*`
     */
    wrapText(before, after = before) {
      const range = editor.somethingSelected() ? editor.listSelections()[0] : editor.findWordAt(editor.getCursor());
      const from = range.from();
      const to = range.to();
      const text2 = editor.getRange(from, to);
      const fromBefore = codemirror.Pos(from.line, from.ch - before.length);
      const toAfter = codemirror.Pos(to.line, to.ch + after.length);
      if (editor.getRange(fromBefore, from) === before && editor.getRange(to, toAfter) === after) {
        editor.replaceRange(text2, fromBefore, toAfter);
        editor.setSelection(
          fromBefore,
          codemirror.Pos(fromBefore.line, fromBefore.ch + text2.length)
        );
      } else {
        editor.replaceRange(before + text2 + after, from, to);
        const cursor = editor.getCursor();
        editor.setSelection(
          codemirror.Pos(cursor.line, cursor.ch - after.length - text2.length),
          codemirror.Pos(cursor.line, cursor.ch - after.length)
        );
      }
    },
    /**
     * replace multiple lines
     *
     * `line -> # line`
     */
    replaceLines(replace) {
      const [selection] = editor.listSelections();
      const range = [
        codemirror.Pos(selection.from().line, 0),
        codemirror.Pos(selection.to().line)
      ];
      const lines2 = editor.getRange(...range).split("\n");
      editor.replaceRange(lines2.map(replace).join("\n"), ...range);
      editor.setSelection(...range);
    },
    /**
     * Append a block based on the cursor position
     */
    appendBlock(content) {
      const cursor = editor.getCursor();
      let emptyLine = -1;
      for (let i = cursor.line; i < editor.lineCount(); i++) {
        if (!editor.getLine(i).trim()) {
          emptyLine = i;
          break;
        }
      }
      if (emptyLine === -1) {
        editor.replaceRange("\n", codemirror.Pos(editor.lineCount()));
        emptyLine = editor.lineCount();
      }
      editor.replaceRange("\n" + content, codemirror.Pos(emptyLine));
      return codemirror.Pos(emptyLine + 1, 0);
    },
    /**
     * Triggers a virtual file input and let user select files
     *
     * https://www.npmjs.com/package/select-files
     */
    selectFiles
  };
}
function findStartIndex(num, nums) {
  let startIndex = nums.length - 2;
  for (let i = 0; i < nums.length; i++) {
    if (num < nums[i]) {
      startIndex = i - 1;
      break;
    }
  }
  startIndex = Math.max(startIndex, 0);
  return startIndex;
}
const getShortcutWithPrefix = (key, shift = false) => {
  const shiftPrefix = shift ? "Shift-" : "";
  const CmdPrefix = typeof navigator !== "undefined" && /Mac/.test(navigator.platform) ? "Cmd-" : "Ctrl-";
  return shiftPrefix + CmdPrefix + key;
};
async function handleImageUpload({ editor, appendBlock, codemirror }, uploadImages, files) {
  const imgs = await uploadImages(files);
  const pos = appendBlock(
    imgs.map(({ url, alt, title }, i) => {
      alt = alt != null ? alt : files[i].name;
      return `![${alt}](${url}${title ? ` "${title}"` : ""})`;
    }).join("\n\n")
  );
  editor.setSelection(pos, codemirror.Pos(pos.line + imgs.length * 2 - 2));
  editor.focus();
}
function getBuiltinActions(locale, plugins, uploadImages) {
  const leftActions = [
    {
      icon: icons.H,
      handler: {
        type: "dropdown",
        actions: [1, 2, 3, 4, 5, 6].map((level) => ({
          title: locale[`h${level}`],
          icon: [
            icons.H1,
            icons.H2,
            icons.H3,
            icons.LevelFourTitle,
            icons.LevelFiveTitle,
            icons.LevelSixTitle
          ][level - 1],
          cheatsheet: level <= 3 ? `${"#".repeat(level)} ${locale.headingText}` : void 0,
          handler: {
            type: "action",
            click({ replaceLines, editor }) {
              replaceLines((line) => {
                line = line.trim().replace(/^#*/, "").trim();
                line = "#".repeat(level) + " " + line;
                return line;
              });
              editor.focus();
            }
          }
        }))
      }
    },
    {
      title: locale.bold,
      icon: icons.TextBold,
      cheatsheet: `**${locale.boldText}**`,
      handler: {
        type: "action",
        shortcut: getShortcutWithPrefix("B"),
        click({ wrapText, editor }) {
          wrapText("**");
          editor.focus();
        }
      }
    },
    {
      title: locale.italic,
      icon: icons.TextItalic,
      cheatsheet: `*${locale.italicText}*`,
      handler: {
        type: "action",
        shortcut: getShortcutWithPrefix("I"),
        click({ wrapText, editor }) {
          wrapText("*");
          editor.focus();
        }
      }
    },
    {
      title: locale.quote,
      icon: icons.Quote,
      cheatsheet: `> ${locale.quotedText}`,
      handler: {
        type: "action",
        click({ replaceLines, editor }) {
          replaceLines((line) => "> " + line);
          editor.focus();
        }
      }
    },
    {
      title: locale.link,
      icon: icons.LinkOne,
      cheatsheet: `[${locale.linkText}](url)`,
      handler: {
        type: "action",
        shortcut: getShortcutWithPrefix("K"),
        click({ editor, wrapText, codemirror }) {
          wrapText("[", "](url)");
          const cursor = editor.getCursor();
          editor.setSelection(
            codemirror.Pos(cursor.line, cursor.ch + 2),
            codemirror.Pos(cursor.line, cursor.ch + 5)
          );
          editor.focus();
        }
      }
    },
    {
      title: locale.image,
      icon: icons.Pic,
      cheatsheet: `![${locale.imageAlt}](url "${locale.imageTitle}")`,
      handler: uploadImages ? {
        type: "action",
        shortcut: getShortcutWithPrefix("I", true),
        async click(ctx) {
          const fileList = await selectFiles({
            accept: "image/*",
            multiple: true
          });
          if (fileList == null ? void 0 : fileList.length) {
            await handleImageUpload(ctx, uploadImages, Array.from(fileList));
          }
        }
      } : void 0
    },
    {
      title: locale.code,
      icon: icons.Code,
      cheatsheet: "`" + locale.codeText + "`",
      handler: {
        type: "action",
        shortcut: getShortcutWithPrefix("K", true),
        click({ wrapText, editor }) {
          wrapText("`");
          editor.focus();
        }
      }
    },
    {
      title: locale.codeBlock,
      icon: icons.CodeBrackets,
      cheatsheet: "```" + locale.codeLang + "↵",
      handler: {
        type: "action",
        shortcut: getShortcutWithPrefix("C", true),
        click({ editor, appendBlock, codemirror }) {
          const pos = appendBlock("```js\n```");
          editor.setSelection(
            codemirror.Pos(pos.line, 3),
            codemirror.Pos(pos.line, 5)
          );
          editor.focus();
        }
      }
    },
    {
      title: locale.ul,
      icon: icons.ListTwo,
      cheatsheet: `- ${locale.ulItem}`,
      handler: {
        type: "action",
        shortcut: getShortcutWithPrefix("U", true),
        click({ replaceLines, editor }) {
          replaceLines((line) => "- " + line);
          editor.focus();
        }
      }
    },
    {
      title: locale.ol,
      icon: icons.OrderedList,
      cheatsheet: `1. ${locale.olItem}`,
      handler: {
        type: "action",
        shortcut: getShortcutWithPrefix("O", true),
        click({ replaceLines, editor }) {
          replaceLines((line, i) => `${i + 1}. ${line}`);
          editor.focus();
        }
      }
    },
    {
      title: locale.hr,
      icon: icons.DividingLine,
      cheatsheet: "---"
    }
  ];
  const rightActions = [];
  plugins.forEach(({ actions }) => {
    if (actions) {
      actions.forEach((action) => {
        if (!action.position || action.position !== "right")
          leftActions.push(action);
        else
          rightActions.unshift(action);
      });
    }
  });
  return {
    leftActions,
    rightActions
  };
}
function get_each_context$2(ctx, list, i) {
  const child_ctx = ctx.slice();
  child_ctx[5] = list[i];
  return child_ctx;
}
function get_each_context_1$1(ctx, list, i) {
  const child_ctx = ctx.slice();
  child_ctx[5] = list[i];
  return child_ctx;
}
function create_if_block_1$2(ctx) {
  let li;
  let div0;
  let raw_value = (
    /*action*/
    ctx[5].icon + ""
  );
  let div1;
  let t0_value = (
    /*action*/
    ctx[5].title + ""
  );
  let t0;
  let div2;
  let code2;
  let t1_value = (
    /*action*/
    ctx[5].cheatsheet + ""
  );
  let t1;
  return {
    c() {
      li = element("li");
      div0 = element("div");
      div1 = element("div");
      t0 = text(t0_value);
      div2 = element("div");
      code2 = element("code");
      t1 = text(t1_value);
      attr(div0, "class", "bytemd-help-icon");
      attr(div1, "class", "bytemd-help-title");
      attr(div2, "class", "bytemd-help-content");
    },
    m(target, anchor) {
      insert(target, li, anchor);
      append(li, div0);
      div0.innerHTML = raw_value;
      append(li, div1);
      append(div1, t0);
      append(li, div2);
      append(div2, code2);
      append(code2, t1);
    },
    p(ctx2, dirty) {
      if (dirty & /*items*/
      4 && raw_value !== (raw_value = /*action*/
      ctx2[5].icon + ""))
        div0.innerHTML = raw_value;
      if (dirty & /*items*/
      4 && t0_value !== (t0_value = /*action*/
      ctx2[5].title + ""))
        set_data(t0, t0_value);
      if (dirty & /*items*/
      4 && t1_value !== (t1_value = /*action*/
      ctx2[5].cheatsheet + ""))
        set_data(t1, t1_value);
    },
    d(detaching) {
      if (detaching)
        detach(li);
    }
  };
}
function create_each_block_1$1(ctx) {
  let if_block_anchor;
  let if_block = (
    /*action*/
    ctx[5].cheatsheet && create_if_block_1$2(ctx)
  );
  return {
    c() {
      if (if_block)
        if_block.c();
      if_block_anchor = empty();
    },
    m(target, anchor) {
      if (if_block)
        if_block.m(target, anchor);
      insert(target, if_block_anchor, anchor);
    },
    p(ctx2, dirty) {
      if (
        /*action*/
        ctx2[5].cheatsheet
      ) {
        if (if_block) {
          if_block.p(ctx2, dirty);
        } else {
          if_block = create_if_block_1$2(ctx2);
          if_block.c();
          if_block.m(if_block_anchor.parentNode, if_block_anchor);
        }
      } else if (if_block) {
        if_block.d(1);
        if_block = null;
      }
    },
    d(detaching) {
      if (if_block)
        if_block.d(detaching);
      if (detaching)
        detach(if_block_anchor);
    }
  };
}
function create_if_block$3(ctx) {
  let li;
  let div0;
  let raw_value = (
    /*action*/
    ctx[5].icon + ""
  );
  let div1;
  let t0_value = (
    /*action*/
    ctx[5].title + ""
  );
  let t0;
  let div2;
  let kbd;
  let t1_value = (
    /*action*/
    ctx[5].handler.shortcut + ""
  );
  let t1;
  return {
    c() {
      li = element("li");
      div0 = element("div");
      div1 = element("div");
      t0 = text(t0_value);
      div2 = element("div");
      kbd = element("kbd");
      t1 = text(t1_value);
      attr(div0, "class", "bytemd-help-icon");
      attr(div1, "class", "bytemd-help-title");
      attr(div2, "class", "bytemd-help-content");
    },
    m(target, anchor) {
      insert(target, li, anchor);
      append(li, div0);
      div0.innerHTML = raw_value;
      append(li, div1);
      append(div1, t0);
      append(li, div2);
      append(div2, kbd);
      append(kbd, t1);
    },
    p(ctx2, dirty) {
      if (dirty & /*items*/
      4 && raw_value !== (raw_value = /*action*/
      ctx2[5].icon + ""))
        div0.innerHTML = raw_value;
      if (dirty & /*items*/
      4 && t0_value !== (t0_value = /*action*/
      ctx2[5].title + ""))
        set_data(t0, t0_value);
      if (dirty & /*items*/
      4 && t1_value !== (t1_value = /*action*/
      ctx2[5].handler.shortcut + ""))
        set_data(t1, t1_value);
    },
    d(detaching) {
      if (detaching)
        detach(li);
    }
  };
}
function create_each_block$2(ctx) {
  let if_block_anchor;
  let if_block = (
    /*action*/
    ctx[5].handler && /*action*/
    ctx[5].handler.type === "action" && /*action*/
    ctx[5].handler.shortcut && create_if_block$3(ctx)
  );
  return {
    c() {
      if (if_block)
        if_block.c();
      if_block_anchor = empty();
    },
    m(target, anchor) {
      if (if_block)
        if_block.m(target, anchor);
      insert(target, if_block_anchor, anchor);
    },
    p(ctx2, dirty) {
      if (
        /*action*/
        ctx2[5].handler && /*action*/
        ctx2[5].handler.type === "action" && /*action*/
        ctx2[5].handler.shortcut
      ) {
        if (if_block) {
          if_block.p(ctx2, dirty);
        } else {
          if_block = create_if_block$3(ctx2);
          if_block.c();
          if_block.m(if_block_anchor.parentNode, if_block_anchor);
        }
      } else if (if_block) {
        if_block.d(1);
        if_block = null;
      }
    },
    d(detaching) {
      if (if_block)
        if_block.d(detaching);
      if (detaching)
        detach(if_block_anchor);
    }
  };
}
function create_fragment$5(ctx) {
  let div;
  let h20;
  let t0_value = (
    /*locale*/
    ctx[0].cheatsheet + ""
  );
  let t0;
  let ul0;
  let h21;
  let t1_value = (
    /*locale*/
    ctx[0].shortcuts + ""
  );
  let t1;
  let ul1;
  let each_value_1 = (
    /*items*/
    ctx[2]
  );
  let each_blocks_1 = [];
  for (let i = 0; i < each_value_1.length; i += 1) {
    each_blocks_1[i] = create_each_block_1$1(get_each_context_1$1(ctx, each_value_1, i));
  }
  let each_value = (
    /*items*/
    ctx[2]
  );
  let each_blocks = [];
  for (let i = 0; i < each_value.length; i += 1) {
    each_blocks[i] = create_each_block$2(get_each_context$2(ctx, each_value, i));
  }
  return {
    c() {
      div = element("div");
      h20 = element("h2");
      t0 = text(t0_value);
      ul0 = element("ul");
      for (let i = 0; i < each_blocks_1.length; i += 1) {
        each_blocks_1[i].c();
      }
      h21 = element("h2");
      t1 = text(t1_value);
      ul1 = element("ul");
      for (let i = 0; i < each_blocks.length; i += 1) {
        each_blocks[i].c();
      }
      attr(div, "class", "bytemd-help");
      toggle_class(div, "bytemd-hidden", !/*visible*/
      ctx[1]);
    },
    m(target, anchor) {
      insert(target, div, anchor);
      append(div, h20);
      append(h20, t0);
      append(div, ul0);
      for (let i = 0; i < each_blocks_1.length; i += 1) {
        if (each_blocks_1[i]) {
          each_blocks_1[i].m(ul0, null);
        }
      }
      append(div, h21);
      append(h21, t1);
      append(div, ul1);
      for (let i = 0; i < each_blocks.length; i += 1) {
        if (each_blocks[i]) {
          each_blocks[i].m(ul1, null);
        }
      }
    },
    p(ctx2, [dirty]) {
      if (dirty & /*locale*/
      1 && t0_value !== (t0_value = /*locale*/
      ctx2[0].cheatsheet + ""))
        set_data(t0, t0_value);
      if (dirty & /*items*/
      4) {
        each_value_1 = /*items*/
        ctx2[2];
        let i;
        for (i = 0; i < each_value_1.length; i += 1) {
          const child_ctx = get_each_context_1$1(ctx2, each_value_1, i);
          if (each_blocks_1[i]) {
            each_blocks_1[i].p(child_ctx, dirty);
          } else {
            each_blocks_1[i] = create_each_block_1$1(child_ctx);
            each_blocks_1[i].c();
            each_blocks_1[i].m(ul0, null);
          }
        }
        for (; i < each_blocks_1.length; i += 1) {
          each_blocks_1[i].d(1);
        }
        each_blocks_1.length = each_value_1.length;
      }
      if (dirty & /*locale*/
      1 && t1_value !== (t1_value = /*locale*/
      ctx2[0].shortcuts + ""))
        set_data(t1, t1_value);
      if (dirty & /*items*/
      4) {
        each_value = /*items*/
        ctx2[2];
        let i;
        for (i = 0; i < each_value.length; i += 1) {
          const child_ctx = get_each_context$2(ctx2, each_value, i);
          if (each_blocks[i]) {
            each_blocks[i].p(child_ctx, dirty);
          } else {
            each_blocks[i] = create_each_block$2(child_ctx);
            each_blocks[i].c();
            each_blocks[i].m(ul1, null);
          }
        }
        for (; i < each_blocks.length; i += 1) {
          each_blocks[i].d(1);
        }
        each_blocks.length = each_value.length;
      }
      if (dirty & /*visible*/
      2) {
        toggle_class(div, "bytemd-hidden", !/*visible*/
        ctx2[1]);
      }
    },
    i: noop,
    o: noop,
    d(detaching) {
      if (detaching)
        detach(div);
      destroy_each(each_blocks_1, detaching);
      destroy_each(each_blocks, detaching);
    }
  };
}
function instance$5($$self, $$props, $$invalidate) {
  let items;
  let { actions } = $$props;
  let { locale } = $$props;
  let { visible } = $$props;
  function flatItems(actions2) {
    let items2 = [];
    actions2.forEach((action) => {
      const { handler, cheatsheet: cheatsheet2 } = action;
      if ((handler == null ? void 0 : handler.type) === "dropdown") {
        items2.push(...flatItems(handler.actions));
      }
      if (cheatsheet2) {
        items2.push(action);
      }
    });
    return items2;
  }
  $$self.$$set = ($$props2) => {
    if ("actions" in $$props2)
      $$invalidate(3, actions = $$props2.actions);
    if ("locale" in $$props2)
      $$invalidate(0, locale = $$props2.locale);
    if ("visible" in $$props2)
      $$invalidate(1, visible = $$props2.visible);
  };
  $$self.$$.update = () => {
    if ($$self.$$.dirty & /*actions*/
    8) {
      $$invalidate(2, items = flatItems(actions));
    }
  };
  return [locale, visible, items, actions];
}
class Help extends SvelteComponent {
  constructor(options) {
    super();
    init(this, options, instance$5, create_fragment$5, safe_not_equal, { actions: 3, locale: 0, visible: 1 });
  }
}
function create_if_block_1$1(ctx) {
  let span;
  let t_value = (
    /*locale*/
    ctx[2].limited + ""
  );
  let t;
  return {
    c() {
      span = element("span");
      t = text(t_value);
      attr(span, "class", "bytemd-status-error");
    },
    m(target, anchor) {
      insert(target, span, anchor);
      append(span, t);
    },
    p(ctx2, dirty) {
      if (dirty & /*locale*/
      4 && t_value !== (t_value = /*locale*/
      ctx2[2].limited + ""))
        set_data(t, t_value);
    },
    d(detaching) {
      if (detaching)
        detach(span);
    }
  };
}
function create_if_block$2(ctx) {
  let label;
  let input;
  let t_value = (
    /*locale*/
    ctx[2].sync + ""
  );
  let t;
  let mounted;
  let dispose;
  return {
    c() {
      label = element("label");
      input = element("input");
      t = text(t_value);
      attr(input, "type", "checkbox");
      input.checked = /*syncEnabled*/
      ctx[1];
    },
    m(target, anchor) {
      insert(target, label, anchor);
      append(label, input);
      append(label, t);
      if (!mounted) {
        dispose = listen(
          input,
          "change",
          /*change_handler*/
          ctx[8]
        );
        mounted = true;
      }
    },
    p(ctx2, dirty) {
      if (dirty & /*syncEnabled*/
      2) {
        input.checked = /*syncEnabled*/
        ctx2[1];
      }
      if (dirty & /*locale*/
      4 && t_value !== (t_value = /*locale*/
      ctx2[2].sync + ""))
        set_data(t, t_value);
    },
    d(detaching) {
      if (detaching)
        detach(label);
      mounted = false;
      dispose();
    }
  };
}
function create_fragment$4(ctx) {
  let div2;
  let div0;
  let span0;
  let t0_value = (
    /*locale*/
    ctx[2].words + ""
  );
  let t0;
  let t1;
  let strong0;
  let t2;
  let span1;
  let t3_value = (
    /*locale*/
    ctx[2].lines + ""
  );
  let t3;
  let t4;
  let strong1;
  let t5;
  let div1;
  let span2;
  let t6_value = (
    /*locale*/
    ctx[2].top + ""
  );
  let t6;
  let mounted;
  let dispose;
  let if_block0 = (
    /*islimited*/
    ctx[3] && create_if_block_1$1(ctx)
  );
  let if_block1 = (
    /*showSync*/
    ctx[0] && create_if_block$2(ctx)
  );
  return {
    c() {
      div2 = element("div");
      div0 = element("div");
      span0 = element("span");
      t0 = text(t0_value);
      t1 = text(": ");
      strong0 = element("strong");
      t2 = text(
        /*words*/
        ctx[5]
      );
      span1 = element("span");
      t3 = text(t3_value);
      t4 = text(": ");
      strong1 = element("strong");
      t5 = text(
        /*lines*/
        ctx[4]
      );
      if (if_block0)
        if_block0.c();
      div1 = element("div");
      if (if_block1)
        if_block1.c();
      span2 = element("span");
      t6 = text(t6_value);
      attr(div0, "class", "bytemd-status-left");
      attr(div1, "class", "bytemd-status-right");
      attr(div2, "class", "bytemd-status");
    },
    m(target, anchor) {
      insert(target, div2, anchor);
      append(div2, div0);
      append(div0, span0);
      append(span0, t0);
      append(span0, t1);
      append(span0, strong0);
      append(strong0, t2);
      append(div0, span1);
      append(span1, t3);
      append(span1, t4);
      append(span1, strong1);
      append(strong1, t5);
      if (if_block0)
        if_block0.m(div0, null);
      append(div2, div1);
      if (if_block1)
        if_block1.m(div1, null);
      append(div1, span2);
      append(span2, t6);
      if (!mounted) {
        dispose = [
          listen(
            span2,
            "click",
            /*click_handler*/
            ctx[9]
          ),
          listen(span2, "keydown", self(
            /*keydown_handler*/
            ctx[10]
          ))
        ];
        mounted = true;
      }
    },
    p(ctx2, [dirty]) {
      if (dirty & /*locale*/
      4 && t0_value !== (t0_value = /*locale*/
      ctx2[2].words + ""))
        set_data(t0, t0_value);
      if (dirty & /*words*/
      32)
        set_data(
          t2,
          /*words*/
          ctx2[5]
        );
      if (dirty & /*locale*/
      4 && t3_value !== (t3_value = /*locale*/
      ctx2[2].lines + ""))
        set_data(t3, t3_value);
      if (dirty & /*lines*/
      16)
        set_data(
          t5,
          /*lines*/
          ctx2[4]
        );
      if (
        /*islimited*/
        ctx2[3]
      ) {
        if (if_block0) {
          if_block0.p(ctx2, dirty);
        } else {
          if_block0 = create_if_block_1$1(ctx2);
          if_block0.c();
          if_block0.m(div0, null);
        }
      } else if (if_block0) {
        if_block0.d(1);
        if_block0 = null;
      }
      if (
        /*showSync*/
        ctx2[0]
      ) {
        if (if_block1) {
          if_block1.p(ctx2, dirty);
        } else {
          if_block1 = create_if_block$2(ctx2);
          if_block1.c();
          if_block1.m(div1, span2);
        }
      } else if (if_block1) {
        if_block1.d(1);
        if_block1 = null;
      }
      if (dirty & /*locale*/
      4 && t6_value !== (t6_value = /*locale*/
      ctx2[2].top + ""))
        set_data(t6, t6_value);
    },
    i: noop,
    o: noop,
    d(detaching) {
      if (detaching)
        detach(div2);
      if (if_block0)
        if_block0.d();
      if (if_block1)
        if_block1.d();
      mounted = false;
      run_all(dispose);
    }
  };
}
function instance$4($$self, $$props, $$invalidate) {
  let words2;
  let lines2;
  let { showSync } = $$props;
  let { value } = $$props;
  let { syncEnabled } = $$props;
  let { locale } = $$props;
  let { islimited } = $$props;
  const dispatch = createEventDispatcher();
  const change_handler = () => dispatch("sync", !syncEnabled);
  const click_handler = () => dispatch("top");
  const keydown_handler = (e) => ["Enter", "Space"].includes(e.code) && dispatch("top");
  $$self.$$set = ($$props2) => {
    if ("showSync" in $$props2)
      $$invalidate(0, showSync = $$props2.showSync);
    if ("value" in $$props2)
      $$invalidate(7, value = $$props2.value);
    if ("syncEnabled" in $$props2)
      $$invalidate(1, syncEnabled = $$props2.syncEnabled);
    if ("locale" in $$props2)
      $$invalidate(2, locale = $$props2.locale);
    if ("islimited" in $$props2)
      $$invalidate(3, islimited = $$props2.islimited);
  };
  $$self.$$.update = () => {
    if ($$self.$$.dirty & /*value*/
    128) {
      $$invalidate(5, words2 = wordCount(value));
    }
    if ($$self.$$.dirty & /*value*/
    128) {
      $$invalidate(4, lines2 = value.split("\n").length);
    }
  };
  return [
    showSync,
    syncEnabled,
    locale,
    islimited,
    lines2,
    words2,
    dispatch,
    value,
    change_handler,
    click_handler,
    keydown_handler
  ];
}
class Status extends SvelteComponent {
  constructor(options) {
    super();
    init(this, options, instance$4, create_fragment$4, safe_not_equal, {
      showSync: 0,
      value: 7,
      syncEnabled: 1,
      locale: 2,
      islimited: 3
    });
  }
}
function get_each_context$1(ctx, list, i) {
  const child_ctx = ctx.slice();
  child_ctx[11] = list[i];
  child_ctx[13] = i;
  return child_ctx;
}
function create_each_block$1(ctx) {
  let li;
  let t_value = (
    /*item*/
    ctx[11].text + ""
  );
  let t;
  let li_class_value;
  let li_style_value;
  let mounted;
  let dispose;
  function click_handler() {
    return (
      /*click_handler*/
      ctx[8](
        /*index*/
        ctx[13]
      )
    );
  }
  function keydown_handler(...args) {
    return (
      /*keydown_handler*/
      ctx[9](
        /*index*/
        ctx[13],
        ...args
      )
    );
  }
  return {
    c() {
      li = element("li");
      t = text(t_value);
      attr(li, "class", li_class_value = `bytemd-toc-${/*item*/
      ctx[11].level}`);
      attr(li, "style", li_style_value = `padding-left:${/*item*/
      (ctx[11].level - /*minLevel*/
      ctx[3]) * 16 + 8}px`);
      toggle_class(
        li,
        "bytemd-toc-active",
        /*currentHeadingIndex*/
        ctx[4] === /*index*/
        ctx[13]
      );
      toggle_class(
        li,
        "bytemd-toc-first",
        /*item*/
        ctx[11].level === /*minLevel*/
        ctx[3]
      );
    },
    m(target, anchor) {
      insert(target, li, anchor);
      append(li, t);
      if (!mounted) {
        dispose = [
          listen(li, "click", click_handler),
          listen(li, "keydown", self(keydown_handler))
        ];
        mounted = true;
      }
    },
    p(new_ctx, dirty) {
      ctx = new_ctx;
      if (dirty & /*items*/
      4 && t_value !== (t_value = /*item*/
      ctx[11].text + ""))
        set_data(t, t_value);
      if (dirty & /*items*/
      4 && li_class_value !== (li_class_value = `bytemd-toc-${/*item*/
      ctx[11].level}`)) {
        attr(li, "class", li_class_value);
      }
      if (dirty & /*items, minLevel*/
      12 && li_style_value !== (li_style_value = `padding-left:${/*item*/
      (ctx[11].level - /*minLevel*/
      ctx[3]) * 16 + 8}px`)) {
        attr(li, "style", li_style_value);
      }
      if (dirty & /*items, currentHeadingIndex*/
      20) {
        toggle_class(
          li,
          "bytemd-toc-active",
          /*currentHeadingIndex*/
          ctx[4] === /*index*/
          ctx[13]
        );
      }
      if (dirty & /*items, items, minLevel*/
      12) {
        toggle_class(
          li,
          "bytemd-toc-first",
          /*item*/
          ctx[11].level === /*minLevel*/
          ctx[3]
        );
      }
    },
    d(detaching) {
      if (detaching)
        detach(li);
      mounted = false;
      run_all(dispose);
    }
  };
}
function create_fragment$3(ctx) {
  let div;
  let h22;
  let t_value = (
    /*locale*/
    ctx[0].toc + ""
  );
  let t;
  let ul2;
  let each_value = (
    /*items*/
    ctx[2]
  );
  let each_blocks = [];
  for (let i = 0; i < each_value.length; i += 1) {
    each_blocks[i] = create_each_block$1(get_each_context$1(ctx, each_value, i));
  }
  return {
    c() {
      div = element("div");
      h22 = element("h2");
      t = text(t_value);
      ul2 = element("ul");
      for (let i = 0; i < each_blocks.length; i += 1) {
        each_blocks[i].c();
      }
      attr(div, "class", "bytemd-toc");
      toggle_class(div, "bytemd-hidden", !/*visible*/
      ctx[1]);
    },
    m(target, anchor) {
      insert(target, div, anchor);
      append(div, h22);
      append(h22, t);
      append(div, ul2);
      for (let i = 0; i < each_blocks.length; i += 1) {
        if (each_blocks[i]) {
          each_blocks[i].m(ul2, null);
        }
      }
    },
    p(ctx2, [dirty]) {
      if (dirty & /*locale*/
      1 && t_value !== (t_value = /*locale*/
      ctx2[0].toc + ""))
        set_data(t, t_value);
      if (dirty & /*items, minLevel, currentHeadingIndex, dispatch*/
      60) {
        each_value = /*items*/
        ctx2[2];
        let i;
        for (i = 0; i < each_value.length; i += 1) {
          const child_ctx = get_each_context$1(ctx2, each_value, i);
          if (each_blocks[i]) {
            each_blocks[i].p(child_ctx, dirty);
          } else {
            each_blocks[i] = create_each_block$1(child_ctx);
            each_blocks[i].c();
            each_blocks[i].m(ul2, null);
          }
        }
        for (; i < each_blocks.length; i += 1) {
          each_blocks[i].d(1);
        }
        each_blocks.length = each_value.length;
      }
      if (dirty & /*visible*/
      2) {
        toggle_class(div, "bytemd-hidden", !/*visible*/
        ctx2[1]);
      }
    },
    i: noop,
    o: noop,
    d(detaching) {
      if (detaching)
        detach(div);
      destroy_each(each_blocks, detaching);
    }
  };
}
function instance$3($$self, $$props, $$invalidate) {
  let { hast } = $$props;
  let { currentBlockIndex } = $$props;
  let { locale } = $$props;
  let { visible } = $$props;
  const dispatch = createEventDispatcher();
  let items;
  let minLevel = 6;
  let currentHeadingIndex = 0;
  function stringifyHeading(e) {
    let result = "";
    visit(e, (node) => {
      if (node.type === "text") {
        result += node.value;
      }
    });
    return result;
  }
  const click_handler = (index2) => {
    dispatch("click", index2);
  };
  const keydown_handler = (index2, e) => {
    if (["Enter", "Space"].includes(e.code)) {
      dispatch("click", index2);
    }
  };
  $$self.$$set = ($$props2) => {
    if ("hast" in $$props2)
      $$invalidate(6, hast = $$props2.hast);
    if ("currentBlockIndex" in $$props2)
      $$invalidate(7, currentBlockIndex = $$props2.currentBlockIndex);
    if ("locale" in $$props2)
      $$invalidate(0, locale = $$props2.locale);
    if ("visible" in $$props2)
      $$invalidate(1, visible = $$props2.visible);
  };
  $$self.$$.update = () => {
    if ($$self.$$.dirty & /*hast, minLevel, items, currentBlockIndex*/
    204) {
      (() => {
        $$invalidate(2, items = []);
        $$invalidate(4, currentHeadingIndex = 0);
        hast.children.filter((v) => v.type === "element").forEach((node, index2) => {
          if (node.tagName[0] === "h" && !!node.children.length) {
            const i = Number(node.tagName[1]);
            $$invalidate(3, minLevel = Math.min(minLevel, i));
            items.push({ level: i, text: stringifyHeading(node) });
          }
          if (currentBlockIndex >= index2) {
            $$invalidate(4, currentHeadingIndex = items.length - 1);
          }
        });
      })();
    }
  };
  return [
    locale,
    visible,
    items,
    minLevel,
    currentHeadingIndex,
    dispatch,
    hast,
    currentBlockIndex,
    click_handler,
    keydown_handler
  ];
}
class Toc extends SvelteComponent {
  constructor(options) {
    super();
    init(this, options, instance$3, create_fragment$3, not_equal, {
      hast: 6,
      currentBlockIndex: 7,
      locale: 0,
      visible: 1
    });
  }
}
function get_each_context(ctx, list, i) {
  const child_ctx = ctx.slice();
  child_ctx[25] = list[i];
  child_ctx[27] = i;
  return child_ctx;
}
function get_each_context_1(ctx, list, i) {
  const child_ctx = ctx.slice();
  child_ctx[25] = list[i];
  child_ctx[27] = i;
  return child_ctx;
}
function create_else_block(ctx) {
  let div0;
  let t0_value = (
    /*locale*/
    ctx[2].write + ""
  );
  let t0;
  let div1;
  let t1_value = (
    /*locale*/
    ctx[2].preview + ""
  );
  let t1;
  let mounted;
  let dispose;
  return {
    c() {
      div0 = element("div");
      t0 = text(t0_value);
      div1 = element("div");
      t1 = text(t1_value);
      attr(div0, "class", "bytemd-toolbar-tab");
      toggle_class(
        div0,
        "bytemd-toolbar-tab-active",
        /*activeTab*/
        ctx[1] !== "preview"
      );
      attr(div1, "class", "bytemd-toolbar-tab");
      toggle_class(
        div1,
        "bytemd-toolbar-tab-active",
        /*activeTab*/
        ctx[1] === "preview"
      );
    },
    m(target, anchor) {
      insert(target, div0, anchor);
      append(div0, t0);
      insert(target, div1, anchor);
      append(div1, t1);
      if (!mounted) {
        dispose = [
          listen(
            div0,
            "click",
            /*click_handler*/
            ctx[16]
          ),
          listen(div0, "keydown", self(
            /*keydown_handler*/
            ctx[17]
          )),
          listen(
            div1,
            "click",
            /*click_handler_1*/
            ctx[18]
          ),
          listen(div1, "keydown", self(
            /*keydown_handler_1*/
            ctx[19]
          ))
        ];
        mounted = true;
      }
    },
    p(ctx2, dirty) {
      if (dirty & /*locale*/
      4 && t0_value !== (t0_value = /*locale*/
      ctx2[2].write + ""))
        set_data(t0, t0_value);
      if (dirty & /*activeTab*/
      2) {
        toggle_class(
          div0,
          "bytemd-toolbar-tab-active",
          /*activeTab*/
          ctx2[1] !== "preview"
        );
      }
      if (dirty & /*locale*/
      4 && t1_value !== (t1_value = /*locale*/
      ctx2[2].preview + ""))
        set_data(t1, t1_value);
      if (dirty & /*activeTab*/
      2) {
        toggle_class(
          div1,
          "bytemd-toolbar-tab-active",
          /*activeTab*/
          ctx2[1] === "preview"
        );
      }
    },
    d(detaching) {
      if (detaching)
        detach(div0);
      if (detaching)
        detach(div1);
      mounted = false;
      run_all(dispose);
    }
  };
}
function create_if_block_1(ctx) {
  let each_1_anchor;
  let each_value_1 = (
    /*actions*/
    ctx[3]
  );
  let each_blocks = [];
  for (let i = 0; i < each_value_1.length; i += 1) {
    each_blocks[i] = create_each_block_1(get_each_context_1(ctx, each_value_1, i));
  }
  return {
    c() {
      for (let i = 0; i < each_blocks.length; i += 1) {
        each_blocks[i].c();
      }
      each_1_anchor = empty();
    },
    m(target, anchor) {
      for (let i = 0; i < each_blocks.length; i += 1) {
        if (each_blocks[i]) {
          each_blocks[i].m(target, anchor);
        }
      }
      insert(target, each_1_anchor, anchor);
    },
    p(ctx2, dirty) {
      if (dirty & /*tippyClass, actions*/
      8) {
        each_value_1 = /*actions*/
        ctx2[3];
        let i;
        for (i = 0; i < each_value_1.length; i += 1) {
          const child_ctx = get_each_context_1(ctx2, each_value_1, i);
          if (each_blocks[i]) {
            each_blocks[i].p(child_ctx, dirty);
          } else {
            each_blocks[i] = create_each_block_1(child_ctx);
            each_blocks[i].c();
            each_blocks[i].m(each_1_anchor.parentNode, each_1_anchor);
          }
        }
        for (; i < each_blocks.length; i += 1) {
          each_blocks[i].d(1);
        }
        each_blocks.length = each_value_1.length;
      }
    },
    d(detaching) {
      destroy_each(each_blocks, detaching);
      if (detaching)
        detach(each_1_anchor);
    }
  };
}
function create_if_block_2(ctx) {
  let div;
  let raw_value = (
    /*item*/
    ctx[25].icon + ""
  );
  return {
    c() {
      div = element("div");
      attr(div, "class", ["bytemd-toolbar-icon", tippyClass].join(" "));
      attr(
        div,
        "bytemd-tippy-path",
        /*index*/
        ctx[27]
      );
    },
    m(target, anchor) {
      insert(target, div, anchor);
      div.innerHTML = raw_value;
    },
    p(ctx2, dirty) {
      if (dirty & /*actions*/
      8 && raw_value !== (raw_value = /*item*/
      ctx2[25].icon + ""))
        div.innerHTML = raw_value;
    },
    d(detaching) {
      if (detaching)
        detach(div);
    }
  };
}
function create_each_block_1(ctx) {
  let if_block_anchor;
  let if_block = (
    /*item*/
    ctx[25].handler && create_if_block_2(ctx)
  );
  return {
    c() {
      if (if_block)
        if_block.c();
      if_block_anchor = empty();
    },
    m(target, anchor) {
      if (if_block)
        if_block.m(target, anchor);
      insert(target, if_block_anchor, anchor);
    },
    p(ctx2, dirty) {
      if (
        /*item*/
        ctx2[25].handler
      ) {
        if (if_block) {
          if_block.p(ctx2, dirty);
        } else {
          if_block = create_if_block_2(ctx2);
          if_block.c();
          if_block.m(if_block_anchor.parentNode, if_block_anchor);
        }
      } else if (if_block) {
        if_block.d(1);
        if_block = null;
      }
    },
    d(detaching) {
      if (if_block)
        if_block.d(detaching);
      if (detaching)
        detach(if_block_anchor);
    }
  };
}
function create_if_block$1(ctx) {
  let div;
  let raw_value = (
    /*item*/
    ctx[25].icon + ""
  );
  return {
    c() {
      div = element("div");
      attr(div, "class", ["bytemd-toolbar-icon", tippyClass, tippyClassRight].join(" "));
      attr(
        div,
        "bytemd-tippy-path",
        /*index*/
        ctx[27]
      );
      toggle_class(
        div,
        "bytemd-toolbar-icon-active",
        /*item*/
        ctx[25].active
      );
    },
    m(target, anchor) {
      insert(target, div, anchor);
      div.innerHTML = raw_value;
    },
    p(ctx2, dirty) {
      if (dirty & /*rightActions*/
      32 && raw_value !== (raw_value = /*item*/
      ctx2[25].icon + ""))
        div.innerHTML = raw_value;
      if (dirty & /*rightActions*/
      32) {
        toggle_class(
          div,
          "bytemd-toolbar-icon-active",
          /*item*/
          ctx2[25].active
        );
      }
    },
    d(detaching) {
      if (detaching)
        detach(div);
    }
  };
}
function create_each_block(ctx) {
  let if_block_anchor;
  let if_block = !/*item*/
  ctx[25].hidden && create_if_block$1(ctx);
  return {
    c() {
      if (if_block)
        if_block.c();
      if_block_anchor = empty();
    },
    m(target, anchor) {
      if (if_block)
        if_block.m(target, anchor);
      insert(target, if_block_anchor, anchor);
    },
    p(ctx2, dirty) {
      if (!/*item*/
      ctx2[25].hidden) {
        if (if_block) {
          if_block.p(ctx2, dirty);
        } else {
          if_block = create_if_block$1(ctx2);
          if_block.c();
          if_block.m(if_block_anchor.parentNode, if_block_anchor);
        }
      } else if (if_block) {
        if_block.d(1);
        if_block = null;
      }
    },
    d(detaching) {
      if (if_block)
        if_block.d(detaching);
      if (detaching)
        detach(if_block_anchor);
    }
  };
}
function create_fragment$2(ctx) {
  let div2;
  let div0;
  let div1;
  let mounted;
  let dispose;
  function select_block_type(ctx2, dirty) {
    if (
      /*split*/
      ctx2[0]
    )
      return create_if_block_1;
    return create_else_block;
  }
  let current_block_type = select_block_type(ctx);
  let if_block = current_block_type(ctx);
  let each_value = (
    /*rightActions*/
    ctx[5]
  );
  let each_blocks = [];
  for (let i = 0; i < each_value.length; i += 1) {
    each_blocks[i] = create_each_block(get_each_context(ctx, each_value, i));
  }
  return {
    c() {
      div2 = element("div");
      div0 = element("div");
      if_block.c();
      div1 = element("div");
      for (let i = 0; i < each_blocks.length; i += 1) {
        each_blocks[i].c();
      }
      attr(div0, "class", "bytemd-toolbar-left");
      attr(div1, "class", "bytemd-toolbar-right");
      attr(div2, "class", "bytemd-toolbar");
    },
    m(target, anchor) {
      insert(target, div2, anchor);
      append(div2, div0);
      if_block.m(div0, null);
      append(div2, div1);
      for (let i = 0; i < each_blocks.length; i += 1) {
        if (each_blocks[i]) {
          each_blocks[i].m(div1, null);
        }
      }
      ctx[20](div2);
      if (!mounted) {
        dispose = [
          listen(
            div2,
            "click",
            /*handleClick*/
            ctx[7]
          ),
          listen(div2, "keydown", self(
            /*keydown_handler_2*/
            ctx[21]
          ))
        ];
        mounted = true;
      }
    },
    p(ctx2, [dirty]) {
      if (current_block_type === (current_block_type = select_block_type(ctx2)) && if_block) {
        if_block.p(ctx2, dirty);
      } else {
        if_block.d(1);
        if_block = current_block_type(ctx2);
        if (if_block) {
          if_block.c();
          if_block.m(div0, null);
        }
      }
      if (dirty & /*tippyClass, tippyClassRight, rightActions*/
      32) {
        each_value = /*rightActions*/
        ctx2[5];
        let i;
        for (i = 0; i < each_value.length; i += 1) {
          const child_ctx = get_each_context(ctx2, each_value, i);
          if (each_blocks[i]) {
            each_blocks[i].p(child_ctx, dirty);
          } else {
            each_blocks[i] = create_each_block(child_ctx);
            each_blocks[i].c();
            each_blocks[i].m(div1, null);
          }
        }
        for (; i < each_blocks.length; i += 1) {
          each_blocks[i].d(1);
        }
        each_blocks.length = each_value.length;
      }
    },
    i: noop,
    o: noop,
    d(detaching) {
      if (detaching)
        detach(div2);
      if_block.d();
      destroy_each(each_blocks, detaching);
      ctx[20](null);
      mounted = false;
      run_all(dispose);
    }
  };
}
const tippyClass = "bytemd-tippy";
const tippyClassRight = "bytemd-tippy-right";
const tippyPathKey = "bytemd-tippy-path";
function instance$2($$self, $$props, $$invalidate) {
  let tocActive;
  let helpActive;
  let writeActive;
  let previewActive;
  let rightActions;
  const dispatch = createEventDispatcher();
  let toolbar;
  let { context } = $$props;
  let { split } = $$props;
  let { activeTab } = $$props;
  let { fullscreen: fullscreen2 } = $$props;
  let { sidebar } = $$props;
  let { locale } = $$props;
  let { actions } = $$props;
  let { rightAfferentActions } = $$props;
  function getPayloadFromElement(e) {
    var _a, _b;
    const paths = (_b = (_a = e.getAttribute(tippyPathKey)) == null ? void 0 : _a.split("-")) == null ? void 0 : _b.map((x) => parseInt(x, 10));
    if (!paths)
      return;
    let item = {
      title: "",
      handler: {
        type: "dropdown",
        actions: e.classList.contains(tippyClassRight) ? rightActions : actions
      }
    };
    paths == null ? void 0 : paths.forEach((index2) => {
      var _a2;
      if (((_a2 = item.handler) == null ? void 0 : _a2.type) === "dropdown") {
        item = item.handler.actions[index2];
      }
    });
    return { paths, item };
  }
  let delegateInstance;
  function init2() {
    delegateInstance = delegate(toolbar, {
      target: `.${tippyClass}`,
      onCreate({ setProps, reference }) {
        const payload = getPayloadFromElement(reference);
        if (!payload)
          return;
        const { item, paths } = payload;
        const { handler } = item;
        if (!handler)
          return;
        if (handler.type === "action") {
          setProps({
            content: item.title,
            onHidden(ins) {
              ins.destroy();
            }
          });
        } else if (handler.type === "dropdown") {
          const dropdown = document.createElement("div");
          dropdown.classList.add("bytemd-dropdown");
          if (item.title) {
            const dropdownTitle = document.createElement("div");
            dropdownTitle.classList.add("bytemd-dropdown-title");
            dropdownTitle.appendChild(document.createTextNode(item.title));
            dropdown.appendChild(dropdownTitle);
          }
          handler.actions.forEach((subAction, i) => {
            var _a;
            const dropdownItem = document.createElement("div");
            dropdownItem.classList.add("bytemd-dropdown-item");
            dropdownItem.setAttribute(tippyPathKey, [...paths, i].join("-"));
            if (((_a = subAction.handler) == null ? void 0 : _a.type) === "dropdown") {
              dropdownItem.classList.add(tippyClass);
            }
            if (reference.classList.contains(tippyClassRight)) {
              dropdownItem.classList.add(tippyClassRight);
            }
            dropdownItem.innerHTML = `${subAction.icon ? `<div class="bytemd-dropdown-item-icon">${subAction.icon}</div>` : ""}<div class="bytemd-dropdown-item-title">${subAction.title}</div>`;
            dropdown.appendChild(dropdownItem);
          });
          setProps({
            allowHTML: true,
            showOnCreate: true,
            theme: "light-border",
            placement: "bottom-start",
            interactive: true,
            interactiveDebounce: 50,
            arrow: false,
            offset: [0, 4],
            content: dropdown.outerHTML,
            onHidden(ins) {
              ins.destroy();
            },
            onCreate(ins) {
              [...ins.popper.querySelectorAll(".bytemd-dropdown-item")].forEach((el, i) => {
                var _a;
                const actionHandler = (_a = handler.actions[i]) == null ? void 0 : _a.handler;
                if ((actionHandler == null ? void 0 : actionHandler.type) === "action") {
                  const { mouseenter, mouseleave } = actionHandler;
                  if (mouseenter) {
                    el.addEventListener("mouseenter", () => {
                      mouseenter(context);
                    });
                  }
                  if (mouseleave) {
                    el.addEventListener("mouseleave", () => {
                      mouseleave(context);
                    });
                  }
                }
              });
            }
          });
        }
      }
    });
  }
  onMount(() => {
    init2();
  });
  function handleClick(e) {
    var _a, _b;
    const target = e.target.closest(`[${tippyPathKey}]`);
    if (!target)
      return;
    const handler = (_b = (_a = getPayloadFromElement(target)) == null ? void 0 : _a.item) == null ? void 0 : _b.handler;
    if ((handler == null ? void 0 : handler.type) === "action") {
      handler.click(context);
    }
    delegateInstance == null ? void 0 : delegateInstance.destroy();
    init2();
  }
  const click_handler = () => dispatch("tab", "write");
  const keydown_handler = (e) => ["Enter", "Space"].includes(e.code) && dispatch("tab", "write");
  const click_handler_1 = () => dispatch("tab", "preview");
  const keydown_handler_1 = (e) => ["Enter", "Space"].includes(e.code) && dispatch("tab", "preview");
  function div2_binding($$value) {
    binding_callbacks[$$value ? "unshift" : "push"](() => {
      toolbar = $$value;
      $$invalidate(4, toolbar);
    });
  }
  const keydown_handler_2 = (e) => ["Enter", "Space"].includes(e.code) && handleClick(e);
  $$self.$$set = ($$props2) => {
    if ("context" in $$props2)
      $$invalidate(8, context = $$props2.context);
    if ("split" in $$props2)
      $$invalidate(0, split = $$props2.split);
    if ("activeTab" in $$props2)
      $$invalidate(1, activeTab = $$props2.activeTab);
    if ("fullscreen" in $$props2)
      $$invalidate(9, fullscreen2 = $$props2.fullscreen);
    if ("sidebar" in $$props2)
      $$invalidate(10, sidebar = $$props2.sidebar);
    if ("locale" in $$props2)
      $$invalidate(2, locale = $$props2.locale);
    if ("actions" in $$props2)
      $$invalidate(3, actions = $$props2.actions);
    if ("rightAfferentActions" in $$props2)
      $$invalidate(11, rightAfferentActions = $$props2.rightAfferentActions);
  };
  $$self.$$.update = () => {
    if ($$self.$$.dirty & /*sidebar*/
    1024) {
      $$invalidate(15, tocActive = sidebar === "toc");
    }
    if ($$self.$$.dirty & /*sidebar*/
    1024) {
      $$invalidate(14, helpActive = sidebar === "help");
    }
    if ($$self.$$.dirty & /*activeTab*/
    2) {
      $$invalidate(13, writeActive = activeTab === "write");
    }
    if ($$self.$$.dirty & /*activeTab*/
    2) {
      $$invalidate(12, previewActive = activeTab === "preview");
    }
    if ($$self.$$.dirty & /*tocActive, locale, helpActive, writeActive, split, previewActive, fullscreen, rightAfferentActions*/
    64005) {
      $$invalidate(5, rightActions = [
        {
          title: tocActive ? locale.closeToc : locale.toc,
          icon: icons.AlignTextLeftOne,
          handler: {
            type: "action",
            click() {
              dispatch("click", "toc");
            }
          },
          active: tocActive
        },
        {
          title: helpActive ? locale.closeHelp : locale.help,
          icon: icons.Helpcenter,
          handler: {
            type: "action",
            click() {
              dispatch("click", "help");
            }
          },
          active: helpActive
        },
        {
          title: writeActive ? locale.exitWriteOnly : locale.writeOnly,
          icon: icons.LeftExpand,
          handler: {
            type: "action",
            click() {
              dispatch("tab", "write");
            }
          },
          active: writeActive,
          hidden: !split
        },
        {
          title: previewActive ? locale.exitPreviewOnly : locale.previewOnly,
          icon: icons.RightExpand,
          handler: {
            type: "action",
            click() {
              dispatch("tab", "preview");
            }
          },
          active: previewActive,
          hidden: !split
        },
        {
          title: fullscreen2 ? locale.exitFullscreen : locale.fullscreen,
          icon: fullscreen2 ? icons.OffScreen : icons.FullScreen,
          handler: {
            type: "action",
            click() {
              dispatch("click", "fullscreen");
            }
          }
        },
        {
          title: locale.source,
          icon: icons.GithubOne,
          handler: {
            type: "action",
            click() {
              window.open("https://github.com/bytedance/bytemd");
            }
          }
        },
        ...rightAfferentActions
      ]);
    }
  };
  return [
    split,
    activeTab,
    locale,
    actions,
    toolbar,
    rightActions,
    dispatch,
    handleClick,
    context,
    fullscreen2,
    sidebar,
    rightAfferentActions,
    previewActive,
    writeActive,
    helpActive,
    tocActive,
    click_handler,
    keydown_handler,
    click_handler_1,
    keydown_handler_1,
    div2_binding,
    keydown_handler_2
  ];
}
class Toolbar extends SvelteComponent {
  constructor(options) {
    super();
    init(this, options, instance$2, create_fragment$2, not_equal, {
      context: 8,
      split: 0,
      activeTab: 1,
      fullscreen: 9,
      sidebar: 10,
      locale: 2,
      actions: 3,
      rightAfferentActions: 11
    });
  }
}
const schemaStr = JSON.stringify(defaultSchema);
function getProcessor({
  sanitize,
  plugins,
  remarkRehype: remarkRehypeOptions = {}
}) {
  let processor = unified().use(remarkParse);
  plugins == null ? void 0 : plugins.forEach(({ remark }) => {
    if (remark)
      processor = remark(processor);
  });
  processor = processor.use(remarkRehype, { allowDangerousHtml: true, ...remarkRehypeOptions }).use(rehypeRaw);
  let schema = JSON.parse(schemaStr);
  schema.attributes["*"].push("className");
  if (typeof sanitize === "function") {
    schema = sanitize(schema);
  }
  processor = processor.use(rehypeSanitize, schema);
  plugins == null ? void 0 : plugins.forEach(({ rehype }) => {
    if (rehype)
      processor = rehype(processor);
  });
  return processor.use(rehypeStringify);
}
function create_fragment$1(ctx) {
  let div;
  return {
    c() {
      div = element("div");
      attr(div, "class", "markdown-body");
    },
    m(target, anchor) {
      insert(target, div, anchor);
      div.innerHTML = /*html*/
      ctx[1];
      ctx[8](div);
    },
    p(ctx2, [dirty]) {
      if (dirty & /*html*/
      2)
        div.innerHTML = /*html*/
        ctx2[1];
    },
    i: noop,
    o: noop,
    d(detaching) {
      if (detaching)
        detach(div);
      ctx[8](null);
    }
  };
}
function instance$1($$self, $$props, $$invalidate) {
  let html;
  const dispatch = createEventDispatcher();
  let { value = "" } = $$props;
  let { plugins = [] } = $$props;
  let { sanitize = void 0 } = $$props;
  let { remarkRehype: remarkRehype2 = void 0 } = $$props;
  let markdownBody;
  let cbs = [];
  function on() {
    cbs = plugins.map((p) => {
      var _a;
      return (_a = p.viewerEffect) == null ? void 0 : _a.call(p, { markdownBody, file });
    });
  }
  function off() {
    cbs.forEach((cb) => cb == null ? void 0 : cb());
  }
  onMount(() => {
    markdownBody.addEventListener("click", (e) => {
      var _a;
      const $ = e.target;
      if ($.tagName !== "A")
        return;
      const href = $.getAttribute("href");
      if (!(href == null ? void 0 : href.startsWith("#")))
        return;
      (_a = markdownBody.querySelector("#user-content-" + href.slice(1))) == null ? void 0 : _a.scrollIntoView();
    });
  });
  onDestroy(off);
  let file;
  let i = 0;
  const dispatchPlugin = () => (tree, file2) => {
    tick().then(() => {
      dispatch("hast", { hast: tree, file: file2 });
    });
  };
  afterUpdate(() => {
    off();
    on();
  });
  function div_binding($$value) {
    binding_callbacks[$$value ? "unshift" : "push"](() => {
      markdownBody = $$value;
      $$invalidate(0, markdownBody);
    });
  }
  $$self.$$set = ($$props2) => {
    if ("value" in $$props2)
      $$invalidate(2, value = $$props2.value);
    if ("plugins" in $$props2)
      $$invalidate(3, plugins = $$props2.plugins);
    if ("sanitize" in $$props2)
      $$invalidate(4, sanitize = $$props2.sanitize);
    if ("remarkRehype" in $$props2)
      $$invalidate(5, remarkRehype2 = $$props2.remarkRehype);
  };
  $$self.$$.update = () => {
    if ($$self.$$.dirty & /*sanitize, plugins, remarkRehype, value, i*/
    188) {
      try {
        $$invalidate(6, file = getProcessor({
          sanitize,
          plugins: [
            ...plugins,
            {
              // remark: (p) =>
              //   p.use(() => (tree) =>{
              //     console.log(tree)
              //   }),
              rehype: (processor) => processor.use(dispatchPlugin)
            }
          ],
          remarkRehype: remarkRehype2
        }).processSync(value));
        $$invalidate(7, i++, i);
      } catch (err) {
        console.error(err);
      }
    }
    if ($$self.$$.dirty & /*file, i*/
    192) {
      $$invalidate(1, html = `${file}<!--${i}-->`);
    }
  };
  return [
    markdownBody,
    html,
    value,
    plugins,
    sanitize,
    remarkRehype2,
    file,
    i,
    div_binding
  ];
}
class Viewer extends SvelteComponent {
  constructor(options) {
    super();
    init(this, options, instance$1, create_fragment$1, not_equal, {
      value: 2,
      plugins: 3,
      sanitize: 4,
      remarkRehype: 5
    });
  }
}
function create_if_block(ctx) {
  let viewer;
  let current;
  viewer = new Viewer({
    props: {
      value: (
        /*debouncedValue*/
        ctx[16]
      ),
      plugins: (
        /*plugins*/
        ctx[1]
      ),
      sanitize: (
        /*sanitize*/
        ctx[2]
      ),
      remarkRehype: (
        /*remarkRehype*/
        ctx[3]
      )
    }
  });
  viewer.$on(
    "hast",
    /*hast_handler*/
    ctx[35]
  );
  return {
    c() {
      create_component(viewer.$$.fragment);
    },
    m(target, anchor) {
      mount_component(viewer, target, anchor);
      current = true;
    },
    p(ctx2, dirty) {
      const viewer_changes = {};
      if (dirty[0] & /*debouncedValue*/
      65536)
        viewer_changes.value = /*debouncedValue*/
        ctx2[16];
      if (dirty[0] & /*plugins*/
      2)
        viewer_changes.plugins = /*plugins*/
        ctx2[1];
      if (dirty[0] & /*sanitize*/
      4)
        viewer_changes.sanitize = /*sanitize*/
        ctx2[2];
      if (dirty[0] & /*remarkRehype*/
      8)
        viewer_changes.remarkRehype = /*remarkRehype*/
        ctx2[3];
      viewer.$set(viewer_changes);
    },
    i(local) {
      if (current)
        return;
      transition_in(viewer.$$.fragment, local);
      current = true;
    },
    o(local) {
      transition_out(viewer.$$.fragment, local);
      current = false;
    },
    d(detaching) {
      destroy_component(viewer, detaching);
    }
  };
}
function create_fragment(ctx) {
  let div5;
  let toolbar;
  let div4;
  let div0;
  let div0_style_value;
  let div1;
  let div1_style_value;
  let div3;
  let div2;
  let raw_value = icons.Close + "";
  let help2;
  let toc2;
  let status;
  let current;
  let mounted;
  let dispose;
  toolbar = new Toolbar({
    props: {
      context: (
        /*context*/
        ctx[10]
      ),
      split: (
        /*split*/
        ctx[11]
      ),
      activeTab: (
        /*activeTab*/
        ctx[8]
      ),
      sidebar: (
        /*sidebar*/
        ctx[9]
      ),
      fullscreen: (
        /*fullscreen*/
        ctx[15]
      ),
      rightAfferentActions: (
        /*actions*/
        ctx[21].rightActions
      ),
      locale: (
        /*mergedLocale*/
        ctx[12]
      ),
      actions: (
        /*actions*/
        ctx[21].leftActions
      )
    }
  });
  toolbar.$on(
    "key",
    /*key_handler*/
    ctx[31]
  );
  toolbar.$on(
    "tab",
    /*tab_handler*/
    ctx[32]
  );
  toolbar.$on(
    "click",
    /*click_handler*/
    ctx[33]
  );
  let if_block = !/*overridePreview*/
  ctx[4] && /*split*/
  (ctx[11] || /*activeTab*/
  ctx[8] === "preview") && create_if_block(ctx);
  help2 = new Help({
    props: {
      locale: (
        /*mergedLocale*/
        ctx[12]
      ),
      actions: (
        /*actions*/
        ctx[21].leftActions
      ),
      visible: (
        /*sidebar*/
        ctx[9] === "help"
      )
    }
  });
  toc2 = new Toc({
    props: {
      hast: (
        /*hast*/
        ctx[18]
      ),
      locale: (
        /*mergedLocale*/
        ctx[12]
      ),
      currentBlockIndex: (
        /*currentBlockIndex*/
        ctx[20]
      ),
      visible: (
        /*sidebar*/
        ctx[9] === "toc"
      )
    }
  });
  toc2.$on(
    "click",
    /*click_handler_2*/
    ctx[39]
  );
  status = new Status({
    props: {
      locale: (
        /*mergedLocale*/
        ctx[12]
      ),
      showSync: !/*overridePreview*/
      ctx[4] && /*split*/
      ctx[11],
      value: (
        /*debouncedValue*/
        ctx[16]
      ),
      syncEnabled: (
        /*syncEnabled*/
        ctx[17]
      ),
      islimited: (
        /*value*/
        ctx[0].length > /*maxLength*/
        ctx[5]
      )
    }
  });
  status.$on(
    "sync",
    /*sync_handler*/
    ctx[40]
  );
  status.$on(
    "top",
    /*top_handler*/
    ctx[41]
  );
  return {
    c() {
      div5 = element("div");
      create_component(toolbar.$$.fragment);
      div4 = element("div");
      div0 = element("div");
      div1 = element("div");
      if (if_block)
        if_block.c();
      div3 = element("div");
      div2 = element("div");
      create_component(help2.$$.fragment);
      create_component(toc2.$$.fragment);
      create_component(status.$$.fragment);
      attr(div0, "class", "bytemd-editor");
      attr(div0, "style", div0_style_value = /*styles*/
      ctx[22].edit);
      attr(div1, "class", "bytemd-preview");
      attr(div1, "style", div1_style_value = /*styles*/
      ctx[22].preview);
      attr(div2, "class", "bytemd-sidebar-close");
      attr(div3, "class", "bytemd-sidebar");
      toggle_class(
        div3,
        "bytemd-hidden",
        /*sidebar*/
        ctx[9] === false
      );
      attr(div4, "class", "bytemd-body");
      attr(div5, "class", "bytemd");
      toggle_class(
        div5,
        "bytemd-split",
        /*split*/
        ctx[11] && /*activeTab*/
        ctx[8] === false
      );
      toggle_class(
        div5,
        "bytemd-fullscreen",
        /*fullscreen*/
        ctx[15]
      );
    },
    m(target, anchor) {
      insert(target, div5, anchor);
      mount_component(toolbar, div5, null);
      append(div5, div4);
      append(div4, div0);
      ctx[34](div0);
      append(div4, div1);
      if (if_block)
        if_block.m(div1, null);
      ctx[36](div1);
      append(div4, div3);
      append(div3, div2);
      div2.innerHTML = raw_value;
      mount_component(help2, div3, null);
      mount_component(toc2, div3, null);
      mount_component(status, div5, null);
      ctx[42](div5);
      current = true;
      if (!mounted) {
        dispose = [
          listen(
            div2,
            "click",
            /*click_handler_1*/
            ctx[37]
          ),
          listen(div2, "keydown", self(
            /*keydown_handler*/
            ctx[38]
          ))
        ];
        mounted = true;
      }
    },
    p(ctx2, dirty) {
      const toolbar_changes = {};
      if (dirty[0] & /*context*/
      1024)
        toolbar_changes.context = /*context*/
        ctx2[10];
      if (dirty[0] & /*split*/
      2048)
        toolbar_changes.split = /*split*/
        ctx2[11];
      if (dirty[0] & /*activeTab*/
      256)
        toolbar_changes.activeTab = /*activeTab*/
        ctx2[8];
      if (dirty[0] & /*sidebar*/
      512)
        toolbar_changes.sidebar = /*sidebar*/
        ctx2[9];
      if (dirty[0] & /*fullscreen*/
      32768)
        toolbar_changes.fullscreen = /*fullscreen*/
        ctx2[15];
      if (dirty[0] & /*actions*/
      2097152)
        toolbar_changes.rightAfferentActions = /*actions*/
        ctx2[21].rightActions;
      if (dirty[0] & /*mergedLocale*/
      4096)
        toolbar_changes.locale = /*mergedLocale*/
        ctx2[12];
      if (dirty[0] & /*actions*/
      2097152)
        toolbar_changes.actions = /*actions*/
        ctx2[21].leftActions;
      toolbar.$set(toolbar_changes);
      if (!current || dirty[0] & /*styles*/
      4194304 && div0_style_value !== (div0_style_value = /*styles*/
      ctx2[22].edit)) {
        attr(div0, "style", div0_style_value);
      }
      if (!/*overridePreview*/
      ctx2[4] && /*split*/
      (ctx2[11] || /*activeTab*/
      ctx2[8] === "preview")) {
        if (if_block) {
          if_block.p(ctx2, dirty);
          if (dirty[0] & /*overridePreview, split, activeTab*/
          2320) {
            transition_in(if_block, 1);
          }
        } else {
          if_block = create_if_block(ctx2);
          if_block.c();
          transition_in(if_block, 1);
          if_block.m(div1, null);
        }
      } else if (if_block) {
        group_outros();
        transition_out(if_block, 1, 1, () => {
          if_block = null;
        });
        check_outros();
      }
      if (!current || dirty[0] & /*styles*/
      4194304 && div1_style_value !== (div1_style_value = /*styles*/
      ctx2[22].preview)) {
        attr(div1, "style", div1_style_value);
      }
      const help_changes = {};
      if (dirty[0] & /*mergedLocale*/
      4096)
        help_changes.locale = /*mergedLocale*/
        ctx2[12];
      if (dirty[0] & /*actions*/
      2097152)
        help_changes.actions = /*actions*/
        ctx2[21].leftActions;
      if (dirty[0] & /*sidebar*/
      512)
        help_changes.visible = /*sidebar*/
        ctx2[9] === "help";
      help2.$set(help_changes);
      const toc_changes = {};
      if (dirty[0] & /*hast*/
      262144)
        toc_changes.hast = /*hast*/
        ctx2[18];
      if (dirty[0] & /*mergedLocale*/
      4096)
        toc_changes.locale = /*mergedLocale*/
        ctx2[12];
      if (dirty[0] & /*currentBlockIndex*/
      1048576)
        toc_changes.currentBlockIndex = /*currentBlockIndex*/
        ctx2[20];
      if (dirty[0] & /*sidebar*/
      512)
        toc_changes.visible = /*sidebar*/
        ctx2[9] === "toc";
      toc2.$set(toc_changes);
      if (!current || dirty[0] & /*sidebar*/
      512) {
        toggle_class(
          div3,
          "bytemd-hidden",
          /*sidebar*/
          ctx2[9] === false
        );
      }
      const status_changes = {};
      if (dirty[0] & /*mergedLocale*/
      4096)
        status_changes.locale = /*mergedLocale*/
        ctx2[12];
      if (dirty[0] & /*overridePreview, split*/
      2064)
        status_changes.showSync = !/*overridePreview*/
        ctx2[4] && /*split*/
        ctx2[11];
      if (dirty[0] & /*debouncedValue*/
      65536)
        status_changes.value = /*debouncedValue*/
        ctx2[16];
      if (dirty[0] & /*syncEnabled*/
      131072)
        status_changes.syncEnabled = /*syncEnabled*/
        ctx2[17];
      if (dirty[0] & /*value, maxLength*/
      33)
        status_changes.islimited = /*value*/
        ctx2[0].length > /*maxLength*/
        ctx2[5];
      status.$set(status_changes);
      if (!current || dirty[0] & /*split, activeTab*/
      2304) {
        toggle_class(
          div5,
          "bytemd-split",
          /*split*/
          ctx2[11] && /*activeTab*/
          ctx2[8] === false
        );
      }
      if (!current || dirty[0] & /*fullscreen*/
      32768) {
        toggle_class(
          div5,
          "bytemd-fullscreen",
          /*fullscreen*/
          ctx2[15]
        );
      }
    },
    i(local) {
      if (current)
        return;
      transition_in(toolbar.$$.fragment, local);
      transition_in(if_block);
      transition_in(help2.$$.fragment, local);
      transition_in(toc2.$$.fragment, local);
      transition_in(status.$$.fragment, local);
      current = true;
    },
    o(local) {
      transition_out(toolbar.$$.fragment, local);
      transition_out(if_block);
      transition_out(help2.$$.fragment, local);
      transition_out(toc2.$$.fragment, local);
      transition_out(status.$$.fragment, local);
      current = false;
    },
    d(detaching) {
      if (detaching)
        detach(div5);
      destroy_component(toolbar);
      ctx[34](null);
      if (if_block)
        if_block.d();
      ctx[36](null);
      destroy_component(help2);
      destroy_component(toc2);
      destroy_component(status);
      ctx[42](null);
      mounted = false;
      run_all(dispose);
    }
  };
}
function instance($$self, $$props, $$invalidate) {
  let mergedLocale;
  let actions;
  let split;
  let styles;
  let context;
  let { value = "" } = $$props;
  let { plugins = [] } = $$props;
  let { sanitize = void 0 } = $$props;
  let { remarkRehype: remarkRehype2 = void 0 } = $$props;
  let { mode = "auto" } = $$props;
  let { previewDebounce = 300 } = $$props;
  let { placeholder = void 0 } = $$props;
  let { editorConfig = void 0 } = $$props;
  let { locale = void 0 } = $$props;
  let { uploadImages = void 0 } = $$props;
  let { overridePreview = void 0 } = $$props;
  let { maxLength = Infinity } = $$props;
  const dispatch = createEventDispatcher();
  let root;
  let editorEl;
  let previewEl;
  let containerWidth = Infinity;
  let codemirror;
  let editor;
  let activeTab;
  let fullscreen2 = false;
  let sidebar = false;
  let cbs = [];
  let keyMap = {};
  function on() {
    cbs = plugins.map((p) => {
      var _a;
      return (_a = p.editorEffect) == null ? void 0 : _a.call(p, context);
    });
    keyMap = {};
    actions.leftActions.forEach(({ handler }) => {
      if ((handler == null ? void 0 : handler.type) === "action" && handler.shortcut) {
        keyMap[handler.shortcut] = () => {
          handler.click(context);
        };
      }
    });
    editor.addKeyMap(keyMap);
  }
  function off() {
    cbs.forEach((cb) => cb && cb());
    editor == null ? void 0 : editor.removeKeyMap(keyMap);
  }
  let debouncedValue = value;
  const setDebouncedValue = debounce(
    (value2) => {
      $$invalidate(16, debouncedValue = value2);
      overridePreview == null ? void 0 : overridePreview(previewEl, {
        value: debouncedValue,
        plugins,
        sanitize,
        remarkRehype: remarkRehype2
      });
    },
    previewDebounce
  );
  let syncEnabled = true;
  let editCalled = false;
  let previewCalled = false;
  let editPs;
  let previewPs;
  let hast = { type: "root", children: [] };
  let vfile;
  let currentBlockIndex = 0;
  onMount(async () => {
    $$invalidate(30, codemirror = createCodeMirror());
    $$invalidate(7, editor = codemirror(editorEl, {
      value,
      mode: "yaml-frontmatter",
      lineWrapping: true,
      tabSize: 8,
      indentUnit: 4,
      extraKeys: {
        Enter: "newlineAndIndentContinueMarkdownList"
      },
      ...editorConfig,
      placeholder
    }));
    editor.addKeyMap({
      Tab: "indentMore",
      "Shift-Tab": "indentLess"
    });
    editor.on("change", () => {
      dispatch("change", { value: editor.getValue() });
    });
    const updateBlockPositions = throttle(
      () => {
        editPs = [];
        previewPs = [];
        const scrollInfo = editor.getScrollInfo();
        const body = previewEl.childNodes[0];
        if (!(body instanceof HTMLElement))
          return;
        const leftNodes = hast.children.filter((v) => v.type === "element");
        const rightNodes = [...body.childNodes].filter((v) => v instanceof HTMLElement);
        for (let i = 0; i < leftNodes.length; i++) {
          const leftNode = leftNodes[i];
          const rightNode = rightNodes[i];
          if (!leftNode.position) {
            continue;
          }
          const left = editor.heightAtLine(leftNode.position.start.line - 1, "local") / (scrollInfo.height - scrollInfo.clientHeight);
          const right = (rightNode.offsetTop - body.offsetTop) / (previewEl.scrollHeight - previewEl.clientHeight);
          if (left >= 1 || right >= 1) {
            break;
          }
          editPs.push(left);
          previewPs.push(right);
        }
        editPs.push(1);
        previewPs.push(1);
      },
      1e3
    );
    const editorScrollHandler = () => {
      if (overridePreview)
        return;
      if (!syncEnabled)
        return;
      if (previewCalled) {
        previewCalled = false;
        return;
      }
      updateBlockPositions();
      const info = editor.getScrollInfo();
      const leftRatio = info.top / (info.height - info.clientHeight);
      const startIndex = findStartIndex(leftRatio, editPs);
      const rightRatio = (leftRatio - editPs[startIndex]) * (previewPs[startIndex + 1] - previewPs[startIndex]) / (editPs[startIndex + 1] - editPs[startIndex]) + previewPs[startIndex];
      previewEl.scrollTo(0, rightRatio * (previewEl.scrollHeight - previewEl.clientHeight));
      editCalled = true;
    };
    const previewScrollHandler = () => {
      if (overridePreview)
        return;
      updateBlockPositions();
      $$invalidate(20, currentBlockIndex = findStartIndex(previewEl.scrollTop / (previewEl.scrollHeight - previewEl.offsetHeight), previewPs));
      if (!syncEnabled)
        return;
      if (editCalled) {
        editCalled = false;
        return;
      }
      const rightRatio = previewEl.scrollTop / (previewEl.scrollHeight - previewEl.clientHeight);
      const startIndex = findStartIndex(rightRatio, previewPs);
      const leftRatio = (rightRatio - previewPs[startIndex]) * (editPs[startIndex + 1] - editPs[startIndex]) / (previewPs[startIndex + 1] - previewPs[startIndex]) + editPs[startIndex];
      if (isNaN(leftRatio)) {
        return;
      }
      const info = editor.getScrollInfo();
      editor.scrollTo(0, leftRatio * (info.height - info.clientHeight));
      previewCalled = true;
    };
    editor.on("scroll", editorScrollHandler);
    previewEl.addEventListener("scroll", previewScrollHandler, { passive: true });
    const handleImages = async (e, itemList) => {
      if (!uploadImages)
        return;
      const files = Array.from(itemList != null ? itemList : []).map((item) => {
        if (item.type.startsWith("image/")) {
          return item.getAsFile();
        }
      }).filter((f) => f != null);
      if (files.length) {
        e.preventDefault();
        await handleImageUpload(context, uploadImages, files);
      }
    };
    editor.on("drop", async (_, e) => {
      var _a;
      handleImages(e, (_a = e.dataTransfer) == null ? void 0 : _a.items);
    });
    editor.on("paste", async (_, e) => {
      var _a;
      handleImages(e, (_a = e.clipboardData) == null ? void 0 : _a.items);
    });
    new ResizeObserver((entries) => {
      $$invalidate(29, containerWidth = entries[0].contentRect.width);
    }).observe(root, {
      box: "border-box"
      // console.log(containerWidth);
    });
  });
  onDestroy(off);
  const key_handler = (e) => {
    editor.setOption("keyMap", e.detail);
    editor.focus();
  };
  const tab_handler = (e) => {
    const v = e.detail;
    if (split) {
      $$invalidate(8, activeTab = activeTab === v ? false : v);
    } else {
      $$invalidate(8, activeTab = v);
    }
    if (activeTab === "write") {
      tick().then(() => {
        editor && editor.focus();
      });
    }
    if (v === "write") {
      tick().then(() => {
        editor && editor.setSize(null, null);
      });
    }
  };
  const click_handler = (e) => {
    switch (e.detail) {
      case "fullscreen":
        $$invalidate(15, fullscreen2 = !fullscreen2);
        break;
      case "help":
        $$invalidate(9, sidebar = sidebar === "help" ? false : "help");
        break;
      case "toc":
        $$invalidate(9, sidebar = sidebar === "toc" ? false : "toc");
        break;
    }
  };
  function div0_binding($$value) {
    binding_callbacks[$$value ? "unshift" : "push"](() => {
      editorEl = $$value;
      $$invalidate(13, editorEl);
    });
  }
  const hast_handler = (e) => {
    $$invalidate(18, hast = e.detail.hast);
    $$invalidate(19, vfile = e.detail.file);
  };
  function div1_binding($$value) {
    binding_callbacks[$$value ? "unshift" : "push"](() => {
      previewEl = $$value;
      $$invalidate(14, previewEl);
    });
  }
  const click_handler_1 = () => {
    $$invalidate(9, sidebar = false);
  };
  const keydown_handler = (e) => {
    if (["Enter", "Space"].includes(e.code)) {
      $$invalidate(9, sidebar = false);
    }
  };
  const click_handler_2 = (e) => {
    const headings = previewEl.querySelectorAll("h1,h2,h3,h4,h5,h6");
    headings[e.detail].scrollIntoView();
  };
  const sync_handler = (e) => {
    $$invalidate(17, syncEnabled = e.detail);
  };
  const top_handler = () => {
    editor.scrollTo(null, 0);
    previewEl.scrollTo({ top: 0 });
  };
  function div5_binding($$value) {
    binding_callbacks[$$value ? "unshift" : "push"](() => {
      root = $$value;
      $$invalidate(6, root);
    });
  }
  $$self.$$set = ($$props2) => {
    if ("value" in $$props2)
      $$invalidate(0, value = $$props2.value);
    if ("plugins" in $$props2)
      $$invalidate(1, plugins = $$props2.plugins);
    if ("sanitize" in $$props2)
      $$invalidate(2, sanitize = $$props2.sanitize);
    if ("remarkRehype" in $$props2)
      $$invalidate(3, remarkRehype2 = $$props2.remarkRehype);
    if ("mode" in $$props2)
      $$invalidate(23, mode = $$props2.mode);
    if ("previewDebounce" in $$props2)
      $$invalidate(24, previewDebounce = $$props2.previewDebounce);
    if ("placeholder" in $$props2)
      $$invalidate(25, placeholder = $$props2.placeholder);
    if ("editorConfig" in $$props2)
      $$invalidate(26, editorConfig = $$props2.editorConfig);
    if ("locale" in $$props2)
      $$invalidate(27, locale = $$props2.locale);
    if ("uploadImages" in $$props2)
      $$invalidate(28, uploadImages = $$props2.uploadImages);
    if ("overridePreview" in $$props2)
      $$invalidate(4, overridePreview = $$props2.overridePreview);
    if ("maxLength" in $$props2)
      $$invalidate(5, maxLength = $$props2.maxLength);
  };
  $$self.$$.update = () => {
    if ($$self.$$.dirty[0] & /*locale*/
    134217728) {
      $$invalidate(12, mergedLocale = { ...en, ...locale });
    }
    if ($$self.$$.dirty[0] & /*mergedLocale, plugins, uploadImages*/
    268439554) {
      $$invalidate(21, actions = getBuiltinActions(mergedLocale, plugins, uploadImages));
    }
    if ($$self.$$.dirty[0] & /*mode, containerWidth*/
    545259520) {
      $$invalidate(11, split = mode === "split" || mode === "auto" && containerWidth >= 800);
    }
    if ($$self.$$.dirty[0] & /*split*/
    2048) {
      ((_) => {
        if (split)
          $$invalidate(8, activeTab = false);
      })();
    }
    if ($$self.$$.dirty[0] & /*split, activeTab, sidebar*/
    2816) {
      $$invalidate(22, styles = (() => {
        let edit;
        let preview2;
        if (split && activeTab === false) {
          if (sidebar) {
            edit = `width:calc(50% - ${sidebar ? 140 : 0}px)`;
            preview2 = `width:calc(50% - ${sidebar ? 140 : 0}px)`;
          } else {
            edit = "width:50%";
            preview2 = "width:50%";
          }
        } else if (activeTab === "preview") {
          edit = "display:none";
          preview2 = `width:calc(100% - ${sidebar ? 280 : 0}px)`;
        } else {
          edit = `width:calc(100% - ${sidebar ? 280 : 0}px)`;
          preview2 = "display:none";
        }
        return { edit, preview: preview2 };
      })());
    }
    if ($$self.$$.dirty[0] & /*codemirror, editor, root*/
    1073742016) {
      $$invalidate(10, context = (() => {
        const context2 = {
          // @ts-ignore
          codemirror,
          editor,
          root,
          // @ts-ignore
          ...createEditorUtils(codemirror, editor)
        };
        return context2;
      })());
    }
    if ($$self.$$.dirty[0] & /*value*/
    1) {
      setDebouncedValue(value);
    }
    if ($$self.$$.dirty[0] & /*editor, value*/
    129) {
      if (editor && value !== editor.getValue()) {
        editor.setValue(value);
      }
    }
    if ($$self.$$.dirty[0] & /*editor, plugins*/
    130) {
      if (editor && plugins) {
        off();
        tick().then(() => {
          on();
        });
      }
    }
  };
  return [
    value,
    plugins,
    sanitize,
    remarkRehype2,
    overridePreview,
    maxLength,
    root,
    editor,
    activeTab,
    sidebar,
    context,
    split,
    mergedLocale,
    editorEl,
    previewEl,
    fullscreen2,
    debouncedValue,
    syncEnabled,
    hast,
    vfile,
    currentBlockIndex,
    actions,
    styles,
    mode,
    previewDebounce,
    placeholder,
    editorConfig,
    locale,
    uploadImages,
    containerWidth,
    codemirror,
    key_handler,
    tab_handler,
    click_handler,
    div0_binding,
    hast_handler,
    div1_binding,
    click_handler_1,
    keydown_handler,
    click_handler_2,
    sync_handler,
    top_handler,
    div5_binding
  ];
}
class Editor extends SvelteComponent {
  constructor(options) {
    super();
    init(
      this,
      options,
      instance,
      create_fragment,
      not_equal,
      {
        value: 0,
        plugins: 1,
        sanitize: 2,
        remarkRehype: 3,
        mode: 23,
        previewDebounce: 24,
        placeholder: 25,
        editorConfig: 26,
        locale: 27,
        uploadImages: 28,
        overridePreview: 4,
        maxLength: 5
      },
      null,
      [-1, -1]
    );
  }
}
export {
  Editor,
  Viewer,
  getProcessor
};
