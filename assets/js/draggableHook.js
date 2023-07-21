export default {
  mounted() {
    const hook = this
    hook.el.addEventListener("dragstart", (event) => {
      event.dataTransfer.clearData()
      event.dataTransfer.setData("text/plain", event.target.id);       
    });
  },
}