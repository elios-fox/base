/// <reference path="../pb_data/types.d.ts" />

// Stuur attendance_request notificatie naar alle teamleden bij nieuw event
onRecordAfterCreateRequest((e) => {
  const dao = new Dao($app.db());

  try {
    const teamRecord = dao.findRecordById("teams", e.record.get("teamId"));
    const memberUids = teamRecord.get("memberUids") || [];
    const eventTitle = e.record.get("title");
    const eventType = e.record.get("type");
    const typeLabel = eventType === "training" ? "Training" : "Wedstrijd";

    const notificationsCollection = dao.findCollectionByNameOrId("notifications");

    for (const memberUid of memberUids) {
      const notification = new Record(notificationsCollection);
      notification.set("userId", memberUid);
      notification.set("title", `Nieuwe ${typeLabel.toLowerCase()}`);
      notification.set("body", `${typeLabel}: ${eventTitle} — geef je beschikbaarheid door.`);
      notification.set("type", "attendance_request");
      notification.set("read", false);
      notification.set("data", JSON.stringify({
        eventId: e.record.getId(),
        teamId: teamRecord.getId(),
      }));
      dao.saveRecord(notification);
    }
  } catch (err) {
    console.log("Error sending event notifications:", err);
  }
}, "events");

// Cron: stuur event_reminder 24 uur voor het event
cronAdd("event_reminders", "0 * * * *", () => {
  const dao = new Dao($app.db());

  try {
    const now = new Date();
    const in24h = new Date(now.getTime() + 24 * 60 * 60 * 1000);
    const in25h = new Date(now.getTime() + 25 * 60 * 60 * 1000);

    // Zoek events die binnen 24-25 uur plaatsvinden
    const events = dao.findRecordsByFilter(
      "events",
      `dateTime >= {:start} && dateTime < {:end}`,
      "-dateTime",
      100,
      0,
      { start: in24h.toISOString(), end: in25h.toISOString() }
    );

    const notificationsCollection = dao.findCollectionByNameOrId("notifications");

    for (const event of events) {
      const teamRecord = dao.findRecordById("teams", event.get("teamId"));
      const memberUids = teamRecord.get("memberUids") || [];
      const eventTitle = event.get("title");
      const eventType = event.get("type");
      const typeLabel = eventType === "training" ? "Training" : "Wedstrijd";

      // Check welke leden nog niet gereageerd hebben
      const attendances = dao.findRecordsByFilter(
        "attendances",
        `eventId = {:eventId}`,
        "",
        100,
        0,
        { eventId: event.getId() }
      );
      const respondedUids = attendances.map((a) => a.get("userUid"));

      for (const memberUid of memberUids) {
        if (!respondedUids.includes(memberUid)) {
          const notification = new Record(notificationsCollection);
          notification.set("userId", memberUid);
          notification.set("title", "Herinnering");
          notification.set("body", `${typeLabel}: ${eventTitle} is morgen! Geef je beschikbaarheid door.`);
          notification.set("type", "event_reminder");
          notification.set("read", false);
          notification.set("data", JSON.stringify({
            eventId: event.getId(),
            teamId: teamRecord.getId(),
          }));
          dao.saveRecord(notification);
        }
      }
    }
  } catch (err) {
    console.log("Error in event reminder cron:", err);
  }
});