const chat = document.getElementById("chat")
const anchor = document.getElementById("chat-anchor")

let scrollAtBottom = true

console.log(chat);

if (chat) {
  // check if scroll is already on the bottom
  chat.addEventListener("scroll", event => {
    console.log(chat.scrollTop + chat.clientHeight + 100 >= chat.scrollHeight);
    scrollAtBottom = chat.scrollTop + chat.clientHeight + 100 >= chat.scrollHeight
  })
  
  // scroll to bottom if new message available
  window.addEventListener("algothink:newMessage", (event) => {
    // delay so that the element can be added to the dom
    setTimeout(() => {
      if (scrollAtBottom) anchor.scrollIntoView()
    }, 1);
  })
}