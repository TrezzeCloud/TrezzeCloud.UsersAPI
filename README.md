# TrezzeCloud.UsersAPI

Microsserviço responsável pelo gerenciamento de usuários da plataforma.

## Responsabilidades

- Cadastro de usuários
- Login
- JWT Authentication
- Roles e autorização
- Seed de usuário administrador
- Publicação do evento UserCreatedEvent

---

## Tecnologias

- .NET 10
- ASP.NET Core
- Entity Framework Core
- SQL Server
- JWT
- RabbitMQ
- MassTransit
- Docker
- Kubernetes

---

## Variáveis de Ambiente

| Variável | Descrição |
|---|---|
| ConnectionStrings__UsersDatabase | Connection string SQL Server |
| RabbitMq__Host | Host RabbitMQ |
| RabbitMq__Username | Usuário RabbitMQ |
| RabbitMq__Password | Senha RabbitMQ |
| Jwt__Issuer | Issuer JWT |
| Jwt__Audience | Audience JWT |
| Jwt__SecretKey | Secret JWT |
| AdminUser__Name | Nome admin |
| AdminUser__Email | Email admin |
| AdminUser__Password | Senha admin |
| TestUser__Id | Id fixo do usuário teste |
| TestUser__Name | Nome usuário teste |
| TestUser__Email | Email usuário teste |
| TestUser__Password | Senha usuário teste |

---

## Usuários Seed (Desenvolvimento)

O serviço cria automaticamente os usuários de seed no startup.

### Admin

- Name: TrezzeCloud Admin
- Email: admin@trezzecloud.com
- Password (dev/local): definida por cada integrante via User Secrets, não versionada

### Teste (compartilhado com CatalogAPI)

- Id: aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa
- Name: Usuario Teste
- Email: teste@trezzecloud.com
- Password (dev/local): definida por cada integrante via User Secrets, não versionada

### Segurança e configuração local

Os arquivos `appsettings.json` e `appsettings.Development.json` **não contêm credenciais**. O projeto já define `UserSecretsId`, então não execute `dotnet user-secrets init` novamente.

Para desenvolvimento, configure os segredos do projeto `src/TrezzeCloud.Users.Api` via `dotnet user-secrets set` ou no Visual Studio em **Gerenciar Segredos do Usuário**:

| Chave | Valor necessário (não versionar) |
|---|---|
| `ConnectionStrings:UsersDatabase` | String SQL Server da máquina |
| `Jwt:SecretKey` | Chave aleatória longa; **a mesma configurada na CatalogAPI** |
| `AdminUser:Password` | Senha forte e exclusiva do administrador local |
| `TestUser:Password` | Senha do usuário fictício de testes locais |
| `RabbitMq:Username` | Usuário do RabbitMQ |
| `RabbitMq:Password` | Senha do RabbitMQ |

Exemplo **sem credenciais reais** para visualizar o local correto:

```powershell
dotnet user-secrets list --project src/TrezzeCloud.Users.Api
```

O `dotnet user-secrets` é adequado apenas para desenvolvimento: não criptografa os valores. Não compartilhe o arquivo de segredos nem coloque senhas em commits, screenshots ou arquivos YAML. Em Kubernetes, as credenciais são injetadas através dos Secrets existentes; nenhum Secret do AKS precisa ser recriado nesta etapa.

Para preservar a segurança, o CI executa `scripts/check-appsettings-secrets.py` (impede credenciais em `appsettings*.json`) e Trivy na imagem Docker (relatório informativo de vulnerabilidades HIGH/CRITICAL). O scan não substitui a atualização das dependências afetadas.

**Importante:** senhas e chave JWT antes presentes em arquivos versionados continuam no histórico Git. Se elas foram utilizadas fora de ambientes locais isolados, devem ser rotacionadas de maneira coordenada, preservando os serviços que compartilham a chave.

---

## Executar Localmente

```bash
dotnet restore
dotnet ef database update
dotnet run
```

---

## Docker

```bash
docker build -t trezzecloud-users-api .
```

---

## Kubernetes

Manifestos disponíveis em:

```txt
k8s/users-api
```

---