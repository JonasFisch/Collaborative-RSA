import Sortable from "sortablejs"

export default {
  cancelDefault(e) {
    e.preventDefault();
    e.stopPropagation();
    return false;
  },

  dragOver(e) {
    this.classList.add("drop-hover");  
  },

  dragLeave(e) {
    this.classList.remove("drop-hover")
  },

  dropped(e, dropzone, hook, selector) {
    console.log("dropped");

    console.log(e);
    dropzone.classList.remove("drop-hover")
    console.log(e);
    console.log(hook);
    console.log(selector);
    hook.pushEventTo(selector, 'dropped', {
      draggedId: Number(String(e.target.id).replace("crypto-artifact-", "")), // id of the dragged item
      // dropzoneId: e.to.id, // id of the drop zone where the drop occured
      // draggableIndex: e.newDraggableIndex, // index where the item was dropped (relative to other items in the drop zone)
    });
  
  },

  mounted() {
    let dragged;
    const hook = this;
    const selector = "#" + this.el.id;    

    document.querySelectorAll('.drop-zone').forEach((dropzone) => {
      dropzone.addEventListener("drop", e => this.dropped(e, dropzone , hook, selector));
      dropzone.addEventListener("dragenter", this.cancelDefault);
      dropzone.addEventListener("dragover", this.dragOver);
      dropzone.addEventListener("dragleave", this.dragLeave);
    });
  },
}