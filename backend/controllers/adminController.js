const prisma = require('../prisma/client');

const getStats = async (req, res) => {

try {

    const [
        totalEvents,
        totalUsers,
        totalBookings,
        pendingRequests
    ] = await Promise.all([

        prisma.event.count(),

        prisma.user.count(),

        prisma.booking.count(),

        prisma.eventRequest.count({
            where: {
                status: "PENDING"
            }
        })

    ]);

    res.json({
        totalEvents,
        totalUsers,
        totalBookings,
        pendingRequests
    });

} catch (err) {

    res.status(500).json({
        message: err.message
    });

}

};

const getAllEvents = async (req, res) => {

try {

    const events = await prisma.event.findMany({

        orderBy: {
            createdAt: 'desc'
        }

    });

    res.json(events);

} catch (err) {

    res.status(500).json({
        message: err.message
    });

}

};

const getAllUsers = async (req, res) => {

try {

    const users = await prisma.user.findMany({

        select: {
            id: true,
            name: true,
            email: true,
            role: true,
            createdAt: true
        },

        orderBy: {
            createdAt: 'desc'
        }

    });

    res.json(users);

} catch (err) {

    res.status(500).json({
        message: err.message
    });

}

};

const deleteUser = async (req, res) => {

try {

    const user = await prisma.user.findUnique({

        where: {
            id: req.params.id
        }

    });

    if (!user) {

        return res.status(404).json({
            message: "User not found"
        });

    }

    await prisma.user.delete({

        where: {
            id: req.params.id
        }

    });

    res.json({
        message: "User deleted"
    });

} catch (err) {

    res.status(500).json({
        message: err.message
    });

}

};

const getAllBookings = async (req, res) => {

try {

    const bookings = await prisma.booking.findMany({

        include: {

            user: {
                select: {
                    name: true,
                    email: true
                }
            },

            event: true

        },

        orderBy: {
            createdAt: 'desc'
        }

    });

    res.json(bookings);

} catch (err) {

    res.status(500).json({
        message: err.message
    });

}

};

const deleteBookingAdmin = async (req, res) => {

try {

    const booking = await prisma.booking.findUnique({

        where: {
            id: req.params.id
        }

    });

    if (!booking) {

        return res.status(404).json({
            message: "Booking not found"
        });

    }

    await prisma.booking.delete({

        where: {
            id: req.params.id
        }

    });

    res.json({
        message: "Booking deleted"
    });

} catch (err) {

    res.status(500).json({
        message: err.message
    });

}

};

const getAllRequests = async (req, res) => {

try {

    const requests = await prisma.eventRequest.findMany({

        include: {

            user: {
                select: {
                    name: true,
                    email: true
                }
            }

        },

        orderBy: {
            createdAt: 'desc'
        }

    });

    res.json(requests);

} catch (err) {

    res.status(500).json({
        message: err.message
    });

}

};

const approveRequest = async (req, res) => {

try {

    const request = await prisma.eventRequest.findUnique({

        where: {
            id: req.params.id
        }

    });

    if (!request) {

        return res.status(404).json({
            message: "Request not found"
        });

    }

    if (request.status !== "PENDING") {

        return res.status(400).json({
            message: "Request already processed"
        });

    }

    const event = await prisma.$transaction(async (tx) => {

        const event = await tx.event.create({

            data: {

                title: request.title,
                description: request.description,
                imageUrl: request.imageUrl,
                category: request.category,
                topic: request.topic,
                location: request.location,
                startDate: request.startDate,
                endDate: request.endDate,
                startTime: request.startTime,
                endTime: request.endTime

            }

        });

        await tx.eventRequest.update({
            where: {
                id: request.id
            },
            data: {
                status: "APPROVED"
            }
        });

        await tx.notification.create({
            data: {
                userId: request.userId,
                title: "Request Approved",
                message: `Your request "${request.title}" has been approved`,
                type: "APPROVAL"
            }
        });

        return event;

    });

    res.json({
        message: "Event approved",
        event
    });

} catch (err) {

    res.status(500).json({
        message: err.message
    });

}

};

const rejectRequest = async (req, res) => {

try {

    const request = await prisma.eventRequest.findUnique({

        where: {
            id: req.params.id
        }

    });

    if (!request) {

        return res.status(404).json({
            message: "Request not found"
        });

    }

    await prisma.eventRequest.update({
        where: {
            id: req.params.id
        },
        data: {
            status: "REJECTED"
        }
    });

    await prisma.notification.create({
        data: {
            userId: request.userId,
            title: "Request Rejected",
            message: `Your request "${request.title}" has been rejected`,
            type: "REJECTION"
        }
    });

    res.json({
        message: "Request rejected"
    });

} catch (err) {

    res.status(500).json({
        message: err.message
    });

}

};

module.exports = {

getStats,

getAllEvents,

getAllUsers,

deleteUser,

getAllBookings,

deleteBookingAdmin,

getAllRequests,

approveRequest,

rejectRequest

};