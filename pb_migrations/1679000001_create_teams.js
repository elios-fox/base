/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const collection = new Collection({
    id: "teams",
    name: "teams",
    type: "base",
    system: false,
    schema: [
      {
        name: "name",
        type: "text",
        required: true,
        options: { min: 1, max: 100 },
      },
      {
        name: "ownerUid",
        type: "relation",
        required: true,
        options: { collectionId: "_pb_users_auth_", maxSelect: 1 },
      },
      {
        name: "sport",
        type: "text",
        options: { max: 50 },
      },
      {
        name: "seasonYear",
        type: "number",
        options: { min: 2020, max: 2100 },
      },
      {
        name: "memberUids",
        type: "relation",
        options: { collectionId: "_pb_users_auth_", maxSelect: null },
      },
      {
        name: "inviteCode",
        type: "text",
        options: { min: 6, max: 10 },
      },
    ],
    indexes: [
      "CREATE UNIQUE INDEX idx_teams_inviteCode ON teams (inviteCode)",
    ],
    listRule: '@request.auth.id != "" && memberUids.id ?= @request.auth.id',
    viewRule: '@request.auth.id != "" && memberUids.id ?= @request.auth.id',
    createRule: '@request.auth.id != ""',
    updateRule: '@request.auth.id != "" && ownerUid = @request.auth.id',
    deleteRule: '@request.auth.id != "" && ownerUid = @request.auth.id',
  });

  return Dao(db).saveCollection(collection);
}, (db) => {
  const dao = new Dao(db);
  const collection = dao.findCollectionByNameOrId("teams");
  return dao.deleteCollection(collection);
});