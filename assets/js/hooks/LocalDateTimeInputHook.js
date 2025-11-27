export function LocalDateTimeInputHook(options = {}) {
  return {
    mounted() {
      // If there's a UTC value, convert to local for display
      const utcValue = this.el.dataset.utc;
      if (utcValue) {
        const local = new Date(utcValue);
        // Format as YYYY-MM-DDTHH:MM for datetime-local input
        const formatted =
          local.getFullYear() +
          "-" +
          String(local.getMonth() + 1).padStart(2, "0") +
          "-" +
          String(local.getDate()).padStart(2, "0") +
          "T" +
          String(local.getHours()).padStart(2, "0") +
          ":" +
          String(local.getMinutes()).padStart(2, "0");
        this.el.value = formatted;
      }

      this.el.addEventListener("change", (e) => {
        const local = new Date(e.target.value);
        this.pushEvent("datetime_changed", {
          id: this.el.id,
          utc: local.toISOString(),
        });
      });
    },
  };
}
