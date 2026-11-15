# FreshRSS on Kubernetes

Generic Kustomize templates for a self-hosted [FreshRSS](https://freshrss.org) reader of the curated feeds in this repository:

- Anyone on the network can browse and search the feeds without logging in.
- Feeds are organised in groups. Retention is set per group and per feed in the admin UI.
- Each group's feed list comes from an OPML file and is re-read automatically.

Copy this directory into the application repository that deploys it and own it there. Exposure, TLS, storage class, secrets and the curated feed lists are deployment-specific and belong in that copy.

```text
deploy/freshrss/
├── base/                         # SQLite on a PVC. Deployable as-is.
│   ├── kustomization.yaml
│   ├── deployment.yaml           # stock freshrss/freshrss image, built-in cron
│   ├── service.yaml              # ClusterIP only
│   ├── pvc.yaml                  # data/ (config, cache, SQLite)
│   ├── config-user.custom.php    # global retention default
│   └── opml/                     # one file per feed group (examples)
└── components/
    └── postgres-cnpg/            # optional: CloudNativePG instead of SQLite
```

## Choose the database first

| Cluster | Use |
|---|---|
| No database operator | `base` alone: SQLite on the data PVC. |
| CloudNativePG operator installed | `base` plus `components/postgres-cnpg`: a dedicated CNPG cluster with `pg_trgm` for fast content search. |

The database is fixed at the first start (`FRESHRSS_INSTALL` runs once). To switch later, move the user's data with `./cli/export-sqlite-for-user.php` and `./cli/import-sqlite-for-user.php` (see the [FreshRSS CLI docs](https://github.com/FreshRSS/FreshRSS/blob/edge/cli/README.md)).

## Deploy

1. **Copy** `deploy/freshrss/` into the application repository, then write an overlay:

   ```yaml
   apiVersion: kustomize.config.k8s.io/v1beta1
   kind: Kustomization
   namespace: freshrss
   resources:
     - base
   # components:
   #   - components/postgres-cnpg
   ```

2. **Create the admin password Secret** `freshrss-admin` with key `password`, e.g. as a SealedSecret. The password must not contain spaces or quotes, because the image's entrypoint shell-expands it.

3. **Replace the example feed groups** in `base/opml/`, one file per group, and list each file in `base/kustomization.yaml`. Each file is a single category outline whose `frss:opmlUrl` is the URL FreshRSS re-reads the list from:

   ```xml
   <outline text="Kubernetes" frss:opmlUrl="http://127.0.0.1/opml/kubernetes.opml">
     <outline text="Kubernetes Blog" type="rss" xmlUrl="https://kubernetes.io/feed.xml"/>
   </outline>
   ```

   - **Served from the pod (default):** the `freshrss-opml` ConfigMap is mounted at `/var/www/FreshRSS/p/opml/`, so the file is served at `http://127.0.0.1/opml/<file>`. `INTERNAL_HOST_ALLOWLIST` permits FreshRSS to fetch from itself. The lists stay in the application repository, which can be private.
   - **Public raw URL:** set `frss:opmlUrl` to e.g. `https://raw.githubusercontent.com/<org>/<repo>/main/<path>.opml`.

4. **Expose the Service** in the overlay. The base only has a ClusterIP Service on port 80, so add a LoadBalancer, Ingress or TLS sidecar as your cluster requires.

5. **Create the groups once**, after the first start:

   ```sh
   for f in kubernetes cyber; do
     kubectl -n freshrss exec deploy/freshrss -- \
       ./cli/import-for-user.php --user admin --filename /var/www/FreshRSS/p/opml/$f.opml
   done
   ```

   This creates one *dynamic OPML* category per group.

6. **With CNPG, add the trigram indexes** once the groups exist (the tables are created on the first start):

   ```sh
   kubectl -n freshrss exec freshrss-postgresql-1 -c postgres -- psql -d freshrss \
     -c "CREATE INDEX IF NOT EXISTS freshrss_admin_entry_title_trgm ON freshrss_admin_entry USING gin (title gin_trgm_ops);" \
     -c "CREATE INDEX IF NOT EXISTS freshrss_admin_entry_content_trgm ON freshrss_admin_entry USING gin (content gin_trgm_ops);" \
     -c "ANALYZE freshrss_admin_entry;"
   ```

## Day 2

- **Changing feed lists:** edit the group's OPML and let the ConfigMap sync.
  - FreshRSS re-reads each list every 12 hours. Use *Refresh* on the category in the admin UI to apply a change sooner.
  - Feeds added to a list are subscribed. Feeds removed are muted, and their articles are kept.
  - Changes to the files can take about a minute to reach the pod.
- **Adding a group:** add a new OPML file, list it in `kustomization.yaml`, then run the import in step 5 for that file only.
- **Retention:** log in as `admin` and open *Subscription management*.
  - A category's *Archiving* settings apply to all its feeds. A feed's own settings override them.
  - Feeds and categories with no settings of their own use the global default in `base/config-user.custom.php`: keep 1 year, no per-feed count limit, always keep the newest 50.
  - That file is read only when the admin user is created. After that, change the global default in the UI.
  - An article is purged when it is older than the period **or** beyond the maximum count, unless a keep rule protects it.
- **Reading:** anonymous visitors can browse and search (`intitle:`, `intext:`, free text) but not mark articles read or star them. Log in as `admin` to keep read state.
- **Backups:** retention settings, read state and the article archive live only in the data PVC (and the CNPG database). Back them up, e.g. with Velero, and with CNPG backups if you use it.
- **Settings that apply only on first start:** `FRESHRSS_INSTALL`, `FRESHRSS_USER` and `config-user.custom.php`. Editing them later does not change a running instance.
- **Startup log:** the image's permission script prints `Read-only file system` warnings for the mounted `config-user.custom.php`. They are harmless; the rest of `data/` is still made writable.
