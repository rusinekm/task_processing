defmodule JobProcessingService.RequirementsChecker do
  @moduledoc false

  def check_requirements(task_names, requirement_list) do
    requirement_list
    |> Enum.map(fn requirement -> check_requirement(task_names, requirement) end)
    |> Enum.all?()
  end

  def check_requirement(task_names, requirement) do
    requirement
    |> Enum.map(fn requirement_task -> requirement_task in task_names end)
    |> Enum.all?()
  end
end
