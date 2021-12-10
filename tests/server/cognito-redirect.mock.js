const app = require("express")();

const HOST = "http://localhost:3000";
const PORT = 3030;

app.get("/login", (req, res) => {
  const committeeId = req.query.state
    ? `&state=${req.query.state}`
    : "&state=null";
  res.redirect(`${HOST}#id_token=abc${committeeId}&token_type=Bearer`);
});

const run = async () => {
  await app.listen(PORT);
};

run();
