<svelte:options accessors={true} />

<script>
  export let items;
  export let command;
  let selectedIndex = 0;
  let activeClasses = "bg-zinc-200 font-medium";

  /* watch: {
  *  items() {
  *    selectedIndex = 0;
  *  },
    }, */
  $: if (items) selectedIndex = 0;

  export function handleKeyEvent(key) {
    if (key === "ArrowUp") {
      upHandler();
      return true;
    }

    if (key === "ArrowDown") {
      downHandler();
      return true;
    }

    if (key === "Enter") {
      enterHandler();
      return true;
    }

    return false;
  }

  function upHandler() {
    selectedIndex = (selectedIndex + items.length - 1) % items.length;
  }

  function downHandler() {
    selectedIndex = (selectedIndex + 1) % items.length;
  }

  function enterHandler() {
    selectItem(selectedIndex);
  }

  function selectItem(index) {
    const item = items[index];

    if (item) {
      command(item);
    }
  }
</script>

<div
  class="items p-2 bg-zinc-100 rounded-xl border border-zinc-200 drop-shadow-lg"
>
  <ul class="text-sm">
    {#if items.length}
      {#each items as item, index}
        <li
          class="item w-full px-4 py-2 rounded-lg flex gap-2 {index ===
          selectedIndex
            ? activeClasses
            : ''}"
          on:click={() => selectItem(index)}
        >
          <svelte:component this={item.icon} />
          <span> {item.title}</span>
        </li>
      {/each}
    {:else}
      <div class="item">No result</div>
    {/if}
  </ul>
</div>
