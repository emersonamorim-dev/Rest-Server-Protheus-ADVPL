## REST Server Protheus

Codificação em ADVPL para implementar um servidor REST usando a linguagem de programação Protheus. O servidor faz implementação de 7 rotas, que são manipuladas por funções estáticas que retornam os dados correspondentes.

## Rotas
As rotas implementadas pelo servidor são:

## GET /products
Retorna uma lista de produtos. Os dados dos produtos são definidos dentro da função estática GetProducts. O formato dos dados é um array de hashes, onde cada hash representa um produto com as chaves "id", "nome" e "preco".

## GET /cart
Retorna o carrinho de compras do usuário logado. Antes de retornar o carrinho, o servidor verifica se o token de autenticação foi enviado na requisição e se é válido. Se o token não for enviado ou não for válido, o servidor retorna um código de erro 401 (Unauthorized). Se o token for válido, o servidor recupera o carrinho do usuário a partir do ID do usuário e retorna os dados do carrinho no formato de um array de hashes, onde cada hash representa um produto com as chaves "id", "nome", "preco" e "quantidade".

## POST /cart
Adiciona um produto ao carrinho de compras do usuário logado. Antes de adicionar o produto ao carrinho, o servidor verifica se o token de autenticação foi enviado na requisição e se é válido. Se o token não for enviado ou não for válido, o servidor retorna um código de erro 401 (Unauthorized). Se o token for válido, o servidor verifica se as informações do produto estão completas e se o produto existe e está disponível em estoque. Se as informações do produto estiverem completas e o produto estiver disponível em estoque, o servidor adiciona o produto ao carrinho do usuário e retorna um código de sucesso 200 (OK). Se as informações do produto estiverem incompletas ou o produto não estiver disponível em estoque, o servidor retorna um código de erro 400 (Bad Request).

## DELETE /cart
Limpa o carrinho de compras do usuário logado. Antes de limpar o carrinho, o servidor verifica se o token de autenticação foi enviado na requisição e se é válido. Se o token não for enviado ou não for válido, o servidor retorna um código de erro 401 (Unauthorized). Se o token for válido, o servidor limpa o carrinho do usuário a partir do ID do usuário e retorna um código de sucesso 200 (OK).

## GET /users
Retorna uma lista de usuários cadastrados. Os dados dos usuários são definidos dentro da função estática GetUsers. O formato dos dados é um array de hashes, onde cada hash representa um usuário com as chaves "id", "nome" e "email".

## POST /users
Cria um novo usuário. O servidor espera receber no corpo da requisição as informações do novo usuário no formato JSON. Antes de criar o novo usuário, o servidor verifica se as informações do novo usuário estão completas e se o usuário já não existe na base de dados. Se as informações do novo usuário estiverem completas e o usuário ainda não existir, o servidor insere o novo usuário na tabela de usuários e retorna um código de sucesso 201 (Created). Se as informações do novo usuário estiverem incompletas ou o usuário já existir, o servidor retorna um código de erro 400 (Bad Request).

## GET /payment-methods
Retorna uma lista de métodos de pagamento. Os dados dos métodos de pagamento
