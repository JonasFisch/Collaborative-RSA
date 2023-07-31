export default {
  mounted() {

    const body = document.querySelector("body")

    const hook = this
    hook.el.addEventListener("dragstart", (event) => {
      hook.pushEventTo(`#${this.el.id}`, 'start_drag', {
        draggedId: Number(String(this.el.id).replace("crypto-artifact-", "")), // id of the dragged item
      });  

      event.dataTransfer.clearData()
      event.dataTransfer.setData("text/plain", event.target.id); 
      body.classList.add("dragging")
      hook.el.classList.add("phx-dragged")
    });

    hook.el.addEventListener("dragend", (event) => {      
      hook.pushEventTo(`#${this.el.id}`, 'end_drag', {
        draggedId: Number(String(this.el.id).replace("crypto-artifact-", "")), // id of the dragged item
      }); 

      body.classList.remove("dragging")
      hook.el.classList.remove("phx-dragged")
    });
  },
}