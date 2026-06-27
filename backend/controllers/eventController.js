const prisma = require('../prisma/client');

const getEvents = async (req, res) => {

try {

    const { search, category } = req.query;

    const events = await prisma.event.findMany({

        where: {

            AND: [

                search
                    ? {
                        title: {
                            contains: search,
                            mode: 'insensitive'
                        }
                    }
                    : {},

                category
                    ? {
                        category
                    }
                    : {}

            ]

        },

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

const getEventById = async (req, res) => {

try {

    const event = await prisma.event.findUnique({

        where: {
            id: req.params.id
        }

    });

    if (!event) {

        return res.status(404).json({
            message: "Event not found"
        });

    }

    res.json(event);

} catch (err) {

    res.status(500).json({
        message: err.message
    });

}

};

const createEvent = async (req, res) => {

try {

    const event = await prisma.event.create({

        data: req.body

    });

    res.status(201).json(event);

} catch (err) {

    res.status(500).json({
        message: err.message
    });

}

};

const updateEvent = async (req, res) => {

try {

    const existingEvent = await prisma.event.findUnique({

        where: {
            id: req.params.id
        }

    });

    if (!existingEvent) {

        return res.status(404).json({
            message: "Event not found"
        });

    }

    const updatedEvent = await prisma.event.update({

        where: {
            id: req.params.id
        },

        data: req.body

    });

    res.json(updatedEvent);

} catch (err) {

    res.status(500).json({
        message: err.message
    });

}

};

const deleteEvent = async (req, res) => {

try {

    const event = await prisma.event.findUnique({

        where: {
            id: req.params.id
        }

    });

    if (!event) {

        return res.status(404).json({
            message: "Event not found"
        });

    }

    await prisma.$transaction(async (tx) => {

        await tx.booking.deleteMany({

            where: {
                eventId: req.params.id
            }

        });

        await tx.event.delete({

            where: {
                id: req.params.id
            }

        });

    });

    res.json({
        message: "Event deleted"
    });

} catch (err) {

    res.status(500).json({
        message: err.message
    });

}

};

module.exports = {

getEvents,

getEventById,

createEvent,

updateEvent,

deleteEvent

};