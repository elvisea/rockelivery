defmodule Rockelivery.Users.Schemas.UserUpdateInput do
  @moduledoc """
  Schema de entrada para edição de usuário.
  Responsabilidade: Validar dados de entrada para edição.
  """
  use Ecto.Schema
  import Ecto.Changeset

  # EMBEDDED SCHEMA: Define a estrutura dos dados para validação
  # IMPORTANTE: embedded_schema NÃO persiste no banco de dados
  #
  # Como funciona:
  # 1. Define os campos e tipos que serão aceitos (todos opcionais)
  # 2. Cria uma struct %UserUpdateInput{} para validação
  # 3. O changeset usa esta struct para validar APENAS campos presentes
  # 4. Campos não enviados ficam como nil (não são validados)
  #
  # EXEMPLO DE USO:
  # %UserUpdateInput{name: "João Atualizado", age: 26}
  # %UserUpdateInput{email: "novo@email.com"}
  # %UserUpdateInput{}  # Struct vazia (todos os campos nil)
  #
  # DIFERENÇA da criação:
  # - Criação: todos os campos são obrigatórios
  # - Atualização: todos os campos são opcionais
  embedded_schema do
    # Campo opcional para nome
    field :name, :string
    # Campo opcional para email
    field :email, :string
    # Campo opcional para idade
    field :age, :integer
    # Campo opcional para biografia
    field :bio, :string
  end

  @doc """
  Changeset para validação de dados de entrada na edição de usuário.
  Permite campos opcionais (diferente da criação).
  """
  def changeset(user_input, attrs \\ %{}) do
    user_input
    # PASSO 1: CAST - Converte e aplica os dados recebidos
    # cast/4 converte os dados de string para os tipos definidos no schema
    # [:name, :email, :age, :bio] = lista de campos permitidos para modificação
    # attrs = dados do request (ex: %{"name" => "João Atualizado"})
    # DIFERENÇA da criação: NÃO há validate_required - todos os campos são opcionais
    |> cast(attrs, [:name, :email, :age, :bio])

    # PASSO 2: VALIDAÇÃO DE COMPRIMENTO DO NOME (se presente)
    # validate_length/3 verifica se o nome tem tamanho adequado
    # min: 2 = nome deve ter pelo menos 2 caracteres (evita "Jo")
    # max: 100 = nome não pode ter mais de 100 caracteres
    # Se name não for enviado, esta validação é ignorada
    |> validate_length(:name, min: 2, max: 100)

    # PASSO 3: VALIDAÇÃO DE COMPRIMENTO DO EMAIL (se presente)
    # validate_length/3 verifica se o email tem tamanho adequado
    # min: 5 = email deve ter pelo menos 5 caracteres (ex: "a@b.c")
    # max: 255 = limite padrão para emails (padrão RFC)
    # Se email não for enviado, esta validação é ignorada
    |> validate_length(:email, min: 5, max: 255)

    # PASSO 4: VALIDAÇÃO DE COMPRIMENTO DA BIO (se presente)
    # validate_length/3 verifica se a bio não é muito longa
    # max: 500 = bio não pode ter mais de 500 caracteres
    # Se bio não for enviada, esta validação é ignorada
    |> validate_length(:bio, max: 500)

    # PASSO 5: VALIDAÇÕES CUSTOMIZADAS CONDICIONAIS
    # Estas funções só validam se o campo estiver presente
    # Se o campo não for enviado, a validação é pulada
    |> validate_email_format_when_present()
    |> validate_name_format_when_present()
    |> validate_age_when_present()
  end

  # VALIDAÇÃO CONDICIONAL DE EMAIL: Só valida se o campo estiver presente
  # Esta função é executada APENAS quando o campo email é enviado no request
  # Se email não for enviado, retorna o changeset sem modificações
  defp validate_email_format_when_present(changeset) do
    # PASSO 1: Verifica se o campo email foi modificado no changeset
    # get_change/2 retorna o valor do campo se foi alterado, ou nil se não foi
    case get_change(changeset, :email) do
      # CASO 1: Email não foi enviado - pula a validação
      nil -> changeset
      # CASO 2: Email foi enviado - executa a validação de formato
      email -> validate_email_format(changeset, email)
    end
  end

  # VALIDAÇÃO DE FORMATO DE EMAIL: Aplica regex para validar estrutura
  # Esta função é chamada APENAS quando email está presente
  defp validate_email_format(changeset, email) do
    # PASSO 1: Verifica se o email tem formato válido usando regex
    if is_valid_email_format(email) do
      # SUCESSO: Email tem formato correto, retorna changeset sem modificações
      changeset
    else
      # ERRO: Email tem formato inválido, adiciona erro ao changeset
      # add_error/4 adiciona uma mensagem de erro para o campo email
      add_error(changeset, :email, "formato inválido")
    end
  end

  # VERIFICAÇÃO DE FORMATO DE EMAIL: Regex para validar estrutura básica
  # Esta função usa uma expressão regular para verificar se o email tem formato válido
  # Regex: ^[^\s@]+@[^\s@]+\.[^\s@]+$
  # - ^ = início da string
  # - [^\s@]+ = um ou mais caracteres que NÃO são espaços ou @
  # - @ = símbolo @ obrigatório
  # - [^\s@]+ = um ou mais caracteres que NÃO são espaços ou @ (domínio)
  # - \. = ponto obrigatório
  # - [^\s@]+ = um ou mais caracteres que NÃO são espaços ou @ (TLD)
  # - $ = fim da string
  defp is_valid_email_format(email) do
    Regex.match?(~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/, email)
  end

  # VALIDAÇÃO CONDICIONAL DE NOME: Só valida se o campo estiver presente
  # Esta função é executada APENAS quando o campo name é enviado no request
  # Se name não for enviado, retorna o changeset sem modificações
  defp validate_name_format_when_present(changeset) do
    # PASSO 1: Verifica se o campo name foi modificado no changeset
    # get_change/2 retorna o valor do campo se foi alterado, ou nil se não foi
    case get_change(changeset, :name) do
      # CASO 1: Nome não foi enviado - pula a validação
      nil -> changeset
      # CASO 2: Nome foi enviado - executa a validação de formato
      name -> validate_name_format(changeset, name)
    end
  end

  # VALIDAÇÃO DE FORMATO DE NOME: Verifica se contém apenas letras e espaços
  # Esta função é chamada APENAS quando name está presente
  defp validate_name_format(changeset, name) do
    # PASSO 1: Verifica se o nome tem formato válido usando regex
    if is_valid_name_format(name) do
      # SUCESSO: Nome tem formato correto, retorna changeset sem modificações
      changeset
    else
      # ERRO: Nome tem formato inválido, adiciona erro ao changeset
      # add_error/4 adiciona uma mensagem de erro para o campo name
      add_error(changeset, :name, "deve conter apenas letras e espaços")
    end
  end

  # VERIFICAÇÃO DE FORMATO DE NOME: Regex para validar apenas letras e espaços
  # Esta função usa uma expressão regular para verificar se o nome contém apenas caracteres válidos
  # Regex: ^[a-zA-ZÀ-ÿ\s]+$
  # - ^ = início da string
  # - [a-zA-ZÀ-ÿ\s]+ = um ou mais caracteres que são:
  #   - a-z = letras minúsculas
  #   - A-Z = letras maiúsculas
  #   - À-ÿ = acentos e caracteres especiais (á, é, ã, ç, etc.)
  #   - \s = espaços em branco
  # - $ = fim da string
  # EXEMPLOS VÁLIDOS: "João Silva", "Maria", "José da Silva"
  # EXEMPLOS INVÁLIDOS: "João123", "Maria@", "José_123"
  defp is_valid_name_format(name) do
    Regex.match?(~r/^[a-zA-ZÀ-ÿ\s]+$/, name)
  end

  # VALIDAÇÃO CONDICIONAL DE IDADE: Só valida se o campo estiver presente
  # Esta função é executada APENAS quando o campo age é enviado no request
  # Se age não for enviado, retorna o changeset sem modificações
  defp validate_age_when_present(changeset) do
    # PASSO 1: Verifica se o campo age foi modificado no changeset
    # get_change/2 retorna o valor do campo se foi alterado, ou nil se não foi
    case get_change(changeset, :age) do
      # CASO 1: Idade não foi enviada - pula a validação
      nil -> changeset
      # CASO 2: Idade foi enviada - executa a validação de faixa
      age -> validate_age_range(changeset, age)
    end
  end

  # VALIDAÇÃO DE FAIXA DE IDADE: Verifica se a idade está em faixa realista
  # Esta função é chamada APENAS quando age está presente
  defp validate_age_range(changeset, age) do
    # PASSO 1: Verifica se a idade está na faixa válida
    if is_valid_age_range(age) do
      # SUCESSO: Idade está na faixa válida, retorna changeset sem modificações
      changeset
    else
      # ERRO: Idade está fora da faixa válida, adiciona erro ao changeset
      # add_error/4 adiciona uma mensagem de erro para o campo age
      add_error(changeset, :age, "deve ser um número entre 1 e 149")
    end
  end

  # VERIFICAÇÃO DE FAIXA DE IDADE: Valida se a idade é um inteiro válido
  # Esta função verifica três condições para uma idade válida:
  # 1. is_integer(age) = deve ser um número inteiro (não float, string, etc.)
  # 2. age > 0 = deve ser maior que 0 (não pode ser 0 ou negativo)
  # 3. age < 150 = deve ser menor que 150 (limite realista para humanos)
  # EXEMPLOS VÁLIDOS: 1, 25, 100, 149
  # EXEMPLOS INVÁLIDOS: 0, -5, 150, 200, 25.5, "25"
  defp is_valid_age_range(age) do
    is_integer(age) and age > 0 and age < 150
  end
end
