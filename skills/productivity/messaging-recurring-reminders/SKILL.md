---
name: messaging-recurring-reminders
description: "Use when scheduling recurring reminders to chat apps."
version: 1.0.0
author: Hadi
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [messaging, whatsapp, telegram, cron, reminders, no_agent]
---

# Messaging Recurring Reminders

Procedures for scheduling recurring or interval-based reminders sent to WhatsApp, Telegram, or other gateway platforms, and stopping them upon user confirmation.

## When to Use
- User asks to be reminded periodically (e.g., every 1 hour, every morning) to pack, buy, or do items.
- Reminders must be delivered to a messaging platform DM or group.
- Reminders should stop when the user reports completion (e.g. "udah beli semua", "done").

## Procedures

### 1. Zero-Token Messaging Reminders (`no_agent=True`)
For simple text or checklist reminders repeating on a fixed interval, prefer `no_agent=True` cron jobs with a script rather than LLM calls on every tick.

1. **State File**: Create a state JSON file under `$HERMES_HOME/<task>_state.json`:
   ```json
   {
     "active": true,
     "items": ["item 1", "item 2"],
     "job_id": null
   }
   ```
2. **Notification Script**: Write a standalone Python script in `$HERMES_HOME/scripts/<name>.py`:
   - Check if the state file exists and `"active"` is true. If false or missing, exit with code 0 without printing (empty stdout suppresses delivery).
   - Add a date/time guard if the job is meant for "tomorrow morning" so it never triggers prematurely on the current day's tail.
   - Print the exact formatted message to stdout. In `no_agent=True` mode, stdout is delivered verbatim.
3. **Register Cron Job**:
   - `cronjob_manage(action='create', schedule='0 7-22 * * *', script='<name>.py', no_agent=True, deliver='whatsapp:<chat_id>', attach_to_session=True, prompt='...')`
   - Store the returned `job_id` into the state file.
4. **Stopping the Reminder**:
   - When the user sends a completion message in chat ("udah beli semua", "done"), update the state file (`active: false`) and remove the cron job via `cronjob_manage(action='remove', job_id=...)`.

## Pitfalls
- **Accidental Same-Day Firing**: When user asks late at night for a reminder "tomorrow morning" every hour (e.g. `0 7-22 * * *`), cron schedules calculate against current wall clock. Always inspect `next_run_at` or guard with a datetime check in the script to ensure it does not fire immediately if the current hour matches the range.
- **Messaging Contacts vs Web Search**: When a user mentions a contact name, handle, or phone number on WhatsApp/Telegram/Slack, do not search the web. Web search leaks private data and yields irrelevant external results. Look up internal channels (`hermes send --list`), search session history (`session_search`), or ask the user directly for context.
