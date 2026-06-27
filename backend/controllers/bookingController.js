const prisma = require('../prisma/client');

const createBooking = async (req, res) => {

try {

    const { eventId } = req.body;

    const event = await prisma.event.findUnique({
        where: {
            id: eventId
        }
    });

    if (!event) {
        return res.status(404).json({
            message: "Event not found"
        });
    }

    if (
        event.capacity !== null &&
        event.currentParticipants >= event.capacity
    ) {
        return res.status(400).json({
            message: "Event full"
        });
    }

    const existing = await prisma.booking.findFirst({
        where: {
            userId: req.user.id,
            eventId
        }
    });

    if (existing) {
        return res.status(400).json({
            message: "Already booked"
        });
    }

    const booking = await prisma.$transaction(async (tx) => {

        const booking = await tx.booking.create({
            data: {
                userId: req.user.id,
                eventId
            }
        });

        await tx.event.update({
            where: {
                id: eventId
            },
            data: {
                currentParticipants: {
                    increment: 1
                }
            }
        });

        await tx.notification.create({
            data: {
                userId: req.user.id,
                title: "Booking Successful",
                message: `You successfully booked "${event.title}"`,
                type: "BOOKING"
            }
        });

        return booking;

    });

    res.status(201).json(booking);

} catch (err) {

    res.status(500).json({
        message: err.message
    });

}


};

const getMyBookings = async (req, res) => {


try {

    const bookings = await prisma.booking.findMany({

        where: {
            userId: req.user.id
        },

        include: {
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

const deleteBooking = async (req, res) => {

try {

    const booking = await prisma.booking.findFirst({

        where: {
            id: req.params.id,
            userId: req.user.id
        },

        include: {
            event: true
        }

    });

    if (!booking) {

        return res.status(404).json({
            message: "Booking not found"
        });

    }

    await prisma.$transaction(async (tx) => {

        await tx.booking.delete({
            where: {
                id: booking.id
            }
        });

        await tx.event.update({
            where: {
                id: booking.eventId
            },
            data: {
                currentParticipants: {
                    decrement: 1
                }
            }
        });

    });

    res.json({
        message: "Booking cancelled"
    });

} catch (err) {

    res.status(500).json({
        message: err.message
    });

}

};

module.exports = {
createBooking,
getMyBookings,
deleteBooking
};
