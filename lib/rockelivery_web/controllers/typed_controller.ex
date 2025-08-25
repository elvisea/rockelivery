defmodule RockeliveryWeb.TypedController do
  @moduledoc """
  Controller demonstrando diferentes formas de tipagem no Phoenix/Elixir

  ## COMPARAÇÃO: TypeScript vs Elixir

  ### TypeScript/Node.js:
  ```typescript
  interface UserResponse {
    id: number;
    name: string;
    email: string;
    active: boolean;
  }

  interface ErrorResponse {
    error: string;
    code: number;
  }

  app.get('/users/:id', (req, res): UserResponse | ErrorResponse => {
    // TypeScript garante que o retorno segue a interface
    return { id: 1, name: "Elvis", email: "elvis@example.com", active: true };
  });
  ```

  ### Phoenix/Elixir - Várias abordagens:
  1. **@type + @spec** (mais próximo do TypeScript)
  2. **Structs** (tipos estruturados)
  3. **Pattern matching** (validação em tempo de execução)
  4. **Ecto schemas** (para dados de banco)
  """

  use RockeliveryWeb, :controller

  # Importa tipos centralizados
  alias RockeliveryWeb.Types

  # ===== ABORDAGEM 1: TYPESPECS (@type + @spec) =====
  # Equivalente mais próximo das interfaces TypeScript

  @type user_response :: %{
          id: integer(),
          name: String.t(),
          email: String.t(),
          active: boolean(),
          created_at: DateTime.t()
        }

  @type error_response :: %{
          error: String.t(),
          code: integer(),
          details: String.t() | nil
        }

  @type api_response :: user_response() | error_response()

  # @spec define que a função retorna Plug.Conn.t() (sempre no Phoenix)
  # mas podemos documentar o JSON retornado nos comentários
  @spec get_user_typed(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def get_user_typed(conn, %{"id" => id}) do
    IO.puts("\n=== ABORDAGEM 1: TYPESPECS ===")
    IO.inspect(@type, label: "🏷️  TYPES definidos no módulo")

    # Simula busca de usuário
    user_data = %{
      id: String.to_integer(id),
      name: "Elvis Presley",
      email: "elvis@graceland.com",
      active: true,
      created_at: DateTime.utc_now()
    }

    # Retorno segue o tipo user_response definido acima
    json(conn, user_data)
  end

  # ===== ABORDAGEM 2: STRUCTS (Tipos estruturados) =====
  # Structs garantem estrutura e permitem validação

  defmodule UserStruct do
    @moduledoc "Struct que define a estrutura de um usuário"

    # Campos obrigatórios
    @enforce_keys [:id, :name, :email]
    defstruct [
      :id,
      :name,
      :email,
      # Valor padrão
      active: true,
      created_at: nil,
      metadata: %{}
    ]

    @type t :: %__MODULE__{
            id: integer(),
            name: String.t(),
            email: String.t(),
            active: boolean(),
            created_at: DateTime.t() | nil,
            metadata: map()
          }
  end

  @spec get_user_struct(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def get_user_struct(conn, %{"id" => id}) do
    IO.puts("\n=== ABORDAGEM 2: STRUCTS ===")

    # Cria struct garantindo tipo e estrutura
    user = %UserStruct{
      id: String.to_integer(id),
      name: "Elvis Presley",
      email: "elvis@graceland.com",
      active: true,
      created_at: DateTime.utc_now(),
      metadata: %{source: "api", version: "1.0"}
    }

    IO.inspect(user, label: "👤 USER STRUCT criado")
    IO.inspect(user.__struct__, label: "🏗️  STRUCT TYPE")

    # Converte struct para mapa para JSON
    json(conn, Map.from_struct(user))
  end

  # ===== ABORDAGEM 3: PATTERN MATCHING + GUARDS =====
  # Validação em tempo de execução

  @spec create_user_validated(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create_user_validated(conn, %{
        "user" => %{
          "name" => name,
          "email" => email,
          "age" => age
        }
      })
      when is_binary(name) and is_binary(email) and is_integer(age) and age > 0 do
    IO.puts("\n=== ABORDAGEM 3: PATTERN MATCHING + GUARDS ===")
    IO.puts("✅ Validação passou: name=#{name}, email=#{email}, age=#{age}")

    user_response = %{
      id: :rand.uniform(1000),
      name: name,
      email: email,
      age: age,
      status: "created",
      created_at: DateTime.utc_now()
    }

    conn
    |> put_status(:created)
    |> json(user_response)
  end

  # Fallback para dados inválidos
  def create_user_validated(conn, params) do
    IO.puts("\n=== PATTERN MATCHING FALHOU ===")
    IO.inspect(params, label: "❌ PARAMS inválidos recebidos")

    error_response = %{
      error: "Dados inválidos",
      code: 400,
      details: "Formato esperado: {user: {name: string, email: string, age: integer}}",
      received: params
    }

    conn
    |> put_status(:bad_request)
    |> json(error_response)
  end

  # ===== ABORDAGEM 4: FUNÇÃO AUXILIAR DE VALIDAÇÃO =====

  @spec get_user_with_validation(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def get_user_with_validation(conn, %{"id" => id}) do
    IO.puts("\n=== ABORDAGEM 4: VALIDAÇÃO CUSTOMIZADA ===")

    case validate_and_build_user_response(id) do
      {:ok, user_data} ->
        IO.puts("✅ Usuário validado com sucesso")
        json(conn, user_data)

      {:error, reason} ->
        IO.puts("❌ Erro na validação: #{reason}")

        error_response = %{
          error: reason,
          code: 400,
          details: "ID deve ser um número positivo"
        }

        conn
        |> put_status(:bad_request)
        |> json(error_response)
    end
  end

  # Função privada de validação que retorna tipos específicos
  @spec validate_and_build_user_response(String.t()) ::
          {:ok, user_response()} | {:error, String.t()}
  defp validate_and_build_user_response(id_string) do
    case Integer.parse(id_string) do
      {id, ""} when id > 0 ->
        user_data = %{
          id: id,
          name: "Elvis Presley",
          email: "elvis@graceland.com",
          active: true,
          created_at: DateTime.utc_now()
        }

        {:ok, user_data}

      _ ->
        {:error, "ID inválido: deve ser um número positivo"}
    end
  end

  # ===== ABORDAGEM 5: TIPOS CENTRALIZADOS =====

  @spec create_user_with_centralized_types(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create_user_with_centralized_types(conn, params) do
    IO.puts("\n=== ABORDAGEM 5: TIPOS CENTRALIZADOS ===")
    IO.inspect(params, label: "📥 PARAMS recebidos")

    case Types.validate_user_creation(params) do
      {:ok, valid_params} ->
        IO.puts("✅ Validação passou com tipos centralizados")
        IO.inspect(valid_params, label: "✨ PARAMS validados")

        # Simula criação do usuário
        user_data = %{
          id: :rand.uniform(1000),
          name: valid_params.name,
          email: valid_params.email,
          active: true,
          created_at: DateTime.utc_now()
        }

        response = Types.success_response(user_data, "Usuário criado com sucesso!")

        conn
        |> put_status(:created)
        |> json(response)

      {:error, reason} ->
        IO.puts("❌ Validação falhou: #{reason}")

        response = Types.error_response(reason, 400, "Verifique os dados enviados")

        conn
        |> put_status(:bad_request)
        |> json(response)
    end
  end

  # ===== FUNÇÃO DE COMPARAÇÃO COM TYPESCRIPT =====

  @doc """
  Compara as diferentes abordagens de tipagem
  """
  def compare_typing_approaches(conn, _params) do
    comparison = %{
      typescript: %{
        interfaces: "Define estrutura em tempo de compilação",
        runtime_safety: false,
        exemplo: "interface UserResponse { id: number; name: string; }"
      },
      elixir_typespecs: %{
        definicao: "@type user_response :: %{id: integer(), name: String.t()}",
        runtime_safety: false,
        uso: "Documentação + análise estática com Dialyzer"
      },
      elixir_structs: %{
        definicao: "defstruct [:id, :name, :email]",
        runtime_safety: true,
        uso: "Estrutura garantida + pattern matching"
      },
      elixir_pattern_matching: %{
        definicao: "def func(conn, %{\"name\" => name}) when is_binary(name)",
        runtime_safety: true,
        uso: "Validação automática na assinatura da função"
      },
      elixir_custom_validation: %{
        definicao: "Funções que retornam {:ok, data} | {:error, reason}",
        runtime_safety: true,
        uso: "Validação explícita com tipos de retorno"
      }
    }

    json(conn, %{
      message: "Comparação de abordagens de tipagem",
      approaches: comparison,
      recomendacao: "Use structs + pattern matching para máxima segurança em runtime"
    })
  end
end
