const { error } = require('../utils/apiResponse');

const roleMiddleware = (...roles) => {
  return (req, res, next) => {
    if (!req.user || !req.user.role) {
      return error(res, 'Access denied. Unauthorized.', 401);
    }
    const userRole = req.user.role.toLowerCase();
    const allowed = roles.map(r => r.toLowerCase());
    if (!allowed.includes(userRole)) {
      return error(res, `Access denied. Requires role: ${roles.join(', ')}`, 403);
    }
    next();
  };
};

module.exports = roleMiddleware;
