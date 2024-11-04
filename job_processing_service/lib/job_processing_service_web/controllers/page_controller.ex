defmodule JobProcessingServiceWeb.PageController do
  use JobProcessingServiceWeb, :controller

  def create(conn, %{"tasks" => tasks}) do
    with {:ok, task_to_process} <- JSON.decode(tasks),
         {:ok, result_commands, result_tasks} <-
           JobProcessingService.Processing.find_proper_execution(task_to_process) do
      IO.inspect(result_commands)

      conn
      |> json(%{bash_representation: result_commands, tasks: result_tasks})
    else
      {:error, :invalid_requirements} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "Error", errors: "invalid requirements were given in the tasks"})

      {:error, :invalid_list} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "Error", errors: "invalid list was given in the tasks"})

      {:error, _reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "Error", errors: "invalid JSON statement"})
    end
  end

  def create(conn, params) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{status: "Error", errors: "no tasks are given to the response"})
  end
end
