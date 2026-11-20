---
name: release-note-trailers
description: Release notes kept as `Release-Note:` git trailers, written on the commit by whoever made the change and collected from the commit range at release time. Use when committing a change users will notice in a repository that follows this convention, when asked to write release notes or a changelog for a release or commit range, or when setting the convention up in a repository.
---

# Release-Note Trailers

A release note is written once, at commit time, by the author who still has the context, as a git trailer on the commit:

```text
feat: twiddle widgets

- do some thing

Release-Note: Add the ability to twiddle widgets
```

At release, the notes are the `Release-Note` trailers of the commits in range. Nobody reconstructs them from diffs later.

Three branches: [writing a trailer](#writing-a-trailer) when you commit, [collecting](#collecting-at-release) when you release, and [setting up](#setting-up-a-repository) a repository.

## Writing a trailer

Add a trailer when the commit completes something a user of the software will notice: a new ability, a changed behaviour, a fix for a bug they could hit, a removal, a deprecation, or a step they must take to upgrade. "User" means whoever consumes the release: an end user for an app, a developer for a library or CLI.

Commits users cannot notice carry no trailer: refactors, tests, CI, internal tooling, and fixes for bugs that never shipped.

One change, one note. When a change spans a stack of commits, put its trailer on the last commit of the stack, where the change becomes whole. A stack that delivers several separate changes carries each note on the commit that completes it.

Word the note for the release notes page, where it will appear verbatim beside notes from other commits:

- One sentence, imperative, starting with a verb: `Add`, `Fix`, `Change`, `Remove`, `Deprecate`.
- Say what the user can now do or will now see, in their vocabulary. `Fix exports failing for reports over 10,000 rows`, where the subject line might say `fix: paginate export query`.
- Lead with `BREAKING:` when the user must act to upgrade, and say what to do: `BREAKING: Rename the --out flag to --output; update scripts that pass it`.

Git reads trailers only from the final paragraph of the message, and only when every line of that paragraph is a trailer. One stray line there and git reads none of them. So:

- Add the trailer with `git commit --trailer "Release-Note: <note>"`. Git then places it in the final paragraph itself, beside any trailer the message already ends with.
- When writing the message by hand, put `Release-Note:` in the same paragraph as the other trailers such as `Co-Authored-By`, with no blank line between them.
- Keep the note on one line, however long. A wrapped note is cut short or lost; where a line-length check complains, the trailer is the exception.
- For several notes on one commit, repeat the trailer.

After committing, run `git log -1 --format='%(trailers:key=Release-Note,valueonly)'`. It must print the whole note, word for word. Anything shorter means git did not read it as written: fix the message.

To fix or add a note on a commit that is already made, amend it while it is unpushed. Once it is shared, put the trailer on the next commit of the same change, or on an empty commit (`git commit --allow-empty`).

Where the repository squash-merges pull requests, the commit's trailer does not reach the main branch on its own. End the pull request description with the same trailers, in the same form.

## Collecting at release

Run the bundled script from inside the repository. It lives in this skill's directory, so call it by that path:

```bash
<skill directory>/scripts/release-notes.sh                      # the next release, or the one just tagged
<skill directory>/scripts/release-notes.sh v1.2.0..v1.3.0       # a named range
<skill directory>/scripts/release-notes.sh --match 'api@*' -- packages/api   # one package of a monorepo
```

With no range it collects from the latest tag to `HEAD`. When `HEAD` itself carries the latest tag, the release is already tagged, and it collects from the tag before it. For any other release that is already tagged, name the range: `git describe --tags --abbrev=0 <tag>^` gives the tag before `<tag>`.

It prints one `- <note> (<short sha>)` line per trailer, oldest first. A note repeated word for word is printed once, and a note on a commit that is reverted within the range is left out. On stderr it prints the range it used and a `warning:` line for anything that needs a look.

Then turn the list into release notes:

1. **Check the range.** Read the `range:` line and confirm it is the release the user asked for: the right starting tag, and in a monorepo the right package. A failed run (non-zero exit) is a wrong range, a shallow clone, or a missing tag; fix that and run again, since an empty list from a failed run says nothing about the notes.
2. **Act on each warning.**
   - *A Release-Note line that is not a trailer:* the author wrote a note and git could not read it. Read that commit's message (`git show -s <sha>`) and include the note as written.
   - *Left out, reverted in this range:* leave it out, and tell the user which note was dropped and why.
   - *No commits in this range:* the range is wrong. Find the right one before reporting anything.
3. **Group the notes** in the repository's existing changelog style. Where there is none, use: Breaking changes, Added, Changed, Fixed, Removed. Keep each note's wording; edit only to merge notes that describe one change or to fix a typo.
4. **Look for forgotten notes.** Run the script again with `--missing` and the same arguments. It lists the commits that carry no note. Most are correct as they are: an earlier commit of a stack whose note is on the last one, or a change users cannot notice. Show the user only the commits that changed something a user would notice and that no collected note covers. When the user confirms one, add its note with an empty commit carrying the trailer, so the commits stay the single source, and collect again.

Two things the range cannot tell you; say so when they apply:

- **Squash merges.** A squash commit keeps a trailer only when the trailer ended up in its final paragraph. The not-a-trailer warning catches notes that landed mid-message. A note that never reached the squash message leaves no trace, so when a squash commit shows up under `--missing`, check its pull request's commits and description for a note.
- **Backports.** A fix cherry-picked to a release branch and shipped from there is a different commit from the original, so it appears again in the next release cut from the main branch. Keep it, unless the user wants notes already published for the earlier release removed.

## Setting up a repository

Add the rule to the repository's agent guidance (`AGENTS.md` or `CLAUDE.md`), adjusting "user" to the repository's audience:

```markdown
## Release notes

When a commit completes a change users will notice, give it a release note:
`git commit --trailer "Release-Note: <one sentence, imperative, in the user's terms>"`.

- For a stack of commits, the note goes on the last commit of the change.
- The trailer sits in the final paragraph of the message, in the same paragraph
  as any other trailer such as `Co-Authored-By`, on one line, never wrapped.
- Prefix the note with `BREAKING:` when users must act to upgrade.
- Commits users cannot notice carry no trailer.
```

Then settle these with the user:

- **Squash merging.** When the host squash-merges pull requests, make the squash message end with the trailers. The dependable arrangement is to build the squash message from the pull request description (on GitHub: Settings, General, Pull Requests, default commit message "Pull request title and description") and add this line to the rule: "End the pull request description with the same `Release-Note:` trailers." Building the message from the list of commits keeps a trailer only when it happens to fall in the last paragraph.
- **Release step.** Where release notes are produced, by a script, a CI job, or by hand, point that step at the trailers. Copy `scripts/release-notes.sh` into the repository when the release runs somewhere this skill is not installed. The script needs full history and tags and stops on a shallow clone, so a CI job must fetch both (in GitHub Actions, `fetch-depth: 0` on the checkout step).
- **Monorepo.** When packages are tagged separately, record the tag pattern and path for each package beside the rule, so the release step passes `--match` and the path.
