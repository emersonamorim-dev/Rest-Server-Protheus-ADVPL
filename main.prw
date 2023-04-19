#include "protheus.ch"
#include "topconn.ch"

User Function RESTServer()
    Local oServer := TcRestServer():New()
    Local oRouter := TcRestRouter():New()

    oRouter:AddRoute("GET", "/products", {|oRequest, oResponse| GetProducts(oRequest, oResponse)})
    oRouter:AddRoute("GET", "/cart", {|oRequest, oResponse| GetCart(oRequest, oResponse)})
    oRouter:AddRoute("POST", "/cart", {|oRequest, oResponse| AddToCart(oRequest, oResponse)})
    oRouter:AddRoute("DELETE", "/cart", {|oRequest, oResponse| ClearCart(oRequest, oResponse)})
    oRouter:AddRoute("GET", "/users", {|oRequest, oResponse| GetUsers(oRequest, oResponse)})
    oRouter:AddRoute("POST", "/users", {|oRequest, oResponse| CreateUser(oRequest, oResponse)})
    oRouter:AddRoute("GET", "/payment-methods", {|oRequest, oResponse| GetPaymentMethods(oRequest, oResponse)})

    oServer:AddRouter(oRouter)
    oServer:Start()
Return

Static Function GetProducts(oRequest, oResponse)
    Local aProducts := {}
    Local aProduct := {}

    aProduct["id"] := 1
    aProduct["nome"] := "Produto 1"
    aProduct["preco"] := 10.99
    aProducts[1] := aProduct

    aProduct := {}
    aProduct["id"] := 2
    aProduct["nome"] := "Produto 2"
    aProduct["preco"] := 20.99
    aProducts[2] := aProduct

    oResponse:SetBody(aProducts)
Return

Static Function GetCart(oRequest, oResponse)
    Local cAuthToken := oRequest:GetHeader("Authorization")

    //Verificar se o token de autenticação foi enviado na requisição
    If !Empty(cAuthToken)
        //Verificar se o token é válido e corresponde a um usuário logado
        If IsUserAuthenticated(cAuthToken)
            //Recuperar o carrinho de compras do usuário logado
            Local cUserId := GetUserIdFromToken(cAuthToken)
            Local aCart := GetCartFromUserId(cUserId)

            oResponse:SetBody(aCart)
        Else
            oResponse:SetStatusCode(401)
            oResponse:SetReasonPhrase("Unauthorized")
            oResponse:SetBody({"message": "Token inválido ou expirado"})
        EndIf
    Else
        oResponse:SetStatusCode(401)
        oResponse:SetReasonPhrase("Unauthorized")
        oResponse:SetBody({"message": "Autenticação requerida"})
    EndIf
Return


Static Function AddToCart(oRequest, oResponse)
    Local cAuthToken := oRequest:GetHeader("Authorization")

    //Verificar se o token de autenticação foi enviado na requisição
    If !Empty(cAuthToken)
        //Verificar se o token é válido e corresponde a um usuário logado
        If IsUserAuthenticated(cAuthToken)
            //recuperar o ID do usuário
            Local cUserId := GetUserIdFromToken(cAuthToken)

            //Converter o corpo da requisição para um hash com as informações do produto
            Local aProduct := JsonToHash(oRequest:GetBody())

            ; Verificar se o produto a ser adicionado está completo
            If !Empty(aProduct["id"]) .And. !Empty(aProduct["quantity"])
                //Verificar se o produto existe e está disponível em estoque
                If ProductExists(aProduct["id"]) .And. ProductInStock(aProduct["id"], aProduct["quantity"])
                //Adicionar o produto ao carrinho do usuário
                    AddProductToCart(cUserId, aProduct["id"], aProduct["quantity"])

                    oResponse:SetStatusCode(200)
                    oResponse:SetReasonPhrase("OK")
                    oResponse:SetBody({"message": "Produto adicionado ao carrinho"})
                Else
                    oResponse:SetStatusCode(400)
                    oResponse:SetReasonPhrase("Bad Request")
                    oResponse:SetBody({"message": "Produto inválido ou estoque insuficiente"})
                EndIf
            Else
                oResponse:SetStatusCode(400)
                oResponse:SetReasonPhrase("Bad Request")
                oResponse:SetBody({"message": "Informações inválidas do produto"})
            EndIf
        Else
            oResponse:SetStatusCode(401)
            oResponse:SetReasonPhrase("Unauthorized")
            oResponse:SetBody({"message": "Token inválido ou expirado"})
        EndIf
    Else
        oResponse:SetStatusCode(401)
        oResponse:SetReasonPhrase("Unauthorized")
        oResponse:SetBody({"message": "Autenticação requerida"})
    EndIf
Return

Static aCarts := {}

Static Function ClearCart(oRequest, oResponse)
    Local cAuthToken := oRequest:GetHeader("Authorization")

       //Verificar se o token de autenticação foi enviado na requisição
    If !Empty(cAuthToken)
        //Verificar se o token é válido e corresponde a um usuário logado
        If IsUserAuthenticated(cAuthToken)
        //Recuperar o ID do usuário e limpar o carrinho de compras
            Local cUserId := GetUserIdFromToken(cAuthToken)
            aCarts[cUserId] := {}

            oResponse:SetStatusCode(200)
            oResponse:SetReasonPhrase("OK")
            oResponse:SetBody({"message": "Carrinho limpo"})
        Else
            oResponse:SetStatusCode(401)
            oResponse:SetReasonPhrase("Unauthorized")
            oResponse:SetBody({"message": "Token inválido ou expirado"})
        EndIf
    Else
        oResponse:SetStatusCode(401)
        oResponse:SetReasonPhrase("Unauthorized")
        oResponse:SetBody({"message": "Autenticação requerida"})
    EndIf
Return


Static Function GetUsers(oRequest, oResponse)
    //Recuperar a lista de usuários cadastrados em um hash
    Local aUsers := {
        {"id": 1, "nome": "Emerson Amorim", "email": "emersonamorim18@examplo.com"},
        {"id": 2, "nome": "Emerson Luiz", "email": "emersonluiz18@examplo.com"},
        {"id": 3, "nome": "Emer Amorim", "email": "emeramorim18@examplo.com"}
    }

    //Converter o hash para o formato JSON e retornar na resposta
    Local cUsersJson := HashToJson(aUsers)

    oResponse:SetBody(cUsersJson)
Return

Static Function CreateUser(oRequest, oResponse)
    //Verificar se o corpo da requisição contém as informações do novo usuário
    If !Empty(oRequest:GetBody())
    //Converter o corpo da requisição para um hash com as informações do novo usuário
        Local aUser := JsonToHash(oRequest:GetBody())

        ; Verificar se as informações do novo usuário estão completas
        If !Empty(aUser["name"]) .And. !Empty(aUser["email"]) .And. !Empty(aUser["password"])
            ; Verificar se o usuário já não existe na base de dados
            If !UserExists(aUser["email"])
                ; Inserir o novo usuário na tabela de usuários
                InsertUser(aUser["name"], aUser["email"], aUser["password"])

                oResponse:SetStatusCode(201)
                oResponse:SetReasonPhrase("Created")
                oResponse:SetBody({"message": "Usuário criado"})
            Else
                oResponse:SetStatusCode(400)
                oResponse:SetReasonPhrase("Bad Request")
                oResponse:SetBody({"message": "Usuário já existe"})
            EndIf
        Else
            oResponse:SetStatusCode(400)
            oResponse:SetReasonPhrase("Bad Request")
            oResponse:SetBody({"message": "Informações incompletas do usuário"})
        EndIf
    Else
        oResponse:SetStatusCode(400)
        oResponse:SetReasonPhrase("Bad Request")
        oResponse:SetBody({"message": "Informações do usuário ausentes"})
    EndIf
Return

Static Function GetPaymentMethods(oRequest, oResponse)
    Local aPaymentMethods := {}
    Local aPaymentMethod := {}

    aPaymentMethod["id"] := 1
    aPaymentMethod["name"] := "Cartão de Crédito"
    aPaymentMethods[1] := aPaymentMethod

    aPaymentMethod := {}
    aPaymentMethod["id"] := 2
    aPaymentMethod["name"] := "Boleto Bancário"
    aPaymentMethods[2] := aPaymentMethod

    oResponse:SetBody(aPaymentMethods)
Return
