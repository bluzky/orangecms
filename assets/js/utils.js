export function debounce(func, timeout = 300) {
  let timer;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => {
      func.apply(this, args);
    }, timeout);
  };
}

export function uploadFile(endpoint, file, options, onSuccess, onError) {
  if (endpoint) {
    const formData = new FormData();
    formData.append("file", file);
    formData.append("_csrf_token", options.csrf_token);

    fetch(endpoint, {
      method: "POST",
      body: formData,
    })
      .then((response) => response.json())
      .then((result) => {
        if (result.status == "ok") {
          onSuccess(result);
        } else {
          onError(result);
        }
      })
      .catch((error) => {
        console.error("Error:", error);
      });
  } else {
    throw new Error("data-upload-path is not set");
  }
}
