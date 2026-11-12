---
name: security
question: Can someone hostile use this change to do something they should not be able to do?
runs: when the changeset touches executable code, configuration, dependencies, or infrastructure definitions
context:
  - security guidance in the repository (SECURITY.md, threat model, auth and permission documentation), when present
---

## Look for

Start from the trust boundaries the change touches: every place where data or control crosses from a less trusted party to a more trusted one. Trace each from entry to sink.

- **Authentication and authorisation:** missing or misplaced checks, checks on the wrong object, privilege escalation, tenant or account isolation.
- **Injection:** SQL, shell, template, path traversal, deserialisation, and any other place where input becomes code, a query, or a path.
- **Outbound requests and redirects:** server-side request forgery, open redirects, unvalidated webhooks and callbacks.
- **Secrets and sensitive data:** credentials in code or config, sensitive values in logs, errors, URLs, or responses, weakened encryption or hashing.
- **Client-side exposure:** cross-site scripting, cross-site request forgery, unsafe HTML rendering, permissive CORS.
- **Abuse and exhaustion:** unbounded input, missing rate limits, expensive operations an anonymous caller can trigger.
- **Dependencies and build:** new or upgraded packages, install scripts, pinned versions loosened, CI or deployment permissions widened.
- **Safe defaults:** a new flag, role, or endpoint that is open until someone closes it.

## Boundaries

- A bug that honest input triggers belongs to **correctness**, even when it is also exploitable. Report the exploit path here.
- Structural concerns with no attack path belong to **architecture**.

## Evidence

Each finding names the attacker (anonymous, authenticated user, other tenant, compromised dependency), the input they control, the path from entry to sink with `file:line` at each step, and what they gain.

A missing hardening measure with no attack path is a NOTE.

## Extra report sections

- **Attack surface:** the trust boundaries this change adds or alters. Write "none" when it adds none.
- **Deeper audit:** say whether the change opens a surface that deserves a full `security-audit` run, and why.
