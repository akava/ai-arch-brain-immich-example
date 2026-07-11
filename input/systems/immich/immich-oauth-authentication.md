---
source_url: https://docs.immich.app/administration/oauth
fetched: 2026-07-12
provenance: first-party Immich documentation, converted to markdown; content abridged only where boilerplate (nav, badges) was stripped
---

# OAuth Authentication

Immich supports third-party authentication through OpenID Connect (OIDC), built on OAuth2. The platform works with major identity providers including Authentik, Authelia, Okta, Google, and Keycloak.

## Prerequisites

Before enabling OAuth, configure a new client application in your authentication server:

1. **Application setup**
   - Provider type: OpenID Connect or OAuth2
   - Client type: Confidential
   - Application type: Web
   - Grant type: Authorization Code

2. **Redirect URIs required**
   - Mobile: `app.immich:///oauth-callback`
   - Web login: `http://DOMAIN:PORT/auth/login`
   - Web settings: `http://DOMAIN:PORT/user-settings`

3. **Optional backchannel logout**
   - Format: `http://DOMAIN:PORT/api/oauth/backchannel-logout`

## Configuration Settings

Key OAuth settings in Immich Administration:

| Setting | Type | Default | Purpose |
|---------|------|---------|---------|
| Enabled | boolean | false | Activate OAuth |
| Issuer URL | URL | required | Self-discovery URL |
| Client ID | string | required | Client identifier |
| Client Secret | string | required | Client secret |
| Scope | string | openid email profile | Authorization scopes |
| ID Token Signed Response Algorithm | string | RS256 | Token signing algorithm |
| Storage Label Claim | string | preferred_username | User identifier mapping |
| Role Claim | string | immich_role | Admin/user role mapping |
| Storage Quota Claim | string | immich_quota | Storage limit mapping |
| Default Storage Quota (GiB) | number | 0 | Fallback quota (0 = unlimited) |
| Auto Register | boolean | true | Auto-create users on first login |
| Auto Launch | boolean | false | Skip login page, start OAuth directly |

## Mobile Redirect URI Override

If the OAuth provider rejects the custom scheme `app.immich:///oauth-callback`, an alternative endpoint can be configured. Immich provides `/api/oauth/mobile-redirect` for this purpose.

## Key Notes

- The issuer URL should point to the `.well-known/openid-configuration` endpoint (automatically appended if omitted).
- Claim options (storage label, role, storage quota) are only used during user creation, not synchronized afterward.
- Auto Launch can be toggled per-request via URL parameter: `/auth/login?autoLaunch=0` or `?autoLaunch=1`.
