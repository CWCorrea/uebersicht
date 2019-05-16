module.exports = function disallowIFraming(req, res, next) {
  res.setHeader('X-Frame-Options', 'deny');
  next();
}
