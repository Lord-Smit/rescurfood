const serializeTimestamps = (obj) => {
  if (obj === null || obj === undefined) return obj;
  if (obj instanceof Date) return obj.toISOString();
  if (typeof obj === 'object' && obj !== null) {
    if (typeof obj.toDate === 'function') return obj.toDate().toISOString();
    if (typeof obj.toMillis === 'function') return new Date(obj.toMillis()).toISOString();
    if (Array.isArray(obj)) return obj.map(serializeTimestamps);
    const cleaned = {};
    for (const [k, v] of Object.entries(obj)) {
      cleaned[k] = serializeTimestamps(v);
    }
    return cleaned;
  }
  return obj;
};

const success = (res, data = null, message = 'Success', statusCode = 200) => {
  return res.status(statusCode).json({ success: true, message, data: serializeTimestamps(data) });
};

const error = (res, message = 'Server Error', statusCode = 500, errors = null) => {
  const body = { success: false, message };
  if (errors) body.errors = errors;
  return res.status(statusCode).json(body);
};

module.exports = { success, error };
