defmodule RockeliveryWeb.UserCreateController do
  @moduledoc """
  Controller responsável APENAS pela criação de usuários.
  Princípio SOLID: Responsabilidade Única.
  """
  use RockeliveryWeb, :controller

  alias Rockelivery.Users.Schemas.UserCreateInput

  @doc """
  Cria um novo usuário.
  Responsabilidade: Receber request, validar entrada, retornar resposta.
  """
  # PATTERN MATCHING: Extrai os dados do usuário do body da requisição
  # %{"user" => user_params} significa:
  # - O body deve ter uma chave "user"
  # - O valor dessa chave será extraído para a variável user_params
  # - Se não existir a chave "user", esta função NÃO será executada
  # - Exemplo: {"user": {"name": "João", "email": "joao@email.com"}}
  #   Resultado: user_params = %{"name" => "João", "email" => "joao@email.com"}
  def create(conn, %{"user" => user_params}) do
    # 1. VALIDAÇÃO DE ENTRADA
    case validate_create_input(user_params) do
      {:ok, validated_params} ->
        # 2. SIMULAÇÃO DE CRIAÇÃO (sem banco de dados)
        case simulate_user_creation(validated_params) do
          {:ok, created_user} ->
            # 3. VALIDAÇÃO DE SAÍDA (simplificada)
            conn
            |> put_status(:created)
            |> json(build_success_response(created_user))

          {:error, reason} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(build_error_response("Erro na criação", reason))
        end

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(build_validation_error_response(changeset))
    end
  end

  # FALLBACK: Função executada quando o pattern matching falha
  # _params significa "qualquer outro parâmetro que não seja %{"user" => ...}"
  # Esta função é executada quando:
  # - O body está vazio: {}
  # - O body não tem a chave "user": {"name": "João"}
  # - O body tem estrutura incorreta: {"user": "string"}
  def create(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{
      error: "Parâmetros inválidos",
      details: "Esperado: %{user: %{name: string, email: string, age: integer, bio: string}}"
    })
  end

  # ===== FUNÇÕES PRIVADAS =====

  # VALIDAÇÃO DE ENTRADA: Valida os dados recebidos antes de processar
  # Esta função é responsável por:
  # 1. Criar um changeset com os dados recebidos
  # 2. Aplicar todas as validações definidas no schema
  # 3. Retornar os dados validados ou os erros encontrados
  defp validate_create_input(params) do
    # PASSO 1: Cria um changeset vazio e aplica os parâmetros recebidos
    # %UserCreateInput{} = struct vazia do EMBEDDED_SCHEMA
    # IMPORTANTE: O embedded_schema é usado AQUI para criar a struct base
    # params = dados do request (ex: %{"name" => "João", "email" => "joao@email.com"})
    # O changeset aplica automaticamente as validações definidas no embedded_schema
    changeset = UserCreateInput.changeset(%UserCreateInput{}, params)

    # PASSO 2: Verifica se o changeset é válido (passou em todas as validações)
    if changeset.valid? do
      # SUCESSO: Aplica as mudanças e retorna os dados validados
      # apply_changes/1 converte o changeset em um struct com os dados limpos
      # Exemplo: %UserCreateInput{name: "João", email: "joao@email.com", age: 25}
      # O embedded_schema garante que os tipos estejam corretos (age como integer)
      {:ok, Ecto.Changeset.apply_changes(changeset)}
    else
      # ERRO: Retorna o changeset com todos os erros de validação
      # O changeset contém detalhes sobre quais campos falharam e por quê
      # Exemplo: %{email: ["should be at least 5 character(s)"], age: ["must be greater than 0"]}
      {:error, changeset}
    end
  end

  # Simulação de criação (sem banco de dados)
  defp simulate_user_creation(validated_params) do
    # Simula um usuário criado com ID e timestamps
    created_user = %{
      id: :rand.uniform(10000),
      name: validated_params.name,
      email: validated_params.email,
      age: validated_params.age,
      bio: validated_params.bio,
      created_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }

    {:ok, created_user}
  end

  # Construção de resposta de sucesso
  defp build_success_response(user_output) do
    %{
      data: user_output,
      message: "Usuário criado com sucesso",
      status: "success",
      timestamp: DateTime.utc_now()
    }
  end

  # Construção de resposta de erro de validação
  defp build_validation_error_response(changeset) do
    %{
      error: "Dados de entrada inválidos",
      details: format_changeset_errors(changeset),
      status: "error",
      timestamp: DateTime.utc_now()
    }
  end

  # Construção de resposta de erro genérico
  defp build_error_response(message, details) do
    %{
      error: message,
      details: details,
      status: "error",
      timestamp: DateTime.utc_now()
    }
  end

  # Formatação de erros do changeset
  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      format_error_message(msg, opts)
    end)
  end

  # FORMATAÇÃO DE MENSAGEM DE ERRO: Substitui placeholders por valores reais
  # Esta função é responsável por tornar as mensagens de erro mais legíveis
  #
  # Parâmetros:
  # - msg = mensagem base com placeholders (ex: "should be at least %{min} character(s)")
  # - opts = lista de opções com chave-valor (ex: [min: 5, max: 255])
  #
  # Como funciona o Enum.reduce:
  # 1. opts = lista de opções para substituir
  # 2. msg = valor inicial (mensagem base)
  # 3. fn {key, value}, acc -> = função que processa cada opção
  # 4. acc = acumulador (mensagem sendo construída)
  #
  # EXEMPLO PRÁTICO:
  # msg = "should be at least %{min} character(s)"
  # opts = [min: 5, max: 255]
  #
  # ITERAÇÃO 1: {min: 5}
  # - key = :min, value = 5
  # - acc = "should be at least %{min} character(s)"
  # - Resultado: "should be at least 5 character(s)"
  #
  # ITERAÇÃO 2: {max: 255}
  # - key = :max, value = 255
  # - acc = "should be at least 5 character(s)"
  # - Resultado: "should be at least 5 character(s)" (não tem %{max})
  #
  # RESULTADO FINAL: "should be at least 5 character(s)"
  defp format_error_message(msg, opts) do
    # Enum.reduce/3: processa cada elemento da lista opts
    # - opts = lista de opções [min: 5, max: 255]
    # - msg = valor inicial (mensagem base)
    # - fn {key, value}, acc -> = função para cada iteração
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      # Para cada opção, substitui o placeholder na mensagem
      # key = :min, value = 5
      # acc = mensagem atual sendo construída
      replace_placeholder(acc, key, value)
    end)
  end

  # SUBSTITUIÇÃO DE PLACEHOLDER: Troca %{chave} pelo valor real
  # Esta função é responsável por fazer a substituição específica de um placeholder
  #
  # Parâmetros:
  # - message = mensagem atual (ex: "should be at least %{min} character(s)")
  # - key = chave do placeholder (ex: :min)
  # - value = valor para substituir (ex: 5)
  #
  # Como funciona:
  # 1. message = "should be at least %{min} character(s)"
  # 2. key = :min
  # 3. value = 5
  # 4. "%{#{key}}" = "%{min}" (interpolação de string)
  # 5. to_string(value) = "5" (converte para string)
  # 6. String.replace substitui "%{min}" por "5"
  #
  # EXEMPLO:
  # String.replace("should be at least %{min} character(s)", "%{min}", "5")
  # Resultado: "should be at least 5 character(s)"
  #
  # OUTROS EXEMPLOS:
  # - %{max} -> 255 → "should be at most 255 character(s)"
  # - %{count} -> 3 → "should be exactly 3 character(s)"
  defp replace_placeholder(message, key, value) do
    # String.replace/3: substitui uma substring por outra
    # - message = texto onde fazer a substituição
    # - "%{#{key}}" = padrão a ser encontrado (ex: "%{min}")
    # - to_string(value) = texto para substituir (ex: "5")
    String.replace(message, "%{#{key}}", to_string(value))
  end
end
