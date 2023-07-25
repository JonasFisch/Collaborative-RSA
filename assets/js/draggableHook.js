export default {
  mounted() {

    const body = document.querySelector("body")

    const hook = this
    hook.el.addEventListener("dragstart", (event) => {
      event.dataTransfer.clearData()
      event.dataTransfer.setData("text/plain", event.target.id); 
      body.classList.add("dragging")
    });

    hook.el.addEventListener("dragend", (event) => {
      console.log("dragged");     

      body.classList.remove("dragging")
    });
  },
}