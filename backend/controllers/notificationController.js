const prisma = require('../prisma/client');

const createNotification = async (req, res) => {
  try {

    console.log("CREATE NOTIFICATION HIT");
    console.log(req.body);

    const notification = await prisma.notification.create({
      data: {
        userId: req.user.id,
        title: req.body.title ?? "Notification",
        message: req.body.message,
        type: req.body.type ?? "SYSTEM"
      }
    });

    res.status(201).json(notification);

  } catch (err) {
    console.error(err);

    res.status(500).json({
      message: err.message
    });
  }
};

const getNotifications = async (req, res) => {

try {

    const notifications = await prisma.notification.findMany({

        where: {
            userId: req.user.id
        },

        orderBy: {
            createdAt: 'desc'
        }

    });

    res.json(notifications);

} catch (err) {

    res.status(500).json({
        message: err.message
    });

}

};

const markAsRead = async (req, res) => {

try {

    const notification = await prisma.notification.findFirst({

        where: {
            id: req.params.id,
            userId: req.user.id
        }

    });

    if (!notification) {

        return res.status(404).json({
            message: "Notification not found"
        });

    }

    await prisma.notification.update({

        where: {
            id: req.params.id
        },

        data: {
            isRead: true
        }

    });

    res.json({
        message: "Notification marked as read"
    });

} catch (err) {

    res.status(500).json({
        message: err.message
    });

}

};

const markAllAsRead = async (req, res) => {

try {

    await prisma.notification.updateMany({

        where: {
            userId: req.user.id,
            isRead: false
        },

        data: {
            isRead: true
        }

    });

    res.json({
        message: "All notifications marked as read"
    });

} catch (err) {

    res.status(500).json({
        message: err.message
    });

}

};

const unreadCount = async (req, res) => {

try {

    const count = await prisma.notification.count({

        where: {
            userId: req.user.id,
            isRead: false
        }

    });

    res.json({
        count
    });

} catch (err) {

    res.status(500).json({
        message: err.message
    });

}

};

module.exports = {
    createNotification,
    getNotifications,
    markAsRead,
    markAllAsRead,
    unreadCount
};