const select = {
  mounted() {
    const el = this.el;
    let show = false;

    // close select popup
    function dismissSelect(event) {
      console.log("dismiss");
      const target = event?.target || el.querySelector(".select-content");
      target.removeEventListener("dismiss", dismissSelect);
      show = false;
      showSelect(false);
    }

    function showSelect(visible) {
      const contentEl = el.querySelector(".select-content");
      if (visible) {
        contentEl.classList.remove("hidden");
        el.setAttribute("data-open", "true");
      } else {
        el.setAttribute("data-open", "false");
        const onTransitionEnd = () => {
          contentEl.classList.add("hidden");
          contentEl.removeEventListener("transitionend", onTransitionEnd);
        };
        contentEl.addEventListener("transitionend", onTransitionEnd);
      }
    }

    // add event listener trigger select
    el.querySelector(".select-trigger").addEventListener("click", () => {
      const contentEl = el.querySelector(".select-content");
      if (!show) {
        console.log("show");
        show = true;
        showSelect(true);
      }
      setTimeout(() => {
        // handle click outside
        if (show) {
          // set focus on selected option or first option
          const selectedOption = contentEl.querySelector("input:checked");
          if (selectedOption) {
            selectedOption.focus();
          } else {
            contentEl.querySelector("input")?.focus();
          }
          contentEl.addEventListener("dismiss", dismissSelect);
        }
      }, 100);
    });

    // handle escape or enter key
    el.querySelector(".select-content").addEventListener("keydown", (event) => {
      if (event.key === "Escape" || event.key === "Enter") {
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

    function updateDisplayText() {
      console.log("changing");
      const selectedValue =
        el.querySelector("input:checked")?.value ||
        el.querySelector(".select-value")?.getAttribute("data-placeholder") ||
        "";
      el.querySelector(".select-value")?.setAttribute(
        "data-content",
        selectedValue
      );
    }
    const observer = new MutationObserver(updateDisplayText);
    observer.observe(el, observerOptions);
  },
};

export default {
  "shad-select": select,
};
