const Donation = require('../models/Donation');
const Request = require('../models/Request');
const User = require('../models/User');
const { success, error } = require('../utils/apiResponse');

const getTracking = async (req, res) => {
  try {
    const { donationId } = req.params;

    const donation = await Donation.getById(donationId);
    if (!donation) return error(res, 'Donation not found', 404);

    const requests = await Request.getByDonationId(donationId);
    const activeRequest = requests.find(r => ['pending', 'accepted', 'picked_up'].includes(r.status));
    const completedRequest = requests.find(r => r.status === 'completed');

    const theRequest = activeRequest || completedRequest;

    const donor = await User.getById(donation.donorId);

    let ngoUser = null;
    if (theRequest) {
      ngoUser = await User.getById(theRequest.ngoId);
    }

    const pickupCoords = {
      lat: donation.latitude || 18.5204,
      lng: donation.longitude || 73.8567,
      address: donation.pickup_address || donation.pickupAddress || '',
    };

    let dropoffCoords = null;
    if (ngoUser && ngoUser.latitude && ngoUser.longitude) {
      dropoffCoords = {
        lat: ngoUser.latitude,
        lng: ngoUser.longitude,
        address: ngoUser.address || '',
      };
    }

    const timelineKeys = ['uploaded', 'accepted', 'picked_up', 'delivered'];
    const timelineLabels = {
      uploaded: 'Donation Uploaded',
      accepted: 'NGO Accepted',
      picked_up: 'Picked Up',
      delivered: 'Delivered',
    };

    const timeline = timelineKeys.map((key, index) => {
      let at = null;
      let done = false;
      let active = false;

      if (key === 'uploaded') {
        at = donation.created_at || donation.createdAt;
        done = true;
        active = true;
      }

      if (theRequest && theRequest.timeline) {
        const entry = theRequest.timeline.find(t => t.key === key);
        if (entry) {
          at = entry.at;
          done = entry.done;
          active = entry.active || false;
        }
      }

      return { key, label: timelineLabels[key], at: at || null, done, active };
    });

    return success(res, {
      donation: {
        id: donation._id,
        food_name: donation.food_name || donation.foodName,
        quantity: donation.quantity,
        unit: donation.unit,
        status: donation.status,
        photo_url: donation.photo_url || donation.photoUrl || null,
      },
      timeline,
      route: {
        pickup: pickupCoords,
        dropoff: dropoffCoords,
        driver_location: null,
        polyline: [],
      },
      contact: {
        name: donor ? donor.name : 'Unknown',
        role: 'Donor',
        phone: donor ? donor.phone : null,
        distance_km: null,
        avatar_url: donor ? (donor.avatar_url || null) : null,
      },
    }, 'Tracking data fetched');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

const updateLocation = async (req, res) => {
  try {
    const { id } = req.params;
    const { lat, lng } = req.body;

    if (lat === undefined || lng === undefined) {
      return error(res, 'lat and lng are required', 400);
    }

    return success(res, { lat: Number(lat), lng: Number(lng) }, 'Location updated');
  } catch (err) {
    return error(res, err.message, 500);
  }
};

module.exports = { getTracking, updateLocation };
