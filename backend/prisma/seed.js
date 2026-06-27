const prisma = require('./client');

async function main() {

    const admin = await prisma.user.create({
        data: {
            name: "Admin",
            email: "admin@ctt.com",
            password: "123456",
            role: "ADMIN"
        }
    });

    const user1 = await prisma.user.create({
        data: {
            name: "Student User",
            email: "user@ctt.com",
            password: "123456"
        }
    });

    const user2 = await prisma.user.create({
        data: {
            name: "Wilson A.",
            email: "wilson@gmail.com",
            password: "123456"
        }
    });

    const event1 = await prisma.event.create({
        data: {
            title: "Data Structures & Algorithms Tutoring",
            category: "tutoring",
            topic: "Algorithms",
            startDate: new Date("2026-06-12"),
            endDate: new Date("2026-06-12"),
            startTime: "18:00",
            endTime: "20:00"
        }
    });

    const event2 = await prisma.event.create({
        data: {
            title: "Cloud Computing with AWS",
            category: "seminar",
            topic: "Cloud Computing",
            startDate: new Date("2026-06-25"),
            endDate: new Date("2026-06-25"),
            startTime: "10:00",
            endTime: "12:00"
        }
    });

    const event3 = await prisma.event.create({
        data: {
            title: "Blockchain & Smart Contracts",
            category: "seminar",
            topic: "Blockchain",
            startDate: new Date("2026-06-22"),
            endDate: new Date("2026-06-22"),
            startTime: "16:00",
            endTime: "18:00"
        }
    });

    const event4 = await prisma.event.create({
        data: {
            title: "UI/UX Design Principles",
            category: "webinar",
            topic: "Design",
            startDate: new Date("2026-06-14"),
            endDate: new Date("2026-06-14"),
            startTime: "13:00",
            endTime: "15:00"
        }
    });

    await prisma.eventRequest.createMany({
        data: [
            {
                title: "Mobile App Development with React Native",
                category: "webinar",
                topic: "Mobile Development",
                description: "Build cross-platform mobile applications using React Native and modern tools.",
                startDate: new Date("2026-07-01"),
                endDate: new Date("2026-07-01"),
                startTime: "14:00",
                endTime: "16:00",
                userId: user1.id
            },
            {
                title: "Algoforge - Data Structure",
                category: "bootcamp",
                topic: "Data Structure",
                description: "Ga pernah jadi2",
                startDate: new Date("2026-06-10"),
                endDate: new Date("2026-06-10"),
                startTime: "09:00",
                endTime: "12:00",
                userId: user2.id
            }
        ]
    });

    await prisma.booking.create({
        data: {
            userId: user2.id,
            eventId: event1.id
        }
    });

    console.log("Seed completed");
}

main()
.then(async () => {
    await prisma.$disconnect();
})
.catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
});