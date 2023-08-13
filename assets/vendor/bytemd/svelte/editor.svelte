<svelte:options immutable={true} /><script>import en from '../locales/en.json';
import { createCodeMirror, createEditorUtils, findStartIndex, getBuiltinActions, handleImageUpload, } from './editor';
import Help from './help.svelte';
import { icons } from './icons';
import Status from './status.svelte';
import Toc from './toc.svelte';
import Toolbar from './toolbar.svelte';
import Viewer from './viewer.svelte';
import { debounce, throttle } from 'lodash-es';
import { onMount, createEventDispatcher, onDestroy, tick } from 'svelte';
export let value = '';
export let plugins = [];
export let sanitize = undefined;
export let remarkRehype = undefined;
export let mode = 'auto';
export let previewDebounce = 300;
export let placeholder = undefined;
export let editorConfig = undefined;
export let locale = undefined;
export let uploadImages = undefined;
export let overridePreview = undefined;
export let maxLength = Infinity;
$: mergedLocale = { ...en, ...locale };
const dispatch = createEventDispatcher();
$: actions = getBuiltinActions(mergedLocale, plugins, uploadImages);
$: split = mode === 'split' || (mode === 'auto' && containerWidth >= 800);
$: ((_) => {
    // reset active tab
    if (split)
        activeTab = false;
})(split);
let root;
let editorEl;
let previewEl;
let containerWidth = Infinity; // TODO: first screen
let codemirror;
let editor;
let activeTab;
let fullscreen = false;
let sidebar = false;
$: styles = (() => {
    let edit;
    let preview;
    if (split && activeTab === false) {
        if (sidebar) {
            edit = `width:calc(50% - ${sidebar ? 140 : 0}px)`;
            preview = `width:calc(50% - ${sidebar ? 140 : 0}px)`;
        }
        else {
            edit = 'width:50%';
            preview = 'width:50%';
        }
    }
    else if (activeTab === 'preview') {
        edit = 'display:none';
        preview = `width:calc(100% - ${sidebar ? 280 : 0}px)`;
    }
    else {
        edit = `width:calc(100% - ${sidebar ? 280 : 0}px)`;
        preview = 'display:none';
        // TODO: use width:0 to make scroll sync work until
        // the position calculation improved (causes white screen after switching to editor only)
    }
    return { edit, preview };
})();
$: context = (() => {
    const context = {
        // @ts-ignore
        codemirror,
        editor,
        root,
        // @ts-ignore
        ...createEditorUtils(codemirror, editor),
    };
    return context;
})();
let cbs = [];
let keyMap = {};
function on() {
    // console.log('on', plugins);
    cbs = plugins.map((p) => p.editorEffect?.(context));
    keyMap = {};
    // TODO: nested shortcuts
    actions.leftActions.forEach(({ handler }) => {
        if (handler?.type === 'action' && handler.shortcut) {
            keyMap[handler.shortcut] = () => {
                handler.click(context);
            };
        }
    });
    editor.addKeyMap(keyMap);
}
function off() {
    // console.log('off', plugins);
    cbs.forEach((cb) => cb && cb());
    editor?.removeKeyMap(keyMap); // onDestroy runs at SSR, optional chaining here
}
let debouncedValue = value;
const setDebouncedValue = debounce((value) => {
    debouncedValue = value;
    overridePreview?.(previewEl, {
        value: debouncedValue,
        plugins,
        sanitize,
        remarkRehype,
    });
}, previewDebounce);
$: setDebouncedValue(value);
$: if (editor && value !== editor.getValue()) {
    editor.setValue(value);
}
$: if (editor && plugins) {
    off();
    tick().then(() => {
        on();
    });
}
// Scroll sync vars
let syncEnabled = true;
let editCalled = false;
let previewCalled = false;
let editPs;
let previewPs;
let hast = { type: 'root', children: [] };
let vfile;
let currentBlockIndex = 0;
onMount(async () => {
    codemirror = createCodeMirror();
    editor = codemirror(editorEl, {
        value,
        mode: 'yaml-frontmatter',
        lineWrapping: true,
        tabSize: 8,
        indentUnit: 4,
        extraKeys: {
            Enter: 'newlineAndIndentContinueMarkdownList',
        },
        ...editorConfig,
        placeholder,
    });
    // https://github.com/codemirror/CodeMirror/issues/2428#issuecomment-39315423
    // https://github.com/codemirror/CodeMirror/issues/988#issuecomment-392232020
    editor.addKeyMap({
        Tab: 'indentMore',
        'Shift-Tab': 'indentLess',
    });
    editor.on('change', () => {
        dispatch('change', { value: editor.getValue() });
    });
    const updateBlockPositions = throttle(() => {
        editPs = [];
        previewPs = [];
        const scrollInfo = editor.getScrollInfo();
        const body = previewEl.childNodes[0];
        if (!(body instanceof HTMLElement))
            return;
        const leftNodes = hast.children.filter((v) => v.type === 'element');
        const rightNodes = [...body.childNodes].filter((v) => v instanceof HTMLElement);
        for (let i = 0; i < leftNodes.length; i++) {
            const leftNode = leftNodes[i];
            const rightNode = rightNodes[i];
            // if there is no position info, move to the next node
            if (!leftNode.position) {
                continue;
            }
            const left = editor.heightAtLine(leftNode.position.start.line - 1, 'local') /
                (scrollInfo.height - scrollInfo.clientHeight);
            const right = (rightNode.offsetTop - body.offsetTop) /
                (previewEl.scrollHeight - previewEl.clientHeight);
            if (left >= 1 || right >= 1) {
                break;
            }
            editPs.push(left);
            previewPs.push(right);
        }
        editPs.push(1);
        previewPs.push(1);
        // console.log(editPs, previewPs);
    }, 1000);
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
        const rightRatio = ((leftRatio - editPs[startIndex]) *
            (previewPs[startIndex + 1] - previewPs[startIndex])) /
            (editPs[startIndex + 1] - editPs[startIndex]) +
            previewPs[startIndex];
        // const rightRatio = rightPs[startIndex]; // for testing
        previewEl.scrollTo(0, rightRatio * (previewEl.scrollHeight - previewEl.clientHeight));
        editCalled = true;
    };
    const previewScrollHandler = () => {
        if (overridePreview)
            return;
        // find the current block in the view
        updateBlockPositions();
        currentBlockIndex = findStartIndex(previewEl.scrollTop / (previewEl.scrollHeight - previewEl.offsetHeight), previewPs);
        if (!syncEnabled)
            return;
        if (editCalled) {
            editCalled = false;
            return;
        }
        const rightRatio = previewEl.scrollTop / (previewEl.scrollHeight - previewEl.clientHeight);
        const startIndex = findStartIndex(rightRatio, previewPs);
        const leftRatio = ((rightRatio - previewPs[startIndex]) *
            (editPs[startIndex + 1] - editPs[startIndex])) /
            (previewPs[startIndex + 1] - previewPs[startIndex]) +
            editPs[startIndex];
        if (isNaN(leftRatio)) {
            return;
        }
        const info = editor.getScrollInfo();
        editor.scrollTo(0, leftRatio * (info.height - info.clientHeight));
        previewCalled = true;
    };
    editor.on('scroll', editorScrollHandler);
    previewEl.addEventListener('scroll', previewScrollHandler, {
        passive: true,
    });
    // handle image drop and paste
    const handleImages = async (e, itemList) => {
        if (!uploadImages)
            return;
        const files = Array.from(itemList ?? [])
            .map((item) => {
            if (item.type.startsWith('image/')) {
                return item.getAsFile();
            }
        })
            .filter((f) => f != null);
        if (files.length) {
            e.preventDefault(); // important
            await handleImageUpload(context, uploadImages, files);
        }
    };
    editor.on('drop', async (_, e) => {
        handleImages(e, e.dataTransfer?.items);
    });
    editor.on('paste', async (_, e) => {
        handleImages(e, e.clipboardData?.items);
    });
    // @ts-ignore
    new ResizeObserver((entries) => {
        containerWidth = entries[0].contentRect.width;
        // console.log(containerWidth);
    }).observe(root, { box: 'border-box' });
    // No need to call `on` because cm instance would change once after init
});
onDestroy(off);
</script><div
  class="bytemd"
  class:bytemd-split={split && activeTab === false}
  class:bytemd-fullscreen={fullscreen}
  bind:this={root}
><Toolbar
    {context}
    {split}
    {activeTab}
    {sidebar}
    {fullscreen}
    rightAfferentActions={actions.rightActions}
    locale={mergedLocale}
    actions={actions.leftActions}
    on:key={(e) =>{
      editor.setOption('keyMap', e.detail)
      editor.focus()
    }}
    on:tab={(e) =>{
      const v = e.detail
      if (split) {
        activeTab = activeTab === v ? false : v
      } else {
        activeTab = v
      }

      if (activeTab === 'write') {
        tick().then(() =>{
          editor && editor.focus()
        })
      }

      if (v === 'write') {
        tick().then(() =>{
          // https://github.com/bytedance/bytemd/issues/232
          // https://github.com/codemirror/codemirror5/issues/3270
          editor && editor.setSize(null, null)
        })
      }
    }}
    on:click={(e) =>{
      switch (e.detail) {
        case 'fullscreen':
          fullscreen = !fullscreen
          break
        case 'help':
          sidebar = sidebar === 'help' ? false : 'help'
          break
        case 'toc':
          sidebar = sidebar === 'toc' ? false : 'toc'
          break
      }
    }}
  /><div class="bytemd-body"><div class="bytemd-editor" style={styles.edit} bind:this={editorEl} /><div bind:this={previewEl} class="bytemd-preview" style={styles.preview}>{#if !overridePreview && (split || activeTab === 'preview')}<Viewer
          value={debouncedValue}
          {plugins}
          {sanitize}
          {remarkRehype}
          on:hast={(e) =>{
            hast = e.detail.hast
            vfile = e.detail.file
          }}
        />{/if}</div><div class="bytemd-sidebar" class:bytemd-hidden={sidebar === false}><div
        class="bytemd-sidebar-close"
        on:click={() =>{
          sidebar = false
        }}
        on:keydown|self={(e) =>{
          if (['Enter', 'Space'].includes(e.code)) {
            sidebar = false
          }
        }}
      >{@html icons.Close}</div><Help
        locale={mergedLocale}
        actions={actions.leftActions}
        visible={sidebar === 'help'}
      /><Toc
        {hast}
        locale={mergedLocale}
        {currentBlockIndex}
        on:click={(e) =>{
          const headings = previewEl.querySelectorAll('h1,h2,h3,h4,h5,h6')
          headings[e.detail].scrollIntoView()
        }}
        visible={sidebar === 'toc'}
      /></div></div><Status
    locale={mergedLocale}
    showSync={!overridePreview && split}
    value={debouncedValue}
    {syncEnabled}
    islimited={value.length > maxLength}
    on:sync={(e) =>{
      syncEnabled = e.detail
    }}
    on:top={() =>{
      editor.scrollTo(null, 0)
      previewEl.scrollTo({ top: 0 })
    }}
  /></div>
