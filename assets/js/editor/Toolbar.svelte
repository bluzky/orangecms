<script type="module">
import { IconBold, IconItalic, IconStrikethrough, IconLink, IconCode, IconList, IconListNumbers, IconPilcrow, IconQuote, IconH1, IconH2, IconH3, IconH4 } from "@tabler/icons-svelte/dist/svelte/tabler-icons-svelte.js";
export let editor;

const commands = [
    {
        name: "Toggle bold",
        type: "command",
        icon: IconBold,
        command: () => editor.chain().focus().toggleBold().run()
    }
    ,
                  {
                      name: "Toggle italic",
                      type: "command",
                      icon: IconItalic,
                      command: () => {}
    },
    {
        name: "Toggle strike through",
        type: "command",
        icon: IconStrikethrough,
        command: () => {}
    },
    {
        name: "Add link",
        type: "command",
        icon: IconLink,
        command: () => {}
    },
    {
        name: "Toggle quote",
        type: "command",
        icon: IconQuote,
        command: () => {}
    },
    {
        name: "Toggle code block",
        type: "command",
        icon: IconCode,
        command: () => {}
    },
    {
        name: "Toggle bullet list",
        type: "command",
        icon: IconList,
        command: () => {}
    },
    {
        name: "Toggle ordered list",
        type: "command",
        icon: IconListNumbers,
        command: () => {}
    },
    {
        name: "Toggle paragraph",
        type: "command",
        icon: IconPilcrow,
        command: () => {}
    },
    {
        name: "Toggle heading 1",
        type: "command",
        icon: IconH1,
        command: () => {}
    },
    {
        name: "Toggle heading 2",
        type: "command",
        icon: IconH2,
        command: () => {}
    },
    {
        name: "Toggle heading 3",
        type: "command",
        icon: IconH3,
        command: () => {}
    },
    {
        name: "Toggle heading 4",
        type: "command",
        icon: IconH4,
        command: () => {}
    },
]
</script>

<div class="flex gap-0.5">
    {#each commands as command}
        <button
            type="button"
            class="p-1 rounded hover:bg-slate-100"
            label={command.label}
            on:click={command.command}
            >
            <svelte:component this={command.icon} class="w-4 h-4" />
        </button>
    {/each}
</div>

<div class="">
    <div class="link-form flex gap-1 p-2">
        <input type="text" placeholder="Past your link here" class="input input-sm" />
        <!-- <span class="btn btn-ghost btn-sm gap-1 bg-white"><Heroicons.check class="text-success h-5 w-5" /> Add</span> -->
        <!-- <span class="btn btn-square btn-outline btn-sm"><Heroicons.x_mark class="h-4 w-4" /></span> -->
    </div>
</div>
