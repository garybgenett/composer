
var t = require('assert')


module.exports = ({browser, popup, advanced, content}) => {

  before(async () => {
    // add origin
    await advanced.bringToFront()
    await advanced.select('.m-select', 'http')
    await advanced.type('[type=text]', 'localhost:3000')
    await advanced.click('button')
    await advanced.waitFor(() => document.querySelectorAll('.m-list li').length === 2)

    // enable header detection
    if (!await advanced.evaluate(() => state.header)) {
      await advanced.click('.m-switch')
    }
  })

  describe('button - raw/markdown', () => {
    before(async () => {
      // popup
      await popup.bringToFront()
      // defaults button
      await popup.click('button:nth-of-type(2)')
    })

    it('render markdown as html', async () => {
      // go to page serving markdown as text/markdown
      await content.goto('http://localhost:3000/correct-content-type')
      await content.bringToFront()
      await content.waitFor('#_html')

      t.equal(
        await content.evaluate(() =>
          document.querySelector('#_html p strong').innerText
        ),
        'bold',
        'markdown should be rendered'
      )

      // popup
      await popup.bringToFront()

      t.strictEqual(
        await popup.evaluate(() =>
          state.raw
        ),
        false,
        'state.raw should equal false'
      )
      t.equal(
        await popup.evaluate(() =>
          document.querySelector('.m-button:first-child').innerText.toLowerCase()
        ),
        'markdown',
        'button text should equal markdown'
      )
    })

    it('display raw markdown', async () => {
      // raw button
      await content.bringToFront()
      await popup.click('button:nth-of-type(1)')
      // content auto reloads
      await content.waitFor('#_markdown')

      t.equal(
        await content.evaluate(() =>
          document.querySelector('#_markdown').innerText
        ),
        '**bold**',
        'markdown should not be rendered'
      )

      // popup
      await popup.bringToFront()

      t.strictEqual(
        await popup.evaluate(() =>
          state.raw
        ),
        true,
        'state.raw should equal true'
      )
      t.equal(
        await popup.evaluate(() =>
          document.querySelector('.m-button:first-child').innerText.toLowerCase()
        ),
        'html',
        'button text should equal html'
      )
    })
  })

  describe('set theme', () => {
    before(async () => {
      // popup
      await popup.bringToFront()
      // defaults button
      await popup.click('button:nth-of-type(2)')
      // theme tab
      await popup.click('.m-tabs a:nth-of-type(1)')
    })

    it('github theme should be set by default', async () => {
      // go to page serving markdown as text/markdown
      await content.goto('http://localhost:3000/correct-content-type')
      await content.bringToFront()
      await content.waitFor('#_theme')

      t.strictEqual(
        await content.evaluate(() =>
          /github\.css$/.test(
            document.querySelector('#_theme').getAttribute('href')
          )
        ),
        true,
        'github theme styles should be included'
      )
    })

    it('set github-dark theme', async () => {
      // select github-dark theme
      await content.bringToFront()
      await popup.select('.m-panel:nth-of-type(1) select', 'github-dark')
      // content auto reloads
      await content.waitFor('#_theme')

      t.strictEqual(
        await content.evaluate(() =>
          /github-dark\.css$/.test(
            document.querySelector('#_theme').getAttribute('href')
          )
        ),
        true,
        'github-dark theme styles should be included'
      )
    })

    it('popup should preserve state', async () => {
      // reload popup
      await popup.bringToFront()
      await popup.reload()
      await popup.waitFor('#popup')

      t.equal(
        await popup.evaluate(() =>
          state.theme
        ),
        'github-dark',
        'state.theme should equal github-dark'
      )
      t.equal(
        await popup.evaluate(() =>
          document.querySelectorAll('.m-panel:nth-of-type(1) select option')[
            document.querySelector('.m-panel:nth-of-type(1) select').selectedIndex
          ].innerText
        ),
        'github-dark',
        'dom select option should be github-dark'
      )
    })
  })

  describe('set compiler options - marked', () => {
    before(async () => {
      // popup
      await popup.bringToFront()
      // defaults button
      await popup.click('button:nth-of-type(2)')
      // compiler tab
      await popup.click('.m-tabs a:nth-of-type(2)')
    })

    it('gfm is enabled by default', async () => {
      // go to page serving markdown as text/markdown
      await content.goto('http://localhost:3000/compiler-options-marked')
      await content.bringToFront()
      await content.waitFor('#_html')

      t.equal(
        await content.evaluate(() =>
          document.querySelector('#_html p del').innerText
        ),
        'strikethrough',
        'gfm should be rendered'
      )
    })

    it('gfm is disabled', async () => {
      // disable gfm
      await content.bringToFront()
      // gfm switch
      await popup.click('.m-panel:nth-of-type(2) .m-switch:nth-of-type(2)')
      // content auto reloads
      await content.waitFor(100)
      await content.waitFor('#_html')

      t.equal(
        await content.evaluate(() =>
          document.querySelector('#_html p').innerText
        ),
        '~~strikethrough~~',
        'gfm should not be rendered'
      )
    })

    it('popup should preserve state', async () => {
      // reload popup
      await popup.bringToFront()
      await popup.reload()
      await popup.waitFor('#popup')

      t.equal(
        await popup.evaluate(() =>
          document.querySelectorAll('.m-panel:nth-of-type(2) .m-select option')[
            document.querySelector('.m-panel:nth-of-type(2) .m-select').selectedIndex
          ].innerText
        ),
        'marked',
        'dom select option should be marked'
      )
      t.strictEqual(
        await popup.evaluate(() =>
          state.options.gfm
        ),
        false,
        'state.options.gfm should be false'
      )
      t.strictEqual(
        await popup.evaluate(() =>
          document.querySelector('.m-panel:nth-of-type(2) .m-switch:nth-of-type(2)')
            .classList.contains('is-checked')
        ),
        false,
        'dom gfm checkbox should be disabled'
      )
    })
  })

  describe('set compiler options - remark', () => {
    before(async () => {
      // popup
      await popup.bringToFront()
      // defaults button
      await popup.click('button:nth-of-type(2)')
      // compiler tab
      await popup.click('.m-tabs a:nth-of-type(2)')
    })

    it('marked should not render gfm task lists', async () => {
      // go to page serving markdown as text/markdown
      await content.goto('http://localhost:3000/compiler-options-remark')
      await content.bringToFront()
      await content.waitFor('#_html')

      t.equal(
        await content.evaluate(() =>
          document.querySelector('#_html ul li').innerText
        ),
        '[ ] task',
        'gfm task lists should not be rendered'
      )
    })

    it('remark should render gfm task lists by default', async () => {
      // select remark compiler
      await content.bringToFront()
      await popup.select('.m-panel:nth-of-type(2) select', 'remark')
      // content auto reloads
      await content.waitFor(100)
      await content.waitFor('#_html')

      t.equal(
        await content.evaluate(() =>
          document.querySelector('#_html ul li').getAttribute('class')
        ),
        'task-list-item',
        'dom li should have a class set'
      )
      t.strictEqual(
        await content.evaluate(() =>
          document.querySelector('#_html ul li [type=checkbox]')
            .hasAttribute('disabled')
        ),
        true,
        'dom li should contain checkbox in it'
      )
      t.equal(
        await content.evaluate(() =>
          document.querySelector('#_html ul li').innerText
        ),
        ' task',
        'dom li should contain the task text'
      )
    })

    it('remark disable gfm', async () => {
      // redraw popup
      await popup.bringToFront()
      await popup.reload()
      await popup.waitFor('#popup')

      // disable gfm
      await content.bringToFront()
      // gfm switch
      await popup.click('.m-panel:nth-of-type(2) .m-switch:nth-of-type(4)')
      // content auto reloads
      await content.waitFor(100)
      await content.waitFor('#_html')

      t.equal(
        await content.evaluate(() =>
          document.querySelector('#_html ul li').innerText
        ),
        '[ ] task',
        'gfm task lists should not be rendered'
      )
    })

    it('popup should preserve state', async () => {
      // reload popup
      await popup.bringToFront()
      await popup.reload()
      await popup.waitFor('#popup')
      await popup.waitFor(100)

      t.equal(
        await popup.evaluate(() =>
          document.querySelectorAll('.m-panel:nth-of-type(2) .m-select option')[
            document.querySelector('.m-panel:nth-of-type(2) .m-select').selectedIndex
          ].innerText
        ),
        'remark',
        'dom select option should be remark'
      )
      t.strictEqual(
        await popup.evaluate(() =>
          state.options.gfm
        ),
        false,
        'state.options.gfm should be false'
      )
      t.strictEqual(
        await popup.evaluate(() =>
          document.querySelector('.m-panel:nth-of-type(2) .m-switch:nth-of-type(4)')
            .classList.contains('is-checked')
        ),
        false,
        'dom gfm checkbox should be disabled'
      )
    })
  })

  describe('set content options - toc', () => {
    before(async () => {
      // popup
      await popup.bringToFront()
      // defaults button
      await popup.click('button:nth-of-type(2)')
      // content tab
      await popup.click('.m-tabs a:nth-of-type(3)')
    })

    it('toc is disabled by default', async () => {
      // go to page serving markdown as text/markdown
      await content.goto('http://localhost:3000/content-options-toc')
      await content.bringToFront()
      await content.waitFor('#_html')

      t.strictEqual(
        await content.evaluate(() =>
          document.querySelector('#_toc')
        ),
        null,
        'toc should be disabled'
      )
    })

    it('enable toc', async () => {
      // enable toc
      await content.bringToFront()
      // toc switch
      await popup.click('.m-panel:nth-of-type(3) .m-switch:nth-of-type(3)')
      // content auto reloads
      await content.waitFor('#_toc')

      t.deepStrictEqual(
        await content.evaluate(() =>
          Array.from(document.querySelectorAll('#_toc #_ul a'))
            .map((a) => ({href: a.getAttribute('href'), text: a.innerText}))
        ),
        [
          {href: '#h1', text: 'h1'},
          {href: '#h2', text: 'h2'},
          {href: '#h3', text: 'h3'},
        ],
        'toc should be rendered'
      )
    })
  })

  describe('set content options - scroll', () => {
    before(async () => {
      // popup
      await popup.bringToFront()
      // defaults button
      await popup.click('button:nth-of-type(2)')
      // content tab
      await popup.click('.m-tabs a:nth-of-type(3)')
    })

    it('preserve scroll position by default', async () => {
      // go to page serving markdown as text/markdown
      await content.goto('http://localhost:3000/content-options-scroll')
      await content.bringToFront()
      await content.waitFor('#_html')

      // scroll down 200px
      await content.evaluate(() =>
        document.querySelector('body').scrollTop = 200
      )
      await content.waitFor(150)

      // reload page
      await content.reload()
      await content.waitFor('#_html')
      await content.waitFor(150)

      t.strictEqual(
        await content.evaluate(() =>
          document.querySelector('body').scrollTop,
        ),
        200,
        'scrollTop should be 200px'
      )
    })

    it('scroll to top', async () => {
      // disable scroll option
      await content.bringToFront()
      // scroll switch
      await popup.click('.m-panel:nth-of-type(3) .m-switch:nth-of-type(2)')
      // content auto reloads
      await content.waitFor(100)
      await content.waitFor('#_html')

      t.strictEqual(
        await content.evaluate(() =>
          document.querySelector('body').scrollTop,
        ),
        0,
        'scrollTop should be 0px'
      )

      // scroll down 200px
      await content.evaluate(() =>
        document.querySelector('body').scrollTop = 200
      )
      await content.waitFor(150)

      // reload page
      await content.reload()
      await content.waitFor('#_html')
      await content.waitFor(150)

      t.strictEqual(
        await content.evaluate(() =>
          document.querySelector('body').scrollTop,
        ),
        0,
        'scrollTop should be 0px'
      )
    })

    it('scroll to anchor', async () => {
      // click on header link
      await content.click('h2 a')
      await content.waitFor(150)

      t.strictEqual(
        await content.evaluate(() =>
          document.querySelector('body').scrollTop + 2
        ),
        await content.evaluate(() =>
          document.querySelector('h2').offsetTop
        ),
        'page should be scrolled to the anchor'
      )

      // scroll down 200px
      await content.evaluate(() =>
        document.querySelector('body').scrollTop += 200
      )
      await content.waitFor(150)

      t.strictEqual(
        await content.evaluate(() =>
          document.querySelector('body').scrollTop + 2
        ),
        await content.evaluate(() =>
          document.querySelector('h2').offsetTop + 200
        ),
        'page should be scrolled below the anchor'
      )

      // reload page
      await content.reload()
      await content.waitFor('#_html')
      await content.waitFor(150)

      t.strictEqual(
        await content.evaluate(() =>
          document.querySelector('body').scrollTop
        ),
        await content.evaluate(() =>
          document.querySelector('h2').offsetTop
        ),
        'page should be scrolled back to the anchor'
      )
    })
  })

}
