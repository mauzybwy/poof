export function LocalTimeHook(options = {}) {
  return {
    mounted() {
      this.updated();
    },
    updated() {
      let trimmed = this.el.textContent.trim();
      let dt = new Date(trimmed);

      this.el.textContent = dt.toLocaleString();
    },
  };
}
