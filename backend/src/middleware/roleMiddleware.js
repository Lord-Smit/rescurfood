const { error } = require('../utils/apiResponse');

const roleMiddleware = (...roles) => {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return error(res, `Access denied. Requires role: ${roles.join(', ')}`, 403);
    }
    next();
  };
};

module.exports = roleMiddleware;
