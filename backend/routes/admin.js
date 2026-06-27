const express = require('express');
const router = express.Router();

const {
    getStats,
    getAllEvents,
    getAllUsers,
    deleteUser,
    getAllBookings,
    deleteBookingAdmin,
    getAllRequests,
    approveRequest,
    rejectRequest
} = require('../controllers/adminController');

const {
    auth,
    adminOnly
} = require('../middleware/auth');

router.get(
    '/stats',
    auth,
    adminOnly,
    getStats
);

router.get(
    '/events',
    auth,
    adminOnly,
    getAllEvents
);

router.get(
    '/users',
    auth,
    adminOnly,
    getAllUsers
);

router.delete(
    '/users/:id',
    auth,
    adminOnly,
    deleteUser
);

router.get(
    '/bookings',
    auth,
    adminOnly,
    getAllBookings
);

router.delete(
    '/bookings/:id',
    auth,
    adminOnly,
    deleteBookingAdmin
);

router.get(
    '/requests',
    auth,
    adminOnly,
    getAllRequests
);

router.patch(
    '/requests/:id/approve',
    auth,
    adminOnly,
    approveRequest
);

router.patch(
    '/requests/:id/reject',
    auth,
    adminOnly,
    rejectRequest
);

module.exports = router;