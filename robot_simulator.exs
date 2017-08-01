defmodule RobotSimulator do
  defstruct direction: nil, position: nil
  @valid_directions [:north, :east, :south, :west]
  @rotation_value %{left: -1, right: 1}
  @step_from_direction %{
    north: {0, 1},
    east: {1, 0},
    south: {0, -1},
    west: {-1, 0}
  }

  @doc """
  Create a Robot Simulator given an initial direction and position.

  Valid directions are: `:north`, `:east`, `:south`, `:west`
  """
  @spec create(direction :: atom, position :: { integer, integer }) :: any
  def create(direction \\ :north, position \\ { 0, 0 }) do
    cond do
      !is_valid_direction?(direction) -> { :error, "invalid direction" }
      !is_valid_position?(position) -> { :error, "invalid position" }
      true -> %RobotSimulator{direction: direction, position: position}
    end
  end

  defp is_valid_direction?(direction), do: Enum.member?(@valid_directions, direction)

  defp is_valid_position?({ x, y }) do
    is_integer(x) && is_integer(y)
  end
  defp is_valid_position?(_), do: false

  @doc """
  Simulate the robot's movement given a string of instructions.

  Valid instructions are: "R" (turn right), "L", (turn left), and "A" (advance)
  """
  @spec simulate(robot :: any, instructions :: String.t ) :: any
  def simulate(robot, instructions) do
    String.split(instructions, "", trim: true)
      |> Enum.reduce(robot, fn(instruction, acc) -> apply_next_instruction(acc, instruction) end)
  end

  defp apply_next_instruction({ :error, message }, _instruction), do: { :error, message } 

  defp apply_next_instruction(robot, "L") do
    %RobotSimulator{robot | direction: get_next_robot_direction(robot.direction, :left)}
  end

  defp apply_next_instruction(robot, "R") do
    %RobotSimulator{robot | direction: get_next_robot_direction(robot.direction, :right)}
  end

  defp apply_next_instruction(robot, "A") do
    %RobotSimulator{robot | position: get_next_robot_position(robot.position, @step_from_direction[robot.direction])}
  end

  defp apply_next_instruction(robot, _unknown_instruction), do: { :error, "invalid instruction" }

  defp get_next_robot_direction(current_direction, rotation) do
    Enum.find_index(@valid_directions, fn(direction) -> direction == current_direction end)
      |> next_index_formula(@rotation_value[rotation])
      |> get_direction_by_index
  end

  defp next_index_formula(index, rotation_value), do: rem(index + rotation_value + length(@valid_directions), length(@valid_directions))
  defp get_direction_by_index(index), do: Enum.at(@valid_directions, index)

  defp get_next_robot_position({x, y}, {delta_x, delta_y}) do
    {x + delta_x, y + delta_y}
  end

  @doc """
  Return the robot's direction.

  Valid directions are: `:north`, `:east`, `:south`, `:west`
  """
  @spec direction(robot :: any) :: atom
  def direction(robot) do
    robot.direction
  end

  @doc """
  Return the robot's position.
  """
  @spec position(robot :: any) :: { integer, integer }
  def position(robot) do
    robot.position
  end
end
