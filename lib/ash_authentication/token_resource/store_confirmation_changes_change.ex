defmodule AshAuthentication.TokenResource.StoreConfirmationChangesChange do
  @moduledoc """
  Populates the JTI based on the token argument.
  """

  use Ash.Resource.Change
  alias Ash.{Changeset, Error.Changes.InvalidArgument, Resource.Change}
  alias AshAuthentication.Jwt

  @doc false
  @impl true
  @spec change(Changeset.t(), keyword, Change.context()) :: Changeset.t()
  def change(changeset, _opts, _context) do
    with token when byte_size(token) > 0 <- Changeset.get_argument(changeset, :token),
         {:ok, %{"jti" => jti, "exp" => exp}} <- Jwt.peek(token),
         {:ok, expires_at} <- DateTime.from_unix(exp) do
      changeset
      |> Changeset.change_attributes(jti: jti, expires_at: expires_at)
    else
      _ ->
        changeset
        |> Changeset.add_error([
          InvalidArgument.exception(field: :token, message: "is not a valid token")
        ])
    end
  end
end
