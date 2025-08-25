defmodule RockeliveryWeb.ComparisonController do
  @moduledoc """
  Controller para demonstrar as diferenças entre Phoenix/Elixir e Node.js

  ## COMPARAÇÃO: Phoenix vs Node.js

  ### Node.js/Express:
  ```javascript
  app.get('/users/:id', (req, res) => {
    console.log(req.params.id);    // parâmetros da rota
    console.log(req.body);         // corpo da requisição
    console.log(req.headers);      // headers
    console.log(req.query);        // query parameters (?name=value)

    res.status(200).json({         // resposta (objeto separado)
      message: "Hello"
    });
  });
  ```

  ### Phoenix/Elixir:
  ```elixir
  def show(conn, %{"id" => id}) do
    # conn contém TUDO: requisição + resposta + estado
    IO.inspect(conn.params)        # parâmetros
    IO.inspect(conn.req_headers)   # headers da requisição
    IO.inspect(conn.method)        # método HTTP
    IO.inspect(conn.query_params)  # query parameters

    json(conn, %{message: "Hello"}) # retorna NOVO conn (imutável)
  end
  ```

  ## PRINCIPAIS DIFERENÇAS:

  ### 1. ESTRUTURA:
  - **Node.js**: `req` + `res` (objetos separados)
  - **Phoenix**: `conn` (struct unificado)

  ### 2. MUTABILIDADE:
  - **Node.js**: Objetos mutáveis
    - `req.user = {id: 1}` (modifica o objeto original)
    - `res.status(200)` (modifica o objeto res)

  - **Phoenix**: Struct imutável
    - `conn = assign(conn, :user, %{id: 1})` (retorna NOVO conn)
    - `conn = put_status(conn, 200)` (retorna NOVO conn)

  ### 3. PATTERN MATCHING:
  - **Node.js**: Acesso manual aos dados
  - **Phoenix**: Pattern matching poderoso na assinatura da função

  ### 4. EQUIVALÊNCIAS:
  | Phoenix (Elixir)     | Node.js           | Propósito                    |
  |---------------------|-------------------|------------------------------|
  | `conn`              | `req` + `res`     | Dados da requisição/resposta |
  | `params`            | `req.params`      | Parâmetros da rota           |
  | `conn.query_params` | `req.query`       | Query parameters (?key=val)  |
  | `conn.req_headers`  | `req.headers`     | Headers da requisição        |
  | `conn.method`       | `req.method`      | Método HTTP (GET, POST, etc) |
  | `json(conn, data)`  | `res.json(data)`  | Resposta JSON               |
  | `conn.assigns`      | `req.locals`      | Dados compartilhados        |

  ## EXEMPLO DE USO:
  Teste com: GET /api/users/123?name=Elvis&age=30&city=BH
  """

  use RockeliveryWeb, :controller

  @doc """
  Demonstra como acessar dados no Phoenix comparado ao Node.js

  ## Pattern Matching nos parâmetros:
  - `%{"id" => id}` extrai o ID diretamente
  - `= params` mantém acesso ao mapa completo

  ## No Node.js seria:
  ```javascript
  const id = req.params.id;
  const params = req.params;
  ```
  """
  def show(conn, %{"id" => id} = params) do
    IO.puts("\n=== COMPARAÇÃO PHOENIX vs NODE.JS ===")

    # ====== PARÂMETROS DA ROTA ======
    IO.inspect(params, label: "📋 PARAMS (equivale ao req.params no Node.js)")
    IO.inspect(id, label: "🆔 ID extraído via pattern matching")

    # ====== DADOS DA REQUISIÇÃO (equivale ao req no Node.js) ======
    IO.inspect(conn.method, label: "🌐 HTTP METHOD (req.method)")
    IO.inspect(conn.request_path, label: "🛣️  REQUEST PATH (req.path)")
    IO.inspect(conn.query_params, label: "❓ QUERY PARAMS (req.query)")
    IO.inspect(conn.req_headers |> Enum.take(3), label: "📨 REQUEST HEADERS (primeiros 3)")

    # ====== DADOS ÚNICOS DO PHOENIX ======
    IO.inspect(conn.assigns, label: "📦 ASSIGNS (como req.locals, dados compartilhados)")
    IO.inspect(conn.state, label: "🔄 CONNECTION STATE (único do Phoenix)")

    # ====== INFORMAÇÕES ADICIONAIS ======
    IO.inspect(conn.remote_ip, label: "🌍 REMOTE IP (req.ip)")
    IO.inspect(conn.scheme, label: "🔒 SCHEME (http/https)")

    IO.puts("=== FIM DA DEMONSTRAÇÃO ===\n")

    # ====== RESPOSTA (equivale ao res.json() no Node.js) ======
    json(conn, %{
      message: "✅ Dados do usuário #{id} processados com sucesso!",
      phoenix_vs_nodejs: %{
        method: conn.method,
        path: conn.request_path,
        query_params: conn.query_params,
        total_headers: length(conn.req_headers),
        remote_ip: conn.remote_ip |> :inet.ntoa() |> to_string(),
        scheme: conn.scheme
      },
      explicacao: %{
        conn_equivale_a: "req + res do Node.js",
        params_equivale_a: "req.params do Node.js",
        diferenca_principal: "Phoenix usa struct imutável, Node.js usa objetos mutáveis",
        pattern_matching: "Phoenix permite extrair dados na assinatura da função"
      },
      exemplo_teste: "GET /api/users/123?name=Elvis&age=30&city=BH"
    })
  end

  @doc """
  Exemplo adicional mostrando diferentes tipos de pattern matching

  ## Teste com POST e JSON body:
  ```bash
  curl -X POST http://localhost:4000/api/users \\
    -H "Content-Type: application/json" \\
    -d '{"user": {"name": "Elvis", "email": "elvis@example.com"}}'
  ```
  """
  def create(conn, %{"user" => %{"name" => name, "email" => email}} = params) do
    IO.puts("\n=== PATTERN MATCHING AVANÇADO ===")
    IO.inspect(params, label: "📋 PARAMS COMPLETOS")
    IO.inspect(name, label: "👤 NOME extraído diretamente")
    IO.inspect(email, label: "📧 EMAIL extraído diretamente")

    # No Node.js seria:
    # const name = req.body.user.name;
    # const email = req.body.user.email;

    json(conn, %{
      message: "Usuário #{name} criado!",
      email: email,
      node_js_equivalente: %{
        codigo: "const name = req.body.user.name; const email = req.body.user.email;",
        diferenca: "Phoenix extrai os dados automaticamente na assinatura da função"
      }
    })
  end

  # Fallback para quando o pattern matching não funciona
  def create(conn, params) do
    # Fallback quando o pattern matching acima não funciona
    IO.inspect(params, label: "⚠️  PARAMS não seguem o padrão esperado")

    json(conn, %{
      error: "Formato inválido",
      esperado: %{
        user: %{
          name: "string",
          email: "string"
        }
      },
      recebido: params
    })
  end
end
