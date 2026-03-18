/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const collection = new Collection({
    id: "notifications",
    name: "notifications",
    type: "base",
    system: false,
    schema: [
      {
        name: "userId",
        type: "relation",
        required: true,
        options: { collectionId: "_pb_users_auth_", maxSelect: 1 },
      },
      {
        name: "title",
        type: "text",
        required: true,
        options: { max: 200 },
      },
      {
        name: "body",
        type: "text",
        options: { max: 1000 },
      },
      {
        name: "type",
        type: "select",
        required: true,
        options: { values: ["event_reminder", "attendance_request", "team_invite"] },
      },
      {
        name: "read",
        type: "bool",
      },
      {
        name: "data",
        type: "json",
      },
    ],
    indexes: [
      "CREATE INDEX idx_notifications_userId ON notifications (userId)",
      "CREATE INDEX idx_notifications_read ON notifications (userId, read)",
    ],
    listRule: '@request.auth.id != "" && userId = @request.auth.id',
    viewRule: '@request.auth.id != "" && userId = @request.auth.id',
    createRule: null,
    updateRule: '@request.auth.id != "" && userId = @request.auth.id',
    deleteRule: '@request.auth.id != "" && userId = @request.auth.id',
  });

  return Dao(db).saveCollection(collection);
}, (db) => {
  const dao = new Dao(db);
  const collection = dao.findCollectionByNameOrId("notifications");
  return dao.deleteCollection(collection);
});