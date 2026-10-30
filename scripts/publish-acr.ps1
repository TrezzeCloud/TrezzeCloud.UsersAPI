param(
    [Parameter(Mandatory = $true)][string]$RegistryName
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw 'Docker nao encontrado. Instale ou inicie o Docker Desktop.'
}

docker info --format '{{.ServerVersion}}' | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw 'O Docker Engine nao esta disponivel.'
}

$commit = git -C $root rev-parse --short HEAD
if ($LASTEXITCODE -ne 0 -or -not $commit) {
    throw 'Nao foi possivel obter o commit Git.'
}

$loginServer = az acr show --name $RegistryName --query loginServer -o tsv
if ($LASTEXITCODE -ne 0 -or -not $loginServer) {
    throw 'Nao foi possivel consultar o registry na assinatura Azure atual.'
}

$image = "$loginServer/trezzecloud-users-api:fase4-$commit"

az acr login --name $RegistryName
if ($LASTEXITCODE -ne 0) {
    throw 'Falha no login do ACR.'
}

docker build --platform linux/amd64 -f (Join-Path $root 'Dockerfile') -t $image $root
if ($LASTEXITCODE -ne 0) {
    throw 'Falha no build da imagem.'
}

docker push $image
if ($LASTEXITCODE -ne 0) {
    throw 'Falha ao enviar a imagem ao ACR.'
}

Write-Host "Imagem publicada: $image"
az acr repository show-tags --name $RegistryName --repository trezzecloud-users-api -o table
if ($LASTEXITCODE -ne 0) {
    throw 'Imagem enviada, mas nao foi possivel listar as tags.'
}
