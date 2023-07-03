const select = {
  mounted() {
    const el = this.el;

    // close select popup
    function dismissSelect(event) {
      const target = event?.target || el.querySelector(".select-content");
      target.classList.add("hidden");
      target.removeEventListener("dismiss", dismissSelect);
    }

    // update display label of selected option
    function updateDisplayLabel() {
      el.querySelector(".select-value").innerText = el.querySelector(
        `input:checked ~ .select-item-label`
      )?.innerText;
    }

    // propgate name to all inputs
    const name = el.getAttribute("data-name");
    if (name)
      el.querySelectorAll(`input`).forEach((input) => {
        input.setAttribute("name", name);
      });

    // checked selected value
    const value = el.getAttribute("data-value");
    if (value) {
      el.querySelector(`input[value="${value}"]`).checked = true;
      updateDisplayLabel();
    }

    // add event listener trigger select
    el.querySelector(".select-trigger").addEventListener("click", () => {
      const contentEl = el.querySelector(".select-content");
      contentEl.classList.toggle("hidden");

      setTimeout(() => {
        // handle click outside
        if (!contentEl.classList.contains("hidden")) {
          // set focus on selected option or first option
          const selectedOption = contentEl.querySelector("input:checked");
          if (selectedOption) {
            selectedOption.focus();
          } else {
            contentEl.querySelector("input")?.focus();
          }
          contentEl.addEventListener("dismiss", dismissSelect);
        } else {
          dismissSelect();
        }
      }, 100);
    });

    // handle click on option
    el.querySelectorAll(".select-content input").forEach((option) => {
      option.addEventListener("change", (event) => {
        if (event.target.checked) {
          updateDisplayLabel();
          dismissSelect();
        }
      });
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
  },
};

export default {
  "shad-select": select,
};
