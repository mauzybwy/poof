export function CtrlEnterSubmitHook(options = {}) {
  return {
    mounted() {
      this.el.addEventListener("keydown", (e) => {
        if (e.key === "Enter" && (e.metaKey || e.ctrlKey)) {
          console.log(this.el);
          e.preventDefault();
          this.el.dispatchEvent(
            new SubmitEvent("submit", { cancelable: true, bubbles: true })
          );
        }
      });
    },
  };
}
