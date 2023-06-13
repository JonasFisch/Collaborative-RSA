defmodule AlgoThink.Classrooms.ClassroomToken do
alias AlgoThink.Classrooms


  @spec generateUniqueToken(integer) :: bitstring
  def generateUniqueToken(length) do
    token = generateToken(length)
    if nil != Classrooms.get_classroom_by_token(token) do
      ^token = generateUniqueToken(length)
    end
    token
  end

  @spec generateToken(integer) :: bitstring
  def generateToken(length) do
    raw_token = for _ <- 1..length, into: "", do: <<Enum.random('0123456789ABCDEF')>>
    String.upcase(raw_token)
  end
end
