<script type="module">
import { onMount, onDestroy } from 'svelte'
import { Editor } from '@tiptap/core'
import  StarterKit from '@tiptap/starter-kit'
import BubbleMenu from '@tiptap/extension-bubble-menu'
import Toolbar from './Toolbar.svelte'


export let html;
let bubbleMenu
let element
let editor



onMount(() => {
    editor = new Editor({
        element: element,
        extensions: [
				    StarterKit,
				    BubbleMenu.configure({
		            element: bubbleMenu,
    		    }),
			  ],
        content: html,
        onTransaction: () => {
            // force re-render so `editor.isActive` works as expected
            editor = editor
        },
    })
})

onDestroy(() => {
    editor.destroy()
})

export function getEditor() {
    return editor
}
</script>

<div style="position: relative" class="app">
	  {#if editor}
        <Toolbar editor={editor} />
	  {/if}

	  <div class="bg-background border-border rounded-lg border p-2 shadow-sm" bind:this="{bubbleMenu}">
		    {#if editor}
<Toolbar editor={editor} />
		    {/if}
	  </div>

	  <div bind:this={element} />
</div>

<style lang="postcss">
</style>
