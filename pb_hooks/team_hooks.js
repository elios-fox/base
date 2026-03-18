/// <reference path="../pb_data/types.d.ts" />

// Genereer unieke inviteCode bij nieuw team
onRecordBeforeCreateRequest((e) => {
  if (!e.record.get("inviteCode")) {
    const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    let code = "";
    for (let i = 0; i < 8; i++) {
      code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    e.record.set("inviteCode", code);
  }

  // Zorg dat de owner ook in memberUids zit
  const ownerUid = e.record.get("ownerUid");
  const memberUids = e.record.get("memberUids") || [];
  if (!memberUids.includes(ownerUid)) {
    memberUids.push(ownerUid);
    e.record.set("memberUids", memberUids);
  }
}, "teams");

// Stuur team_invite notificatie bij join
onRecordAfterUpdateRequest((e) => {
  const dao = new Dao($app.db());

  try {
    const oldMemberUids = e.record.originalCopy().get("memberUids") || [];
    const newMemberUids = e.record.get("memberUids") || [];

    // Vind nieuwe leden
    const addedUids = newMemberUids.filter((uid) => !oldMemberUids.includes(uid));

    if (addedUids.length > 0) {
      const teamName = e.record.get("name");
      const ownerUid = e.record.get("ownerUid");
      const notificationsCollection = dao.findCollectionByNameOrId("notifications");

      // Notificeer de coach
      for (const uid of addedUids) {
        const userRecord = dao.findRecordById("users", uid);
        const userName = userRecord.get("name") || userRecord.get("username");

        const notification = new Record(notificationsCollection);
        notification.set("userId", ownerUid);
        notification.set("title", "Nieuw teamlid");
        notification.set("body", `${userName} is toegetreden tot ${teamName}.`);
        notification.set("type", "team_invite");
        notification.set("read", false);
        notification.set("data", JSON.stringify({
          teamId: e.record.getId(),
          userId: uid,
        }));
        dao.saveRecord(notification);
      }
    }
  } catch (err) {
    console.log("Error sending team join notification:", err);
  }
}, "teams");

// Custom API route: POST /api/clubhub/teams/join
routerAdd("POST", "/api/clubhub/teams/join", (c) => {
  const data = $apis.requestInfo(c).data;
  const inviteCode = data.inviteCode;

  if (!inviteCode) {
    throw new BadRequestError("Uitnodigingscode is verplicht.");
  }

  const authRecord = c.get("authRecord");
  if (!authRecord) {
    throw new UnauthorizedError("Je moet ingelogd zijn.");
  }

  const dao = new Dao($app.db());

  // Zoek team op inviteCode
  let team;
  try {
    team = dao.findFirstRecordByFilter(
      "teams",
      `inviteCode = {:code}`,
      { code: inviteCode }
    );
  } catch (err) {
    throw new NotFoundError("Ongeldig uitnodigingscode.");
  }

  // Check of user al lid is
  const memberUids = team.get("memberUids") || [];
  if (memberUids.includes(authRecord.getId())) {
    throw new BadRequestError("Je bent al lid van dit team.");
  }

  // Voeg user toe aan team
  memberUids.push(authRecord.getId());
  team.set("memberUids", memberUids);
  dao.saveRecord(team);

  return c.json(200, {
    message: "Je bent toegetreden tot het team.",
    teamId: team.getId(),
    teamName: team.get("name"),
  });
}, $apis.requireRecordAuth());