export function LocalTimezoneHook(options = {}) {
  return {
    mounted() {
      this.el.value = Intl.DateTimeFormat().resolvedOptions().timeZone;
    },
  };
}
