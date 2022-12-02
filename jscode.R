jscode <- "
//const connex = new Connex({
//node: 'https://mainnet.veblocks.net/', // veblocks public node, use your own if needed
//network: 'main' // defaults to mainnet, so it can be omitted here
//})

document.addEventListener('DOMContentLoaded', function () {
  const connex = new Connex({
    node: 'https://mainnet.veblocks.net/',
    network: 'main'
  })

  let address = '';

  shinyjs.cert = function ([reason = null]) {
    connex.vendor.sign('cert', {
      purpose: 'agreement',
      payload: {
        type: 'text',
        content: reason || 'Identification'
      }
    })
      .request()
      .then((cert) => {
        address = cert.annex.signer
      })
      .catch((err) => {
        console.log('error:' + err.message)
        address = ''
      })
      .finally(() => {
        document.getElementById('cert').innerText = address ? `Signed as ${address}` : 'Sign In'
      })
  };


 shinyjs.sendBtn = function ([clauses = [], comment = '']) {
    connex.vendor.sign('tx', clauses)
      .link('https://connex.vecha.in/{txid}') // User will be back to the app by the url https://connex.vecha.in/0xffff....
      .comment(comment)
      .request()
      .then(result => {
        console.log(result)
        Shiny.setInputValue('r_result',result);
      })
  };
});
"
