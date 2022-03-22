
md.messages = ({storage: {defaults, state, set}, compilers, mathjax, headers}) => {

  return (req, sender, sendResponse) => {

    if (req.message === 'markdown') {
      var markdown = req.markdown

      if (state.content.mathjax) {
        var jax = mathjax()
        markdown = jax.tokenize(markdown)
      }

      var html = compilers[state.compiler].compile(markdown)

      if (state.content.mathjax) {
        html = jax.detokenize(html)
      }

      sendResponse({message: 'html', html})
    }

    // popup
    else if (req.message === 'popup') {
      sendResponse(Object.assign({}, state, {
        options: state[state.compiler],
        description: compilers[state.compiler].description,
        compilers: Object.keys(compilers)
      }))
    }
    else if (req.message === 'popup.theme') {
      set({theme: req.theme})
      notifyContent({message: 'theme', theme: req.theme})
      sendResponse()
    }
    else if (req.message === 'popup.raw') {
      set({raw: req.raw})
      notifyContent({message: 'raw', raw: req.raw})
      sendResponse()
    }
    else if (req.message === 'popup.defaults') {
      var options = Object.assign({}, defaults)
      options.origins = state.origins
      set(options)
      notifyContent({message: 'reload'})
      sendResponse()
    }
    else if (req.message === 'popup.compiler.name') {
      set({compiler: req.compiler})
      notifyContent({message: 'reload'})
      sendResponse()
    }
    else if (req.message === 'popup.compiler.options') {
      set({[req.compiler]: req.options})
      notifyContent({message: 'reload'})
      sendResponse()
    }
    else if (req.message === 'popup.content') {
      set({content: req.content})
      notifyContent({message: 'reload'})
      sendResponse()
    }
    else if (req.message === 'popup.advanced') {
      // ff: opens up about:addons with openOptionsPage
      if (/Firefox/.test(navigator.userAgent)) {
        chrome.management.getSelf((extension) => {
          chrome.tabs.create({url: extension.optionsUrl})
        })
      }
      else {
        chrome.runtime.openOptionsPage()
      }
      sendResponse()
    }

    // options
    else if (req.message === 'options') {
      sendResponse({
        origins: state.origins,
        header: state.header,
        csp: state.csp,
        exclude: state.exclude,
      })
    }
    else if (req.message === 'options.header') {
      set({header: req.header})
      sendResponse()
    }
    else if (req.message === 'options.csp') {
      // ff: onHeadersReceived is enabled by default
      if (!/Firefox/.test(navigator.userAgent)) {
        headers[req.csp ? 'add' : 'remove']()
      }
      set({csp: req.csp})
      sendResponse()
    }

    // options origins
    else if (req.message === 'origin.add') {
      state.origins[req.origin] = defaults.match
      set({origins: state.origins})
      sendResponse()
    }
    else if (req.message === 'origin.remove') {
      delete state.origins[req.origin]
      set({origins: state.origins})
      sendResponse()
    }
    else if (req.message === 'origin.update') {
      state.origins[req.origin] = req.match
      set({origins: state.origins})
      sendResponse()
    }
  }

  function notifyContent (req, res) {
    chrome.tabs.query({active: true, currentWindow: true}, (tabs) => {
      chrome.tabs.sendMessage(tabs[0].id, req, res)
    })
  }
}
