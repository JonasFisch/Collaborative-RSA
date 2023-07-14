const chat = document.getElementById("chat")
const anchor = document.getElementById("chat-anchor")

let scrollAtBottom = true

// check if scroll is already on the bottom
chat.addEventListener("scroll", event => {
  scrollAtBottom = chat.scrollTop + chat.clientHeight + 100 >= chat.scrollHeight
})

// scroll to bottom if new message available
window.addEventListener("algothink:newMessage", (event) => {
  if (scrollAtBottom) anchor.scrollIntoView();
})