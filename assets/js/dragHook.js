export default {
  cancelDefault(e) {
    e.preventDefault();
    e.stopPropagation();
    return false;
  },

  dragOver(e) {
    this.classList.add("drop-hover");  
    this.classList.add("phx-dragging");  
  },

  dragLeave(e) {
    this.classList.remove("drop-hover")
    this.classList.remove("phx-dragging")
  },

  dragEnter(e) {
    console.log("dragenter");
  },

  dropped(e, dropzone, hook, selector) {
    console.log("dropped");
    dropzone.classList.remove("drop-hover")
    dropzone.classList.remove("phx-dragging")
    const draggable_id = e.dataTransfer.getData("text")

    console.log(dropzone.id);
    // trigger dropped event in backend
    hook.pushEventTo(selector, 'dropped', {
      draggedId: Number(String(draggable_id).replace("crypto-artifact-", "")), // id of the dragged item
      dropzoneId: dropzone.id, // id of the drop zone where the drop occured
    });
  },

  mounted() {
    const hook = this;
    const selector = "#" + this.el.id;    

    // register event for every dropzone that is child of hook element
    hook.el.querySelectorAll('.drop-zone').forEach((dropzone) => {
      dropzone.addEventListener("drop", e => this.dropped(e, dropzone , hook, selector));
      dropzone.addEventListener("dragenter", this.dragEnter);
      dropzone.addEventListener("dragover", this.dragOver);
      dropzone.addEventListener("dragleave", this.dragLeave);
    });
  },
}