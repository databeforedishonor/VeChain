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

  var address = '';

  shinyjs.cert = function () {
    connex.vendor.sign('cert', {
      purpose: 'agreement',
      payload: {
        type: 'text',
        content: 'cert'
      }
    })
      .request()
      .then((r) => {
        address = r.annex.signer
        var userAddress = address.toLowerCase();
        document.getElementById('cert').innerText = 'Signed In';
        Shiny.setInputValue('r_address',address);
      })
      .catch((e) => console.log('error:' + e.message));
  };

  // Set blank global variable for Shiny event to hook to

  var clauses = '';
  var comments = '';

  Shiny.addCustomMessageHandler('myCallbackHandler',
    function(tx_clauses) {
      // Set global variable to callback handler from Shiny Element
      clauses = tx_clauses;
      console.log(clauses);
      return clauses;
  });

  Shiny.addCustomMessageHandler('myCallbackHandler_comments',
    function(tx_comments) {
      // Set global variable to callback handler from Shiny Element
      comments = tx_comments;
      console.log(comments);
      return comments;
  });


 shinyjs.sendBtn = function () {

    connex.vendor.sign('tx',

      clauses

      )
      .link('https://connex.vecha.in/{txid}') // User will be back to the app by the url https://connex.vecha.in/0xffff....
      .comment(comments)
      .request()
      .then(result => {
        console.log(result)
        Shiny.setInputValue('r_result',result);
      })
  };
});
"
