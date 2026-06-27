const express = require('express');
const router = express.Router();

const { auth } = require('../middleware/auth');

const {
    createBooking,
    getMyBookings,
    deleteBooking
} = require('../controllers/bookingController');

router.post('/', auth, createBooking);

router.get('/my', auth, getMyBookings);

router.delete('/:id', auth, deleteBooking);

module.exports = router;