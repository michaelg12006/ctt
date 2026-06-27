const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');

const {
    createNotification,
    getNotifications,
    markAsRead,
    markAllAsRead,
    unreadCount
} = require('../controllers/notificationController');

router.get('/', auth, getNotifications);

router.patch('/read-all', auth, markAllAsRead);

router.patch('/:id', auth, markAsRead);

router.get('/unread-count', auth, unreadCount);

router.post('/', auth, createNotification);

module.exports = router;