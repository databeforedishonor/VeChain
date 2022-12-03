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
        Shiny.setInputValue('r_address', cert.annex.signer);
      })
      .catch((err) => {
        console.log('error:' + err.message)
        Shiny.setInputValue('r_address', '');
      })
  };


 shinyjs.sendBtn = function ([clauses = [], comment = '']) {
    connex.vendor.sign('tx', clauses)
      .comment(comment)
      .request()
      .then(result => {
        console.log(result)
        Shiny.setInputValue('r_result',result);
      })
      .catch((err) => {
        console.log('error:' + err.message)
      })
  };
});
"
