defmodule Rockelivery.Users.Schemas.UserOutput do
  @moduledoc """
  Schema de saída para usuário.
  Responsabilidade: Definir estrutura e validar dados de saída.
  """
  use Ecto.Schema
  import Ecto.Changeset

  # EMBEDDED SCHEMA: Define a estrutura dos dados de SAÍDA
  # IMPORTANTE: embedded_schema NÃO persiste no banco de dados
  #
  # Como funciona:
  # 1. Define os campos que serão retornados na resposta da API
  # 2. Cria uma struct %UserOutput{} para validação de saída
  # 3. Garante que os dados retornados tenham estrutura consistente
  # 4. Valida se todos os campos obrigatórios estão presentes
  #
  # EXEMPLO DE USO:
  # %UserOutput{
  #   name: "João Silva",
  #   email: "joao@email.com",
  #   age: 25,
  #   bio: "Desenvolvedor",
  #   created_at: ~U[2025-08-25 04:00:00Z],
  #   updated_at: ~U[2025-08-25 04:00:00Z]
  # }
  #
  # DIFERENÇA dos schemas de entrada:
  # - Entrada: valida dados recebidos do usuário
  # - Saída: valida dados que serão enviados para o usuário
  embedded_schema do
    # Campo obrigatório para nome
    field :name, :string
    # Campo obrigatório para email
    field :email, :string
    # Campo obrigatório para idade
    field :age, :integer
    # Campo opcional para biografia
    field :bio, :string
    # Campo obrigatório para data de criação
    field :created_at, :utc_datetime
    # Campo obrigatório para data de atualização
    field :updated_at, :utc_datetime
  end

  @doc """
  Changeset para validação de dados de saída.
  Garante que todos os campos obrigatórios estejam presentes e válidos.
  """
  def changeset(user_output, attrs \\ %{}) do
    user_output
    |> cast(attrs, [:id, :name, :email, :age, :bio, :created_at, :updated_at])
    |> validate_required([:id, :name, :email, :age])
    |> validate_number(:id, greater_than: 0)
    |> validate_length(:name, min: 1)
    |> validate_length(:email, min: 1)
    |> validate_number(:age, greater_than: 0)
  end

  @doc """
  Cria um UserOutput a partir de um map ou struct.
  """
  def from_data(data) do
    %__MODULE__{}
    |> changeset(data)
    |> apply_changes()
  end

  @doc """
  Valida se os dados de saída estão corretos.
  """
  def validate_output(data) do
    changeset = changeset(%__MODULE__{}, data)

    if changeset.valid? do
      {:ok, apply_changes(changeset)}
    else
      {:error, changeset}
    end
  end
end
