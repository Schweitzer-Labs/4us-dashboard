import './main.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';
import Auth from '@aws-amplify/auth'

Auth.configure({

  // REQUIRED only for Federated Authentication - Amazon Cognito Identity Pool ID
  identityPoolId: 'us-east-1:8ec0ca2c-4e7d-4f5e-9755-ad27a946f885',

  // REQUIRED - Amazon Cognito Region
  region: 'us-east-1',

  // OPTIONAL - Amazon Cognito Federated Identity Pool Region
  // Required only if it's different from Amazon Cognito Region
  identityPoolRegion: 'us-east-1',

  // OPTIONAL - Amazon Cognito User Pool ID
  userPoolId: 'us-east-1_L04zA9HKx',

  // OPTIONAL - Amazon Cognito Web Client ID (26-char alphanumeric string)
  userPoolWebClientId: '6bhp15ot1l2tqe849ikq06hvet',
})




async function runApp() {
  try {
    const user = await Auth.signIn('evan@schweitzerlabs.com', 'Passowrd_123');
    console.log(user)
    Elm.Main.init({
      node: document.getElementById('root')
    });
  } catch (error) {
    console.log('error signing in', error);
  }
}

runApp();


// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
