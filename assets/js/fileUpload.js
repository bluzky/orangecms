import { uploadFile } from "./utils";

export class FileUpload {
  constructor(inputEl, options) {
    this.inputEl = inputEl;
    this.inputEl.onchange = (e) => this.handleInputChanged(e);
    this.targetEl = document.getElementById(
      inputEl.getAttribute("data-target")
    );

    this.previewEl = document.getElementById(
      inputEl.getAttribute("data-preview")
    );
    this.errorEl = document.getElementById(
      inputEl.getAttribute("data-error-display")
    );
    this.options = options;
  }

  handleInputChanged(e) {
    if (e.target.files.length > 0) {
      const uploadPath = this.inputEl.getAttribute("data-upload-path");
      uploadFile(
        uploadPath,
        e.target.files[0],
        this.options,
        (result) => {
          if (this.targetEl) {
            this.targetEl.value = result.data.access_path;
            this.previewEl.src = result.data.url;
            this.errorEl.innerHTML = "";
            const e = new Event("input", {
              bubbles: true,
              cancelable: true,
            });
            this.targetEl.dispatchEvent(e);
          }
        },
        (result) => {
          if (this.errorEl) {
            this.errorEl.innerHTML = result.message || "Cannot upload image";
          }
        }
      );
    }
  }
}
