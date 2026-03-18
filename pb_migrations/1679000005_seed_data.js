/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const dao = new Dao(db);
  const usersCollection = dao.findCollectionByNameOrId("users");

  // Seed coach
  const coach = new Record(usersCollection);
  coach.setEmail("coach@clubhub.test");
  coach.setPassword("testtest123");
  coach.set("name", "Jan de Vries");
  coach.set("username", "coach_jan");
  coach.setVerified(true);
  dao.saveRecord(coach);

  // Seed speler 1
  const speler1 = new Record(usersCollection);
  speler1.setEmail("speler1@clubhub.test");
  speler1.setPassword("testtest123");
  speler1.set("name", "Pieter Bakker");
  speler1.set("username", "pieter_b");
  speler1.setVerified(true);
  dao.saveRecord(speler1);

  // Seed speler 2
  const speler2 = new Record(usersCollection);
  speler2.setEmail("speler2@clubhub.test");
  speler2.setPassword("testtest123");
  speler2.set("name", "Klaas Jansen");
  speler2.set("username", "klaas_j");
  speler2.setVerified(true);
  dao.saveRecord(speler2);

  // Seed team
  const teamsCollection = dao.findCollectionByNameOrId("teams");
  const team = new Record(teamsCollection);
  team.set("name", "Heren 1");
  team.set("ownerUid", coach.getId());
  team.set("sport", "Voetbal");
  team.set("seasonYear", 2026);
  team.set("memberUids", [coach.getId(), speler1.getId(), speler2.getId()]);
  team.set("inviteCode", "HRN1-2026");
  dao.saveRecord(team);

  // Seed events
  const eventsCollection = dao.findCollectionByNameOrId("events");
  const now = new Date();

  const eventData = [
    {
      title: "Training",
      type: "training",
      daysOffset: -3,
      location: "Sportpark Noord veld 2",
    },
    {
      title: "vs. FC Tegenstander",
      type: "wedstrijd",
      daysOffset: -1,
      location: "Sportpark Zuid",
    },
    {
      title: "Training",
      type: "training",
      daysOffset: 2,
      location: "Sportpark Noord veld 2",
    },
    {
      title: "Training",
      type: "training",
      daysOffset: 5,
      location: "Sportpark Noord veld 1",
    },
    {
      title: "vs. SV Rivaal",
      type: "wedstrijd",
      daysOffset: 8,
      location: "Sportpark Oost",
    },
  ];

  const events = [];
  for (const data of eventData) {
    const event = new Record(eventsCollection);
    const eventDate = new Date(now);
    eventDate.setDate(eventDate.getDate() + data.daysOffset);
    eventDate.setHours(19, 0, 0, 0);
    if (data.type === "wedstrijd") {
      eventDate.setHours(14, 30, 0, 0);
    }

    event.set("teamId", team.getId());
    event.set("title", data.title);
    event.set("type", data.type);
    event.set("dateTime", eventDate.toISOString());
    event.set("location", data.location);
    event.set("recurring", data.type === "training");
    dao.saveRecord(event);
    events.push(event);
  }

  // Seed attendances voor afgelopen events
  const attendancesCollection = dao.findCollectionByNameOrId("attendances");
  const players = [
    { record: coach, name: "Jan de Vries" },
    { record: speler1, name: "Pieter Bakker" },
    { record: speler2, name: "Klaas Jansen" },
  ];
  const statuses = ["aanwezig", "aanwezig", "afwezig", "onzeker", "aanwezig"];

  for (let i = 0; i < 2; i++) {
    for (let j = 0; j < players.length; j++) {
      const attendance = new Record(attendancesCollection);
      attendance.set("eventId", events[i].getId());
      attendance.set("userUid", players[j].record.getId());
      attendance.set("userName", players[j].name);
      attendance.set("status", statuses[(i * 3 + j) % statuses.length]);
      attendance.set("respondedAt", new Date().toISOString());
      if (statuses[(i * 3 + j) % statuses.length] === "afwezig") {
        attendance.set("reason", "Blessure");
      }
      dao.saveRecord(attendance);
    }
  }
}, (db) => {
  // Seed data cleanup not needed for development
});
