export function LocalTimezoneHook(options = {}) {
  return {
    mounted() {
      this.updated();
    },
    updated() {
      this.el.value = Intl.DateTimeFormat().resolvedOptions().timeZone;
    },
  };
}
