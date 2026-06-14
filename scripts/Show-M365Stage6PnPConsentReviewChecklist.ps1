param(
    [string]$ClientId = "46a71fd0-068c-4f89-9575-65c6405ca067",
    [string]$ApplicationName = "agent-pnp-provisioning"
)

# Stage 6 - safe consent review checklist.
# Does not open a browser and does not initiate consent. Use this before any
# retry of automated PnP provisioning.

$ErrorActionPreference = "Stop"

Write-Host "Microsoft 365 Stage 6 - PnP consent review checklist" -ForegroundColor Cyan
Write-Host ""
Write-Host "App name: $ApplicationName" -ForegroundColor Gray
Write-Host "ClientId: $ClientId" -ForegroundColor Gray
Write-Host ""
Write-Host "Do NOT approve any consent page that shows a phishing, risky app, unknown publisher, or suspicious consent warning." -ForegroundColor Red
Write-Host ""
Write-Host "Safer review path:" -ForegroundColor Yellow
Write-Host "1. Open https://entra.microsoft.com manually." -ForegroundColor White
Write-Host "2. Go to Identity > Applications > App registrations > All applications." -ForegroundColor White
Write-Host "3. Find '$ApplicationName' and confirm the Application (client) ID is '$ClientId'." -ForegroundColor White
Write-Host "4. Review API permissions. Expected setup-time delegated permissions are:" -ForegroundColor White
Write-Host "   - SharePoint: AllSites.FullControl" -ForegroundColor White
Write-Host "   - Microsoft Graph: Group.ReadWrite.All" -ForegroundColor White
Write-Host "   - Microsoft Graph: User.Read" -ForegroundColor White
Write-Host "5. Open Enterprise applications for the same app and review Permissions and sign-in/audit activity." -ForegroundColor White
Write-Host "6. Grant or refresh admin consent only from the trusted Entra portal if the identity and permissions match exactly." -ForegroundColor White
Write-Host "7. If any warning appears, stop and rebuild the provisioning app deliberately instead of approving." -ForegroundColor White
Write-Host ""
Write-Host "Current Stage 6 automation should remain paused until this review is clean." -ForegroundColor Yellow
