defmodule JobProcessingService.Processing do
  @moduledoc false

  alias JobProcessingService.RequirementsChecker

  def find_proper_execution(tasks) when is_list(tasks) do
    if check_proper_requirements?(tasks) do
      find_proper_task_execution_queue(tasks)
    else
      {:error, :invalid_requirements}
    end
  end

  def find_proper_execution(tasks), do: {:error, :invalid_list}

  defp check_proper_requirements?(tasks) do
    all_task_names = Enum.map(tasks, fn task -> task["name"] end)

    all_requirements =
      tasks |> Enum.map(fn task -> task["requires"] end) |> Enum.reject(&is_nil/1)

    RequirementsChecker.check_requirements(all_task_names, all_requirements)
  end

  defp find_proper_task_execution_queue(
         [head | tail],
         result_commands \\ ["#!/usr/bin/env bash"],
         result_tasks \\ [],
         processed_tasks \\ []
       ) do
    if !head["requires"] ||
         RequirementsChecker.check_requirement(processed_tasks, head["requires"]) do
      result_commands = result_commands ++ [head["command"]]
      {_, task_without_requirement} = Map.pop(head, "requires")
      result_tasks = result_tasks ++ [task_without_requirement]
      processed_tasks = processed_tasks ++ [head["name"]]
      find_proper_task_execution_queue(tail, result_commands, result_tasks, processed_tasks)
    else
      {list, new_result_commands, new_result_tasks, new_processed_tasks} =
        find_proper_task_execution_queue_for_non_head_task(
          tail,
          result_commands,
          result_tasks,
          processed_tasks
        )

      find_proper_task_execution_queue(
        [head | list],
        new_result_commands,
        new_result_tasks,
        new_processed_tasks
      )
    end
  end

  defp find_proper_task_execution_queue([], result_commands, result_tasks, _processed_tasks),
    do: {:ok, Enum.join(result_commands, "
"), result_tasks}

  defp find_proper_task_execution_queue_for_non_head_task(
         [head | tail],
         result_commands,
         result_tasks,
         processed_tasks
       ) do
    if !head["requires"] ||
         RequirementsChecker.check_requirement(processed_tasks, head["requires"]) do
      result_commands = result_commands ++ [head["command"]]
      {_, task_without_requirement} = Map.pop(head, "requires")
      result_tasks = result_tasks ++ [task_without_requirement]
      processed_tasks = processed_tasks ++ [head["name"]]
      {tail, result_commands, result_tasks, processed_tasks}
    else
      {list, new_result_commands, new_result_tasks, new_processed_tasks} =
        find_proper_task_execution_queue_for_non_head_task(
          tail,
          result_commands,
          result_tasks,
          processed_tasks
        )

      find_proper_task_execution_queue(
        [head | list],
        new_result_commands,
        new_result_tasks,
        new_processed_tasks
      )
    end
  end
end
