const select = {
  mounted() {
    const el = this.el;
    const contentEl = this.el.querySelector(".select-content");
    const inputEl = el.querySelector(`.select-input`);
    let focusIndex = -1;
    let isOpen = false;

    function syncInputValue() {
      const selectedValue = el
        .querySelector(".select-item[data-selected=true]")
        ?.getAttribute("data-value");

      const changed = selectedValue && inputEl.value != selectedValue;
      if (changed) {
        inputEl.value = selectedValue;
        inputEl.dispatchEvent(
          new Event("input", {
            bubbles: true,
            cancelable: true,
          })
        );
        el.querySelector(".select-value")?.setAttribute(
          "data-content",
          selectedValue
        );
      }
    }

    function open() {
      el.setAttribute("data-state", "open");
      setFocus(focusIndex);
      isOpen = true;
    }

    function close() {
      el.setAttribute("data-state", "close");
      focusIndex = -1;
      isOpen = false;
    }

    function setFocus(idx) {
      const items = contentEl.querySelectorAll(".select-item");
      items.forEach((e) => e.setAttribute("data-focus", false));
      items[idx]?.setAttribute("data-focus", true);
    }

    el.addEventListener("select-change", (e) => {
      // if item state changed from not selected -> select
      if (e.target.getAttribute("data-selected") != "true") {
        el.querySelectorAll(".select-item").forEach((e) =>
          e.setAttribute("data-selected", false)
        );
        e.target.setAttribute("data-selected", true);
        syncInputValue();
      }

      // close after selected
      close();
    });

    el.addEventListener("select-open", (e) => {
      open();
    });
    el.addEventListener("select-close", (e) => {
      close();
    });
    el.addEventListener("select-toggle", (e) => {
      const state = el.getAttribute("data-state");
      if (isOpen) {
        close();
      } else {
        open();
      }
    });

    // handle arrow key to move focused option
    el.addEventListener("keydown", (e) => {
      e.preventDefault();
      open();
      if (e.key === "ArrowDown") {
        focusIndex += 1;
        if (focusIndex >= contentEl.querySelectorAll(".select-item").length) {
          focusIndex = 0;
        }
        setFocus(focusIndex);
      } else if (e.key === "ArrowUp") {
        focusIndex -= 1;
        if (focusIndex < 0) {
          focusIndex = contentEl.querySelectorAll(".select-item").length - 1;
        }
        setFocus(focusIndex);
      } else if (e.key === "Enter") {
        // select item
        const items = contentEl.querySelectorAll(".select-item");
        items.forEach((e) => {
          e.setAttribute("data-focus", false);
          e.setAttribute("data-selected", false);
        });
        items[focusIndex].setAttribute("data-focus", false);
        items[focusIndex].setAttribute("data-selected", true);
        syncInputValue();
      } else if (e.key === "Escape") {
        close();
      }

      return true;
    });

    // close when click outside
    document.addEventListener("click", (e) => {
      if (isOpen && !contentEl.contains(e.target) && !el.contains(e.target)) {
        close();
      }
    });
  },
};

const preventEnter = {
  mounted() {
    this.addEventListener("keydown", (e) => {
      if (e.keyCode === 13) {
        e.preventDefault();
      }
    });
  },
};

export default {
  "lad-select": select,
  "lad-prevent-enter": preventEnter,
};
