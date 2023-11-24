document.addEventListener("DOMContentLoaded", () => {
  const usernameField = document.getElementById("username");
  const viewButton = document.getElementById("view-button");
  viewButton.addEventListener("click", (e) => {
    e.preventDefault();
    const username = usernameField.value;
    if (username) {
      window.location.href = `/tracks/${username}`;
    }
  });
});
