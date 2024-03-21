bring ex;
bring cloud;

let tasks = new ex.Table(
  name: "Tasks",
  columns: {
    "id" => ex.ColumnType.STRING,
    "title" => ex.ColumnType.STRING
  },
  primaryKey: "id"
) as "taskTable";
let counter = new cloud.Counter();
let api = new cloud.Api();
let path = "/tasks";

api.get(
  path,
  inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
    let rows = tasks.list();
    let var result = MutArray<Json>[];
    for row in rows {
      result.push(row);
    }
    return cloud.ApiResponse{
      status: 200,
      headers: {
        "Content-Type" => "application/json"
      },
      body: Json.stringify(result)
    };
  });

api.post(
  path,
  inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
    if let task = Json.tryParse(request.body) {
      let id = "{counter.inc()}";
      let record = Json{
        id: id,
        title: task.get("title").asStr()
      };
      tasks.insert(id, record);
      return cloud.ApiResponse {
        status: 200,
        headers: {
          "Content-Type" => "application/json"
        },
        body: Json.stringify(record)
      };
    } else {
      return cloud.ApiResponse {
        status: 400,
        headers: {
          "Content-Type" => "text/plain"
        },
        body: "Bad Request"
      };
    }
  }
);
  
api.put(
  "{path}/:id",
  inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
    let id = request.vars.get("id");
    if let task = Json.tryParse(request.body) {
      let record = Json{
        id: id,
        title: task.get("title").asStr()
      };
      tasks.update(id, record);
      return cloud.ApiResponse {
        status: 200,
        headers: {
          "Content-Type" => "application/json"
        },
        body: Json.stringify(record)
      };
    } else {
      return cloud.ApiResponse {
        status: 400,
        headers: {
          "Content-Type" => "text/plain"
        },
        body: "Bad Request"
      };
    }
  });

api.delete(
"{path}/:id",
inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
  let id = request.vars.get("id");
  tasks.delete(id);
  return cloud.ApiResponse {
    status: 200,
    headers: {
      "Content-Type" => "text/plain"
    },
    body: ""
  };
});
