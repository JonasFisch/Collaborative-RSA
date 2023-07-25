const accordions = document.querySelectorAll("details")
const accordionTriggerButtons = document.querySelectorAll("summary")

accordions.forEach(accordion => {
  accordion.addEventListener("click", e => {
    for (const other_accordion of accordions) {
      // close all other accordions 
      if (accordion != other_accordion) {
        other_accordion.open = false
      }
    }
  })
})