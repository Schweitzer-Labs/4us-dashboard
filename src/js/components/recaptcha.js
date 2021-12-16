export default class Recaptcha extends HTMLElement {
  constructor() {
    const self = super();

    self._grecaptcha = null;
    self._token = null;

    return self;
  }

  connectedCallback() {
    this._grecaptcha = grecaptcha.render(this, {
      hl: "en",
      sitekey: "6LeYuKQdAAAAAH1DkOMQ8pyeSa8p1ijz66jUbSnf",
      callback: (token) => {
        this._token = token;
        this.dispatchEvent(new CustomEvent("gotToken"));
      },
    });
  }

  set token(token) {
    this._token = token;

    if (this._grecaptcha !== null && token === null)
      grecaptcha.reset(this._grecaptcha);
  }

  get token() {
    return this._token;
  }
}
