defmodule AlgoThink.Classrooms.ClassroomToken do
  alias AlgoThink.Classrooms

  @spec generate_unique_token(integer) :: bitstring
  def generate_unique_token(length) do
    token = generate_token(length)

    if {:ok, nil} != Classrooms.get_classroom_by_token(token) do
      ^token = generate_unique_token(length)
    end

    token
  end

  @spec generate_token(integer) :: bitstring
  def generate_token(length) do
    raw_token = for _ <- 1..length, into: "", do: <<Enum.random('123456789ABCDEF')>>
    String.upcase(raw_token)
  end
end
