/// <reference path="../pb_data/types.d.ts" />

// Valideer dat user lid is van het team voordat attendance wordt aangemaakt
onRecordBeforeCreateRequest((e) => {
  const dao = new Dao($app.db());
  const eventRecord = dao.findRecordById("events", e.record.get("eventId"));
  const teamRecord = dao.findRecordById("teams", eventRecord.get("teamId"));
  const memberUids = teamRecord.get("memberUids") || [];
  const userUid = e.record.get("userUid");

  if (!memberUids.includes(userUid)) {
    throw new BadRequestError("Je bent geen lid van dit team.");
  }

  // Set respondedAt automatisch
  e.record.set("respondedAt", new Date().toISOString());
}, "attendances");

// Notificeer de coach na een nieuwe attendance response
onRecordAfterCreateRequest((e) => {
  const dao = new Dao($app.db());

  try {
    const eventRecord = dao.findRecordById("events", e.record.get("eventId"));
    const teamRecord = dao.findRecordById("teams", eventRecord.get("teamId"));
    const coachUid = teamRecord.get("ownerUid");
    const userName = e.record.get("userName");
    const status = e.record.get("status");
    const eventTitle = eventRecord.get("title");

    const statusText = {
      aanwezig: "is aanwezig bij",
      afwezig: "is afwezig bij",
      onzeker: "is onzeker voor",
    };

    // Maak notificatie voor de coach
    const notificationsCollection = dao.findCollectionByNameOrId("notifications");
    const notification = new Record(notificationsCollection);
    notification.set("userId", coachUid);
    notification.set("title", "Reactie ontvangen");
    notification.set("body", `${userName} ${statusText[status] || "reageerde op"} ${eventTitle}`);
    notification.set("type", "attendance_request");
    notification.set("read", false);
    notification.set("data", JSON.stringify({
      eventId: eventRecord.getId(),
      attendanceId: e.record.getId(),
    }));
    dao.saveRecord(notification);
  } catch (err) {
    console.log("Error sending attendance notification:", err);
  }
}, "attendances");