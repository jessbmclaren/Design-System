# Resend control

`DsResendControl` is the "didn't get it? resend" line that follows any "we've sent you something" step. It holds the resend behind a short cooldown so a link is not fired five times in five seconds, then offers it. The caller owns the send and returns a `DsResendOutcome`, so the same control covers a plain resend, a rate-limited one and a failed one without three states wired by hand.

Return `DsResendOutcome.sent` and the cooldown restarts. Return `DsResendOutcome.rateLimited` and the control drops the link for the wait you pass as `rateLimitedLabel`, built from the API's retry-after so it names the wait. Return `DsResendOutcome.failed` and the resend stays offerable, so an offline tap can be retried rather than lost. Set `startRateLimited: true` for a step reached after a send that was already refused, so the control opens on the wait.

The cooldown is an animation, not a timer, so it needs no cancellation and leaves nothing pending in a test. It honours reduced motion: a per-second ticker is the kind of live motion the reduce-motion law silences, so the countdown is skipped and the resend offered straight away rather than animating a clock no one asked to move. A null `onResend` disables the link, and a send in flight blocks a second tap.

![Desktop (1120dp)](img/resend-control_desktop.png)

*Desktop (1120dp)*

## Guidelines

**Do**

- Return the outcome that matches the send; the control renders the state from it.
- Build rateLimitedLabel from the retry-after so it names the wait.
- Use startRateLimited when the step is reached after a refused send.
- Keep the send idempotent enough that a failed-then-retried tap is safe.

**Don't**

- Don't run your own timer alongside it; the control owns the cooldown.
- Don't swallow a failure as sent; return failed so the person can retry.
- Don't phrase the rate-limited label as an error; it is a wait, not a fault.
- Don't fire the send on build; it belongs behind the resend tap.

## Example

```dart
DsResendControl(
  rateLimitedLabel: 'Try again in $minutes minutes',
  onResend: () async {
    final result = await api.resendLink(email);
    return result.rateLimited
        ? DsResendResult.rateLimited('Try again in $minutes minutes')
        : const DsResendResult.sent();
  },
);
```

## See also

- [Verify email](verify-email.md)
- [Sign in](sign-in.md)
