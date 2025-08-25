defmodule Rockelivery.Users.Types do
  @moduledoc """
  Módulo para centralizar definições de tipos relacionados a usuários.
  Responsabilidade: Definir tipos reutilizáveis para validação e documentação.
  """

  # ===== TIPOS DE ENTRADA =====

  @type user_create_params :: %{
          name: String.t(),
          email: String.t(),
          age: pos_integer(),
          bio: String.t() | nil
        }

  @type user_update_params :: %{
          name: String.t() | nil,
          email: String.t() | nil,
          age: pos_integer() | nil,
          bio: String.t() | nil
        }

  # ===== TIPOS DE SAÍDA =====

  @type user_data :: %{
          id: pos_integer(),
          name: String.t(),
          email: String.t(),
          age: pos_integer(),
          bio: String.t() | nil,
          created_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @type success_response :: %{
          data: user_data(),
          message: String.t(),
          status: String.t(),
          timestamp: DateTime.t()
        }

  @type validation_error_response :: %{
          error: String.t(),
          details: map(),
          status: String.t(),
          timestamp: DateTime.t()
        }

  @type generic_error_response :: %{
          error: String.t(),
          details: String.t(),
          status: String.t(),
          timestamp: DateTime.t()
        }

  @type error_response :: validation_error_response() | generic_error_response()

  # ===== TIPOS DE RESULTADO =====

  @type validation_result ::
          {:ok, user_create_params() | user_update_params()} | {:error, Ecto.Changeset.t()}
  @type output_validation_result :: {:ok, user_data()} | {:error, Ecto.Changeset.t()}
  @type operation_result :: {:ok, user_data()} | {:error, atom()}

  # ===== FUNÇÕES AUXILIARES =====

  @doc """
  Constrói uma resposta de sucesso padronizada.
  """
  @spec build_success_response(user_data(), String.t()) :: success_response()
  def build_success_response(data, message) do
    %{
      data: data,
      message: message,
      status: "success",
      timestamp: DateTime.utc_now()
    }
  end

  @doc """
  Constrói uma resposta de erro de validação padronizada.
  """
  @spec build_validation_error_response(String.t(), Ecto.Changeset.t()) ::
          validation_error_response()
  def build_validation_error_response(error, changeset) do
    %{
      error: error,
      details: format_changeset_errors(changeset),
      status: "error",
      timestamp: DateTime.utc_now()
    }
  end

  @doc """
  Constrói uma resposta de erro genérico padronizada.
  """
  @spec build_generic_error_response(String.t(), String.t()) :: generic_error_response()
  def build_generic_error_response(error, details) do
    %{
      error: error,
      details: details,
      status: "error",
      timestamp: DateTime.utc_now()
    }
  end

  # ===== FUNÇÕES PRIVADAS =====

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
