/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const collection = new Collection({
    id: "events",
    name: "events",
    type: "base",
    system: false,
    schema: [
      {
        name: "teamId",
        type: "relation",
        required: true,
        options: { collectionId: "teams", maxSelect: 1, cascadeDelete: true },
      },
      {
        name: "title",
        type: "text",
        required: true,
        options: { min: 1, max: 200 },
      },
      {
        name: "type",
        type: "select",
        required: true,
        options: { values: ["training", "wedstrijd"] },
      },
      {
        name: "dateTime",
        type: "date",
        required: true,
      },
      {
        name: "endDateTime",
        type: "date",
      },
      {
        name: "location",
        type: "text",
        options: { max: 200 },
      },
      {
        name: "notes",
        type: "text",
        options: { max: 2000 },
      },
      {
        name: "recurring",
        type: "bool",
      },
      {
        name: "recurringPattern",
        type: "json",
      },
    ],
    indexes: [
      "CREATE INDEX idx_events_teamId ON events (teamId)",
      "CREATE INDEX idx_events_dateTime ON events (dateTime)",
    ],
    listRule: '@request.auth.id != ""',
    viewRule: '@request.auth.id != ""',
    createRule: '@request.auth.id != ""',
    updateRule: '@request.auth.id != ""',
    deleteRule: '@request.auth.id != ""',
  });

  return Dao(db).saveCollection(collection);
}, (db) => {
  const dao = new Dao(db);
  const collection = dao.findCollectionByNameOrId("events");
  return dao.deleteCollection(collection);
});