
md.inject = ({storage: {state}}) => (id) => {

  chrome.tabs.executeScript(id, {
    code: `
      document.querySelector('pre').style.visibility = 'hidden'
      var theme = '${state.theme}'
      var raw = ${state.raw}
      var content = ${JSON.stringify(state.content)}
      var compiler = '${state.compiler}'
    `,
    runAt: 'document_start'
  })

  chrome.tabs.insertCSS(id, {file: 'css/content.css', runAt: 'document_start'})
  chrome.tabs.insertCSS(id, {file: 'vendor/prism.min.css', runAt: 'document_start'})

  chrome.tabs.executeScript(id, {file: 'vendor/mithril.min.js', runAt: 'document_start'})
  chrome.tabs.executeScript(id, {file: 'vendor/prism.min.js', runAt: 'document_start'})
  if (state.content.emoji) {
    chrome.tabs.executeScript(id, {file: 'content/emoji.js', runAt: 'document_start'})
  }
  chrome.tabs.executeScript(id, {file: 'content/content.js', runAt: 'document_start'})
}
