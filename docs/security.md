# Security And Publishing Notes

This repository should contain reproducible setup logic, not a live Wine
environment.

For third-party binaries and generated runtime contents, document acquisition
sources in `docs/runtime-sources.md` instead of committing the files.

Do not commit:

- Wine or Proton prefixes.
- Battle.net installers.
- Blizzard game files.
- `ProgramData` or account caches.
- Registry dumps.
- Logs and crash dumps.
- Screenshots that may include accounts or regions.
- Proxy configs with passwords.
- Tokens, cookies, or `client.config`.

Before publishing:

```bash
rg -n "password|token|secret|refresh_token|VerifyWebCredentials|ST=|KR-|@"
find . -maxdepth 3 -type f -size +5M
```

Review every match manually.
