# Eval Workflow

Detailed workflow for testing, evaluating, and iterating on skills.

## Table of Contents

- [Running Test Cases](#running-test-cases)
- [What the User Sees](#what-the-user-sees)
- [Reading Feedback](#reading-feedback)
- [The Iteration Loop](#the-iteration-loop)
- [Blind Comparison](#blind-comparison)
- [Description Optimization](#description-optimization)
- [Environment-Specific Instructions](#environment-specific-instructions)

---

## Running Test Cases

This section is one continuous sequence — don't stop partway through. Put results in `<skill-name>-workspace/` as a sibling to the skill directory. Organize by iteration (`iteration-1/`, `iteration-2/`, etc.) and within that, each test case gets a directory (`eval-0/`, `eval-1/`, etc.). Create directories as you go.

### Step 1: Spawn All Runs in the Same Turn

For each test case, spawn two subagents in the same turn — one with the skill, one without. Don't spawn with-skill runs first and come back for baselines. Launch everything at once.

**With-skill run:**
```
Execute this task:
- Skill path: <path-to-skill>
- Task: <eval prompt>
- Input files: <eval files if any, or "none">
- Save outputs to: <workspace>/iteration-<N>/eval-<ID>/with_skill/outputs/
- Outputs to save: <what the user cares about>
```

**Baseline run** (same prompt, no skill):
- **New skill**: No skill at all. Save to `without_skill/outputs/`.
- **Improving existing skill**: Snapshot the old version (`cp -r <skill-path> <workspace>/skill-snapshot/`), point baseline at the snapshot. Save to `old_skill/outputs/`.

Write `eval_metadata.json` for each test case with a descriptive name:
```json
{
  "eval_id": 0,
  "eval_name": "descriptive-name-here",
  "prompt": "The user's task prompt",
  "assertions": []
}
```

### Step 2: Draft Assertions While Runs Are in Progress

Don't wait — use this time to draft quantitative assertions. Good assertions are objectively verifiable and have descriptive names that read clearly in the benchmark viewer.

Subjective skills (writing style, design quality) are better evaluated qualitatively — don't force assertions onto things needing human judgment.

Update `eval_metadata.json` files and `evals/evals.json` with assertions. Explain to the user what they'll see in the viewer.

### Step 3: Capture Timing Data as Runs Complete

When each subagent completes, the notification contains `total_tokens` and `duration_ms`. Save immediately to `timing.json`:
```json
{
  "total_tokens": 84852,
  "duration_ms": 23332,
  "total_duration_seconds": 23.3
}
```
This is the only opportunity to capture this data — process each notification as it arrives.

### Step 4: Grade, Aggregate, and Launch Viewer

Once all runs are done:

1. **Grade each run** — Spawn a grader subagent that reads `agents/grader.md` and evaluates each assertion. Save to `grading.json`. The `expectations` array must use fields `text`, `passed`, and `evidence` (the viewer depends on these exact names). For programmatically checkable assertions, write and run a script.

2. **Aggregate into benchmark** — Run:
   ```bash
   python -m scripts.aggregate_benchmark <workspace>/iteration-N --skill-name <name>
   ```
   Produces `benchmark.json` and `benchmark.md`. See `references/schemas.md` for the exact schema. Put each with_skill version before its baseline counterpart.

3. **Analyst pass** — Read benchmark data and surface patterns aggregate stats might hide. See `agents/analyzer.md` for what to look for: non-discriminating assertions, high-variance evals, time/token tradeoffs.

4. **Launch the viewer**:
   ```bash
   nohup python <skill-path>/eval-viewer/generate_review.py \
     <workspace>/iteration-N \
     --skill-name "my-skill" \
     --benchmark <workspace>/iteration-N/benchmark.json \
     > /dev/null 2>&1 &
   VIEWER_PID=$!
   ```
   For iteration 2+, also pass `--previous-workspace <workspace>/iteration-<N-1>`.

   **Headless environments:** Use `--static <output_path>` for a standalone HTML file. Feedback downloads as `feedback.json` when user clicks "Submit All Reviews".

Use `eval-viewer/generate_review.py` — don't write custom HTML.

5. **Tell the user** the results are in their browser. Two tabs: "Outputs" for qualitative review and feedback, "Benchmark" for quantitative comparison.

---

## What the User Sees

The **Outputs** tab shows one test case at a time:
- **Prompt**: The task given
- **Output**: Files produced, rendered inline where possible
- **Previous Output** (iteration 2+): Collapsed, showing last iteration
- **Formal Grades**: Collapsed assertion pass/fail
- **Feedback**: Auto-saving textbox
- **Previous Feedback** (iteration 2+): Comments from last time

The **Benchmark** tab shows: pass rates, timing, token usage per configuration, per-eval breakdowns, analyst observations.

Navigation via prev/next or arrow keys. "Submit All Reviews" saves feedback to `feedback.json`.

---

## Reading Feedback

When the user is done, read `feedback.json`:
```json
{
  "reviews": [
    {"run_id": "eval-0-with_skill", "feedback": "the chart is missing axis labels", "timestamp": "..."},
    {"run_id": "eval-1-with_skill", "feedback": "", "timestamp": "..."}
  ],
  "status": "complete"
}
```

Empty feedback means the user thought it was fine. Focus improvements on test cases with specific complaints.

Kill the viewer server when done: `kill $VIEWER_PID 2>/dev/null`

---

## The Iteration Loop

After improving the skill:

1. Apply improvements
2. Rerun all test cases into `iteration-<N+1>/`, including baselines. For new skills, baseline is always `without_skill`. For existing skills, use judgment on baseline: original version or previous iteration.
3. Launch reviewer with `--previous-workspace` pointing at previous iteration
4. Wait for user review
5. Read feedback, improve, repeat

Keep going until:
- The user says they're happy
- Feedback is all empty
- No meaningful progress being made

---

## Blind Comparison

For rigorous comparison between two skill versions. Read `agents/comparator.md` and `agents/analyzer.md` for details. The basic idea: give two outputs to an independent agent without revealing which is which, let it judge quality, then analyze why the winner won.

Optional — requires subagents. The human review loop is usually sufficient.

---

## Description Optimization

The description field is the primary mechanism determining whether Claude invokes a skill. After creating or improving a skill, offer to optimize it.

### Step 1: Generate Trigger Eval Queries

Create 20 eval queries — a mix of should-trigger (8-10) and should-not-trigger (8-10):

```json
[
  {"query": "the user prompt", "should_trigger": true},
  {"query": "another prompt", "should_trigger": false}
]
```

**Queries must be realistic** — concrete, specific, with file paths, personal context, column names, URLs. Include casual speech, abbreviations, typos, varied lengths. Focus on edge cases, not clear-cut examples.

**Bad:** `"Format this data"`, `"Extract text from PDF"`
**Good:** `"ok so my boss just sent me this xlsx file (its in my downloads, called something like 'Q4 sales final FINAL v2.xlsx') and she wants me to add a column that shows the profit margin..."`

**Should-trigger queries**: Different phrasings of the same intent, cases where user doesn't name the skill but clearly needs it, uncommon use cases, cases where this skill competes with another but should win.

**Should-not-trigger queries**: Near-misses sharing keywords but needing something different, adjacent domains, ambiguous phrasing where naive keyword matching would trigger but shouldn't. Avoid obviously irrelevant queries — the negatives should be genuinely tricky.

### Step 2: Review with User

Use the HTML template at `assets/eval_review.html`:
1. Replace `__EVAL_DATA_PLACEHOLDER__` with the JSON array and `__SKILL_NAME_PLACEHOLDER__` / `__SKILL_DESCRIPTION_PLACEHOLDER__` with skill info
2. Write to temp file and open it
3. User edits queries, toggles triggers, exports the eval set
4. Check `~/Downloads/eval_set.json` for the result

### Step 3: Run the Optimization Loop

```bash
python -m scripts.run_loop \
  --eval-set <path-to-trigger-eval.json> \
  --skill-path <path-to-skill> \
  --model <model-id-powering-this-session> \
  --max-iterations 5 \
  --verbose
```

Use the model ID from the current session. The loop splits 60% train / 40% test, evaluates descriptions (3 runs each for reliability), proposes improvements via extended thinking, and iterates up to 5 times. Selects best by test score to avoid overfitting.

### How Skill Triggering Works

Skills appear in Claude's `available_skills` list. Claude consults skills only for tasks it can't easily handle alone — simple one-step queries may not trigger even with a matching description. Eval queries should be substantive enough that Claude would benefit from consulting a skill.

### Step 4: Apply the Result

Take `best_description` from output, update SKILL.md frontmatter. Show user before/after and report scores.

---

## Environment-Specific Instructions

### Claude.ai

Core workflow is the same (draft → test → review → improve → repeat), but no subagents:

- **Test cases**: Run them yourself one at a time by reading the skill then following its instructions. Less rigorous but useful as a sanity check.
- **Review**: Present results directly in conversation instead of the browser viewer. Save output files and tell the user where to find them.
- **Benchmarking**: Skip quantitative benchmarking without baselines. Focus on qualitative feedback.
- **Description optimization**: Requires `claude` CLI — skip on Claude.ai.
- **Blind comparison**: Requires subagents — skip.

### Cowork

- Subagents work — the main workflow functions fully (spawn in parallel; if timeouts occur, run in series)
- No browser — use `--static <output_path>` for the eval viewer, proffer link for user to open
- **Always generate the eval viewer before evaluating inputs yourself** — get results in front of the human ASAP
- Feedback downloads as `feedback.json` file
- Description optimization works (uses `claude -p` via subprocess)

### Packaging (if `present_files` tool is available)

```bash
python -m scripts.package_skill <path/to/skill-folder>
```

Direct the user to the resulting `.skill` file.
