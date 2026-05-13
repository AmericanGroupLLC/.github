# `.github` — Org-level GitHub Configuration

> 🏛 **Special-purpose org repo.** GitHub renders [`profile/README.md`](./profile/README.md) on the [AmericanGroupLLC organisation home page](https://github.com/AmericanGroupLLC). This repo also hosts org-wide reusable workflows, build scripts, and release templates.

## What lives here

| Path | Purpose |
|---|---|
| [`profile/README.md`](./profile/README.md) | Renders on https://github.com/AmericanGroupLLC. Edit to update the org homepage. |
| [`.github/workflows/`](./.github/workflows/) | **Reusable workflows** callable from any repo in the org via `uses: AmericanGroupLLC/.github/.github/workflows/<name>.yml@master`. |
| [`scripts/`](./scripts/) | Shared shell + Node scripts called by the reusable workflows (release book builder, video assembler, dashboard updater, icon maker, video-script parser). |
| [`templates/`](./templates/) | Templates consumed by the reusable workflows (release-book LaTeX/Pandoc, release-video intro/outro HTML + transitions). |
| [`SECRETS.md`](./SECRETS.md) | Inventory of org-level secrets and per-repo overrides. |

## Reusable workflows

Each repo in the org can call these without copying:

```yaml
jobs:
  release-book:
    uses: AmericanGroupLLC/.github/.github/workflows/release-book.yml@master
    with:
      version: ${{ github.ref_name }}
    secrets: inherit
```

Available workflows:
- `release-book.yml` — builds per-release reference PDF from repo's `.md` files.
- `release-video.yml` — assembles per-release MP4 reel from screenshots + scripts.
- `release-dashboard.yml` — refreshes the cross-portfolio dashboard.
- `validate.yml` — lints YAML + Markdown + shell scripts in this org-config repo.

## How org profile rendering works

GitHub looks for a `.github` repo on the organisation. If it finds `profile/README.md` inside, that markdown is used as the organisation's profile page (visible at https://github.com/AmericanGroupLLC). To update the homepage, edit `profile/README.md` and push to `master`.

## Migration history

- **2026-05-13** — repo created from the former `AmericanGroupLLC/AmericanGroupLLC` namesake repo. Profile README, scripts, templates, and reusable workflows migrated. Namesake repo deleted to remove the duplicate-of-org-homepage.

## License

MIT — see [LICENSE](./LICENSE). Reusable workflows are intentionally permissive so any AGLLC repo (including future-projects) can consume them with no friction.
