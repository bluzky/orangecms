<svelte:options immutable={true} /><script>import { getProcessor } from './utils';
import { tick, onDestroy, onMount, createEventDispatcher, afterUpdate, } from 'svelte';
const dispatch = createEventDispatcher();
export let value = '';
export let plugins = [];
export let sanitize = undefined;
export let remarkRehype = undefined;
let markdownBody;
let cbs = [];
function on() {
    // console.log('von')
    cbs = plugins.map((p) => p.viewerEffect?.({ markdownBody, file }));
}
function off() {
    // console.log('voff')
    cbs.forEach((cb) => cb?.());
}
onMount(() => {
    markdownBody.addEventListener('click', (e) => {
        const $ = e.target;
        if ($.tagName !== 'A')
            return;
        const href = $.getAttribute('href');
        if (!href?.startsWith('#'))
            return;
        markdownBody
            .querySelector('#user-content-' + href.slice(1))
            ?.scrollIntoView();
    });
});
onDestroy(off);
let file;
let i = 0;
const dispatchPlugin = () => (tree, file) => {
    tick().then(() => {
        // console.log(tree);
        dispatch('hast', { hast: tree, file });
    });
};
$: try {
    file = getProcessor({
        sanitize,
        plugins: [
            ...plugins,
            {
                // remark: (p) =>
                //   p.use(() => (tree) =>{
                //     console.log(tree)
                //   }),
                rehype: (processor) => processor.use(dispatchPlugin),
            },
        ],
        remarkRehype,
    }).processSync(value);
    i++;
}
catch (err) {
    console.error(err);
}
afterUpdate(() => {
    // TODO: `off` should be called before DOM update
    // https://github.com/sveltejs/svelte/issues/6016
    off();
    on();
});
$: html = `${file}<!--${i}-->`;
</script><div bind:this={markdownBody} class="markdown-body">{@html html}</div>
