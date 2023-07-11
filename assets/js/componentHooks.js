const select = {
  mounted() {
    const el = this.el;
    const contentEl = this.el.querySelector(".select-content");
    const inputEl = el.querySelector(`#${el.id}-input`);
    let show = false;
    let opening = false;

    // close select popup
    function dismissSelect() {
      console.log("dismiss");
      contentEl.classList.add("hidden");
      show = false;

      // wait for click event to populated to input control
      setTimeout(() => {
        syncInputValue();
      }, 100);
    }

    // sync input value with select value and display text
    // if DOM changed, in case of option list does not contain selected value, reset it
    // if user press enter or escape, update to new selected option

    function syncInputValue(triggerChange = false) {
      const selectedValue =
        el.querySelector("input:checked")?.getAttribute("data-value") || "";
      const currentValue = inputEl.value;

      console.log("sync input value", selectedValue, currentValue);
      if (selectedValue !== currentValue) {
        inputEl.value = selectedValue;
        inputEl.dispatchEvent(
          new Event("input", { bubbles: true, cancelable: true })
        );
      }

      const label =
        selectedValue ||
        el.querySelector(".select-value")?.getAttribute("data-placeholder") ||
        "";
      el.querySelector(".select-value")?.setAttribute("data-content", label);
    }

    // add event listener trigger select
    el.querySelector(".select-trigger").addEventListener("click", () => {
      if (!show) {
        show = true;
        opening = true;
        contentEl.classList.remove("hidden");

        // set focus on selected option or first option
        const selectedOption = contentEl.querySelector("input:checked");
        if (selectedOption) {
          selectedOption.focus();
        } else {
          contentEl.querySelector("input")?.focus();
        }
      }

      // this prevent dissmiss event fired too early
      setTimeout(() => {
        opening = false;
      }, 100);
    });

    syncInputValue();

    // close if select is opened
    contentEl.addEventListener("dismiss", (e) => {
      console.log("dismiss event", e);
      if (show && !opening) dismissSelect();
    });

    // handle escape or enter key
    contentEl.addEventListener("keydown", (event) => {
      if (event.key === "Enter") {
        dismissSelect();
        event.preventDefault();
        event.stopPropagation();
        return false;
      }
    });

    // observe changes in select content
    const observerOptions = {
      childList: true,
      subtree: true,
    };

    const observer = new MutationObserver(syncInputValue);
    observer.observe(el, observerOptions);
  },
};

export default {
  "shad-select": select,
};
