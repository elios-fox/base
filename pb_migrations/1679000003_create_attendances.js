/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const collection = new Collection({
    id: "attendances",
    name: "attendances",
    type: "base",
    system: false,
    schema: [
      {
        name: "eventId",
        type: "relation",
        required: true,
        options: { collectionId: "events", maxSelect: 1, cascadeDelete: true },
      },
      {
        name: "userUid",
        type: "relation",
        required: true,
        options: { collectionId: "_pb_users_auth_", maxSelect: 1 },
      },
      {
        name: "userName",
        type: "text",
        required: true,
        options: { max: 100 },
      },
      {
        name: "status",
        type: "select",
        required: true,
        options: { values: ["aanwezig", "afwezig", "onzeker"] },
      },
      {
        name: "reason",
        type: "text",
        options: { max: 500 },
      },
      {
        name: "respondedAt",
        type: "date",
      },
    ],
    indexes: [
      "CREATE INDEX idx_attendances_eventId ON attendances (eventId)",
      "CREATE UNIQUE INDEX idx_attendances_event_user ON attendances (eventId, userUid)",
    ],
    listRule: '@request.auth.id != ""',
    viewRule: '@request.auth.id != ""',
    createRule: '@request.auth.id != "" && @request.auth.id = userUid',
    updateRule: '@request.auth.id != "" && @request.auth.id = userUid',
    deleteRule: '@request.auth.id != "" && @request.auth.id = userUid',
  });

  return Dao(db).saveCollection(collection);
}, (db) => {
  const dao = new Dao(db);
  const collection = dao.findCollectionByNameOrId("attendances");
  return dao.deleteCollection(collection);
});