defmodule Rockelivery.Users.Schemas.UserCreateInput do
  @moduledoc """
  Schema de entrada para criação de usuário.
  Responsabilidade: Validar dados de entrada para criação.
  """
  use Ecto.Schema
  import Ecto.Changeset

  # EMBEDDED SCHEMA: Define a estrutura dos dados para validação
  # IMPORTANTE: embedded_schema NÃO persiste no banco de dados
  #
  # Como funciona:
  # 1. Define os campos e tipos que serão aceitos
  # 2. Cria uma struct %UserCreateInput{} para validação
  # 3. O changeset usa esta struct para validar os dados recebidos
  # 4. Após validação, os dados são convertidos para map/struct
  #
  # EXEMPLO DE USO:
  # %UserCreateInput{name: "João", email: "joao@email.com", age: 25, bio: "Dev"}
  #
  # DIFERENÇA de schema normal:
  # - schema normal: persiste no banco, tem timestamps, associations
  # - embedded_schema: só valida, não persiste, mais leve
  embedded_schema do
    # Campo obrigatório para nome
    field :name, :string
    # Campo obrigatório para email
    field :email, :string
    # Campo obrigatório para idade
    field :age, :integer
    # Campo opcional para biografia
    field :bio, :string
  end

  @doc """
  Changeset para validação de dados de entrada na criação de usuário.
  """
  def changeset(user_input, attrs \\ %{}) do
    user_input
    # PASSO 1: CAST - Converte e aplica os dados recebidos
    # cast/4 converte os dados de string para os tipos definidos no schema
    # [:name, :email, :age, :bio] = lista de campos permitidos para modificação
    # attrs = dados do request (ex: %{"name" => "João", "age" => "25"})
    # Resultado: age será convertido de "25" (string) para 25 (integer)
    |> cast(attrs, [:name, :email, :age, :bio])

    # PASSO 2: VALIDAÇÃO DE CAMPOS OBRIGATÓRIOS
    # validate_required/3 verifica se os campos essenciais estão presentes
    # [:name, :email, :age] = campos que NÃO podem ser nil ou vazios
    # Se qualquer um estiver faltando, o changeset fica inválido
    |> validate_required([:name, :email, :age])

    # PASSO 3: VALIDAÇÃO DE COMPRIMENTO DO NOME
    # validate_length/3 verifica se o nome tem tamanho adequado
    # min: 2 = nome deve ter pelo menos 2 caracteres (evita "Jo")
    # max: 100 = nome não pode ter mais de 100 caracteres
    |> validate_length(:name, min: 2, max: 100)

    # PASSO 4: VALIDAÇÃO DE COMPRIMENTO DO EMAIL
    # validate_length/3 verifica se o email tem tamanho adequado
    # min: 5 = email deve ter pelo menos 5 caracteres (ex: "a@b.c")
    # max: 255 = limite padrão para emails (padrão RFC)
    |> validate_length(:email, min: 5, max: 255)

    # PASSO 5: VALIDAÇÃO DE IDADE
    # validate_number/3 verifica se a idade está em faixa válida
    # greater_than: 0 = idade deve ser maior que 0 (não pode ser 0 ou negativa)
    # less_than: 150 = idade deve ser menor que 150 (limite realista)
    |> validate_number(:age, greater_than: 0, less_than: 150)
  end
end
