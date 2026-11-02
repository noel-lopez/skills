---
name: gh-attach
description: "Attach local images or videos to GitHub issues, PRs and comments. Use when a screenshot or recording has to go to GitHub."
disable-model-invocation: false
---

# gh attach

`gh` uploads local media itself through `--attach` on `issue create|edit|comment` and `pr create|edit|comment`. Each file becomes a `https://github.com/user-attachments/assets/…` URL.

1. **Reference the media in the body.** Write `![alt text](./shot.png)` where the image goes. A video goes alone in its own paragraph, `![](./clip.mp4)`, and renders as a player. gh resolves these paths against the body file's folder first, then the working directory.
2. **Upload.** Pass one `--attach` per file: `gh pr comment 42 --body-file body.md --attach ./shot.png --attach ./clip.mp4`. gh rewrites each reference to the uploaded URL. It appends any file the body doesn't reference at the end. On `edit` with no body flag, it keeps the current body and appends the files.

Alt text goes where the reference is. For an image in the body, write it in `![alt](…)`. For an appended image, put it after `#` in the flag, as in `--attach './shot.png#Login error'`. Videos take none.

Uploading puts the file on GitHub, so it needs the user's approval, same as the text it goes with.

If gh rejects `--attach` as an unknown flag, check `gh --version`. The flag needs 2.99 or later.
