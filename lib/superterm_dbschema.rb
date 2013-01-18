class Superterm::Dbschema
  SCHEMA = {
    "tables" => {
      "Option" => {
        "columns" => [
          {"name" => "id", "type" => "int", "autoincr" => true, "primarykey" => true},
          {"name" => "title", "type" => "varchar"},
          {"name" => "value", "type" => "varchar"}
        ]
      }
    }
  }
end