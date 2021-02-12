import './main.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';

const getTokenFromUrl = (url) => {
  const firstTrim = url.split('id_token=')
  if (firstTrim.length > 1) {
    return firstTrim[1].split('&')[0]
  } else {
    throw new Error('token from url not found')
  }
}

const getCommitteeIdFromUrlRedirect = (url) => {
  const firstTrim = url.split('state=')
  if (firstTrim.length > 1) {
    return firstTrim[1].split('&')[0]
  } else {
    throw new Error('token from url not found')
  }
}

const getCommitteeIdFromUrlQueryString = (url) => {
  const firstTrim = url.split('?committeeId=')
  if (firstTrim.length > 1) {
    return firstTrim[1]
  } else {
    throw new Error('committeeId from url not found')
  }
}

async function runApp() {
  let token;
  let committeeId;
  try {
    token = getTokenFromUrl(window.location.href)
    committeeId = getCommitteeIdFromUrlRedirect(window.location.href)
    localStorage.setItem('token', token)
    window.location = `http://localhost:3000?committeeId=${committeeId}`
  } catch (e) {
    token = localStorage.getItem('token')
    committeeId = getCommitteeIdFromUrlQueryString(window.location.href)
    if (token) {
      Elm.Main.init({
        node: document.getElementById('root'),
        flags: token
      });
    } else {
      window.location =
        `https://platform-user.auth.us-east-1.amazoncognito.com/login?client_id=6bhp15ot1l2tqe849ikq06hvet&response_type=token&scope=aws.cognito.signin.user.admin+email+openid+phone+profile&redirect_uri=http://localhost:3000&state=${committeeId}`
    }
  }
}

runApp();


// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
