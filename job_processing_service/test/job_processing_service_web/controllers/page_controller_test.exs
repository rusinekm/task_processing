defmodule JobProcessingServiceWeb.PageControllerTest do
  use JobProcessingServiceWeb.ConnCase

  describe "POST /" do
    test "returns valid data, when valid input is given", %{conn: conn} do
      {_, json_data} =
        JSON.encode([
          %{"name" => "task-1", "command" => "touch /tmp/file1"},
          %{"name" => "task-2", "command" => "cat /tmp/file1", "requires" => ["task-3"]},
          %{
            "name" => "task-3",
            "command" => "echo 'Hello World!' > /tmp/file1",
            "requires" => ["task-1"]
          },
          %{"name" => "task-4", "command" => "rm /tmp/file1", "requires" => ["task-2", "task-3"]}
        ])

      params = %{"tasks" => json_data}

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/", params)

      assert response(conn, 200) =~
               "\"bash_representation\":\"#!/usr/bin/env bash\\n  touch /tmp/file1\\n  echo 'Hello World!' > /tmp/file1\\n  cat /tmp/file1\\n  rm /tmp/file1\""

      assert response(conn, 200) =~
               "\"tasks\":[{\"command\":\"touch /tmp/file1\",\"name\":\"task-1\"},{\"command\":\"echo 'Hello World!' > /tmp/file1\",\"name\":\"task-3\"},{\"command\":\"cat /tmp/file1\",\"name\":\"task-2\"},{\"command\":\"rm /tmp/file1\",\"name\":\"task-4\"}]"
    end

    test "returns error when impossible requirements are given", %{conn: conn} do
      {_, json_data} =
        JSON.encode([
          %{"name" => "task-1", "command" => "touch /tmp/file1"},
          %{"name" => "task-2", "command" => "cat /tmp/file1", "requires" => ["task-35"]},
          %{
            "name" => "task-3",
            "command" => "echo 'Hello World!' > /tmp/file1",
            "requires" => ["task-1"]
          },
          %{"name" => "task-4", "command" => "rm /tmp/file1", "requires" => ["task-2", "task-3"]}
        ])

      params = %{"tasks" => json_data}

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/", params)

      assert response(conn, 422) =~
               "{\"status\":\"Error\",\"errors\":\"invalid requirements were given in the tasks\"}"
    end

    test "returns error when invalid input is given", %{conn: conn} do
      {_, json_data} =
        JSON.encode([
          %{"name" => "task-1", "command" => "touch /tmp/file1"},
          %{"name" => "task-2", "command" => "cat /tmp/file1", "requires" => ["task-3"]},
          %{
            "name" => "task-3",
            "command" => "echo 'Hello World!' > /tmp/file1",
            "requires" => ["task-1"]
          },
          %{"name" => "task-4", "command" => "rm /tmp/file1", "requires" => ["task-2", "task-3"]}
        ])

      params = %{"wrong_key_that_is_not_processed" => json_data}

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/", params)

      assert response(conn, 422) =~
               "{\"status\":\"Error\",\"errors\":\"no tasks are given to the response\"}"
    end
  end
end
