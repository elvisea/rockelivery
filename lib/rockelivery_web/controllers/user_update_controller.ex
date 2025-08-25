defmodule RockeliveryWeb.UserUpdateController do
  @moduledoc """
  Controller responsável APENAS pela edição de usuários.
  Princípio SOLID: Responsabilidade Única.
  """
  use RockeliveryWeb, :controller

  alias Rockelivery.Users.Schemas.UserUpdateInput

  @doc """
  Atualiza um usuário existente.
  Responsabilidade: Receber request, validar entrada, retornar resposta.
  """
  # PATTERN MATCHING: Extrai o ID da URL e os dados do usuário do body
  # %{"id" => id, "user" => user_params} significa:
  # - O body deve ter uma chave "id" (vinda da URL /api/users/123)
  # - O body deve ter uma chave "user" com os dados para atualizar
  # - Se qualquer uma das chaves não existir, esta função NÃO será executada
  # - Exemplo: {"id": "123", "user": {"name": "João Atualizado"}}
  #   Resultado: id = "123", user_params = %{"name" => "João Atualizado"}
  def update(conn, %{"id" => id, "user" => user_params}) do
    # 1. VALIDAÇÃO DO ID
    case validate_id(id) do
      {:ok, user_id} ->
        # 2. VALIDAÇÃO DE ENTRADA
        case validate_update_input(user_params) do
          {:ok, validated_params} ->
            # 3. SIMULAÇÃO DE ATUALIZAÇÃO (sem banco de dados)
            case simulate_user_update(user_id, validated_params) do
              {:ok, updated_user} ->
                # 4. VALIDAÇÃO DE SAÍDA (simplificada)
                conn
                |> put_status(:ok)
                |> json(build_success_response(updated_user))

              {:error, :user_not_found} ->
                conn
                |> put_status(:not_found)
                |> json(build_error_response("Usuário não encontrado", "ID: #{user_id}"))

              {:error, reason} ->
                conn
                |> put_status(:unprocessable_entity)
                |> json(build_error_response("Erro na atualização", reason))
            end

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(build_validation_error_response(changeset))
        end

      {:error, :invalid_id} ->
        conn
        |> put_status(:bad_request)
        |> json(build_error_response("ID inválido", "O ID deve ser um número inteiro válido"))
    end
  end

  # FALLBACK: Função executada quando o pattern matching falha
  # _params significa "qualquer outro parâmetro que não seja %{"id" => ..., "user" => ...}"
  # Esta função é executada quando:
  # - O body está vazio: {}
  # - O body não tem a chave "id": {"user": {"name": "João"}}
  # - O body não tem a chave "user": {"id": "123"}
  # - O body tem estrutura incorreta: {"id": "123", "user": "string"}
  def update(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{
      error: "Parâmetros inválidos",
      details:
        "Esperado: %{id: integer, user: %{name?: string, email?: string, age?: integer, bio?: string}}"
    })
  end

  # ===== FUNÇÕES PRIVADAS =====

  # VALIDAÇÃO DO ID: Converte e valida o ID recebido da URL
  # Esta função é responsável por:
  # 1. Verificar se o ID é uma string válida
  # 2. Converter a string para inteiro
  # 3. Validar se o ID é um número positivo
  # 4. Retornar o ID validado ou erro
  defp validate_id(id) when is_binary(id) do
    # PASSO 1: Tenta converter a string para inteiro
    # Integer.parse/1 retorna {numero, resto_string} ou :error
    # Exemplo: "123" -> {123, ""} | "123abc" -> {123, "abc"} | "abc" -> :error
    case Integer.parse(id) do
      # PASSO 2: Verifica se a conversão foi bem-sucedida
      # {user_id, ""} = conversão perfeita (sem caracteres extras)
      # user_id > 0 = ID deve ser positivo (não pode ser 0 ou negativo)
      {user_id, ""} when user_id > 0 -> {:ok, user_id}
      # ERRO: ID inválido (tem caracteres extras ou é <= 0)
      # Exemplos: "123abc", "0", "-5", "abc"
      _ -> {:error, :invalid_id}
    end
  end

  # FALLBACK: Para qualquer outro tipo de ID (não string)
  # Exemplos: nil, 123, %{}, []
  defp validate_id(_), do: {:error, :invalid_id}

  # VALIDAÇÃO DE ENTRADA: Valida os dados recebidos para atualização
  # Esta função é responsável por:
  # 1. Criar um changeset com os dados recebidos
  # 2. Aplicar validações específicas para atualização (campos opcionais)
  # 3. Retornar os dados validados ou os erros encontrados
  # DIFERENÇA da criação: campos são opcionais, apenas validados se presentes
  defp validate_update_input(params) do
    # PASSO 1: Cria um changeset vazio e aplica os parâmetros recebidos
    # %UserUpdateInput{} = struct vazia do schema de atualização
    # params = dados do request (ex: %{"name" => "João Atualizado", "age" => 26})
    # O changeset aplica validações condicionais (só valida campos presentes)
    changeset = UserUpdateInput.changeset(%UserUpdateInput{}, params)

    # PASSO 2: Verifica se o changeset é válido (passou em todas as validações)
    if changeset.valid? do
      # SUCESSO: Aplica as mudanças e retorna os dados validados
      # apply_changes/1 converte o changeset em um struct com os dados limpos
      # Exemplo: %UserUpdateInput{name: "João Atualizado", age: 26}
      # Campos não enviados ficam como nil (não são validados)
      {:ok, Ecto.Changeset.apply_changes(changeset)}
    else
      # ERRO: Retorna o changeset com todos os erros de validação
      # O changeset contém detalhes sobre quais campos falharam e por quê
      # Exemplo: %{email: ["formato inválido"], age: ["deve ser um número entre 1 e 149"]}
      {:error, changeset}
    end
  end

  # Simulação de atualização (sem banco de dados)
  defp simulate_user_update(user_id, validated_params) do
    # Simula um usuário existente
    existing_user = %{
      id: user_id,
      name: "Usuário Existente",
      email: "existente@email.com",
      age: 30,
      bio: "Bio existente",
      # 1 dia atrás
      created_at: DateTime.utc_now() |> DateTime.add(-86400, :second),
      # 1 hora atrás
      updated_at: DateTime.utc_now() |> DateTime.add(-3600, :second)
    }

    # Aplica as mudanças
    updated_user = Map.merge(existing_user, Map.from_struct(validated_params))
    updated_user = %{updated_user | updated_at: DateTime.utc_now()}

    {:ok, updated_user}
  end

  # Construção de resposta de sucesso
  defp build_success_response(user_output) do
    %{
      data: user_output,
      message: "Usuário atualizado com sucesso",
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
