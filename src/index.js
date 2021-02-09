import './main.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';

import OktaSignIn from '@okta/okta-signin-widget';
// import '@okta/okta-signin-widget/dist/css/okta-sign-in.min.css';


const signIn = new OktaSignIn({
  baseUrl: 'https://dev-23201487.okta.com',
  clientId: '0oa58u4h8mlrqVPIS5d6'
});
signIn.renderEl({
  el: '#widget-container'
}, function success(res) {
  if (res.status === 'SUCCESS') {
    console.log(res)
    Elm.Main.init({
      node: document.getElementById('root')
    });
  } else {
    // The user can be in another authentication state that requires further action.
    // For more information about these states, see:
    //   https://github.com/okta/okta-signin-widget#rendereloptions-success-error
  }
});

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
