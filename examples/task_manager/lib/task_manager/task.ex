defmodule TaskManager.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field(:title, :string)
    field(:status, :string, default: "todo")
    field(:priority, :integer, default: 2)

    timestamps(type: :utc_datetime)
  end

  @statuses ~w(todo in_progress done)
  @priorities [1, 2, 3]

  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :status, :priority])
    |> validate_required([:title])
    |> validate_inclusion(:status, @statuses)
    |> validate_inclusion(:priority, @priorities)
  end
end
