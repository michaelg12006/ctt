const prisma = require('../prisma/client');

const createRequest = async (req, res) => {
  try {

    const request = await prisma.eventRequest.create({
      data: {
        title: req.body.title,
        description: req.body.description || null,
        imageUrl: req.body.imageUrl || null,
        category: req.body.category,
        topic: req.body.topic || null,

        startDate: new Date(req.body.startDate),
        endDate: new Date(req.body.endDate),

        startTime: req.body.startTime || null,
        endTime: req.body.endTime || null,

        userId: req.user.id
      }
    });

    await prisma.notification.create({
        data: {
            userId: req.user.id,
            title: "Request Submitted",
            message: `Your request "${request.title}" has been submitted`,
            type: "SYSTEM"
        }
    });

    res.status(201).json(request);

  } catch (err) {

    console.error(err);

    res.status(500).json({
      message: err.message
    });

  }
};

const getMyRequests = async (req, res) => {

try {

    const requests = await prisma.eventRequest.findMany({

        where: {
            userId: req.user.id
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

const updateRequest = async (req, res) => {

try {

    const request = await prisma.eventRequest.findFirst({

        where: {
            id: req.params.id,
            userId: req.user.id
        }

    });

    if (!request) {

        return res.status(404).json({
            message: "Request not found"
        });

    }

    if (request.status !== "PENDING") {

        return res.status(400).json({
            message: "Only pending requests can be updated"
        });

    }

    const updatedRequest = await prisma.eventRequest.update({

        where: {
            id: req.params.id
        },

        data: req.body

    });

    res.json(updatedRequest);

} catch (err) {

    res.status(500).json({
        message: err.message
    });

}

};

const deleteRequest = async (req, res) => {

try {

    const request = await prisma.eventRequest.findFirst({

        where: {
            id: req.params.id,
            userId: req.user.id
        }

    });

    if (!request) {

        return res.status(404).json({
            message: "Request not found"
        });

    }

    if (request.status !== "PENDING") {

        return res.status(400).json({
            message: "Only pending requests can be deleted"
        });

    }

    await prisma.eventRequest.delete({

        where: {
            id: req.params.id
        }

    });

    res.json({
        message: "Request deleted"
    });

} catch (err) {

    res.status(500).json({
        message: err.message
    });

}

};

module.exports = {

createRequest,

getMyRequests,

updateRequest,

deleteRequest

};