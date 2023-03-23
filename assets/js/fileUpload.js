export class FileUpload {
  constructor(inputEl, options) {
    this.inputEl = inputEl;
    this.inputEl.onchange = (e) => this.handleInputChanged(e);
    this.targetEl = document.getElementById(
      inputEl.getAttribute("data-target")
    );
    this.errorEl = document.getElementById(
      inputEl.getAttribute("data-error-display")
    );
    this.options = options;
  }

  handleInputChanged(e) {
    if (e.target.files.length > 0) {
      this.uploadFile(e.target.files[0]);
    }
  }

  uploadFile(file) {
    const uploadPath = this.inputEl.getAttribute("data-upload-path");
    if (uploadPath) {
      const formData = new FormData();
      formData.append("file", file);
      formData.append("_csrf_token", this.options.csrf_token);

      fetch(uploadPath, {
        method: "POST",
        body: formData,
      })
        .then((response) => response.json())
        .then((result) => {
          if (result.status == "ok") {
            if (this.targetEl) {
              this.targetEl.value = result.data.url;
            }
          } else {
            if (this.errorEl) {
              this.errorEl.innerHTML = result.message || "Cannot upload image";
            }
          }
        })
        .catch((error) => {
          console.error("Error:", error);
        });
    } else {
      throw new Error("data-upload-path is not set");
    }
  }
}
