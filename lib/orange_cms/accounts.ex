defmodule OrangeCms.Accounts do
  @moduledoc false
  use OrangeCms, :context

  alias OrangeCms.Accounts.User

  def list_users(filters \\ %{}), do: OrangeCms.Accounts.ListUsersUsecase.call(filters)

  def delete_user(user) do
    Repo.delete(user)
  end

  ## Database getters

  @doc """
  Gets a user by filter.

  ## Examples

      iex> find_user(email: "foo@example.com")
      {:ok, %User{}}

      iex> find_user(email: "unknown@example.com")
      {:error, :not_found}

  """
  def find_user(filters) do
    OrangeCms.Accounts.FindUserUsecase.call(filters)
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> authorize_user("foo@example.com", "correct_password")
      {:ok, %User{}}

      iex> authorize_user("foo@example.com", "invalid_password")
      {:error, :unauthorized}

  """
  def authorize_user(email, password), do: OrangeCms.Accounts.AuthorizeUserUsecase.call(email, password)

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def create_user(attrs), do: OrangeCms.Accounts.CreateUserUsecase.call(attrs)

  def update_user(%User{} = user, attrs), do: OrangeCms.Accounts.UpdateUserUsecase.call(user, attrs)

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs), do: OrangeCms.Accounts.RegisterUserUsecase.call(attrs)

  @doc """
  TODO: move to application layer
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false, validate_email: false)
  end

  ## Settings

  @doc """
  TODO: move to application layer
  Returns an `%Ecto.Changeset{}` for changing the user email.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, attrs \\ %{}) do
    User.email_changeset(user, attrs, validate_email: false)
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_user_email(user, token) do
    OrangeCms.Accounts.UpdateUserEmailUsecase.call(user, token)
  end

  @doc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/settings/confirm_email/#{&1})")
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_update_email_instructions(%User{} = user, password, attrs, update_email_url_fun) do
    OrangeCms.Accounts.SendUpdateEmailInstructionUsecase.call(user, password, attrs, update_email_url_fun)
  end

  @doc """
  TODO: move to application layer

  Returns an `%Ecto.Changeset{}` for changing the user password.

  ## Examples

      iex> change_user_password(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_password(user, attrs \\ %{}) do
    User.password_changeset(user, attrs, hash_password: false)
  end

  @doc """
  Updates the user password.

  ## Examples

      iex> update_user_password(user, "valid password", %{password: ...})
      {:ok, %User{}}

      iex> update_user_password(user, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(user, password, attrs) do
    OrangeCms.Accounts.UpdateUserPasswordUsecase.call(user, password, attrs)
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def log_in_user(user) do
    OrangeCms.Accounts.LogInUserUsecase.call(user)
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    OrangeCms.Accounts.GetUserBySessionTokenUsecase.call(token)
  end

  @doc """
  logout the user by the given token.
  """
  def logout_user(token) do
    OrangeCms.Accounts.LogoutUserUsecase.call(token)
  end

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given user.

  ## Examples

      iex> deliver_user_confirmation_instructions(user, &url(~p"/users/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_user_confirmation_instructions(confirmed_user, &url(~p"/users/confirm/#{&1}"))
      {:error, :already_confirmed}

  """
  def deliver_user_confirmation_instructions(email, confirmation_url_fun) do
    OrangeCms.Accounts.SendConfirmationInstructionUsecase.call(email, confirmation_url_fun)
  end

  @doc """
  Confirms a user by the given token.

  If the token matches, the user account is marked as confirmed
  and the token is deleted.
  """
  def confirm_user(token) do
    OrangeCms.Accounts.ConfirmUserUsecase.call(token)
  end

  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given user.

  ## Examples

      iex> deliver_user_reset_password_instructions(user, &url(~p"/users/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_reset_password_instructions(current_email, update_email_url_fun) do
    OrangeCms.Accounts.ForgotPasswordUsecase.call(current_email, update_email_url_fun)
  end

  @doc """
  Gets the user by reset password token.

  ## Examples

      iex> get_user_by_reset_password_token("validtoken")
      {:ok, %User{}}

      iex> get_user_by_reset_password_token("invalidtoken")
      {:error, :invalid_token}

  """
  def get_user_by_reset_password_token(token) do
    OrangeCms.Accounts.FindUserByResetPasswordTokenUsecase.call(token)
  end

  @doc """
  Resets the user password.

  ## Examples

      iex> reset_user_password(user, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %User{}}

      iex> reset_user_password(user, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_user_password(user, attrs), do: OrangeCms.Accounts.ResetUserPasswordUsecase.call(user, attrs)
end
