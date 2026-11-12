# Reassuring copy

**Reassuring copy** is UI text that restates the brief. It describes a quality of the software, narrates a design decision, or calms a worry the user never had. It is written to show the prompter that the brief was followed, and the prompter is not the audience.

## The rule

Write for the **stranger**: the person using the product, who never saw the prompt, the ticket, or the design discussion.

A requirement in the brief is an instruction about behaviour. Meet it in the behaviour. "No signup" means the product has no signup screen; the stranger finds that out by using it.

## The stranger test

A string ships when both are true:

1. The stranger needs it to decide or act.
2. The stranger cannot get it from the screen itself.

Text that passes: a label that names a thing, a consequence ("Deletes after 30 days"), a constraint ("Only admins can see this"), current state ("Saved 2 minutes ago"), an error with its next step.

Text that fails names a quality (simple, fast, clean, minimal, private, lightweight, powerful), explains why the screen looks the way it does, or repeats what the heading or the control already says.

## Where it shows up

Check each of these slots, because they get filled by habit:

- the subtitle under a page or section heading
- helper text under a field or a button
- empty states
- footers and fine print
- badges, pills, and feature chips
- tooltips
- confirmation dialogs
- banners and onboarding cards

## Examples

| The brief said | Reassuring copy | Ship |
| --- | --- | --- |
| "Keep it simple and fast, no signup." | Subtitle: "A simple, fast way to manage your tasks. No signup required." | The heading alone. |
| "Store everything locally." | Footer: "Your data never leaves your device." | No footer. |
| "Make delete undoable." | Under the button: "Don't worry, you can undo this at any time." | An "Undo" action in the toast after delete. |
| "Minimal, no clutter." | Empty state: "Nothing here yet. We keep things minimal so you can focus." | "No tasks" and the "New task" button. |
| "Add a settings page." | "Settings: configure your preferences below." | "Settings". |
| "Lightweight and privacy-first." | Chips: "Lightweight", "Privacy-first", "No clutter". | No chips. |

## The fix

Delete the string and the element that held it. An empty subtitle slot, a footer with nothing in it, or a helper line that only fills space goes too. A reworded version of the same sentence fails the same test.

When the brief promises a behaviour the stranger does need to know about, show it at the moment it matters and as something they can act on: the undo action after the delete, the retention period on the delete dialog.

## Requested copy

When the user asks for specific wording, or for a page whose job is to sell (a landing page, a pricing page, an app store listing), write what they asked for. The stranger test still applies to every string they did not ask for.

## Check

List every user-visible string you added or changed, including strings in the slots above. Put each one through the stranger test. Each string either passes or is deleted with its element.
