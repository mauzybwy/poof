export function ForcedAutofocusHook(options = {}) {
  return {
    mounted() {
      this.updated();
    },
    updated() {
      const autofocusTo = this.el.dataset.autofocus_to;

      this.el.focus();

      if (autofocusTo === "end") {
        const valueLength = this.el.value.length;
        this.el.setSelectionRange(valueLength, valueLength);
      }
    },
  };
}
