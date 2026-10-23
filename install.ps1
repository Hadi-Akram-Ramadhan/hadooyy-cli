$ErrorActionPreference = "Stop"
if (Get-Command python -ErrorAction SilentlyContinue) {
    & python (Join-Path $PSScriptRoot "setup.py") @args
} elseif (Get-Command py -ErrorAction SilentlyContinue) {
    & py -3 (Join-Path $PSScriptRoot "setup.py") @args
} else {
    throw "Python 3.10+ required. Ask your agent to install it first."
}
exit $LASTEXITCODE
