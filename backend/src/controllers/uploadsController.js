const { success, error } = require('../utils/apiResponse');

const uploadFoodPhoto = async (req, res) => {
  try {
    if (!req.file) {
      return error(res, 'No file uploaded', 400);
    }
    const url = `/uploads/${req.file.filename}`;
    return success(res, { url }, 'File uploaded', 201);
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const uploadAvatar = async (req, res) => {
  try {
    if (!req.file) {
      return error(res, 'No file uploaded', 400);
    }
    const url = `/uploads/${req.file.filename}`;
    return success(res, { url }, 'Avatar uploaded', 201);
  } catch (err) {
    return error(res, err.message, 500);
  }
};

module.exports = { uploadFoodPhoto, uploadAvatar };
