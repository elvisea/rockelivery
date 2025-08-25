defmodule RockeliveryWeb.Types do
  @moduledoc """
  Módulo centralizador de tipos para a aplicação

  Similar ao que você faria em TypeScript com arquivos .d.ts
  ou interfaces centralizadas.

  ## Equivalência TypeScript:
  ```typescript
  // types.ts
  export interface User {
    id: number;
    name: string;
    email: string;
    active: boolean;
  }

  export interface ApiResponse<T> {
    data: T;
    status: string;
    timestamp: string;
  }
  ```
  """

  # ===== TIPOS BÁSICOS =====

  @type user_id :: pos_integer()
  @type email :: String.t()
  @type timestamp :: DateTime.t()

  # ===== TIPOS DE ENTIDADES =====

  @type user :: %{
          id: user_id(),
          name: String.t(),
          email: email(),
          active: boolean(),
          created_at: timestamp()
        }

  @type product :: %{
          id: pos_integer(),
          name: String.t(),
          price: float(),
          category: String.t(),
          available: boolean()
        }

  # ===== TIPOS DE RESPOSTA DA API =====

  @type success_response(data_type) :: %{
          data: data_type,
          status: :ok,
          message: String.t(),
          timestamp: timestamp()
        }

  @type error_response :: %{
          error: String.t(),
          code: integer(),
          details: String.t() | nil,
          timestamp: timestamp()
        }

  @type api_response(data_type) :: success_response(data_type) | error_response()

  # ===== TIPOS DE ENTRADA (REQUEST) =====

  @type user_creation_params :: %{
          name: String.t(),
          email: email(),
          age: pos_integer()
        }

  @type user_update_params :: %{
          name: String.t() | nil,
          email: email() | nil,
          active: boolean() | nil
        }

  # ===== FUNÇÕES AUXILIARES PARA VALIDAÇÃO =====

  @doc """
  Valida se um mapa segue a estrutura de user_creation_params

  ## Exemplo:
  ```elixir
  case RockeliveryWeb.Types.validate_user_creation(%{"name" => "Elvis", "email" => "elvis@example.com", "age" => 30}) do
    {:ok, valid_params} -> # usar valid_params
    {:error, reason} -> # tratar erro
  end
  ```
  """
  @spec validate_user_creation(map()) :: {:ok, user_creation_params()} | {:error, String.t()}
  def validate_user_creation(%{"name" => name, "email" => email, "age" => age})
      when is_binary(name) and is_binary(email) and is_integer(age) and age > 0 do
    validated_params = %{
      name: String.trim(name),
      email: String.downcase(String.trim(email)),
      age: age
    }

    {:ok, validated_params}
  end

  def validate_user_creation(_params) do
    {:error,
     "Parâmetros inválidos: esperado %{name: string, email: string, age: positive_integer}"}
  end

  @doc """
  Constrói uma resposta de sucesso padronizada
  """
  @spec success_response(any(), String.t()) :: success_response(any())
  def success_response(data, message \\ "Operação realizada com sucesso") do
    %{
      data: data,
      status: :ok,
      message: message,
      timestamp: DateTime.utc_now()
    }
  end

  @doc """
  Constrói uma resposta de erro padronizada
  """
  @spec error_response(String.t(), integer(), String.t() | nil) :: error_response()
  def error_response(error, code \\ 400, details \\ nil) do
    %{
      error: error,
      code: code,
      details: details,
      timestamp: DateTime.utc_now()
    }
  end

  @doc """
  Exemplo de como usar guards para validação de tipos
  """
  @spec is_valid_email?(String.t()) :: boolean()
  def is_valid_email?(email) when is_binary(email) do
    email
    |> String.trim()
    |> String.match?(~r/^[^\s]+@[^\s]+\.[^\s]+$/)
  end

  def is_valid_email?(_), do: false
end
